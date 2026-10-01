#!/usr/bin/env bash
# @DESC: downsub 스크립트의 파일 이름 불필요한 부분 정리하기
# @TAGS: obsidian, youtube, script, file renamer
# @USAGE: rename_downsub.sh
# @STATUS: 사용중

# rename_move_transcripts.sh
#
# 1) /home/lwh/Downloads/Download_phone/ 안의 .txt 파일들에서
#    - 공통 패턴 "[Korean (auto-generated)] " (접두사) 제거
#    - 공통 패턴 " [DownSub.com" (확장자 앞 접미사) 제거
#    - 남은 파일명에서 대괄호 [ ] 모두 제거
#    - 확장자를 .md 로 변경
#    - 파일명 앞뒤 공백 제거 (+ 중복 공백 정리)
# 2) 처리된 파일을 /home/lwh/Documents/001_Brain_Notes/50_inbox/script_src/ 로 이동
#
# 사용법:
#   ./rename_move_transcripts.sh          # 실제 실행
#   ./rename_move_transcripts.sh --dry-run  # 미리보기만 (파일 변경 없음)

set -euo pipefail

SRC_DIR="/home/lwh/Downloads/Download_phone"
DEST_DIR="/home/lwh/Documents/001_Brain_Notes/50_inbox/script_src"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[DRY RUN] 실제 파일은 변경되지 않습니다."
fi

mkdir -p "$DEST_DIR"

shopt -s nullglob

count=0

for f in "$SRC_DIR"/*.txt; do
  base="$(basename "$f")"
  name="${base%.txt}"

  # 1) 공통 접두사 제거: "[Korean (auto-generated)] "
  name="${name#\[Korean (auto-generated)\] }"

  # 2) 공통 접미사 제거: " [DownSub.com"
  name="${name% \[DownSub.com}"

  # 3) 남은 대괄호 문자 전부 제거
  name="${name//[\[\]]/}"

  # 4) 중복 공백을 하나로 정리
  name="$(echo -n "$name" | sed -E 's/[[:space:]]+/ /g')"

  # 5) 앞뒤 공백 제거
  name="$(echo -n "$name" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  new_name="${name}.md"
  dest_path="$DEST_DIR/$new_name"

  if [[ -e "$dest_path" ]]; then
    echo "경고: 대상에 동일한 이름의 파일이 이미 존재합니다. 건너뜁니다 -> $new_name"
    continue
  fi

  echo "$base"
  echo "  -> $new_name"

  if ! $DRY_RUN; then
    mv -- "$f" "$dest_path"
  fi

  ((count++)) || true
done

echo ""
echo "처리된 파일 수: $count"
if $DRY_RUN; then
  echo "(dry-run 모드였으므로 실제로 이동/변경된 파일은 없습니다)"
fi