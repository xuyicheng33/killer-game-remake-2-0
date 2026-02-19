#!/bin/bash
# soak_test.sh - Run multiple game cycles to detect memory leaks
# Usage: bash dev/tools/soak_test.sh [cycles]
#
# Output: dev/tools/baselines/soak_test_report.txt
#
# Note: Godot 4.x headless mode has limited memory diagnostics.
# This script tracks:
# - Test execution time per cycle
# - Orphan StringName statistics
# - Exit codes to detect crashes

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
CYCLES="${1:-10}"
BASELINE_DIR="dev/tools/baselines"
REPORT_FILE="${BASELINE_DIR}/soak_test_report.txt"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Avoid Godot log path crash on macOS
export HOME=/tmp

echo "[SOAK] Starting soak test (cycles: ${CYCLES})..."

# Create baseline directory if needed
mkdir -p "$BASELINE_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOF
# Soak Test Report
# Generated: $(date)
# Cycles: $CYCLES

## Execution Per Cycle

EOF

TOTAL_START=$(date +%s)

for i in $(seq 1 "$CYCLES"); do
    echo "[SOAK] Cycle $i/$CYCLES..."

    CYCLE_LOG="$(mktemp -t soak_cycle.XXXXXX)"

    CYCLE_START=$(date +%s.%N)

    # Run test suite and capture memory info
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
        -gexit >"$CYCLE_LOG" 2>&1
    GODOT_EXIT=$?
    set -e

    CYCLE_END=$(date +%s.%N)
    CYCLE_TIME=$(echo "$CYCLE_END - $CYCLE_START" | bc 2>/dev/null || echo "0")

    if [ $GODOT_EXIT -ne 0 ]; then
        echo "[SOAK] WARNING: Cycle $i Godot exited with code $GODOT_EXIT"
    fi

    # Extract test results (format: "Tests               131" and "Passing Tests       131")
    TESTS_PASSED=$(sed -n 's/^Passing Tests[[:space:]]*\([0-9]*\).*/\1/p' "$CYCLE_LOG" | tail -1)
    TESTS_TOTAL=$(sed -n 's/^Tests[[:space:]]*\([0-9]*\).*/\1/p' "$CYCLE_LOG" | tail -1)

    # Extract orphan statistics (Godot 4.x format)
    UNCLAIMED_STRINGS=$(sed -n 's/.*StringName: \([0-9]*\) unclaimed string names at exit.*/\1/p' "$CYCLE_LOG" | tail -1)

    # Set defaults
    TESTS_PASSED=${TESTS_PASSED:-0}
    TESTS_TOTAL=${TESTS_TOTAL:-0}
    UNCLAIMED_STRINGS=${UNCLAIMED_STRINGS:-0}

    echo "Cycle $i: Exit=$GODOT_EXIT, Time=${CYCLE_TIME}s, Tests=${TESTS_PASSED}/${TESTS_TOTAL}, UnclaimedStrings=${UNCLAIMED_STRINGS}" >> "$REPORT_FILE"

    rm -f "$CYCLE_LOG"
done

TOTAL_END=$(date +%s)
TOTAL_TIME=$((TOTAL_END - TOTAL_START))

# Add summary
cat >> "$REPORT_FILE" << EOF

## Summary

- Total Time: ${TOTAL_TIME}s
- Cycles: $CYCLES
- Average Time per Cycle: $((TOTAL_TIME / CYCLES))s

## Leak Detection

If Unclaimed Strings increases over cycles, investigate:
1. StringName allocations not freed
2. Resource references not released
3. Static variables holding references

## Notes

- Godot 4.x headless has limited memory diagnostics
- Exit code should always be 0
- Unclaimed Strings should be stable (not increasing)
- Run this test after significant changes
- Compare reports to detect regressions
EOF

echo "[SOAK] Completed in ${TOTAL_TIME}s"
echo "[SOAK] Report: $REPORT_FILE"
