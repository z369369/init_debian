#!/bin/bash

# ==============================================================================
# 디렉터리 경로 설정
# ==============================================================================
SOURCE_DIR="/media/lwh/lwh_backup/Wallpaper"
TARGET_DIR="/media/lwh/lwh_backup/Wallpaper/backup"
KEEP_COUNT=100

# ==============================================================================
# 사전 검증 및 디렉터리 생성
# ==============================================================================
# 원본 디렉터리가 존재하지 않으면 스크립트 종료
if [ ! -d "$SOURCE_DIR" ]; then
    echo "🚨 오류: 원본 폴더($SOURCE_DIR)가 존재하지 않습니다." >&2
    exit 1
fi

# 백업 디렉터리가 없으면 자동 생성
if [ ! -d "$TARGET_DIR" ]; then
    echo "📂 백업 폴더가 없어 새로 생성합니다: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# ==============================================================================
# 파일 이동 로직 실행
# ==============================================================================
echo "🔄 Wallpaper 폴더 정리를 시작합니다... (최신 $KEEP_COUNT개 유지)"

# 1. 원본 폴더로 이동 (공백이 포함된 파일명을 안전하게 처리하기 위함)
cd "$SOURCE_DIR" || exit 1

# 2. 파일 목록을 수정 시간 역순(최신순)으로 정렬하여 배열에 할당
# -maxdepth 1: 서브 디렉터리는 제외하고 현재 폴더의 파일만 대상
# -type f: 파일만 대상 (디렉터리 제외)
# %T@: 수정 시간을 타임스탬프로 출력 (정렬용)
# %p: 파일 경로 출력
mapfile -d '' -t FILES < <(find . -maxdepth 1 -type f -printf "%T@ %p\0" | sort -z -r -n | cut -z -d' ' -f2-)

TOTAL_FILES=${#FILES[@]}

# 3. 파일 개수가 100개를 초과하는 경우에만 이동 작업 수행
if [ "$TOTAL_FILES" -gt "$KEEP_COUNT" ]; then
    MOVE_COUNT=$((TOTAL_FILES - KEEP_COUNT))
    echo "📈 총 파일 수: $TOTAL_FILES개 | 초과 파일 수: $MOVE_COUNT개"
    echo "📦 오래된 파일 $MOVE_COUNT개를 백업 폴더로 이동합니다..."

    # 배열의 100번째 인덱스부터 끝까지 반복하며 이동
    for ((i=KEEP_COUNT; i<TOTAL_FILES; i++)); do
        # 파일명 추출 (./파일명 형태에서 ./ 제거)
        FILE_NAME="${FILES[i]}"
        
        # 안전한 이동 수행 (파일명에 공백이 있어도 안전하도록 쌍따옴표 처리)
        mv "$FILE_NAME" "$TARGET_DIR/"
    done

    echo "✅ 정리가 완료되었습니다. 현재 Wallpaper 폴더에는 최신 $KEEP_COUNT개의 파일만 남았습니다."
else
    echo "✅ 현재 파일 수가 ${TOTAL_FILES}개이므로 이동할 파일이 없습니다. (기준: ${KEEP_COUNT}개)"
fi