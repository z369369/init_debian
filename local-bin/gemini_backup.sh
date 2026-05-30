#!/usr/bin/env bash

set -e

BACKUP_DIR="/home/lwh/git/init_debian"
echo "=========================================="
echo " 고도화된 시스템 구성 백업을 시작합니다."
echo "=========================================="

# 기본 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 1. APT 패키지 리스트 및 저장소 백업
echo "[1/6] APT 패키지 및 저장소(Sources/Keyrings) 백업 중..."
apt-mark showmanual > "$BACKUP_DIR/apt-packages.list"

# 써드파티 PPA 및 저장소 리스트 백업
if [ -d "/etc/apt/sources.list.d" ]; then
    mkdir -p "$BACKUP_DIR/sources.list.d"
    rsync -av --delete /etc/apt/sources.list.d/ "$BACKUP_DIR/sources.list.d/"
fi

# 저장소 GPG 키링 백업 (데비안 13 표준 보안 방식 권장 위치)
if [ -d "/etc/apt/keyrings" ]; then
    mkdir -p "$BACKUP_DIR/keyrings"
    rsync -av --delete /etc/apt/keyrings/ "$BACKUP_DIR/keyrings/"
fi


# 2. Flatpak 애플리케이션 리스트 백업
if command -v flatpak &> /dev/null; then
    echo "[2/6] Flatpak 애플리케이션 리스트 백업 중..."
    flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-packages.list"
fi


# 3. 쉘 환경 설정 파일 백업 (.bashrc, .bash_aliases 등)
echo "[3/6] 터미널 및 쉘 환경 설정 백업 중..."
mkdir -p "$BACKUP_DIR/shell-env"
for file in ".bashrc" ".bash_aliases" ".profile" ".bash_logout"; do
    if [ -f "$HOME/$file" ]; then
        cp "$HOME/$file" "$BACKUP_DIR/shell-env/$file"
    fi
done


# 4. 사용자 커스텀 스크립트 및 바이너리 백업 ($HOME/.local/bin)
if [ -d "$HOME/.local/bin" ]; then
    echo "[4/6] 사용자 로컬 바이너리 및 쉘 스크립트($HOME/.local/bin) 백업 중..."
    mkdir -p "$BACKUP_DIR/local-bin"
    rsync -av --delete "$HOME/.local/bin/" "$BACKUP_DIR/local-bin/"
else
    echo "[4/6] $HOME/.local/bin 디렉토리가 없어 건너뜁니다."
fi


# 5. Systemd User 서비스 및 타이머 백업
if [ -d "$HOME/.config/systemd/user" ]; then
    echo "[5/6] Systemd 사용자 서비스 및 타이머 설정 백업 중..."
    mkdir -p "$BACKUP_DIR/systemd-user"
    rsync -av --delete "$HOME/.config/systemd/user/" "$BACKUP_DIR/systemd-user/"
fi


# 6. XFCE4 데스크톱 환경 설정 백업
if [ -d "$HOME/.config/xfce4" ]; then
    echo "[6/6] XFCE4 데스크톱 테마 및 패널 설정 백업 중..."
    rsync -av --delete "$HOME/.config/xfce4/" "$BACKUP_DIR/xfce4/"
fi

echo "=========================================="
echo " 모든 핵심 요소 백업 완료! 'git push'를 통해 저장소에 반영하세요."
echo "=========================================="