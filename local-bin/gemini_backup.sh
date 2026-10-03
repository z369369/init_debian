#!/usr/bin/env bash
# @DESC: GIT repo에 백업
# @TAGS: GIT, xfce, etc, config backup
# @USAGE: gemini_backup.sh
set -e

SYSTEM_PATHS=(
    "/etc/apt"
    "/etc/default/grub"
    "/etc/fstab"
    "/etc/grub.d"
    "/etc/lightdm"
    "/etc/pam.d"
    "/etc/ssh"
    "/etc/ufw"
)

SHELL_PATHS=(
    ".bashrc"
    ".bash_logout"
    ".bash_aliases"
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


# 3. 쉘 환경 설정 파일 백업 (.bashrc, .bash_aliases 등)
echo "[3/7] 터미널 및 쉘 환경 설정 백업 중..."
mkdir -p "$BACKUP_DIR/shell-env"
for file in "${SHELL_PATHS[@]}"; do
    if [ -f "$HOME/$file" ]; then
        cp "$HOME/$file" "$BACKUP_DIR/shell-env/$file"
    fi
done


# 4. 사용자 커스텀 스크립트 및 바이너리 백업 ($HOME/.local/bin)
if [ -d "$HOME/.local/bin" ]; then
    echo "[4/7] 사용자 로컬 바이너리 및 쉘 스크립트($HOME/.local/bin) 백업 중..."
    mkdir -p "$BACKUP_DIR/local-bin"
    rsync -av --delete "$HOME/.local/bin/" "$BACKUP_DIR/local-bin/"
else
    echo "[4/7] $HOME/.local/bin 디렉토리가 없어 건너뜁니다."
fi


# 5. Systemd User 서비스 및 타이머 백업
if [ -d "$HOME/.config/systemd/user" ]; then
    echo "[5/7] Systemd 사용자 서비스 및 타이머 설정 백업 중..."
    mkdir -p "$BACKUP_DIR/systemd-user"
    rsync -av --delete "$HOME/.config/systemd/user/" "$BACKUP_DIR/systemd-user/"
fi


# 6. XFCE4 데스크톱 환경 설정 백업
if [ -d "$HOME/.config/xfce4" ]; then
    echo "[6/7] XFCE4 데스크톱 테마 및 패널 설정 백업 중..."
    rsync -av --delete "$HOME/.config/xfce4/" "$BACKUP_DIR/xfce4/"
fi


# 7. 시스템 설정(/etc) 백업 - 배열 기반
# 백업할 경로를 아래 배열에 추가하면 됩니다.
# 디렉토리는 끝에 /를 붙이지 않아도 됩니다.


echo "[7/7] 시스템 설정(/etc) 백업 중..."
for src in "${SYSTEM_PATHS[@]}"; do
    if [ ! -e "$src" ]; then
        echo "  - $src 없음, 건너뜁니다."
        continue
    fi

    # /etc/ssh -> $BACKUP_DIR/etc/ssh 처럼 원본 경로 구조를 유지
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