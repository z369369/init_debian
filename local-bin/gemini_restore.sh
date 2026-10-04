#!/usr/bin/env bash
# @DESC: Restore Debian 13 configuration backed up by gemini_backup.sh
# @TAGS: GIT, xfce, etc, config restore
# @USAGE: gemini_restore.sh 
set -u

SYSTEM_PATHS=(
    "/etc/apt"
    "/etc/bluetooth"
    "/etc/conky"
    "/etc/cups"
    "/etc/lightdm"
    "/etc/pam.d"
    "/etc/ssh/sshd_config"
    "/etc/ufw"
    "/etc/hosts"
    "/etc/network"
    "/etc/xdg"
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
        if ! sudo apt install --no-install-recommends -y "${INSTALLABLE[@]}"; then
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
# [8/8] Restore remaining system settings (/etc)
# ------------------------------------------------------------------
echo "[8/8] Restoring system settings (/etc)..."
echo "  (Existing files are saved to $SAFE_DIR before being overwritten)"

for src in "${SYSTEM_PATHS[@]}"; do
    restore_system_path "$src"
done

# ------------------------------------------------------------------
# restore .config
# ------------------------------------------------------------------
rsync -av "$BACKUP_DIR/user-config/" "$HOME/.config" 

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