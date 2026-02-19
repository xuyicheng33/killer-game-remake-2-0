#!/bin/bash
# memory_baseline.sh - Collect memory baseline metrics
# Usage: bash dev/tools/memory_baseline.sh
#
# Captures memory usage statistics using Godot's built-in diagnostics.
# Output: dev/tools/baselines/memory_baseline.txt
#
# Note: Godot 4.x headless mode has limited memory diagnostics.
# This script captures:
# - Test execution status
# - Orphan node warnings from logs
# - StringName statistics (via --debug-stringnames)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
BASELINE_DIR="dev/tools/baselines"
BASELINE_FILE="${BASELINE_DIR}/memory_baseline.txt"

# Avoid Godot log path crash on macOS
export HOME=/tmp

echo "[MEM] Collecting memory baseline..."

# Create baseline directory if needed
mkdir -p "$BASELINE_DIR"

LOG_FILE="$(mktemp -t memory_baseline.XXXXXX)"
trap 'rm -f "$LOG_FILE"' EXIT

# Run tests with debug-stringnames for memory tracking
# Note: We capture exit code but don't fail immediately to allow log analysis
set +e
$GODOT \
    --path "$ROOT_DIR" \
    --headless \
    --display-driver headless \
    --audio-driver Dummy \
    --debug-stringnames \
    -s addons/gut/gut_cmdln.gd \
    -gdir=res://dev/tests \
    -ginclude_subdirs \
    -gexit >"$LOG_FILE" 2>&1
GODOT_EXIT=$?
set -e

if [ $GODOT_EXIT -ne 0 ]; then
    echo "[MEM] WARNING: Godot exited with code $GODOT_EXIT"
fi

# Extract test results (format: "Tests               131" and "Passing Tests       131")
TESTS_PASSED=$(sed -n 's/^Passing Tests[[:space:]]*\([0-9]*\).*/\1/p' "$LOG_FILE" | tail -1)
TESTS_TOTAL=$(sed -n 's/^Tests[[:space:]]*\([0-9]*\).*/\1/p' "$LOG_FILE" | tail -1)

# Extract orphan warnings (Godot 4.x format: "Orphan StringName: ... (static: X, total: Y)")
ORPHAN_STRINGNAME=$(sed -n 's/.*Orphan StringName:.*static: \([0-9]*\), total: \([0-9]*\).*/\1\/\2/p' "$LOG_FILE" | tail -1)

# Extract unclaimed string names at exit
UNCLAIMED_STRINGS=$(sed -n 's/.*StringName: \([0-9]*\) unclaimed string names at exit.*/\1/p' "$LOG_FILE" | tail -1)

# Count GUT orphan reports (format: "[N] orphans" as standalone line, not in test names)
# GUT outputs orphan reports like: "  [5] orphans" (with indentation)
# We exclude lines that are test names (which start with "* test_")
# Note: grep -c returns count (even 0), but exit code 1 if no match on macOS
# We suppress the exit code issue with || true
set +e
GUT_ORPHANS=$(grep -cE '^\s*\[[0-9]+\] orphans$' "$LOG_FILE" 2>/dev/null)
set -e
# Ensure GUT_ORPHANS is a valid number
GUT_ORPHANS=${GUT_ORPHANS:-0}
# Trim any whitespace/newlines
GUT_ORPHANS=$(echo "$GUT_ORPHANS" | tr -d '[:space:]')

# Set defaults for missing values
TESTS_PASSED=${TESTS_PASSED:-0}
TESTS_TOTAL=${TESTS_TOTAL:-0}
ORPHAN_STRINGNAME=${ORPHAN_STRINGNAME:-"0/0"}
UNCLAIMED_STRINGS=${UNCLAIMED_STRINGS:-0}
GUT_ORPHANS=${GUT_ORPHANS:-0}

# Write baseline file
cat > "$BASELINE_FILE" << EOF
# Memory Baseline
# Generated: $(date)

## Test Results
- Tests Passed: ${TESTS_PASSED}/${TESTS_TOTAL}
- Exit Code: ${GODOT_EXIT}

## Memory Metrics (Godot 4.x Headless)
- Orphan StringName (static/total): ${ORPHAN_STRINGNAME}
- Unclaimed String Names at Exit: ${UNCLAIMED_STRINGS}
- GUT Orphan Reports: ${GUT_ORPHANS}

## Environment
- Godot: $($GODOT --version 2>/dev/null || echo "unknown")
- Platform: $(uname -s) $(uname -m)

## Acceptance Thresholds
- Tests Passed: should equal Tests Total
- Exit Code: should be 0
- Unclaimed String Names: should be 0 or stable across runs
- GUT Orphan Reports: should be 0

## Notes
- Godot 4.x headless has limited memory diagnostics compared to 3.x
- Use GUT's orphan_counter in tests for detailed orphan tracking
- Run this baseline after each significant change
- Compare values to detect memory regressions
EOF

echo "[MEM] Baseline written to $BASELINE_FILE"

# Report any issues found
if [ "$GODOT_EXIT" != "0" ]; then
    echo "[MEM] WARNING: Godot exited with non-zero code: $GODOT_EXIT"
fi

if [ "$UNCLAIMED_STRINGS" != "0" ]; then
    echo "[MEM] INFO: Unclaimed string names detected: $UNCLAIMED_STRINGS"
fi
