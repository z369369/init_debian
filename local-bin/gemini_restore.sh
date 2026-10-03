#!/usr/bin/env bash
# @DESC: Restore Debian 13 configuration backed up by gemini_backup.sh
# @TAGS: GIT, xfce, etc, config restore
# @USAGE: gemini_restore.sh 

set -u

SYSTEM_PATHS=(
    "/etc/apt"
    "/etc/lightdm"
    "/etc/pam.d"
    "/etc/ssh"
    "/etc/ufw"
)

# Paths that can make boot/login impossible if restored incorrectly (prompt defaults to N)
RISKY_PATHS=(
    "/etc/pam.d"
)

ASSUME_YES=0
ASSUME_ALL=0
BACKUP_DIR="/home/lwh/git/init_debian"

for arg in "$@"; do
    case "$arg" in
        -y|--yes) ASSUME_YES=1 ;;
        -a|--all) ASSUME_ALL=1 ;;
        -h|--help)
            sed -n '2,16p' "$0"
            exit 0
            ;;
        *) BACKUP_DIR="$arg" ;;
    esac
done

TS="$(date +%Y%m%d-%H%M%S)"
SAFE_DIR="/var/backups/restore-$TS"   # Where existing /etc files are kept before being overwritten
FAILED=()

# ------------------------------------------------------------------
# Utilities
# ------------------------------------------------------------------
is_risky() {
    local p
    for p in "${RISKY_PATHS[@]}"; do
        [ "$p" = "$1" ] && return 0
    done
    return 1
}

# confirm "question" [default y|n]
confirm() {
    local prompt="$1" def="${2:-y}" ans hint
    if [ "$ASSUME_YES" -eq 1 ]; then
        # Risky items are not auto-approved without -a; follow the default instead
        [ "$def" = "n" ] && [ "$ASSUME_ALL" -eq 0 ] && return 1
        return 0
    fi
    [ "$def" = "y" ] && hint="[Y/n]" || hint="[y/N]"
    read -r -p "  $prompt $hint " ans
    ans="${ans:-$def}"
    [[ "$ans" =~ ^[Yy] ]]
}

warn() { echo "  ⚠ $*"; }

# restore_system_path /etc/apt
# Restores $BACKUP_DIR/etc/apt -> /etc/apt (existing files are saved to $SAFE_DIR first)
restore_system_path() {
    local src="$1"                       # e.g. /etc/apt
    local backup_src="$BACKUP_DIR$src"   # e.g. $BACKUP_DIR/etc/apt
    local default="y"

    if [ ! -e "$backup_src" ]; then
        echo "  - $src : not in backup, skipping."
        return 0
    fi

    is_risky "$src" && default="n"

    if ! confirm "Restore $src ?" "$default"; then
        echo "  - $src : skipped."
        return 0
    fi

    # Save the existing files first
    if [ -e "$src" ]; then
        sudo mkdir -p "$SAFE_DIR$(dirname "$src")"
        if ! sudo cp -a "$src" "$SAFE_DIR$(dirname "$src")/"; then
            warn "Failed to back up existing $src - skipping restore for safety."
            FAILED+=("backup:$src")
            return 1
        fi
    fi

    # Directory or single file
    if [ -d "$backup_src" ]; then
        sudo mkdir -p "$src"
        if sudo rsync -a --chown=root:root "$backup_src/" "$src/"; then
            echo "  - $src : restored"
        else
            warn "Failed to restore $src"
            FAILED+=("restore:$src")
            return 1
        fi
    else
        sudo mkdir -p "$(dirname "$src")"
        if sudo rsync -a --chown=root:root "$backup_src" "$src"; then
            echo "  - $src : restored"
        else
            warn "Failed to restore $src"
            FAILED+=("restore:$src")
            return 1
        fi
    fi
}

