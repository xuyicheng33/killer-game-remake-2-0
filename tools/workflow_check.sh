#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_paths=(
  "docs/module_architecture.md"
  "docs/work_log.md"
  "docs/work_logs"
  "docs/task_plan_template.md"
  "docs/handoff_template.md"
  "docs/glossary.md"
  "docs/contracts"
  "docs/tasks"
  "Makefile"
)

missing_count=0
for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "[workflow-check] missing: $path" >&2
    missing_count=$((missing_count + 1))
  fi
done

if [[ "$missing_count" -gt 0 ]]; then
  echo "[workflow-check] failed: missing required scaffold files." >&2
  exit 1
fi

task_id="${TASK_ID:-}"
if [[ -z "$task_id" ]]; then
  echo "[workflow-check] failed: TASK_ID is required." >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[workflow-check] failed: current directory is not a git repository." >&2
  exit 1
fi

branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [[ -z "$branch" ]]; then
  echo "[workflow-check] failed: detached HEAD or invalid branch state." >&2
  exit 1
fi

branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'
if [[ "$branch" != "main" && ! "$branch" =~ $branch_pattern ]]; then
  echo "[workflow-check] failed: branch '$branch' does not match feat|fix|chore/<module>-<task-id>." >&2
  exit 1
fi

task_dir="docs/tasks/$task_id"
for f in plan.md handoff.md verification.md; do
  if [[ ! -f "$task_dir/$f" ]]; then
    echo "[workflow-check] failed: missing $task_dir/$f" >&2
    exit 1
  fi
done

plan_file="$task_dir/plan.md"
whitelist_patterns=()
while IFS= read -r line; do
  whitelist_patterns+=("$line")
done < <(
  awk '
    /^## .*白名单文件/ {in_block=1; next}
    /^## / && in_block {exit}
    in_block && /^- / {
      gsub(/^- /, "", $0)
      gsub(/`/, "", $0)
      if (length($0) > 0) print $0
    }
  ' "$plan_file"
)

if [[ "${#whitelist_patterns[@]}" -eq 0 ]]; then
  echo "[workflow-check] failed: $plan_file has empty whitelist section." >&2
  exit 1
fi

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  changed_files=()
  while IFS= read -r line; do
    changed_files+=("$line")
  done < <(
    {
      git -c core.quotepath=false diff --name-only --cached
      git -c core.quotepath=false diff --name-only
    } | sed '/^$/d' | sort -u
  )
else
  changed_files=()
  while IFS= read -r line; do
    changed_files+=("$line")
  done < <(
    git -c core.quotepath=false diff --name-only --cached | sed '/^$/d' | sort -u
  )
fi

if [[ "${#changed_files[@]}" -gt 0 ]]; then
  for file in "${changed_files[@]}"; do
    allowed=0
    for pattern in "${whitelist_patterns[@]}"; do
      pattern="${pattern#./}"
      if [[ "$file" == $pattern ]]; then
        allowed=1
        break
      fi
      if [[ "$file" == $pattern/* ]]; then
        allowed=1
        break
      fi
      if [[ "$pattern" == */ ]] && [[ "$file" == "$pattern"* ]]; then
        allowed=1
        break
      fi
    done

    if [[ "$allowed" -ne 1 ]]; then
      echo "[workflow-check] failed: '$file' is outside whitelist in $plan_file." >&2
      exit 1
    fi
  done
fi

echo "[workflow-check] passed."
