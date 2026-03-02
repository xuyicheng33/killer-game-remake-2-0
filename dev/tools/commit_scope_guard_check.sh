#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[commit-scope-guard] failed: current directory is not a git repository." >&2
  exit 1
fi

collect_changed_files() {
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    {
      git -c core.quotepath=false diff --name-only --cached
      git -c core.quotepath=false diff --name-only
      git -c core.quotepath=false ls-files --others --exclude-standard
    }
  else
    {
      git -c core.quotepath=false diff --name-only --cached
      git -c core.quotepath=false ls-files --others --exclude-standard
    }
  fi
}

changed_files=()
while IFS= read -r line; do
  changed_files+=("$line")
done < <(collect_changed_files | sed '/^$/d' | sort -u)

if [[ "${#changed_files[@]}" -eq 0 ]]; then
  echo "[commit-scope-guard] passed: no local changes."
  exit 0
fi

map_domain() {
  local file="$1"
  case "$file" in
    runtime/*) echo "runtime" ;;
    content/*) echo "content" ;;
    dev/*) echo "dev" ;;
    docs/*) echo "docs" ;;
    references/*) echo "references" ;;
    *) echo "root" ;;
  esac
}

domains=()
for file in "${changed_files[@]}"; do
  domain="$(map_domain "$file")"
  domains+=("$domain")
done

changed_count="${#changed_files[@]}"
domain_count="$(
  printf "%s\n" "${domains[@]}" \
    | sed '/^$/d' \
    | sort -u \
    | wc -l \
    | tr -d ' '
)"

if (( changed_count > 80 )); then
  echo "[commit-scope-guard] failed: ${changed_count} files changed. Split this work into smaller commits/tasks." >&2
  exit 1
fi

if (( changed_count > 30 && domain_count > 2 )); then
  echo "[commit-scope-guard] failed: ${changed_count} files span ${domain_count} domains."
  echo "[commit-scope-guard] hint: separate runtime/dev/docs concerns into different commits." >&2
  exit 1
fi

echo "[commit-scope-guard] passed: ${changed_count} files across ${domain_count} domains."
