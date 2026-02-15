#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[install-hooks] failed: current directory is not a git repository." >&2
  echo "[install-hooks] run 'git init' first, then retry."
  exit 1
fi

HOOK_PATH=".git/hooks/pre-commit"

cat > "$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${TASK_ID:-}" ]]; then
  echo "[pre-commit] TASK_ID is required. Example: TASK_ID=feat-bootstrap-20260215 git commit -m '...'" >&2
  exit 1
fi
make workflow-check TASK_ID="$TASK_ID"
HOOK

chmod +x "$HOOK_PATH"
echo "[install-hooks] installed $HOOK_PATH"
