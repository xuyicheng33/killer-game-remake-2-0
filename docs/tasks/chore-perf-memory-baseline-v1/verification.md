# Task: chore-perf-memory-baseline-v1

## Verification Summary

**Date**: 2026-02-20
**Status**: COMPLETED

## Files Created

1. `dev/tools/perf_baseline.sh` - Performance baseline collection script
2. `dev/tools/memory_baseline.sh` - Memory baseline collection script
3. `dev/tools/soak_test.sh` - Soak test for memory leak detection
4. `dev/tools/baselines/` - Output directory for baseline files

## Implementation Details

### perf_baseline.sh
- Runs GUT tests multiple times (default 5)
- Measures execution time for each run
- Calculates average, min, max
- Outputs to `dev/tools/baselines/perf_baseline.txt`

### memory_baseline.sh
- Runs GUT tests with `--debug-stringnames` for memory tracking
- Captures: Tests Passed, Exit Code, Orphan StringName stats, Unclaimed Strings
- GUT Orphan Reports detected via precise regex (excludes test names)
- Outputs to `dev/tools/baselines/memory_baseline.txt`

### soak_test.sh
- Runs multiple game cycles (default 10)
- Tracks execution time and memory metrics per cycle
- Detects memory regressions over time
- Outputs to `dev/tools/baselines/soak_test_report.txt`

## Usage

```bash
# Performance baseline
bash dev/tools/perf_baseline.sh [iterations]

# Memory baseline
bash dev/tools/memory_baseline.sh

# Soak test
bash dev/tools/soak_test.sh [cycles]
```

## Acceptance Criteria

- [x] perf_baseline.sh is executable
- [x] memory_baseline.sh is executable
- [x] soak_test.sh is executable
- [x] All scripts output baseline data
- [x] macOS compatibility (no grep -P)
