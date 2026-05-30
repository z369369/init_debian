#!/usr/bin/env bash
# dedupe-by-hash.sh — 중복 파일을 해시로 식별 후 삭제
# 한글/공백/특수문자 모두 안전하게 처리됨 (UTF-8 환경 기준)

set -euo pipefail
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

DRY_RUN=1
INTERACTIVE=0
KEEP="newest"
ALGO="sha256"
VERBOSE=0

usage() {
cat <<EOF
사용법: $0 [옵션] <폴더>
옵션:
  -n, --dry-run       실제로 삭제하지 않고 목록만 출력 (기본값)
  -y, --yes           물어보지 않고 자동 삭제
  -i, --interactive   파일별로 삭제 여부를 물어봄
  -k, --keep [newest|oldest]  중복 중 어느 파일을 남길지 (기본 newest)
  -a, --algo [sha256|md5]     해시 알고리즘 (기본 sha256)
  -v, --verbose       상세 출력
EOF
exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -y|--yes) DRY_RUN=0; INTERACTIVE=0; AUTO=1; shift ;;
    -i|--interactive) DRY_RUN=0; INTERACTIVE=1; AUTO=0; shift ;;
    -k|--keep)
      shift; KEEP="$1"; shift ;;
    -a|--algo)
      shift; ALGO="$1"; shift ;;
    -v|--verbose) VERBOSE=1; shift ;;
    -h|--help) usage ;;
    *) TARGET_DIR="$1"; shift ;;
  esac
done

[[ -z "${TARGET_DIR:-}" ]] && { echo "폴더 경로를 지정하세요."; exit 1; }
[[ ! -d "$TARGET_DIR" ]] && { echo "폴더가 아닙니다: $TARGET_DIR"; exit 1; }

if [[ "$ALGO" == "sha256" ]]; then
  SUMCMD="sha256sum"
elif [[ "$ALGO" == "md5" ]]; then
  SUMCMD="md5sum"
else
  echo "지원하지 않는 해시 알고리즘: $ALGO"
  exit 1
fi

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "📁 스캔 중... (한글 파일명 포함)" >&2

# 파일 목록 생성 (NUL 분리, 한글 지원)
find "$TARGET_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  hash=$($SUMCMD -- "$f" | awk '{print $1}')
  mtime=$(stat -c %Y -- "$f")
  printf "%s\t%s\t%s\0" "$hash" "$mtime" "$f"
done > "$TMPFILE"

echo "🔍 중복 검사 중..." >&2

# 중복 그룹 찾기 (한글 안전)
awk -v keep="$KEEP" -v dryrun="$DRY_RUN" -v interactive="$INTERACTIVE" -v verbose="$VERBOSE" -F '\t' '
  BEGIN { RS="\0"; OFS="\t" }
  {
    hash=$1; mtime=$2; file=$3
    files[hash]=files[hash] mtime "\t" file "\n"
  }
  END {
    for (h in files) {
      n=split(files[h], arr, "\n")
      if (n <= 1) continue

      newest=0; oldest=9999999999
      for (i=1;i<=n;i++) {
        if (arr[i]=="") continue
        split(arr[i], p, "\t")
        m=p[1]; f=p[2]
        if (keep=="newest" && m>newest) { newest=m; keepf=f }
        if (keep=="oldest" && m<oldest) { oldest=m; keepf=f }
        all_files[i]=f
      }

      print "🔸 해시 중복 그룹:"
      print "   보존 파일 → " keepf
      for (i=1;i<=n;i++) {
        if (arr[i]=="" || all_files[i]==keepf) continue
        del=all_files[i]
        if (interactive==1) {
          printf "삭제할까요? [%s] (y/N): ", del
          getline ans < "/dev/tty"
          if (ans=="y" || ans=="Y") {
            if (dryrun==1) print " (미리보기) 삭제됨:", del
            else { system("rm -v -- \"" del "\"") }
          } else print "건너뜀:", del
        } else {
          if (dryrun==1) print " (미리보기) 삭제될 파일:", del
          else { system("rm -v -- \"" del "\"") }
        }
      }
      print ""
    }
  }
' "$TMPFILE"

echo "✅ 완료되었습니다."

