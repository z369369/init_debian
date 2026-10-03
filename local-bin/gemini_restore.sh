#!/usr/bin/env bash
# @DESC: Restore Debian 13 configuration backed up by gemini_backup.sh
# @TAGS: GIT, xfce, etc, config restore
# @USAGE: gemini_debian.sh [-u user] [-y] [-d backup_dir] [--with-fstab] [step...]

#!/usr/bin/env bash
#
# 복원 스크립트 - backup.sh(init_debian 백업)의 역방향
#
# 사용법:
#   ./gemini_restore.sh              # 항목마다 확인하며 복원
#   ./gemini_restore.sh -y           # 위험 항목(fstab/pam/grub)을 제외하고 모두 자동 승인
#   ./gemini_restore.sh -y -a        # 위험 항목까지 전부 자동 승인 (비추천)
#   ./gemini_restore.sh /path/to/init_debian   # 백업 디렉토리 직접 지정
#

set -u

SYSTEM_PATHS=(
    "/etc/apt"
    "/etc/lightdm"
    "/etc/pam.d"
    "/etc/ssh"
    "/etc/ufw"
)

# 잘못 복원하면 부팅/로그인이 불가능해질 수 있는 경로 (기본 N 으로 질문)
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
SAFE_DIR="/var/backups/restore-$TS"   # 덮어쓰기 전 기존 /etc 파일 보관 위치
FAILED=()

# ------------------------------------------------------------------
# 유틸리티
# ------------------------------------------------------------------
is_risky() {
    local p
    for p in "${RISKY_PATHS[@]}"; do
        [ "$p" = "$1" ] && return 0
    done
    return 1
}

# confirm "질문" [기본값 y|n]
confirm() {
    local prompt="$1" def="${2:-y}" ans hint
    if [ "$ASSUME_YES" -eq 1 ]; then
        # 위험 항목은 -a 가 없으면 자동 승인하지 않고 기본값을 따름
        [ "$def" = "n" ] && [ "$ASSUME_ALL" -eq 0 ] && return 1
        return 0
    fi
    [ "$def" = "y" ] && hint="[Y/n]" || hint="[y/N]"
    read -r -p "  $prompt $hint " ans
    ans="${ans:-$def}"
    [[ "$ans" =~ ^[Yy] ]]
}

warn() { echo "  ⚠ $*"; }

# ------------------------------------------------------------------
# 사전 점검
# ------------------------------------------------------------------
echo "=========================================="
echo " 시스템 구성 복원을 시작합니다."
echo "=========================================="

if [ "$EUID" -eq 0 ]; then
    echo "root 로 실행하지 마세요. 복원 대상 사용자 계정으로 실행하세요." >&2
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    if [ -n "${REPO_URL:-}" ]; then
        echo "백업 디렉토리가 없어 저장소를 clone 합니다: $REPO_URL"
        mkdir -p "$(dirname "$BACKUP_DIR")"
        git clone "$REPO_URL" "$BACKUP_DIR" || { echo "clone 실패" >&2; exit 1; }
    else
        echo "백업 디렉토리($BACKUP_DIR)가 없습니다." >&2
        echo "REPO_URL 환경변수로 저장소를 지정하거나, 경로를 인자로 넘겨주세요." >&2
        exit 1
    fi
fi

if [ -d "$BACKUP_DIR/.git" ]; then
    echo "최신 백업을 가져옵니다 (git pull)..."
    git -C "$BACKUP_DIR" pull --ff-only || warn "git pull 실패 - 현재 로컬 내용으로 진행합니다."
fi

echo "백업 소스: $BACKUP_DIR"
echo "sudo 권한을 미리 확인합니다..."
sudo -v || { echo "sudo 권한이 필요합니다." >&2; exit 1; }
echo ""

# ------------------------------------------------------------------
# [2/8] APT 패키지 설치
# ------------------------------------------------------------------
echo "[2/8] APT 패키지 설치 중..."
APT_LIST="$BACKUP_DIR/apt-packages.list"
if [ -f "$APT_LIST" ]; then
    sudo apt-get update
    # 현재 저장소에서 설치 가능한 패키지만 추려서 설치
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

    echo "  - 설치 대상 ${#INSTALLABLE[@]}개 / 저장소에 없음 ${#MISSING[@]}개"
    if [ "${#MISSING[@]}" -gt 0 ]; then
        warn "저장소에서 찾을 수 없는 패키지 (설치 제외): ${MISSING[*]}"
    fi

    if [ "${#INSTALLABLE[@]}" -gt 0 ] && confirm "패키지를 설치할까요?" "y"; then
        if ! sudo apt-get install -y "${INSTALLABLE[@]}"; then
            warn "일괄 설치 실패 - 패키지를 하나씩 설치합니다."
            for pkg in "${INSTALLABLE[@]}"; do
                sudo apt-get install -y "$pkg" || FAILED+=("apt:$pkg")
            done
        fi
    fi
