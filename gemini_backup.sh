#!/usr/bin/env bash

set -e

/home/lwh/Desktop/bin/document_backup.sh

echo " "

BACKUP_DIR="/home/lwh/git/init_debian/config"
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

# 7. UFW 방화벽 설정 백업
if [ -d "/etc/ufw" ]; then
    echo "[7/8] UFW 방화벽 규칙 및 설정 백업 중..."
    mkdir -p "$BACKUP_DIR/ufw"
    # 사용자 정의 규칙 파일 및 기본 구성 파일 복사
    sudo cp /etc/ufw/user.rules "$BACKUP_DIR/ufw/" 2>/dev/null || true
    sudo cp /etc/ufw/user6.rules "$BACKUP_DIR/ufw/" 2>/dev/null || true
    sudo cp /etc/ufw/ufw.conf "$BACKUP_DIR/ufw/" 2>/dev/null || true
    
    # Git 관리를 위해 백업된 파일의 소유권을 현재 사용자로 변경
    sudo chown -R $(whoami):$(whoami) "$BACKUP_DIR/ufw"
else
    echo "[7/8] UFW가 설치되어 있지 않아 건너뜁니다."
fi


# 8. SSHD 서버 설정 백업
if [ -f "/etc/ssh/sshd_config" ]; then
    echo "[8/8] SSHD 서버 설정 파일 백업 중..."
    mkdir -p "$BACKUP_DIR/sshd"
    sudo cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd/"
    
    # 소유권 변경
    sudo chown -R $(whoami):$(whoami) "$BACKUP_DIR/sshd"
else
    echo "[8/8] SSHD 설정 파일을 찾을 수 없습니다."
fi

# 9. GRUB 부트 설정 및 스크립트 백업 (추가된 항목)
if [ -d "/etc/grub.d" ]; then
    echo "[9/9] GRUB 부트 설정 디렉토리(/etc/grub.d) 백업 중..."
    mkdir -p "$BACKUP_DIR/grub.d"
    
    # 커스텀 메뉴 및 순서 파일 안전하게 복사 (rsync 활용)
    sudo rsync -av --delete /etc/grub.d/ "$BACKUP_DIR/grub.d/"
    
    # 메인 설정 파일인 /etc/default/grub이 존재하면 함께 백업하여 무결성 확보
    if [ -f "/etc/default/grub" ]; then
        sudo cp /etc/default/grub "$BACKUP_DIR/grub.d/default_grub"
    fi
    
    # Git 관리를 위해 백업된 파일의 소유권을 현재 사용자로 변경
    sudo chown -R $(whoami):$(whoami) "$BACKUP_DIR/grub.d"
else
    echo "[9/9] /etc/grub.d 디렉토리를 찾을 수 없습니다."
fi

echo "=========================================="
echo " 모든 핵심 요소 백업 완료! 'git push'를 통해 저장소에 반영하세요."
echo "=========================================="

cd "$BACKUP_DIR"
cd ..

git add -A
git commit -m "feat: 백업 데이터 업데이트"
git push -v origin main

echo "=========================================="
echo " git 반영 완료 "
echo "=========================================="
