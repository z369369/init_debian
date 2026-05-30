#!/usr/bin/env bash

set -e

BACKUP_DIR="/home/lwh/git/init_debian"
echo "=========================================="
echo " 시스템 구성 전체 복원을 시작합니다. (sudo 권한 필요)"
echo "=========================================="

# 1. APT 저장소 및 키링 복원 (패키지 설치 전 선행 필수)
echo "[1/7] APT 외부 저장소 및 GPG 키링 복원 중..."
if [ -d "$BACKUP_DIR/keyrings" ]; then
    sudo mkdir -p /etc/apt/keyrings
    sudo rsync -av "$BACKUP_DIR/keyrings/" /etc/apt/keyrings/
fi

if [ -d "$BACKUP_DIR/sources.list.d" ]; then
    sudo mkdir -p /etc/apt/sources.list.d
    sudo rsync -av "$BACKUP_DIR/sources.list.d/" /etc/apt/sources.list.d/
fi

# 저장소 반영을 위한 패키지 인덱스 갱신
sudo apt update


# 2. APT 패키지 일괄 재설치
if [ -f "$BACKUP_DIR/apt-packages.list" ]; then
    echo "[2/7] 백업 리스트 기반 APT 패키지 설치 중..."
    sudo apt install -y $(cat "$BACKUP_DIR/apt-packages.list")
fi


# 3. Flatpak 패키지 복원
if [ -f "$BACKUP_DIR/flatpak-packages.list" ]; then
    echo "[3/7] Flatpak 및 애플리케이션 복원 중..."
    if ! command -v flatpak &> /dev/null; then
        sudo apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    while read -r app; do
        if [ -n "$app" ]; then
            flatpak install -y flathub "$app" || echo "$app 설치 실패 (건너뜀)"
        fi
    done < "$BACKUP_DIR/flatpak-packages.list"
fi


# 4. 쉘 환경 설정 파일 복원
echo "[4/7] 터미널 환경 파일(.bashrc 등) 복원 중..."
if [ -d "$BACKUP_DIR/shell-env" ]; then
    for file in ".bashrc" ".bash_aliases" ".profile" ".bash_logout"; do
        if [ -f "$BACKUP_DIR/shell-env/$file" ]; then
            # 기존 파일은 백업 처리 후 복사
            if [ -f "$HOME/$file" ]; then
                mv "$HOME/$file" "$HOME/${file}_backup_$(date +%Y%m%d)"
            fi
            cp "$BACKUP_DIR/shell-env/$file" "$HOME/$file"
        fi
    done
fi


# 5. 사용자 스크립트 및 바이너리($HOME/.local/bin) 복원
if [ -d "$BACKUP_DIR/local-bin" ]; then
    echo "[5/7] 사용자 로컬 바이너리 및 커스텀 스크립트 복원 중..."
    mkdir -p "$HOME/.local/bin"
    rsync -av "$BACKUP_DIR/local-bin/" "$HOME/.local/bin/"
    chmod +x $HOME/.local/bin/* 2>/dev/null || true
fi


# 6. Systemd User 서비스 복원 및 데몬 재로드
if [ -d "$BACKUP_DIR/systemd-user" ]; then
    echo "[6/7] Systemd 사용자 서비스 파일 복원 중..."
    mkdir -p "$HOME/.config/systemd/user"
    rsync -av "$BACKUP_DIR/systemd-user/" "$HOME/.config/systemd/user/"
    # 서비스 데몬 재로드 (새 서비스 인식)
    systemctl --user daemon-reload
fi


# 7. XFCE4 데스크톱 환경 설정 복원
if [ -d "$BACKUP_DIR/xfce4" ]; then
    echo "[7/7] XFCE4 테마 및 패널 구성 복원 중..."
    if [ -d "$HOME/.config/xfce4" ]; then
        mv "$HOME/.config/xfce4" "$HOME/.config/xfce4_backup_$(date +%Y%m%d)"
    fi
    mkdir -p "$HOME/.config"
    cp -r "$BACKUP_DIR/xfce4" "$HOME/.config/xfce4"
    
    # 패널 실시간 반영 시도
    xfce4-panel --restart || true
fi

echo "=========================================="
echo " 모든 시스템 복원이 완료되었습니다."
echo " 변경된 쉘과 데스크톱 환경 적용을 위해 [로그아웃 후 재로그인] 혹은 [재부팅]을 해주세요."
echo "=========================================="