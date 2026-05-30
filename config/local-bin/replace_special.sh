#!/bin/bash
#
# 스크립트 이름: rename_cleaner.sh
# 설명: 현재 디렉토리 및 모든 하위 디렉토리의 파일 및 폴더 이름을 재귀적으로 정리합니다.
#        공백, 괄호 ( ), 쉼표 , 만 밑줄(_)로 치환하고 중복 밑줄을 정리합니다.
#
# 사용법:
#   1. Dry-Run (실제 변경 없이 결과만 확인): ./rename_cleaner.sh --dry-run
#   2. 실제 실행: ./rename_cleaner.sh
#

# Dry-run 모드 설정 (기본값: false)
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=========================================================="
    echo "  Dry-Run 모드로 실행합니다. 실제 파일은 변경되지 않습니다."
    echo "=========================================================="
else
    echo "=========================================================="
    echo "  실제 파일 변경 모드로 실행합니다. 백업 후 실행을 권장합니다."
    echo "=========================================================="
fi

# Perl 의존성 확인
if ! command -v perl &> /dev/null; then
    echo "오류: 이 스크립트는 정규표현식 처리를 위해 'perl'이 필요합니다." >&2
    exit 1
fi

# 현재 디렉토리부터 시작하여 모든 파일과 디렉토리를 깊이 우선 탐색 (find -depth)
find . -depth -print0 | while IFS= read -r -d $'\0' OLD_PATH; do
    # 현재 디렉토리 '.'는 건너뜁니다.
    if [[ "$OLD_PATH" == "." ]]; then
        continue
    fi

    DIR_NAME=$(dirname "$OLD_PATH")
    OLD_BASE_NAME=$(basename "$OLD_PATH")
    NEW_BASE_NAME="$OLD_BASE_NAME"

    # LC_ALL=C.UTF-8 설정으로 한글(UTF-8)을 안정적으로 처리
    NEW_BASE_NAME=$(echo "$NEW_BASE_NAME" | LC_ALL=C.UTF-8 perl -pe '
        use utf8;
        
        # 1. 공백, 괄호 (, ), 쉼표 , 를 밑줄(_)로 치환
        s/[ (),]/_/g;

        # 2. 연속된 밑줄을 하나의 밑줄로 치환
        s/__+/_/g;

        # 3. 파일명 끝의 "_." 패턴을 "." 하나로 치환 (예: "파일명_.txt" -> "파일명.txt")
        s/_\.$/./g;

        # 4. 파일명 시작이나 끝에 남아있는 불필요한 밑줄 제거
        s/(^_+|_+$)//g;
    ')

    # 새로운 이름이 이전 이름과 다를 경우에만 처리합니다.
    if [[ "$OLD_BASE_NAME" != "$NEW_BASE_NAME" ]]; then
        if [[ -z "$NEW_BASE_NAME" ]]; then
            echo "SKIP: '$OLD_PATH'는 정리 후 파일 이름이 비어있어 건너뜁니다." >&2
            continue
        fi

        NEW_PATH="$DIR_NAME/$NEW_BASE_NAME"

        if $DRY_RUN; then
            echo "DRY RUN: '$OLD_PATH' -> '$NEW_PATH'"
        else
            # 이름 변경 실행
            mv -T "$OLD_PATH" "$NEW_PATH" 2>/dev/null

            if [ $? -eq 0 ]; then
                echo "SUCCESS: '$OLD_PATH' -> '$NEW_PATH'"
            else
                echo "ERROR: 이름 변경에 실패했습니다. '$OLD_PATH' -> '$NEW_PATH'" >&2
            fi
        fi
    fi

done

echo "=========================================================="
echo "작업 완료."
echo "=========================================================="
