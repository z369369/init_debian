#!/bin/bash

# 5초 대기 (부팅 직후 실행 등 네트워크 안정화 목적)
sleep 5

TARGET_DIR="/media/lwh/lwh_backup/Wallpaper"

# 디렉터리가 없으면 자동 생성
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

# 1. Bing API 호출을 위한 랜덤 인덱스 설정 (0~7)
random_idx=$((RANDOM % 8))

# Bing 이미지 메타데이터 가져오기 및 유령 문자 정제
api_res=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=${random_idx}&n=1&mkt=en-US" | tr -d '\r\n\t')

# API 응답 파싱 및 URL 조합
img_path=$(echo "$api_res" | jq -r '.images[0].url' 2>/dev/null | tr -d '\r\n\t')
if [ -z "$img_path" ] || [ "$img_path" == "null" ]; then
    echo "오류: Bing API로부터 이미지 URL을 가져오지 못했습니다."
    exit 1
fi
bing_url="https://www.bing.com${img_path}"

# 2. 고유 ID 추출 및 .jpg 확장자 강제 고정
# 파라미터에서 id= 뒷부분을 가져온 후, 첫 번째 '&' 기호가 나오면 그 뒤를 전부 버립니다.
raw_id=$(echo "$img_path" | grep -oP 'id=\K[^&]+')

# 만약 .jpg 문자열이 포함되어 있다면 .jpg 앞부분만 추출합니다. (jpghp, jpg&pid=hp 등 완벽 차단)
if [[ "$raw_id" == *".jpg"* ]]; then
    clean_id="${raw_id%%.jpg*}"
else
    clean_id=$(echo "$raw_id" | tr -cd '[:alnum:]._-')
fi

# 정제된 ID 뒤에 깨끗한 .jpg 확장자를 강제로 결합
save_id="${clean_id}.jpg"

# 만약 파일명이 비정상적일 경우를 대비한 2차 안전장치
if [ -z "$clean_id" ]; then
    save_id="bing_$(date +%Y%m%d_%H%M%S).jpg"
fi

save_path="${TARGET_DIR}/${save_id}"

# 3. 1차 검증: 동일한 파일명이 이미 존재하는지 확인 (속도 최적화)
if [ -f "$save_path" ]; then
    echo "=================================================="
    echo "[중복 건너뛰기] 이미 동일한 ID의 파일이 존재합니다."
    echo " - 파일명: $save_id"
    echo "=================================================="
    exit 0
fi

# 4. 임시 다운로드 및 2차 검증 (해시 비교)
tmp_file=$(mktemp)
if ! curl -s -o "$tmp_file" "$bing_url"; then
    echo "오류: 이미지 다운로드에 실패했습니다."
    rm -f "$tmp_file"
    exit 1
fi

# 새 이미지의 SHA256 해시 계산
new_sha256=$(sha256sum "$tmp_file" | awk '{print $1}')

# 기존 파일들 중 동일한 해시가 있는지 딱 1번만 루프 돌며 확인
is_duplicate=false
duplicate_file=""

while IFS= read -r -d '' file; do
    [ -f "$file" ] || continue
    current_sha256=$(sha256sum "$file" | awk '{print $1}')
    
    if [ "$new_sha256" == "$current_sha256" ]; then
        is_duplicate=true
        duplicate_file=$(basename "$file")
        break
    fi
done < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) -print0)

# 5. 최종 처리
echo "=================================================="
if [ "$is_duplicate" = true ]; then
    echo "[중복 취소] 다운로드한 이미지가 기존 파일과 동일합니다."
    echo " - 원본 파일: $duplicate_file"
    rm -f "$tmp_file"
else
    mv "$tmp_file" "$save_path"
    echo " 작업 완료!"
    echo " - 저장된 이미지: $save_id"
fi
echo "=================================================="
/home/lwh/Desktop/bin/bing_wall_move.sh