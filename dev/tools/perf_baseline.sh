#!/bin/bash
# perf_baseline.sh - Collect performance baseline metrics
# Usage: bash dev/tools/perf_baseline.sh [iterations]
#
# Measures frame timing during a simulated gameplay session.
# Output: dev/tools/baselines/perf_baseline.txt

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
ITERATIONS="${1:-5}"
BASELINE_DIR="dev/tools/baselines"
BASELINE_FILE="${BASELINE_DIR}/perf_baseline.txt"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Avoid Godot log path crash on macOS
export HOME=/tmp

echo "[PERF] Collecting performance baseline (iterations: ${ITERATIONS})..."

# Create baseline directory if needed
mkdir -p "$BASELINE_DIR"

# Run GUT tests to simulate gameplay load and capture timing
LOG_FILE="$(mktemp -t perf_baseline.XXXXXX)"
trap 'rm -f "$LOG_FILE"' EXIT

TOTAL_TIME=0
TIMES=()

for i in $(seq 1 "$ITERATIONS"); do
    echo "[PERF] Run $i/$ITERATIONS..."

    START_TIME=$(date +%s.%N)

    # Run tests with timing focus
    # Note: We capture exit code but don't fail immediately
    set +e
    $GODOT \
        --path "$ROOT_DIR" \
        --headless \
        --display-driver headless \
        --audio-driver Dummy \
        -s addons/gut/gut_cmdln.gd \
        -gdir=res://dev/tests \
        -ginclude_subdirs \
        -gexit >"$LOG_FILE" 2>&1
    GODOT_EXIT=$?
    set -e

    if [ $GODOT_EXIT -ne 0 ]; then
        echo "[PERF] WARNING: Run $i Godot exited with code $GODOT_EXIT"
    fi

    END_TIME=$(date +%s.%N)
    ELAPSED=$(echo "$END_TIME - $START_TIME" | bc)
    TIMES+=("$ELAPSED")
    TOTAL_TIME=$(echo "$TOTAL_TIME + $ELAPSED" | bc)
done

# Calculate average
AVG_TIME=$(echo "scale=2; $TOTAL_TIME / $ITERATIONS" | bc)

# Find min/max
MIN_TIME=${TIMES[0]}
MAX_TIME=${TIMES[0]}
for t in "${TIMES[@]}"; do
    if (( $(echo "$t < $MIN_TIME" | bc -l) )); then
        MIN_TIME=$t
    fi
    if (( $(echo "$t > $MAX_TIME" | bc -l) )); then
        MAX_TIME=$t
    fi
done

# Write baseline file
cat > "$BASELINE_FILE" << EOF
# Performance Baseline
# Generated: $(date)
# Iterations: $ITERATIONS

## Test Suite Execution Time (seconds)
- Average: ${AVG_TIME}s
- Min: ${MIN_TIME}s
- Max: ${MAX_TIME}s
- Raw: ${TIMES[*]}

## Environment
- Godot: $($GODOT --version 2>/dev/null || echo "unknown")
- Platform: $(uname -s) $(uname -m)
- Resolution: headless

## Notes
- Lower is better
- Use this baseline to detect performance regressions
EOF

echo "[PERF] Baseline written to $BASELINE_FILE"
echo "[PERF] Average test time: ${AVG_TIME}s"
