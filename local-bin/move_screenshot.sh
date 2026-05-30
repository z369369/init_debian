#!/bin/bash

# --- 설정 변수 ---
# 파일을 찾을 루트 디렉토리
ROOT_DIR="/home/lwh/Pictures/Pictures에 링크"
# 이동될 대상 디렉토리 (최종 스크린샷 저장소)
DEST_DIR="/home/lwh/Pictures/스크린샷"

# 확인해야 할 스크린샷 서브 디렉토리 목록
SOURCE_DIRS=(
    "스크린샷"
    "Screenshot"
    "Screenshots"
    "screenshot"
    "screenshots"
)

# -----------------

echo "🚀 스크린샷 파일 이동을 시작합니다."
echo "⚠️ 대상 디렉토리 '$DEST_DIR'이(가) 존재한다고 가정하고 진행합니다."

# 지정된 소스 디렉토리를 순회하며 작업
for SUB_DIR in "${SOURCE_DIRS[@]}"; do
    SOURCE_PATH="$ROOT_DIR/$SUB_DIR"

    # 1. 소스 디렉토리가 존재하는지 (체크)
    if [ -d "$SOURCE_PATH" ]; then
        echo "🔍 소스 디렉토리 '$SOURCE_PATH'이(가) 존재합니다. 파일을 확인합니다."

        # 2. 해당 디렉토리에 파일이 있는지 확인
        if compgen -G "$SOURCE_PATH/*" > /dev/null; then
            echo "✅ 파일이 발견되었습니다. 이동 (강제 덮어쓰기)을 시작합니다..."
            
            # -f: 강제 덮어쓰기 (묻지 않음)
            # -v: 이동하는 파일명을 출력
            mv -f -v "$SOURCE_PATH"/* "$DEST_DIR/"
        else
            echo "ℹ️ 디렉토리 '$SOURCE_PATH'는 비어있습니다. 건너뜁니다."
        fi
    else
        # 3. 소스 디렉토리가 존재하지 않으면 (패스)
        echo "➡️ 소스 디렉토리 '$SOURCE_PATH'는 존재하지 않습니다. 패스합니다."
    fi
done

echo "🎉 스크립트 실행이 완료되었습니다."
