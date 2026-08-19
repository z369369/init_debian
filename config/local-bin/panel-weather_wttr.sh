#!/bin/bash

# 설정: 도시명 및 캐시 파일 경로
LOCATION="Cheonan"
CACHE_FILE="/home/lwh/.cache/genmon-weather.cache"
MAX_RETRIES=10
RETRY_INTERVAL=3

# 네트워크 응답을 기다리며 재시도하는 함수
get_weather() {
    local count=0
    local res=""
    
    while [ $count -lt $MAX_RETRIES ]; do
        # wttr.in 연결 시도 (타임아웃 3초)
        res=$(curl -s --max-time 3 "wttr.in/${LOCATION}?format=%c+%t" | xargs)
        
        # 데이터 수령 성공 시 반환
        if [ -n "$res" ] && [[ "$res" != *"Unknown"* ]]; then
            echo "$res"
            return 0
        fi
        
        # 실패 시 RETRY_INTERVAL 만큼 대기 후 재시도
        count=$((count + 1))
        sleep $RETRY_INTERVAL
    done
    
    return 1
}

# 날씨 정보 획득 시도
CURRENT_WEATHER=$(get_weather)

if [ $? -eq 0 ]; then
    # 성공 시 캐시 파일 업데이트
    echo "$CURRENT_WEATHER" > "$CACHE_FILE"
    DISPLAY_TEXT="$CURRENT_WEATHER"
else
    # 실패 시 캐시 파일이 존재하면 이전 날씨 표시, 없으면 N/A
    if [ -f "$CACHE_FILE" ]; then
        DISPLAY_TEXT="$(cat "$CACHE_FILE") (!)"
    else
        DISPLAY_TEXT="N/A"
    fi
fi

# 패널 출력
echo "<txt> ${DISPLAY_TEXT} </txt>"
echo "<tool>위치: ${LOCATION}\n클릭 시 상세 예보 확인 (우클릭/중간클릭 시 수동 갱신)</tool>"
echo "<click>xdg-open https://wttr.in/${LOCATION}</click>"