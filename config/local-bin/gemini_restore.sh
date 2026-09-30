#!/usr/bin/env bash
# @DESC: gemini_backup.sh 로 백업한 Debian 13 구성을 복원
# @TAGS: GIT, xfce, etc, config restore
# @USAGE: restore_debian.sh [-y] [-d 백업경로] [--with-fstab] [단계번호...]
#
# 단계:
#   1 APT 저장소/키링 + 수동설치 패키지   6 XFCE4 설정
#   2 Flatpak 앱                          7 UFW 방화벽
#   3 쉘 환경 파일                        8 SSHD 설정
#   4 ~/.local/bin                        9 GRUB 설정
#   5 systemd user 유닛                  10 /etc/fstab (--with-fstab 지정 시에만, 위험)
#
# 예)  ./restore_debian.sh            # 1~9단계 전체 (위험 단계는 확인 질문)
#      ./restore_debian.sh 3 4 5      # 쉘/로컬바이너리/systemd 만
#      ./restore_debian.sh -y 1 2     # 질문 없이 1,2단계

set -uo pipefail

BACKUP_DIR="~/git/init_debian/config"
ASSUME_YES=0
WITH_FSTAB=0
STEPS=()
TS="$(date +%Y%m%d-%H%M%S)"

# ---------- 인자 처리 ----------
while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes)      ASSUME_YES=1 ;;
        -d|--dir)      shift; BACKUP_DIR="${1:?백업 경로 필요}" ;;
        --with-fstab)  WITH_FSTAB=1 ;;
        -h|--help)     sed -n '2,20p' "$0"; exit 0 ;;
        [0-9]*)        STEPS+=("$1") ;;
        *)             echo "알 수 없는 옵션: $1"; exit 1 ;;
    esac
    shift
done

if [ ${#STEPS[@]} -eq 0 ]; then
    STEPS=(1 2 3 4 5 6 7 8 9)
    [ "$WITH_FSTAB" -eq 1 ] && STEPS+=(10)
fi

# ---------- 공통 함수 ----------
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }

confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    local ans
    read -r -p "$1 [y/N] " ans < /dev/tty
    [[ "$ans" =~ ^[Yy]$ ]]
}

# 덮어쓰기 전에 기존 파일/디렉토리를 .bak.<시각> 으로 보존
backup_existing() {
    local target="$1"
    if [ -e "$target" ]; then
        if [ -w "$(dirname "$target")" ] && [ -w "$target" ]; then
            cp -a "$target" "${target}.bak.${TS}"
        else
            sudo cp -a "$target" "${target}.bak.${TS}"
        fi
    fi
}

# ---------- 사전 점검 ----------
if [ "$EUID" -eq 0 ]; then
    echo "root 로 실행하지 마세요. 일반 사용자로 실행하면 필요한 부분만 sudo 를 사용합니다."
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "백업 디렉토리를 찾을 수 없습니다: $BACKUP_DIR"
    exit 1
fi

if ! command -v rsync &>/dev/null; then
    info "rsync 가 없어 설치합니다."
    sudo apt-get update && sudo apt-get install -y rsync || exit 1
fi

sudo -v || exit 1

echo "=========================================="
echo " 시스템 구성 복원을 시작합니다."
echo " 백업 원본: $BACKUP_DIR"
echo " 실행 단계: ${STEPS[*]}"
echo "=========================================="

