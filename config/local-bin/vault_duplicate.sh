#!/bin/bash

# 검색 대상 디렉터리 목록
TARGET_DIRS=(
    "/home/lwh/Pictures/001_Brain_Notes_Images"
    "/home/lwh/Documents/001_Brain_Notes"
    "/home/lwh/Documents/101_Personal_Data"
)

# 임시 파일 생성
TMP_ALL_FILES=$(mktemp)
TMP_DUP_NAMES=$(mktemp)

trap 'rm -f "$TMP_ALL_FILES" "$TMP_DUP_NAMES"' EXIT

echo "=========================================="
echo " 중복 파일 검색을 시작합니다..."
echo "=========================================="

# 1. 지정된 폴더에서 숨김 파일/폴더를 제외한 모든 파일 경로 수집
for dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # -not -path '*/.*' : 숨김 폴더 및 파일 제외
        find "$dir" -type f -not -path '*/.*' >> "$TMP_ALL_FILES"
    else
        echo "[경고] 디렉터리가 존재하지 않습니다: $dir"
    fi
done

# 2. 파일명 추출 후 중복된 파일명(2회 이상 등장)만 추출
awk -F'/' '{print $NF}' "$TMP_ALL_FILES" | sort | uniq -d > "$TMP_DUP_NAMES"

# 3. 결과 출력
if [ ! -s "$TMP_DUP_NAMES" ]; then
    echo "중복된 파일이 존재하지 않습니다."
    exit 0
fi

echo -e "\n[중복 파일 검색 결과]\n"

TOTAL_DUPS=0
while IFS= read -r filename; do
    ((TOTAL_DUPS++))
    echo "------------------------------------------"
    echo "파일명: $filename"
    echo "위치 목록:"
    grep -E "/${filename}$" "$TMP_ALL_FILES" | sed 's/^/  - /'
done < "$TMP_DUP_NAMES"

echo "------------------------------------------"
echo "총 ${TOTAL_DUPS}개의 중복 파일명이 발견되었습니다."