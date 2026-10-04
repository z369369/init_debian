#!/usr/bin/env bash
# @DESC: GIT repo에 백업
# @TAGS: GIT, xfce, etc, config backup
# @USAGE: gemini_backup.sh
set -e

SYSTEM_PATHS=(
    "/etc/apt"
    "/etc/bluetooth"
    "/etc/conky"
    "/etc/cups"
    "/etc/default/grub"
    "/etc/fstab"
    "/etc/grub.d"
    "/etc/lightdm"
    "/etc/pam.d"
    "/etc/ssh/sshd_config"
    "/etc/ufw"
    "/etc/hosts"
    "/etc/network"
    "/etc/xdg"
)

CONFIG_PATHS=(
    ".config/systemd"
    ".config/xfce4"
    ".bash_logout"
    ".bashrc"
    ".conkyrc"
    ".fdignore"
    ".gitconfig"
    ".profile"
    ".rgignore"
    ".xprofile"
)


BACKUP_DIR="/home/lwh/git/init_debian"
echo "=========================================="
echo " 고도화된 시스템 구성 백업을 시작합니다."
echo "=========================================="

# 기본 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 1. APT 패키지 리스트 및 저장소 백업
echo "[1/7] APT 패키지 및 저장소(Sources/Keyrings) 백업 중..."
apt-mark showmanual > "$BACKUP_DIR/apt-packages.list"

# 2. Flatpak 애플리케이션 리스트 백업
if command -v flatpak &> /dev/null; then
    echo "[2/7] Flatpak 애플리케이션 리스트 백업 중..."
    flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-packages.list"
fi

# 4. 사용자 커스텀 스크립트 및 바이너리 백업 ($HOME/.local/bin)
if [ -d "$HOME/.local/bin" ]; then
    echo "[4/7] 사용자 로컬 바이너리 및 쉘 스크립트($HOME/.local/bin) 백업 중..."
    mkdir -p "$BACKUP_DIR/local-bin"
    rsync -av --delete "$HOME/.local/bin/" "$BACKUP_DIR/local-bin/"
else
    echo "[4/7] $HOME/.local/bin 디렉토리가 없어 건너뜁니다."
fi


for src in "${CONFIG_PATHS[@]}"; do
    if [ ! -e "/home/lwh/$src" ]; then
        echo "  - /home/lwh/$src 없음, 건너뜁니다."
        continue
    fi

    dest="$BACKUP_DIR/user_root/$src"

    echo "  - /home/lwh/$src 백업 중..."

    if [ -d "$src" ]; then
        sudo mkdir -p "$dest"
        sudo rsync -a --delete "/home/lwh/$src/" "$dest/"
    else
        sudo mkdir -p "$(dirname "$dest")"
        sudo cp -a "$src" "$dest"
    fi
done



echo "[7/7] 시스템 설정(/etc) 백업 중..."
for src in "${SYSTEM_PATHS[@]}"; do
    if [ ! -e "$src" ]; then
        echo "  - $src 없음, 건너뜁니다."
        continue
    fi

    dest="$BACKUP_DIR$src"

    echo "  - $src 백업 중..."
    if [ -d "$src" ]; then
        sudo mkdir -p "$dest"
        sudo rsync -a --delete "$src/" "$dest/"
    else
        sudo mkdir -p "$(dirname "$dest")"
        sudo cp -a "$src" "$dest"
    fi
done

# Git 관리를 위해 백업된 파일의 소유권을 현재 사용자로 변경
sudo chown -R "$(whoami):$(whoami)" "$BACKUP_DIR/etc"

echo ""

#dont delete under command 
cd ~/git/init_debian
git add .
git commit -m "backup"
git push

echo "=========================================="
echo " 백업 Complete "
echo "=========================================="