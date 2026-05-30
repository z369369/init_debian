#!/bin/bash

PACKAGE_FILE="/home/lwh/git/init_debian/install_package.list"
# 사용법: ./check_packages_no_comment.sh [패키지 목록 파일]

# 1. 파일 경로 확인 (기존과 동일)

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "오류: 파일 '$PACKAGE_FILE'을(를) 찾을 수 없습니다."
    exit 1
fi

echo "--- '$PACKAGE_FILE'에 있는 패키지 설치 상태 확인 (주석 무시) ---"

# 2. 파일의 각 줄을 읽어 패키지 이름 추출 및 설치 여부 확인
while IFS= read -r LINE; do
    
    # a. 주석 제거 및 공백 정리
    # 1) '#' 기호와 그 뒤의 모든 내용을 제거한다.
    # 2) 앞뒤의 공백/탭을 제거한다.
    PACKAGE_NAME=$(echo "$LINE" | sed 's/#.*//' | xargs)
    
    # b. 이름 추출 후 빈 줄이거나 주석만 있었던 줄은 건너뛰기
    if [ -z "$PACKAGE_NAME" ]; then
        continue
    fi

    # 3. dpkg를 사용하여 설치 상태 확인 (기존과 동일)
    # 'ii'는 'install ok installed'를 의미하며, 정상적으로 설치되었음을 나타냄.
    if dpkg -l | grep -q "^ii[[:space:]].*${PACKAGE_NAME}\b"; then
        echo "✅ 설치됨: ${PACKAGE_NAME}"
    else
        echo "❌ 미설치: ${PACKAGE_NAME}"
    fi
    
done < "$PACKAGE_FILE"

echo "--------------------------------------------------------"
