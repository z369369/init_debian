#!/bin/bash

# ==============================================================================
# Script Name : rename_screenshots.sh
# Description : 스크린샷 파일명 일괄 변경 (스크린샷_ -> Screenshot_, '-' 제거)
# ==============================================================================

# 대상 디렉토리 설정
TARGET_DIR="/home/lwh/phone/DCIM/Screenshots"

# 1. 디렉토리 존재 여부 검증
if [ ! -d "$TARGET_DIR" ]; then
    echo "[ERROR] 지정한 디렉토리가 존재하지 않습니다: $TARGET_DIR" >&2
    exit 1
fi

# 2. 해당 디렉토리로 이동
cd "$TARGET_DIR" || {
    echo "[ERROR] 디렉토리 이동 실패: $TARGET_DIR" >&2
    exit 1
}

echo "=== 파일명 변경 작업 시작: $TARGET_DIR ==="
count=0

# 3. 디렉토리 내부 파일 순회 (공백/특수문자 안전 처리)
for file in *; do
    # 파일이 존재하는지 및 일반 파일인지 검증 (빈 디렉토리 및 서브디렉토리 제외)
    [ -f "$file" ] || continue

    # "스크린샷_" 또는 "-" 문자가 포함된 경우에만 처리
    if [[ "$file" == *"스크린샷_"* ]] || [[ "$file" == *"-"* ]]; then
        # A. "스크린샷_" -> "Screenshot_" 문자열 치환
        new_name="${file//스크린샷_/Screenshot_}"
        
        # B. "-" 문자를 완전히 제거
        new_name="${new_name//-/}"

        # 실제 변경사항이 존재하는 경우 실행
        if [ "$file" != "$new_name" ]; then
            # 변경 대상 동일 파일명이 존재하는 경우 덮어쓰기 방지 (-n)
            if [ -e "$new_name" ]; then
                echo "[WARNING] 동일한 파일명이 이미 존재하여 건너뜁니다: '$new_name'"
            else
                echo "[RENAME] '$file' -> '$new_name'"
                mv -n -- "$file" "$new_name"
                ((count++))
            fi
        fi
    fi
done

echo "=== 작업 완료 (총 $count개 파일 변경됨) ==="