# ---------- 1. APT ----------
step_1() {
    echo "[1] APT 저장소/키링/패키지 복원"

    # 키링을 먼저 복원해야 sources 가 참조하는 signed-by 키가 존재함
    if [ -d "$BACKUP_DIR/keyrings" ]; then
        sudo mkdir -p /etc/apt/keyrings
        sudo rsync -av "$BACKUP_DIR/keyrings/" /etc/apt/keyrings/ --chown=root:root
        sudo chmod 755 /etc/apt/keyrings
        sudo find /etc/apt/keyrings -type f -exec chmod 644 {} +
    fi

    if [ -d "$BACKUP_DIR/sources.list.d" ]; then
        # --delete 는 사용하지 않음 (현재 시스템의 저장소를 지우지 않기 위해)
        sudo rsync -av "$BACKUP_DIR/sources.list.d/" /etc/apt/sources.list.d/ --chown=root:root
        sudo find /etc/apt/sources.list.d -type f -exec chmod 644 {} +
    fi

    sudo apt-get update || warn "apt update 중 오류 발생 (저장소 설정 확인 필요)"

    local list="$BACKUP_DIR/apt-packages.list"
    if [ ! -f "$list" ]; then
        warn "apt-packages.list 없음 - 패키지 설치 건너뜀"
        return
    fi

    local avail=() missing=() pkg
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
        if apt-cache show "$pkg" &>/dev/null; then
            avail+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done < "$list"

    if [ ${#missing[@]} -gt 0 ]; then
        warn "저장소에서 찾을 수 없어 건너뛰는 패키지(${#missing[@]}개): ${missing[*]}"
        printf '%s\n' "${missing[@]}" > "$HOME/apt-restore-missing.$TS.txt"
        info "누락 목록 저장: $HOME/apt-restore-missing.$TS.txt"
    fi

    if [ ${#avail[@]} -gt 0 ]; then
        info "${#avail[@]}개 패키지를 설치합니다."
        if ! sudo apt-get install -y "${avail[@]}"; then
            warn "일괄 설치 실패 - 개별 설치로 재시도합니다."
            for pkg in "${avail[@]}"; do
                sudo apt-get install -y "$pkg" || warn "설치 실패: $pkg"
            done
        fi
        # 수동 설치 표시 복원 (autoremove 방지)
        sudo apt-mark manual "${avail[@]}" >/dev/null 2>&1 || true
    fi
}

# ---------- 2. Flatpak ----------
step_2() {
    echo "[2] Flatpak 애플리케이션 복원"
    local list="$BACKUP_DIR/flatpak-packages.list"
    if [ ! -f "$list" ]; then
        warn "flatpak-packages.list 없음 - 건너뜀"
        return
    fi

    if ! command -v flatpak &>/dev/null; then
        sudo apt-get install -y flatpak || { warn "flatpak 설치 실패"; return; }
    fi

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    local app
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        flatpak install -y --noninteractive flathub "$app" || warn "Flatpak 설치 실패: $app"
    done < "$list"
}

# ---------- 3. 쉘 환경 ----------
step_3() {
    echo "[3] 쉘 환경 설정 복원"
    local src="$BACKUP_DIR/shell-env" file
    if [ ! -d "$src" ]; then warn "shell-env 없음 - 건너뜀"; return; fi

    for file in .bashrc .bash_aliases .profile .bash_logout; do
        if [ -f "$src/$file" ]; then
            backup_existing "$HOME/$file"
            cp "$src/$file" "$HOME/$file"
            info "복원: ~/$file"
        fi
    done
}

# ---------- 4. ~/.local/bin ----------
step_4() {
    echo "[4] ~/.local/bin 복원"
    if [ ! -d "$BACKUP_DIR/local-bin" ]; then warn "local-bin 없음 - 건너뜀"; return; fi
    mkdir -p "$HOME/.local/bin"
    rsync -av --no-owner --no-group "$BACKUP_DIR/local-bin/" "$HOME/.local/bin/"
}

# ---------- 5. systemd user ----------
step_5() {
    echo "[5] systemd 사용자 서비스/타이머 복원"
    if [ ! -d "$BACKUP_DIR/systemd-user" ]; then warn "systemd-user 없음 - 건너뜀"; return; fi
    mkdir -p "$HOME/.config/systemd/user"
    # -a 는 심볼릭 링크(*.wants/ 의 enable 정보)도 그대로 복원함
    rsync -av --no-owner --no-group "$BACKUP_DIR/systemd-user/" "$HOME/.config/systemd/user/"
    systemctl --user daemon-reload || warn "daemon-reload 실패 (사용자 세션 확인)"
    info "필요하면 'systemctl --user list-unit-files' 로 활성화 상태를 확인하세요."
}

# ---------- 6. XFCE4 ----------
step_6() {
    echo "[6] XFCE4 설정 복원"
    if [ ! -d "$BACKUP_DIR/xfce4" ]; then warn "xfce4 없음 - 건너뜀"; return; fi

    if pgrep -x xfconfd >/dev/null 2>&1 || pgrep -x xfce4-panel >/dev/null 2>&1; then
        warn "XFCE 세션이 실행 중입니다. 실행 중에 복원하면 xfconfd/패널이 종료 시 설정을 덮어쓸 수 있습니다."
        warn "가장 안전한 방법: 로그아웃 후 TTY(Ctrl+Alt+F3)에서 './restore_debian.sh 6' 실행"
        confirm "그래도 지금 복원할까요?" || { info "XFCE 복원 건너뜀"; return; }
    fi

    backup_existing "$HOME/.config/xfce4"
    mkdir -p "$HOME/.config/xfce4"
    rsync -av --no-owner --no-group "$BACKUP_DIR/xfce4/" "$HOME/.config/xfce4/"
    info "복원 완료. 재로그인하면 적용됩니다."
}

# ---------- 7. UFW ----------
step_7() {
    echo "[7] UFW 방화벽 복원"
    local src="$BACKUP_DIR/ufw" f
    if [ ! -d "$src" ]; then warn "ufw 백업 없음 - 건너뜀"; return; fi

    if ! command -v ufw &>/dev/null; then
        sudo apt-get install -y ufw || { warn "ufw 설치 실패"; return; }
    fi

    confirm "UFW 규칙을 덮어쓰고 리로드합니다. SSH 규칙이 포함되어 있는지 확인했나요?" \
        || { info "UFW 복원 건너뜀"; return; }

    for f in user.rules user6.rules ufw.conf; do
        if [ -f "$src/$f" ]; then
            backup_existing "/etc/ufw/$f"
            sudo install -o root -g root -m 640 "$src/$f" "/etc/ufw/$f"
            info "복원: /etc/ufw/$f"
        fi
    done
    sudo ufw reload || warn "ufw reload 실패 (비활성 상태일 수 있음)"
    sudo ufw status verbose || true
}

# ---------- 8. SSHD ----------
step_8() {
    echo "[8] SSHD 설정 복원"
    local src="$BACKUP_DIR/sshd/sshd_config"
    if [ ! -f "$src" ]; then warn "sshd_config 백업 없음 - 건너뜀"; return; fi

    if [ ! -x /usr/sbin/sshd ]; then
        confirm "openssh-server 가 없습니다. 설치할까요?" \
            && sudo apt-get install -y openssh-server || return
    fi

    confirm "sshd_config 를 복원합니다 (문법 검사 후 적용)." || { info "SSHD 복원 건너뜀"; return; }

    backup_existing "/etc/ssh/sshd_config"
    sudo install -o root -g root -m 644 "$src" /etc/ssh/sshd_config

    if sudo sshd -t; then
        sudo systemctl restart ssh || sudo systemctl restart sshd || warn "sshd 재시작 실패"
        info "sshd 설정 적용 완료 (현재 SSH 세션은 유지한 채 새 접속을 테스트하세요)."
    else
        warn "sshd 문법 검사 실패 - 이전 설정으로 되돌립니다."
        sudo cp -a "/etc/ssh/sshd_config.bak.${TS}" /etc/ssh/sshd_config
    fi
}

# ---------- 9. GRUB ----------
step_9() {
    echo "[9] GRUB 설정 복원"
    local src="$BACKUP_DIR/grub.d"
    if [ ! -d "$src" ]; then warn "grub.d 백업 없음 - 건너뜀"; return; fi

    confirm "GRUB 설정(/etc/grub.d, /etc/default/grub)을 덮어쓰고 update-grub 을 실행합니다." \
        || { info "GRUB 복원 건너뜀"; return; }

    backup_existing "/etc/grub.d"
    backup_existing "/etc/default/grub"

    # default_grub 은 /etc/default/grub 용이므로 grub.d 에는 복사하지 않음
    sudo rsync -av --exclude='default_grub' --chown=root:root "$src/" /etc/grub.d/

    if [ -f "$src/default_grub" ]; then
        sudo install -o root -g root -m 644 "$src/default_grub" /etc/default/grub
        info "복원: /etc/default/grub"
    fi

    # 실행 권한이 있어야 하는 스크립트 확인 (백업 시 권한이 보존되었는지 검사)
    sudo ls -l /etc/grub.d/
    sudo update-grub || warn "update-grub 실패"
}

# ---------- 10. fstab (opt-in) ----------
step_10() {
    echo "[10] /etc/fstab 복원"
    local src="$BACKUP_DIR/fstab"
    if [ ! -f "$src" ]; then warn "fstab 백업 없음 - 건너뜀"; return; fi

    warn "fstab 은 디스크 UUID 가 다른 환경(새 디스크/재설치)에서 복원하면 부팅 실패를 일으킬 수 있습니다."
    echo "---- 현재 fstab 과의 차이 ----"
    diff -u /etc/fstab "$src" || true
    echo "------------------------------"

    confirm "위 내용으로 /etc/fstab 을 교체할까요?" || { info "fstab 복원 건너뜀"; return; }

    backup_existing "/etc/fstab"
    sudo install -o root -g root -m 644 "$src" /etc/fstab

    if command -v findmnt &>/dev/null && ! sudo findmnt --verify; then
        warn "fstab 검증 실패 - 이전 fstab 으로 되돌립니다."
        sudo cp -a "/etc/fstab.bak.${TS}" /etc/fstab
    else
        sudo systemctl daemon-reload
    fi
}

# ---------- 실행 ----------
for s in "${STEPS[@]}"; do
    if declare -F "step_$s" >/dev/null; then
        "step_$s" || warn "단계 $s 에서 오류가 발생했습니다."
        echo
    else
        warn "존재하지 않는 단계: $s"
    fi
done

echo "=========================================="
echo " 복원 Complete"
echo " - 기존 파일은 *.bak.$TS 로 보존되었습니다."
echo " - 쉘 설정/XFCE/systemd 는 재로그인 또는 재부팅 후 완전히 적용됩니다."
echo "=========================================="
