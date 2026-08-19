#!/bin/bash

# 필수 의존성 체크 (jq가 없을 경우 설치 필요: sudo apt install jq)
if ! command -v jq &> /dev/null; then
    echo "<txt> Error: jq 필요 </txt>"
    exit 1
fi

# 설정: 천안 위도/경도 및 캐시 경로
LAT="36.8151"
LON="127.1139"
LOCATION_NAME="Cheonan"
CACHE_FILE="/home/lwh/.cache/genmon-weather.cache"
MAX_RETRIES=5
RETRY_INTERVAL=2

# WMO 날씨 코드를 아이콘/문자로 변환하는 함수
get_weather_icon() {
    case $1 in
        0) echo "☀️" ;;          # Clear sky
        1|2|3) echo "⛅" ;;      # Mainly clear, partly cloudy, overcast
        45|48) echo "🌫️" ;;      # Fog
        51|53|55|56|57) echo "🌧️" ;; # Drizzle
        61|63|65|66|67) echo "🌧️" ;; # Rain
        71|73|75|77) echo "❄️" ;;    # Snow
        80|81|82) echo "🌦️" ;;    # Rain showers
        85|86) echo "🌨️" ;;       # Snow showers
        95|96|99) echo "🌩️" ;;    # Thunderstorm
        *) echo "🌡️" ;;
    esac
}

get_weather() {
    local count=0
    local url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current_weather=true"
    
    while [ $count -lt $MAX_RETRIES ]; do
        # Open-Meteo API 호출 (타임아웃 3초)
        res=$(curl -s --max-time 3 "$url")
        
        # JSON 응답 정상 확인
        if [ -n "$res" ] && echo "$res" | jq -e '.current_weather' > /dev/null 2>&1; then
            temp=$(echo "$res" | jq -r '.current_weather.temperature')
            code=$(echo "$res" | jq -r '.current_weather.weathercode')
            
            # 반올림 및 아이콘 매핑
            round_temp=$(printf "%.0f" "$temp")
            icon=$(get_weather_icon "$code")
            
            echo "${icon} ${round_temp}°C"
            return 0
        fi
        
        count=$((count + 1))
        sleep $RETRY_INTERVAL
    done
    
    return 1
}

# 날씨 정보 획득 시도
CURRENT_WEATHER=$(get_weather)

if [ $? -eq 0 ]; then
    echo "$CURRENT_WEATHER" > "$CACHE_FILE"
    DISPLAY_TEXT="$CURRENT_WEATHER"
else
    if [ -f "$CACHE_FILE" ]; then
        DISPLAY_TEXT="$(cat "$CACHE_FILE") (!)"
    else
        DISPLAY_TEXT="N/A"
    fi
fi

# Genmon 패널 출력
echo "<txt> ${DISPLAY_TEXT} </txt>"
echo "<tool>위치: ${LOCATION_NAME}\n클릭 시 Open-Meteo 기상 웹페이지 이동</tool>"
echo "<click>xdg-open https://open-meteo.com/en/docs</click>"