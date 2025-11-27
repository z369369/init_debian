#!/bin/bash

# --- 설정 변수 ---
# 1. CPU 코어 수 확인 (시스템마다 다름)
# nproc 명령이 없거나 오류가 발생하면 기본값 1을 사용합니다.
NUM_CORES=$(nproc 2>/dev/null || echo 1)

# 2. CPU 부하 임계값 설정 (전체 코어 대비 10% 미만)
# 예: 4코어 시스템에서 0.4 미만일 때 실행
THRESHOLD=$(echo "scale=2; $NUM_CORES * 0.1" | bc)

# --- 스크립트 본문 ---

# 1. 'uptime' 명령으로 로드 평균을 가져옵니다.
#    awk를 사용하여 1분 로드 평균(세 번째 값)만 추출합니다.
LOAD_AVG_1MIN=$(uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1}')

echo "시스템 코어 수: $NUM_CORES"
echo "부하 임계값 (1분 Load Avg): $THRESHOLD"
echo "현재 1분 Load Average: $LOAD_AVG_1MIN"

# 2. 로드 평균과 임계값을 비교합니다.
#    'bc'를 사용하여 소수점 비교를 수행합니다. (결과 1 = 참, 0 = 거짓)
#    "$LOAD_AVG_1MIN <= $THRESHOLD"
IS_IDLE=$(echo "$LOAD_AVG_1MIN < $THRESHOLD" | bc)

if [ "$IS_IDLE" -eq 1 ]; then
    echo "✅ CPU 부하($LOAD_AVG_1MIN)가 임계값($THRESHOLD) 미만입니다. 작업을 시작합니다."

    # ⬇️⬇️⬇️ 여기에 실행하고 싶은 명령을 넣으세요! ⬇️️⬇️️⬇️️
    
    # 💡 예시 1: 백업 스크립트 실행 (백그라운드 실행을 원하면 & 를 붙입니다)
    # /path/to/my_backup_script.sh &
    
    #update 
    cat /home/lwh/.key | sudo -S apt update -y
    cat /home/lwh/.key | sudo -S apt upgrade -y
    cat /home/lwh/.key | sudo -S apt autoremove -y
	flatpak uninstall --unused -y;
	flatpak upgrade --assumeyes --noninteractive | grep -v 'Info:';
	
    # 💡 예시 2: 로그 기록 및 파일 정리
    echo "$(date): 저부하 작업을 실행했습니다." 
    # find /tmp -type f -mtime +7 -delete # 7일 이상된 임시 파일 삭제
    
    # 이 작업이 완료되면 스크립트는 자동으로 종료됩니다.
    
else
    echo "❌ CPU 부하($LOAD_AVG_1MIN)가 임계값($THRESHOLD) 초과입니다. 작업을 건너뛰고 종료합니다."
fi

# 스크립트가 여기에 도달하면 종료됩니다.
