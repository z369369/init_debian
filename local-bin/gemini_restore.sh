#!/usr/bin/env bash
# @DESC: Restore Debian 13 configuration backed up by gemini_backup.sh
# @TAGS: GIT, xfce, etc, config restore
# @USAGE: restore_debian.sh [-u user] [-y] [-d backup_dir] [--with-fstab] [step...]
#
# Steps:
#   1 APT repos/keyrings + manually installed packages   6 XFCE4 settings
#   2 Flatpak apps                                       7 UFW firewall
#   3 Shell environment files                            8 SSHD settings
#   4 ~/.local/bin                                       9 GRUB settings
#   5 systemd user units                                10 /etc/fstab (only with --with-fstab, risky)
#
# Examples:
#   ./restore_debian.sh                 # prompts for the user name, runs steps 1-9
#   ./restore_debian.sh -u lwh 3 4 5    # user "lwh", shell/local-bin/systemd only
#   ./restore_debian.sh -y -u lwh 1 2   # no confirmation prompts

set -uo pipefail

BACKUP_DIR=""
TARGET_USER=""
ASSUME_YES=0
WITH_FSTAB=0
STEPS=()
TS="$(date +%Y%m%d-%H%M%S)"
CURRENT_USER="$(id -un)"

# ---------- Argument parsing ----------
while [ $# -gt 0 ]; do
    case "$1" in
        -u|--user)     shift; TARGET_USER="${1:?user name required}" ;;
        -y|--yes)      ASSUME_YES=1 ;;
        -d|--dir)      shift; BACKUP_DIR="${1:?backup path required}" ;;
        --with-fstab)  WITH_FSTAB=1 ;;
        -h|--help)     sed -n '2,19p' "$0"; exit 0 ;;
        [0-9]*)        STEPS+=("$1") ;;
        *)             echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

if [ ${#STEPS[@]} -eq 0 ]; then
    STEPS=(1 2 3 4 5 6 7 8 9)
    [ "$WITH_FSTAB" -eq 1 ] && STEPS+=(10)
fi

# ---------- Common helpers ----------
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }

confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    local ans
    read -r -p "$1 [y/N] " ans < /dev/tty
    [[ "$ans" =~ ^[Yy]$ ]]
}

# Run a command as the target user (no sudo needed if it is the current user)
as_user() {
    if [ "$CURRENT_USER" = "$TARGET_USER" ]; then
        "$@"
    else
        sudo -u "$TARGET_USER" "$@"
    fi
}

# Backup dir may not be readable by the current user, so test existence via sudo
is_dir()  { sudo test -d "$1"; }
is_file() { sudo test -f "$1"; }

