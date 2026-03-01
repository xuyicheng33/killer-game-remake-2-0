#!/bin/bash
# run_gut_test_file.sh - 运行单个 GUT 测试文件，带超时保护
# 用法: bash dev/tools/run_gut_test_file.sh <test_script_path> [timeout_seconds]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [ $# -lt 1 ]; then
	echo "Usage: bash dev/tools/run_gut_test_file.sh <test_script_path> [timeout_seconds]"
	exit 1
fi

TEST_SCRIPT_PATH="$1"
TIMEOUT="${2:-120}"
GODOT="${GODOT:-godot}"
LOG_FILE="$(mktemp -t gut_single_test_log.XXXXXX)"
trap 'rm -f "$LOG_FILE"' EXIT

# On macOS, using a stable temp HOME avoids first-run Abort trap in headless mode.
_default_home_root="${TMPDIR:-/tmp}"
_default_home_root="${_default_home_root%/}"
GODOT_HOME="${STS_GODOT_HOME:-${_default_home_root}/sts_godot_home}"
export HOME="$GODOT_HOME"
mkdir -p "$HOME" >/dev/null 2>&1 || true

echo "[GUT] Running single test (timeout: ${TIMEOUT}s)..."
echo "[GUT] Test file: ${TEST_SCRIPT_PATH}"
echo "[GUT] Using HOME=${HOME}"

run_godot_once() {
	$GODOT \
		--path "$ROOT_DIR" \
		--headless \
		--display-driver headless \
		--audio-driver Dummy \
		-s addons/gut/gut_cmdln.gd \
		-gtest="${TEST_SCRIPT_PATH}" \
		-gexit >"$LOG_FILE" 2>&1 &
	GODOT_PID=$!

	ELAPSED=0
	while kill -0 $GODOT_PID 2>/dev/null; do
		if [ $ELAPSED -ge $TIMEOUT ]; then
			echo "[GUT] TIMEOUT: Killing Godot process after ${TIMEOUT}s"
			kill $GODOT_PID 2>/dev/null || true
			sleep 1
			kill -9 $GODOT_PID 2>/dev/null || true
			echo "[GUT] TIMEOUT: test process did not exit cleanly"
			return 124
		fi
		sleep 1
		ELAPSED=$((ELAPSED + 1))
	done

	if wait $GODOT_PID; then
		GODOT_EXIT=0
	else
		GODOT_EXIT=$?
	fi
	return $GODOT_EXIT
}

if run_godot_once; then
	GODOT_EXIT=0
else
	GODOT_EXIT=$?
fi

if [ $GODOT_EXIT -ne 0 ] && grep -q "Failed to open 'user://logs/" "$LOG_FILE"; then
	echo "[GUT] Retrying with backup HOME=/tmp/sts_godot_home after user://logs failure"
	export HOME=/tmp/sts_godot_home
	mkdir -p "$HOME" >/dev/null 2>&1 || true
	echo "[GUT] Using HOME=${HOME}"
	if run_godot_once; then
		GODOT_EXIT=0
	else
		GODOT_EXIT=$?
	fi
fi

cat "$LOG_FILE"

if [ $GODOT_EXIT -ne 0 ]; then
	echo "[GUT] FAILED: Godot exited with code ${GODOT_EXIT}"
	exit $GODOT_EXIT
fi

RUNTIME_ERROR_PATTERN='SCRIPT ERROR:|Node not found:|FreeType: Error loading font'
if grep -E "$RUNTIME_ERROR_PATTERN" "$LOG_FILE" >/dev/null 2>&1; then
	echo "[GUT] FAILED: runtime errors detected in test log"
	grep -nE "$RUNTIME_ERROR_PATTERN" "$LOG_FILE" | head -50
	exit 1
fi

echo "[GUT] Single test completed"
