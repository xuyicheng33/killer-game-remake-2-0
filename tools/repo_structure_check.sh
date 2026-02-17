#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

errors=0

required_paths=(
  "README.md"
  "docs/repo_conventions.md"
  "docs/roadmap"
  "docs/roadmap/README.md"
  "docs/session"
  "docs/session/task_plan.md"
  "docs/session/findings.md"
  "docs/session/progress.md"
)

deprecated_paths=(
  "plan"
  "task_plan.md"
  "findings.md"
  "progress.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "[repo-structure-check] missing required path: $path" >&2
    errors=$((errors + 1))
  fi
done

for path in "${deprecated_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "[repo-structure-check] deprecated root path still exists: $path" >&2
    errors=$((errors + 1))
  fi
done

if [[ "$errors" -gt 0 ]]; then
  echo "[repo-structure-check] failed with $errors issue(s)." >&2
  exit 1
fi

echo "[repo-structure-check] passed."
