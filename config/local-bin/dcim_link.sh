#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="/home/lwh/phone/DCIM"
DST_DIR="/home/lwh/Pictures"
PREFIX="DCIM_"

if [[ ! -d "$DST_DIR" ]]; then
    mkdir -p "$DST_DIR"
fi

echo "=== 심볼릭 링크 동기화 및 정리 시작 ==="

# 1. 원본 폴더 기준 심볼릭 링크 생성 및 갱신
if [[ -d "$SRC_DIR" ]]; then
    for target in "$SRC_DIR"/*; do
        if [[ -d "$target" ]]; then
            folder_name="$(basename "$target")"
            link_name="${DST_DIR}/${PREFIX}${folder_name}"

            # 기존 링크가 없거나, 바라보는 원본 경로가 바뀐 경우 강제(-f) 갱신/생성
            if [[ ! -L "$link_name" || "$(readlink "$link_name")" != "$target" ]]; then
                ln -snf "$target" "$link_name"
                echo "링크 생성/갱신 완료: $link_name -> $target"
            fi
        fi
    done
fi

# 2. 끊어진 심볼릭 링크 정리
for link in "${DST_DIR}/${PREFIX}"*; do
    [[ -e "$link" || -L "$link" ]] || continue

    if [[ -L "$link" ]]; then
        if [[ ! -e "$link" ]]; then
            rm "$link"
            echo "끊어진 링크 삭제 완료: $link"
        fi
    fi
done

echo "=== 작업 완료 ==="