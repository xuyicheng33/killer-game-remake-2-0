#!/bin/bash
# run_gut_tests.sh - 运行 GUT 测试，带超时保护
# 用法: bash dev/tools/run_gut_tests.sh [timeout_seconds]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
TIMEOUT="${1:-60}"
LOG_FILE="$(mktemp -t gut_test_log.XXXXXX)"
trap 'rm -f "$LOG_FILE"' EXIT

echo "[GUT] Running tests (timeout: ${TIMEOUT}s)..."

# 在后台运行 Godot（显式关闭显示/音频，避免 macOS headless 阻塞）
$GODOT \
    --path "$ROOT_DIR" \
    --headless \
    --display-driver headless \
    --audio-driver Dummy \
    -s addons/gut/gut_cmdln.gd \
    -gdir=res://dev/tests \
    -ginclude_subdirs \
    -gexit >"$LOG_FILE" 2>&1 &
GODOT_PID=$!

# 等待并检查超时
ELAPSED=0
while kill -0 $GODOT_PID 2>/dev/null; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "[GUT] TIMEOUT: Killing Godot process after ${TIMEOUT}s"
        kill $GODOT_PID 2>/dev/null || true
        sleep 1
        kill -9 $GODOT_PID 2>/dev/null || true
        echo "[GUT] TIMEOUT: test process did not exit cleanly"
        exit 124
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

# 等待进程结束并获取退出码
set +e
wait $GODOT_PID
GODOT_EXIT=$?
set -e

cat "$LOG_FILE"

if [ $GODOT_EXIT -ne 0 ]; then
    echo "[GUT] FAILED: Godot exited with code ${GODOT_EXIT}"
    exit $GODOT_EXIT
fi

RUNTIME_ERROR_PATTERN='SCRIPT ERROR:|Node not found:|FreeType: Error loading font|ObjectDB instances leaked at exit|resources still in use at exit|Resource still in use'
if grep -E "$RUNTIME_ERROR_PATTERN" "$LOG_FILE" >/dev/null 2>&1; then
    echo "[GUT] FAILED: runtime errors detected in test log"
    grep -nE "$RUNTIME_ERROR_PATTERN" "$LOG_FILE" | head -50
    exit 1
fi

echo "[GUT] Tests completed"
