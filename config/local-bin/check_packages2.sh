#!/bin/bash

LIST_FILE="/home/lwh/git/init_debian/install_package.list"

if [ ! -f "$LIST_FILE" ]; then
    echo "오류: $LIST_FILE 파일이 존재하지 않습니다."
    exit 1
fi

echo -e "| 패키지 유형 | 패키지명 / ID | 설치 여부 |"
echo -e "| :--- | :--- | :--- |"

while IFS= read -r line || [ -n "$line" ]; do
    # 공백 제거 및 주석, 빈 줄, 구분 기호(*) 제외
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" == "#"* || "$line" == "*" ]] && continue

    # Flatpak 역도메인 형태(예: org.gnome..., com.discordapp...) 판별
    if [[ "$line" =~ ^[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+ ]]; then
        # [수정 포인트] --columns=application 옵션으로 ID만 정확히 추출하여 비교
        if flatpak list --columns=application | grep -q "^$line$"; then
            echo -e "| **Flatpak** | $line | \e[32m설치됨 (Installed)\e[0m |"
        else
            echo -e "| **Flatpak** | $line | \e[31m미설치 (Missing)\e[0m |"
        fi
    else
        # APT 패키지 설치 확인
        if dpkg-query -W -f='${Status}' "$line" 2>/dev/null | grep -q "ok installed"; then
            echo -e "| **APT** | $line | \e[32m설치됨 (Installed)\e[0m |"
        else
            echo -e "| **APT** | $line | \e[31m미설치 (Missing)\e[0m |"
        fi
    fi
done < "$LIST_FILE"