# ------------------------------------------------------------------
# [2/8] Install APT packages
# ------------------------------------------------------------------
echo "[2/8] Installing APT packages..."
APT_LIST="$BACKUP_DIR/apt-packages.list"
if [ -f "$APT_LIST" ]; then
    sudo apt-get update
    # Pick only the packages that are installable from the current repositories
    mapfile -t ALL_PKGS < <(grep -vE '^\s*(#|$)' "$APT_LIST")
    INSTALLABLE=()
    MISSING=()
    for pkg in "${ALL_PKGS[@]}"; do
        if apt-cache show "$pkg" &>/dev/null; then
            INSTALLABLE+=("$pkg")
        else
            MISSING+=("$pkg")
        fi
    done

    echo "  - To install: ${#INSTALLABLE[@]} / Not in repositories: ${#MISSING[@]}"
    if [ "${#MISSING[@]}" -gt 0 ]; then
        warn "Packages not found in repositories (skipped): ${MISSING[*]}"
    fi

    if [ "${#INSTALLABLE[@]}" -gt 0 ] && confirm "Install packages?" "y"; then
        if ! sudo apt-get install -y "${INSTALLABLE[@]}"; then
            warn "Bulk install failed - installing packages one by one."
            for pkg in "${INSTALLABLE[@]}"; do
                sudo apt-get install -y "$pkg" || FAILED+=("apt:$pkg")
            done
        fi
    fi
else
    echo "  - $APT_LIST not found, skipping."
fi

# ------------------------------------------------------------------
# [3/8] Install Flatpak apps
# ------------------------------------------------------------------
FLATPAK_LIST="$BACKUP_DIR/flatpak-packages.list"
if [ -f "$FLATPAK_LIST" ]; then
    echo "[3/8] Installing Flatpak applications..."
    if ! command -v flatpak &>/dev/null; then
        echo "  - flatpak is not installed, installing it."
        sudo apt-get install -y flatpak
    fi

    sudo flatpak --system remote-delete flathub
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-delete --system flathub

    if command -v flatpak &>/dev/null; then
        # Add the flathub repository if it is missing
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
            || warn "Failed to add flathub repository"
        while IFS= read -r app; do
            [ -z "$app" ] && continue
            echo "  - Installing $app ..."
            flatpak install -y --noninteractive flathub "$app" || FAILED+=("flatpak:$app")
        done < "$FLATPAK_LIST"
    fi
else
    echo "[3/8] No Flatpak list found, skipping."
fi

# ------------------------------------------------------------------
# [4/8] Restore shell environment settings
# ------------------------------------------------------------------
echo "[4/8] Restoring terminal and shell environment settings..."
if [ -d "$BACKUP_DIR/shell-env" ]; then
    rsync -av "$BACKUP_DIR/shell-env/" "$HOME/"
else
    echo "  - No shell-env backup, skipping."
fi

# ------------------------------------------------------------------
# [5/8] Restore user local binaries/scripts
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/local-bin" ]; then
    echo "[5/8] Restoring user local binaries and shell scripts ($HOME/.local/bin)..."
    mkdir -p "$HOME/.local/bin"
    # No --delete: keep files that already exist on the new system
    rsync -av "$BACKUP_DIR/local-bin/" "$HOME/.local/bin/"
    # git only stores the executable bit, so explicitly make scripts executable to be safe
    find "$HOME/.local/bin" -maxdepth 1 -type f \
        \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} +
else
    echo "[5/8] No local-bin backup, skipping."
fi

# ------------------------------------------------------------------
# [6/8] Restore systemd user services and timers
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/systemd-user" ]; then
    echo "[6/8] Restoring systemd user services and timers..."
    mkdir -p "$HOME/.config/systemd/user"
    # rsync -a also restores symlinks (.wants/), so the enabled state is preserved
    rsync -av "$BACKUP_DIR/systemd-user/" "$HOME/.config/systemd/user/"

    if systemctl --user daemon-reload 2>/dev/null; then
        echo "  - daemon-reload done"
        # Try to start timers immediately
        for t in "$HOME/.config/systemd/user/"*.timer; do
            [ -e "$t" ] || continue
            name="$(basename "$t")"
            systemctl --user enable --now "$name" 2>/dev/null \
                && echo "  - $name enabled" \
                || warn "Failed to enable $name (you may need to run it manually from a login session)"
        done
    else
        warn "Cannot connect to the systemd user session. After logging in to the desktop, run 'systemctl --user daemon-reload'."
    fi