else
    echo "  - $APT_LIST 없음, 건너뜁니다."
fi

# ------------------------------------------------------------------
# [3/8] Flatpak 앱 설치
# ------------------------------------------------------------------
FLATPAK_LIST="$BACKUP_DIR/flatpak-packages.list"
if [ -f "$FLATPAK_LIST" ]; then
    echo "[3/8] Flatpak 애플리케이션 설치 중..."
    if ! command -v flatpak &>/dev/null; then
        echo "  - flatpak 이 설치되어 있지 않아 설치합니다."
        sudo apt-get install -y flatpak
    fi

    sudo flatpak --system remote-delete flathub
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-delete --system flathub

    if command -v flatpak &>/dev/null; then
        # flathub 저장소가 없으면 추가
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
            || warn "flathub 저장소 추가 실패"
        while IFS= read -r app; do
            [ -z "$app" ] && continue
            echo "  - $app 설치 중..."
            flatpak install -y --noninteractive flathub "$app" || FAILED+=("flatpak:$app")
        done < "$FLATPAK_LIST"
    fi
else
    echo "[3/8] Flatpak 리스트가 없어 건너뜁니다."
fi

# ------------------------------------------------------------------
# [4/8] 쉘 환경 설정 복원
# ------------------------------------------------------------------
echo "[4/8] 터미널 및 쉘 환경 설정 복원 중..."
if [ -d "$BACKUP_DIR/shell-env" ]; then
    for file in ".bashrc" ".bash_aliases" ".profile" ".bash_logout"; do
        if [ -f "$BACKUP_DIR/shell-env/$file" ]; then
            if [ -f "$HOME/$file" ] && ! cmp -s "$BACKUP_DIR/shell-env/$file" "$HOME/$file"; then
                cp -a "$HOME/$file" "$HOME/$file.bak-$TS"
                echo "  - 기존 $file 을(를) $file.bak-$TS 로 보관"
            fi
            cp -a "$BACKUP_DIR/shell-env/$file" "$HOME/$file"
            echo "  - $file 복원 완료"
        fi
    done
else
    echo "  - shell-env 백업 없음, 건너뜁니다."
fi

# ------------------------------------------------------------------
# [5/8] 사용자 로컬 바이너리/스크립트 복원
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/local-bin" ]; then
    echo "[5/8] 사용자 로컬 바이너리 및 쉘 스크립트($HOME/.local/bin) 복원 중..."
    mkdir -p "$HOME/.local/bin"
    # --delete 없음: 새 시스템에 이미 있는 파일은 유지
    rsync -av "$BACKUP_DIR/local-bin/" "$HOME/.local/bin/"
    # git 은 실행 비트만 저장하므로, 확실히 하기 위해 스크립트에 실행 권한 부여
    find "$HOME/.local/bin" -maxdepth 1 -type f \
        \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} +
else
    echo "[5/8] local-bin 백업이 없어 건너뜁니다."
fi

# ------------------------------------------------------------------
# [6/8] Systemd User 서비스 및 타이머 복원
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/systemd-user" ]; then
    echo "[6/8] Systemd 사용자 서비스 및 타이머 복원 중..."
    mkdir -p "$HOME/.config/systemd/user"
    # rsync -a 로 심볼릭 링크(.wants/)도 함께 복원되므로 enable 상태도 유지됨
    rsync -av "$BACKUP_DIR/systemd-user/" "$HOME/.config/systemd/user/"

    if systemctl --user daemon-reload 2>/dev/null; then
        echo "  - daemon-reload 완료"
        # 타이머는 즉시 시작 시도
        for t in "$HOME/.config/systemd/user/"*.timer; do
            [ -e "$t" ] || continue
            name="$(basename "$t")"
            systemctl --user enable --now "$name" 2>/dev/null \
                && echo "  - $name 활성화" \
                || warn "$name 활성화 실패 (로그인 세션에서 직접 실행 필요할 수 있음)"
        done
    else
        warn "systemd user 세션에 연결할 수 없습니다. 데스크톱 로그인 후 'systemctl --user daemon-reload' 를 실행하세요."
    fi
else
    echo "[6/8] systemd-user 백업이 없어 건너뜁니다."
