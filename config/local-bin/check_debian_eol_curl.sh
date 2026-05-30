#!/bin/bash

# ==============================================================================
# Debian EOL Check Script (JSON 필드: extendedSupport 만 사용)
# ==============================================================================

# 1. 현재 주 버전 확인
CURRENT_VERSION=$(cat /etc/debian_version 2>/dev/null | sed 's/\..*//g')

# 주 버전이 숫자가 아니거나 파일이 없으면 종료
if ! [[ "$CURRENT_VERSION" =~ ^[0-9]+$ ]]; then
    exit 0
fi

# 2. endoflife.date API에서 EOL 정보 가져오기
API_URL="https://endoflife.date/api/debian/${CURRENT_VERSION}.json"
JSON_DATA=$(curl -s --fail "$API_URL")

# curl 실패 확인
if [ $? -ne 0 ] || [ -z "$JSON_DATA" ]; then
    echo -e "\033[1;31m[경고] EOL 정보를 가져오는 데 실패했습니다. 네트워크 연결을 확인하십시오.\033[0m"
    exit 1
fi

# 3. 'extendedSupport' 필드에서 만료일 추출 (요청하신 정확한 필드 이름)
# 필드 이름에 하이픈(-)이 없으므로, 따옴표 없이도 작동할 수 있지만, 안전을 위해 사용합니다.
EOL_DATE=$(echo "$JSON_DATA" | jq -r '."extendedSupport"' 2>/dev/null)
EOL_TYPE="확장"

# 'extendedSupport' 필드에 유효한 날짜 정보가 없는 경우, 사용자에게 알리고 종료
if [[ "$EOL_DATE" == "null" ]] || [[ "$EOL_DATE" == "false" ]] || [[ -z "$EOL_DATE" ]]; then
    echo -e "\033[1;36m[정보] ${CURRENT_VERSION}에 대한 ${EOL_TYPE} EOL 정보를 API에서 찾을 수 없습니다. API 필드 이름을 확인해 보세요.\033[0m"
    exit 0
fi


# 4. 날짜 계산 및 정보 출력
# GNU date를 사용하여 Unix timestamp로 변환
EOL_TS=$(date -d "$EOL_DATE" +%s 2>/dev/null)
NOW_TS=$(date +%s)

if [ $? -ne 0 ] || [ -z "$EOL_TS" ]; then
    echo -e "\033[1;31m[경고] EOL 날짜 (${EOL_DATE}) 처리 오류. 날짜 형식을 확인하십시오.\033[0m"
    exit 1
fi

DIFF_SECONDS=$((EOL_TS - NOW_TS))
DAYS_REMAINING=$((DIFF_SECONDS / 86400))
WARNING_THRESHOLD=90 # 3개월

# 5. 상태에 따른 메시지 및 색상 설정
COLOR_RESET="\033[0m"
#MESSAGE_PREFIX="📣 [Debian ${EOL_TYPE} EOL 정보] "
MESSAGE_PREFIX="📣 "
FINAL_MESSAGE=""

if [[ $DAYS_REMAINING -le $WARNING_THRESHOLD ]]; then
    if [[ $DAYS_REMAINING -lt 0 ]]; then
        # 🔴 지원 종료됨 (Red/Bold)
        COLOR_CODE="\033[1;31m"
        FINAL_MESSAGE="${MESSAGE_PREFIX}경고! ${CURRENT_VERSION} (${EOL_TYPE} EOL: ${EOL_DATE})은 이미 **지원 기간이 종료**되었습니다. 즉시 업그레이드를 고려하십시오! ⚠️"
    elif [[ $DAYS_REMAINING -eq 0 ]]; then
        # ⚠️ 오늘 종료 (Red/Bold)
        COLOR_CODE="\033[1;31m"
        FINAL_MESSAGE="${MESSAGE_PREFIX}오늘! ${CURRENT_VERSION} (${EOL_TYPE} EOL: ${EOL_DATE})의 **지원 기간이 종료**됩니다. ⚠️"
    else
        # 🟡 6개월 이내 (Yellow/Bold)
        COLOR_CODE="\033[1;33m"
        FINAL_MESSAGE="${MESSAGE_PREFIX}${CURRENT_VERSION}의 ${EOL_TYPE} 지원이 \
${EOL_DATE} (${DAYS_REMAINING}일 남음)에 종료됩니다. **업그레이드를 계획하십시오!**"
    fi
else
    # ⚫ 안전 기간 (기본 색상)
    COLOR_CODE=$COLOR_RESET
    FINAL_MESSAGE="${MESSAGE_PREFIX}${CURRENT_VERSION}의 ${EOL_TYPE} 지원은 ${EOL_DATE}에 종료됩니다. 남은 기간: ${DAYS_REMAINING}일"
fi

# 6. 터미널에 메시지 출력
echo -e "${COLOR_CODE}${FINAL_MESSAGE}${COLOR_RESET}"

exit 0