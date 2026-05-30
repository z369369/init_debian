#!/bin/bash
sleep 5

# 1. 0~9 사이의 랜덤 숫자 생성
# $RANDOM % 10은 0부터 9까지의 나머지를 반환합니다.
random_idx=$((RANDOM % 9))

# 1. Bing 이미지 URL 가져오기
bing_url="https://www.bing.com$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=${random_idx}&n=1&mkt=en-US" | jq -r '.images[0].url')"
#save_id=$(echo "$bing_url" | sed 's/.*th?id=\([^&]*\).*/\1/')
#save_path="$HOME/Pictures/009_wallpaper/${save_id}"
save_path="$HOME/Pictures/009_wallpaper/bing_wallpaper_${random_idx}.jpg"

#echo $bing_url $save_path



# 2. 이미지 다운로드
curl -s -o "$save_path" "$bing_url"