fi

# ------------------------------------------------------------------
# [7/8] XFCE4 데스크톱 설정 복원
# ------------------------------------------------------------------
if [ -d "$BACKUP_DIR/xfce4" ]; then
    echo "[7/8] XFCE4 데스크톱 테마 및 패널 설정 복원 중..."
    warn "XFCE 세션이 실행 중이면 로그아웃 시 설정이 덮어써질 수 있습니다."
    warn "가장 안전한 방법: TTY(Ctrl+Alt+F3)에서 실행 후 재로그인."
    if confirm "XFCE4 설정을 복원할까요?" "y"; then
        if [ -d "$HOME/.config/xfce4" ]; then
            cp -a "$HOME/.config/xfce4" "$HOME/.config/xfce4.bak-$TS"
            echo "  - 기존 설정을 ~/.config/xfce4.bak-$TS 로 보관"
        fi
        mkdir -p "$HOME/.config/xfce4"
        rsync -av "$BACKUP_DIR/xfce4/" "$HOME/.config/xfce4/"
        echo "  - 완료 (재로그인 후 적용)"
    fi
else
    echo "[7/8] xfce4 백업이 없어 건너뜁니다."
fi

# ------------------------------------------------------------------
# [8/8] 나머지 시스템 설정(/etc) 복원
# ------------------------------------------------------------------
echo "[8/8] 시스템 설정(/etc) 복원 중..."
echo "  (덮어쓰기 전 기존 파일은 $SAFE_DIR 에 보관됩니다)"

for src in "${SYSTEM_PATHS[@]}"; do
    [ "$src" = "/etc/apt" ] && continue   # 1단계에서 이미 처리
    restore_system_path "$src"
done

# ---- 복원 후 후처리 -------------------------------------------------

# SSH: 개인키 권한 복구 (git 은 파일 권한을 보존하지 않음) + 문법 검사
if [ -d /etc/ssh ] && [ -d "$BACKUP_DIR/etc/ssh" ]; then
    sudo find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key' -exec chmod 600 {} +
    sudo find /etc/ssh -maxdepth 1 -type f -name 'ssh_host_*_key.pub' -exec chmod 644 {} +
    if command -v sshd &>/dev/null || [ -x /usr/sbin/sshd ]; then
        if sudo /usr/sbin/sshd -t 2>/dev/null; then
            echo "  - sshd 설정 검사 통과"
            if confirm "ssh 서비스를 재시작할까요?" "n"; then
                sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
            fi
        else
            warn "sshd 설정 검사 실패! 재시작하지 마세요. (이전 설정: $SAFE_DIR/etc/ssh)"
        fi
    fi
fi

# fstab: 문법 검증 (UUID 가 다른 시스템이면 부팅 실패 위험)
if [ -f /etc/fstab ] && [ -f "$BACKUP_DIR/etc/fstab" ]; then
    if command -v findmnt &>/dev/null; then
        echo "  - fstab 검증:"
        sudo findmnt --verify 2>&1 | sed 's/^/      /'
    fi
    warn "fstab 의 UUID 가 현재 디스크와 일치하는지 'lsblk -f' 로 꼭 확인하세요."
fi

# GRUB: 설정 반영
if [ -f "$BACKUP_DIR/etc/default/grub" ] || [ -d "$BACKUP_DIR/etc/grub.d" ]; then
    if command -v update-grub &>/dev/null && confirm "update-grub 을 실행할까요?" "y"; then
        sudo update-grub || FAILED+=("update-grub")
    fi
fi

# UFW: 규칙 재적용
if [ -d /etc/ufw ] && [ -d "$BACKUP_DIR/etc/ufw" ] && command -v ufw &>/dev/null; then
    if confirm "ufw 규칙을 다시 불러올까요?" "y"; then
        sudo ufw reload 2>/dev/null || warn "ufw reload 실패 (비활성 상태일 수 있음: 'sudo ufw enable')"
    fi
fi

# ------------------------------------------------------------------
# 결과 요약
# ------------------------------------------------------------------
echo ""
echo "=========================================="
if [ "${#FAILED[@]}" -eq 0 ]; then
    echo " 복원 Complete (오류 없음)"
else
    echo " 복원 Complete (일부 실패)"
    echo " 실패 항목:"
    printf '   - %s\n' "${FAILED[@]}"
fi
echo " 기존 /etc 보관 위치: $SAFE_DIR"
echo " 일부 설정(XFCE, 쉘, 서비스)은 재로그인 또는 재부팅 후 적용됩니다."
echo "=========================================="