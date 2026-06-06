#!/bin/bash
sleep 5

# 1. 0~9 사이의 랜덤 숫자 생성
# $RANDOM % 10은 0부터 9까지의 나머지를 반환합니다.
random_idx=$((RANDOM % 8))
save_idx=$((RANDOM % 5000))

# 1. Bing 이미지 URL 가져오기
bing_url="https://www.bing.com$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=${random_idx}&n=1&mkt=en-US" | jq -r '.images[0].url')"
#save_id=$(echo "$bing_url" | sed 's/.*th?id=\([^&]*\).*/\1/')
#save_path="$HOME/Pictures/009_wallpaper/${save_id}"
save_path="$HOME/Pictures/009_wallpaper/bing_wallpaper_${save_idx}.jpg"

#echo $bing_url $save_path



# 2. 이미지 다운로드
curl -s -o "$save_path" "$bing_url"


#3. 중복제거
TARGET_DIR="$HOME/Pictures/009_wallpaper"

# 디렉터리 존재 여부 확인
if [ ! -d "$TARGET_DIR" ]; then
    echo "오류: $TARGET_DIR 디렉터리가 존재하지 않습니다."
    exit 1
fi

# 중복 해시 체크를 위한 연상 배열(Associative Array) 선언
declare -A hash_map

# 카운터 초기화
total_files=0
deleted_files=0

# 하위 디렉터리를 제외하고 해당 폴더의 파일만 처리 (필요시 -maxdepth 1 제거 가능)
while IFS= read -r -d '' file; do
    # 파일이 실제로 존재하는지 확인 (심볼릭 링크 등 예외 처리)
    [ -f "$file" ] || continue
    ((total_files++))

    # SHA256 해시값 추출 (파일명에 공백이 있어도 안전하도록 처리)
    sha256=$(sha256sum "$file" | awk '{print $1}')

    # 이미 동일한 해시값이 배열에 등록되어 있다면 중복 파일임
    if [[ -n "${hash_map[$sha256]}" ]]; then
        echo "[중복 삭제] '${hash_map[$sha256]}' 파일과 동일함:"
        echo "  -> 삭제 파일: $(basename "$file")"
        
        # 파일 삭제 실행
        rm "$file"
        ((deleted_files++))
    else
        # 새로운 해시값인 경우 배열에 원본 경로 저장
        hash_map[$sha256]="$file"
    fi
done < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) -print0)


echo "=================================================="
echo " 작업 완료!"
echo " - 스캔한 총 이미지 수: $total_files 장"
echo " - 삭제된 중복 이미지 수: $deleted_files 장"
echo "=================================================="
