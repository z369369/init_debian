#!/usr/bin/env bash

# ==============================================================================
# Debian 13 XFCE - Duplicate File Finder Script
# 현재 폴더(및 하위 폴더)의 SHA-256 해시를 비교하여 중복 파일 목록을 출력합니다.
# ==============================================================================

# 작업 디렉토리 설정 (기본값: 현재 폴더)
TARGET_DIR="."

echo -e "\n🔍 **[1/2] 파일 해시 계산 중...** (파일 수에 따라 시간이 소요될 수 있습니다)\n"

# 1. find로 파일 목록 추출 (빈 파일 제외)
# 2. sha256sum으로 해시 계산
# 3. awk를 사용하여 동일한 해시를 가진 파일들을 그룹화하여 출력
find "$TARGET_DIR" -type f ! -empty -exec sha256sum {} + 2>/dev/null | \
awk '
{
    hash = $1
    # 파일명에 공백이 포함된 경우 처리
    $1 = ""
    sub(/^ /, "", $0)
    file = $0

    count[hash]++
    files[hash] = files[hash] "\n  - `" file "`"
}
END {
    found = 0
    print "## 📋 중복 파일 검사 결과\n"
    
    for (hash in count) {
        if (count[hash] > 1) {
            found++
            print "### 🔴 중복 그룹 #" found " (SHA-256: `" substr(hash, 1, 12) "...`)"
            print files[hash]
            print ""
        }
    }
    
    if (found == 0) {
        print "✅ 중복된 파일이 발견되지 않았습니다."
    } else {
        print "---"
        print "**총 " found "개의 중복 파일 그룹이 발견되었습니다.**"
    }
}
'