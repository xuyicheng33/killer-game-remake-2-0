#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REF_DIR="$ROOT_DIR/references/slay_the_spire_cn"
OUT_DIR="$ROOT_DIR/docs/reference_index"
INDEX_FILE="$OUT_DIR/index.md"
DUP_FILE="$OUT_DIR/duplicate_filenames.md"

if [[ ! -d "$REF_DIR" ]]; then
  echo "[content-index] missing reference directory: $REF_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

total_files="$(find "$REF_DIR" -type f | wc -l | tr -d ' ')"
txt_files="$(find "$REF_DIR" -type f -name '*.txt' | wc -l | tr -d ' ')"
generated_at="$(date '+%Y-%m-%d %H:%M:%S')"

{
  echo "# 参考资料索引"
  echo
  echo "- 生成时间：$generated_at"
  echo "- 文件总数：$total_files"
  echo "- TXT 文件数：$txt_files"
  echo
  echo "## 一级目录统计（TXT）"
  while IFS= read -r dir; do
    count="$(find "$dir" -type f -name '*.txt' | wc -l | tr -d ' ')"
    echo "- $(basename "$dir"): $count"
  done < <(find "$REF_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
  echo
  echo "## 文件清单（TXT）"
  find "$REF_DIR" -type f -name '*.txt' | sed "s|^$ROOT_DIR/||" | sort | sed 's/^/- /'
} > "$INDEX_FILE"

{
  echo "# 重名文件报告"
  echo
  if find "$REF_DIR" -type f -name '*.txt' -exec basename {} \; | sort | uniq -cd | grep -q .; then
    find "$REF_DIR" -type f -name '*.txt' -exec basename {} \; | sort | uniq -cd \
      | awk '{ printf("- %s (x%s)\n", $2, $1) }'
  else
    echo "- 未检测到重名 TXT 文件。"
  fi
} > "$DUP_FILE"

echo "[content-index] generated:"
echo "  - $INDEX_FILE"
echo "  - $DUP_FILE"