# Keep the existing file/dir as <path>.bak.<timestamp> before overwriting
backup_existing() {
    local target="$1"
    if sudo test -e "$target"; then
        sudo cp -a "$target" "${target}.bak.${TS}"
        # Give the backup copy back to the user if it lives in their home
        case "$target" in
            "$TARGET_HOME"/*) sudo chown -R "$TARGET_USER:" "${target}.bak.${TS}" ;;
        esac
    fi
}

# ---------- Determine target user ----------
sudo -v || exit 1

if [ -z "$TARGET_USER" ]; then
    read -r -p "Enter the user name to restore for [$CURRENT_USER]: " TARGET_USER < /dev/tty
    TARGET_USER="${TARGET_USER:-$CURRENT_USER}"
fi

if ! getent passwd "$TARGET_USER" >/dev/null; then
    echo "User does not exist: $TARGET_USER"
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_UID="$(id -u "$TARGET_USER")"

# Default backup location is derived from the chosen user's home
[ -z "$BACKUP_DIR" ] && BACKUP_DIR="$TARGET_HOME/git/init_debian/config"

# ---------- Pre-flight checks ----------
if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root. Run as a normal sudo-capable user; sudo is used only where needed."
    exit 1
fi

if ! is_dir "$BACKUP_DIR"; then
    echo "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

if ! command -v rsync &>/dev/null; then
    info "rsync is missing, installing it."
    sudo apt-get update && sudo apt-get install -y rsync || exit 1
fi

echo "=========================================="
echo " Starting system configuration restore."
echo " Target user : $TARGET_USER ($TARGET_HOME)"
echo " Backup source: $BACKUP_DIR"
echo " Steps       : ${STEPS[*]}"
echo "=========================================="

# ---------- 1. APT ----------
step_1() {
    echo "[1] Restoring APT repositories/keyrings/packages"

    # Restore keyrings first so that signed-by references in sources resolve
    if is_dir "$BACKUP_DIR/keyrings"; then
        sudo mkdir -p /etc/apt/keyrings
        sudo rsync -av --chown=root:root "$BACKUP_DIR/keyrings/" /etc/apt/keyrings/
        sudo chmod 755 /etc/apt/keyrings
        sudo find /etc/apt/keyrings -type f -exec chmod 644 {} +
    fi

    if is_dir "$BACKUP_DIR/sources.list.d"; then
        # No --delete here: do not remove repositories that exist on the current system
        sudo rsync -av --chown=root:root "$BACKUP_DIR/sources.list.d/" /etc/apt/sources.list.d/
        sudo find /etc/apt/sources.list.d -type f -exec chmod 644 {} +
    fi

    sudo apt-get update || warn "apt update reported errors (check repository settings)"

    local list="$BACKUP_DIR/apt-packages.list"
    if ! is_file "$list"; then
        warn "apt-packages.list not found - skipping package installation"
        return
    fi

    # Split the list into packages that exist in the current repos and those that do not
    local avail=() missing=() pkg
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
        if apt-cache show "$pkg" &>/dev/null; then
            avail+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done < <(sudo cat "$list")

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Skipping ${#missing[@]} packages not found in repositories: ${missing[*]}"
        printf '%s\n' "${missing[@]}" | as_user tee "$TARGET_HOME/apt-restore-missing.$TS.txt" >/dev/null
        info "Missing package list saved: $TARGET_HOME/apt-restore-missing.$TS.txt"
    fi

    if [ ${#avail[@]} -gt 0 ]; then
        info "Installing ${#avail[@]} packages."
        if ! sudo apt-get install -y "${avail[@]}"; then
            warn "Bulk install failed - retrying one by one."
            for pkg in "${avail[@]}"; do
                sudo apt-get install -y "$pkg" || warn "Install failed: $pkg"
            done
        fi
        # Re-mark as manually installed so autoremove does not drop them
        sudo apt-mark manual "${avail[@]}" >/dev/null 2>&1 || true
    fi
}

# ---------- 2. Flatpak ----------
step_2() {
    echo "[2] Restoring Flatpak applications"



    local list="$BACKUP_DIR/flatpak-packages.list"
    if ! is_file "$list"; then
        warn "flatpak-packages.list not found - skipping"
        return
    fi

    if ! command -v flatpak &>/dev/null; then
        sudo apt-get install -y flatpak || { warn "Failed to install flatpak"; return; }
    fi

    sudo flatpak --system remote-delete flathub
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-delete --system flathub


    local app
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        # System-wide install via sudo, so it does not depend on the user's session
        flatpak install -y --noninteractive flathub "$app" || warn "Flatpak install failed: $app"
    done < <(sudo cat "$list")
}

# ---------- 3. Shell environment ----------
step_3() {
    echo "[3] Restoring shell environment files"
    local src="$BACKUP_DIR/shell-env" file
    if ! is_dir "$src"; then warn "shell-env not found - skipping"; return; fi

    for file in .bashrc .bash_aliases .profile .bash_logout; do
        if is_file "$src/$file"; then
            backup_existing "$TARGET_HOME/$file"
            sudo install -o "$TARGET_USER" -g "$(id -gn "$TARGET_USER")" -m 644 "$src/$file" "$TARGET_HOME/$file"
            info "Restored: $TARGET_HOME/$file"
        fi
    done
}

# ---------- 4. ~/.local/bin ----------
step_4() {
    echo "[4] Restoring ~/.local/bin"
    if ! is_dir "$BACKUP_DIR/local-bin"; then warn "local-bin not found - skipping"; return; fi
    as_user mkdir -p "$TARGET_HOME/.local/bin"
    # rsync -a preserves permission bits (executables stay executable)
    sudo rsync -av --chown="$TARGET_USER:$(id -gn "$TARGET_USER")" \
        "$BACKUP_DIR/local-bin/" "$TARGET_HOME/.local/bin/"
}

# ---------- 5. systemd user ----------
step_5() {
    echo "[5] Restoring systemd user services/timers"
    if ! is_dir "$BACKUP_DIR/systemd-user"; then warn "systemd-user not found - skipping"; return; fi
    as_user mkdir -p "$TARGET_HOME/.config/systemd/user"
    # -a also restores symlinks (the *.wants/ enable state)
    sudo rsync -av --chown="$TARGET_USER:$(id -gn "$TARGET_USER")" \
        "$BACKUP_DIR/systemd-user/" "$TARGET_HOME/.config/systemd/user/"

    # The user manager needs XDG_RUNTIME_DIR when invoked on behalf of another user
    if [ "$CURRENT_USER" = "$TARGET_USER" ]; then
        systemctl --user daemon-reload || warn "daemon-reload failed (check user session)"
    else
        sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$TARGET_UID" \
            systemctl --user daemon-reload || warn "daemon-reload failed (user must be logged in)"
    fi
    info "Check enable state with 'systemctl --user list-unit-files'."
}

# ---------- 6. XFCE4 ----------
step_6() {
    echo "[6] Restoring XFCE4 settings"
    if ! is_dir "$BACKUP_DIR/xfce4"; then warn "xfce4 not found - skipping"; return; fi

    # A running xfconfd/panel may overwrite restored settings on exit
    if pgrep -u "$TARGET_UID" -x xfconfd >/dev/null 2>&1 || pgrep -u "$TARGET_UID" -x xfce4-panel >/dev/null 2>&1; then
        warn "An XFCE session is running for $TARGET_USER. Restoring now may be overwritten on logout."
        warn "Safest: log out, switch to a TTY (Ctrl+Alt+F3) and run './restore_debian.sh -u $TARGET_USER 6'"
        confirm "Restore anyway?" || { info "Skipping XFCE restore"; return; }
    fi

    backup_existing "$TARGET_HOME/.config/xfce4"
    as_user mkdir -p "$TARGET_HOME/.config/xfce4"
    sudo rsync -av --chown="$TARGET_USER:$(id -gn "$TARGET_USER")" \
        "$BACKUP_DIR/xfce4/" "$TARGET_HOME/.config/xfce4/"
    info "Restore complete. Log in again to apply."
}

# ---------- 7. UFW ----------
step_7() {
    echo "[7] Restoring UFW firewall"
    local src="$BACKUP_DIR/ufw" f
    if ! is_dir "$src"; then warn "ufw backup not found - skipping"; return; fi

    if ! command -v ufw &>/dev/null; then
        sudo apt-get install -y ufw || { warn "Failed to install ufw"; return; }
    fi

    confirm "This overwrites UFW rules and reloads. Did you verify the SSH rule is included?" \
        || { info "Skipping UFW restore"; return; }

    for f in user.rules user6.rules ufw.conf; do
        if is_file "$src/$f"; then
            backup_existing "/etc/ufw/$f"
            sudo install -o root -g root -m 640 "$src/$f" "/etc/ufw/$f"
            info "Restored: /etc/ufw/$f"
        fi
    done
    sudo ufw reload || warn "ufw reload failed (it may be inactive)"
    sudo ufw status verbose || true
}

# ---------- 8. SSHD ----------
step_8() {
    echo "[8] Restoring SSHD configuration"
    local src="$BACKUP_DIR/sshd/sshd_config"
    if ! is_file "$src"; then warn "sshd_config backup not found - skipping"; return; fi

    if [ ! -x /usr/sbin/sshd ]; then
        confirm "openssh-server is not installed. Install it?" \
            && sudo apt-get install -y openssh-server || return
    fi

    confirm "Restore sshd_config (syntax is validated before applying)?" \
        || { info "Skipping SSHD restore"; return; }

    backup_existing "/etc/ssh/sshd_config"
    sudo install -o root -g root -m 644 "$src" /etc/ssh/sshd_config

    if sudo sshd -t; then
        sudo systemctl restart ssh || sudo systemctl restart sshd || warn "Failed to restart sshd"
        info "sshd configuration applied (keep your current SSH session open and test a new login)."
    else
        warn "sshd syntax check failed - reverting to the previous configuration."
        sudo cp -a "/etc/ssh/sshd_config.bak.${TS}" /etc/ssh/sshd_config
    fi
}

# ---------- Run ----------
for s in "${STEPS[@]}"; do
    if declare -F "step_$s" >/dev/null; then
        "step_$s" || warn "An error occurred in step $s."
        echo
    else
        warn "Unknown step: $s"
    fi
done

echo "=========================================="
echo " Restore Complete"
echo " - Overwritten files were preserved as *.bak.$TS"
echo " - Shell/XFCE/systemd changes fully apply after re-login or reboot."
echo "=========================================="
