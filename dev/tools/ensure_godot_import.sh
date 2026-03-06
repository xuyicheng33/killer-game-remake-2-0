#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
IMPORT_TIMEOUT="${STS_GODOT_IMPORT_TIMEOUT:-180}"
STAMP_FILE="${STS_GODOT_IMPORT_STAMP:-${HOME}/.sts_godot_import_$(basename "$ROOT_DIR").stamp}"

mkdir -p "$(dirname "$STAMP_FILE")"

latest_source_mtime="$(python3 - <<'PY'
from pathlib import Path

roots = [
    Path('project.godot'),
    Path('runtime'),
    Path('content'),
    Path('dev/tests'),
    Path('addons/gut'),
]
latest = 0.0
for root in roots:
    if not root.exists():
        continue
    if root.is_file():
        latest = max(latest, root.stat().st_mtime)
        continue
    for path in root.rglob('*'):
        if path.is_file():
            latest = max(latest, path.stat().st_mtime)
print(int(latest))
PY
)"

stamp_mtime="0"
if [ -f "$STAMP_FILE" ]; then
	stamp_mtime="$(python3 - "$STAMP_FILE" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
print(int(path.stat().st_mtime) if path.exists() else 0)
PY
)"
fi

if [ "$stamp_mtime" -ge "$latest_source_mtime" ]; then
	echo "[godot-import] up to date: $STAMP_FILE"
	exit 0
fi

echo "[godot-import] importing project metadata..."
LOG_FILE="$(mktemp -t godot_import_log.XXXXXX)"
trap 'rm -f "$LOG_FILE"' EXIT

"$GODOT" --headless --path "$ROOT_DIR" --import >"$LOG_FILE" 2>&1 &
GODOT_PID=$!
ELAPSED=0
while kill -0 "$GODOT_PID" 2>/dev/null; do
	if [ "$ELAPSED" -ge "$IMPORT_TIMEOUT" ]; then
		echo "[godot-import] TIMEOUT after ${IMPORT_TIMEOUT}s"
		kill "$GODOT_PID" 2>/dev/null || true
		sleep 1
		kill -9 "$GODOT_PID" 2>/dev/null || true
		cat "$LOG_FILE"
		exit 124
	fi
	sleep 1
	ELAPSED=$((ELAPSED + 1))
done

if ! wait "$GODOT_PID"; then
	cat "$LOG_FILE"
	exit 1
fi

cat "$LOG_FILE"
touch "$STAMP_FILE"
echo "[godot-import] completed"
