#!/bin/bash

TARGET_DIR="/home/lwh/Documents"

# ANSI 색상 코드 정의 (GREEN: 녹색, NC: 색상 초기화)
GREEN='\033[0;32m'
NC='\033[0m'

# 1. Documents 디렉터리로 이동
cd "$TARGET_DIR" || exit

# 2. 변경된 사항(새 파일, 수정, 삭제)이 있는지 체크
if [ -z "$(git status --porcelain)" ]; then
    # 색상 적용을 위해 echo에 -e 옵션 사용
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] 변경된 문서가 없습니다.${NC}"
    exit 0
fi

# 3. 변경 사항 전체 반영 (git add .)
git add -A

# 4. 현재 날짜/시간을 메시지로 담아 커밋
COMMIT_MSG="Document updated: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG"

# 백업 완료 메시지를 녹색으로 출력
echo -e "${GREEN}=================================="
echo "백업 완료: $COMMIT_MSG"
echo -e "==================================${NC}"