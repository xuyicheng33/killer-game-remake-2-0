#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

task_id="${1:-${TASK_ID:-}}"
if [[ -z "$task_id" ]]; then
  echo "[new-task] usage: make new-task TASK_ID=<task-id>" >&2
  exit 1
fi

task_dir="docs/tasks/$task_id"
mkdir -p "$task_dir"

copy_template_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ ! -f "$dst" ]]; then
    cp "$src" "$dst"
  fi
}

if [[ ! -f "$task_dir/plan.md" ]]; then
  copy_template_if_missing "docs/task_plan_template.md" "$task_dir/plan.md"
  printf "\n\n> 自动填充任务ID：\`%s\`\n" "$task_id" >> "$task_dir/plan.md"
fi

if [[ ! -f "$task_dir/handoff.md" ]]; then
  copy_template_if_missing "docs/handoff_template.md" "$task_dir/handoff.md"
  printf "\n\n> 自动填充任务ID：\`%s\`\n" "$task_id" >> "$task_dir/handoff.md"
fi

if [[ ! -f "$task_dir/verification.md" ]]; then
  cat > "$task_dir/verification.md" <<EOF
# 验证记录

## 步骤

1. 

## 结果

- 待验证
EOF
fi

echo "[new-task] created: $task_dir/{plan.md,handoff.md,verification.md}"