else
    echo "[6/8] No systemd-user backup, skipping."
fi

# ------------------------------------------------------------------
# [7/8] Restore XFCE4 desktop settings
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/xfce4" ]; then
    echo "[7/8] Restoring XFCE4 desktop theme and panel settings..."
    warn "If an XFCE session is running, the settings may be overwritten at logout."
    warn "Safest approach: run this from a TTY (Ctrl+Alt+F3), then log in again."
    if confirm "Restore XFCE4 settings?" "y"; then
        if [ -d "$HOME/.config/xfce4" ]; then
            cp -a "$HOME/.config/xfce4" "$HOME/.config/xfce4.bak-$TS"
            echo "  - Saved existing settings as ~/.config/xfce4.bak-$TS"
        fi
        mkdir -p "$HOME/.config/xfce4"
        rsync -av "$BACKUP_DIR/xfce4/" "$HOME/.config/xfce4/"
        echo "  - Done (takes effect after re-login)"
    fi
else
    echo "[7/8] No xfce4 backup, skipping."
fi

# ------------------------------------------------------------------
# [8/8] Restore remaining system settings (/etc)
# ------------------------------------------------------------------
echo "[8/8] Restoring system settings (/etc)..."
echo "  (Existing files are saved to $SAFE_DIR before being overwritten)"

for src in "${SYSTEM_PATHS[@]}"; do
    restore_system_path "$src"
done

# ---- Post-restore processing ----------------------------------------

# SSH: fix private key permissions (git does not preserve file permissions) + syntax check
if [ -d /etc/ssh ] && [ -d "$BACKUP_DIR/etc/ssh" ]; then
    sudo find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key' -exec chmod 600 {} +
    sudo find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} +
    if command -v sshd &>/dev/null || [ -x /usr/sbin/sshd ]; then
        if sudo /usr/sbin/sshd -t 2>/dev/null; then
            echo "  - sshd config check passed"
            if confirm "Restart the ssh service?" "n"; then
                sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
            fi
        else
            warn "sshd config check failed! Do not restart. (Previous config: $SAFE_DIR/etc/ssh)"
        fi
    fi
fi

# fstab: syntax verification (a different UUID on another system risks boot failure)
if [ -f /etc/fstab ] && [ -f "$BACKUP_DIR/etc/fstab" ]; then
    if command -v findmnt &>/dev/null; then
        echo "  - fstab verification:"
        sudo findmnt --verify 2>&1 | sed 's/^/      /'
    fi
    warn "Be sure to check with 'lsblk -f' that the UUIDs in fstab match the current disks."
fi

# GRUB: apply settings
if [ -f "$BACKUP_DIR/etc/default/grub" ] || [ -d "$BACKUP_DIR/etc/grub.d" ]; then
    if command -v update-grub &>/dev/null && confirm "Run update-grub?" "y"; then
        sudo update-grub || FAILED+=("update-grub")
    fi
fi

# UFW: reapply rules
if [ -d /etc/ufw ] && [ -d "$BACKUP_DIR/etc/ufw" ] && command -v ufw &>/dev/null; then
    if confirm "Reload ufw rules?" "y"; then
        sudo ufw reload 2>/dev/null || warn "ufw reload failed (it may be inactive: 'sudo ufw enable')"
    fi
fi

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
echo ""
echo "=========================================="
if [ "${#FAILED[@]}" -eq 0 ]; then
    echo " Restore complete (no errors)"
else
    echo " Restore complete (some failures)"
    echo " Failed items:"
    printf '   - %s\n' "${FAILED[@]}"
fi
echo " Previous /etc files saved at: $SAFE_DIR"
echo " Some settings (XFCE, shell, services) take effect after re-login or reboot."
echo "=========================================="

getent group autologin >/dev/null || sudo groupadd -r autologin
sudo usermod -aG autologin lwh