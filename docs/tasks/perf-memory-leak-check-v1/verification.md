# Task: perf-memory-leak-check-v1

## Verification Summary

**Date**: 2026-02-20
**Status**: COMPLETED

## Files Created

### 1. Soak Test Script (`dev/tools/soak_test.sh`)

- Runs N game cycles (default 10)
- Records memory metrics per cycle
- Detects orphan nodes and leaks
- Outputs report to `dev/tools/baselines/soak_test_report.txt`

### 2. Memory Test Suite (`dev/tests/perf/test_scene_switch_memory.gd`)

5 new test cases:
- `test_scene_instantiation_no_orphans` - Verifies scene creation doesn't create orphans
- `test_card_creation_no_leaks` - Verifies Card resource creation is clean
- `test_resource_loading_no_leaks` - Verifies resource loading doesn't grow memory
- `test_signal_connections_cleanup` - Verifies signal connections are cleaned
- `test_run_state_memory_stability` - Verifies basic object creation is clean

## Test Results

- All 131 tests pass (5 new memory tests included)
- Test count increased from 126 to 131
- Assert count: 798

## Godot 4 Performance Monitor Indices

```gdscript
const MONITOR_OBJECT_COUNT := 0
const MONITOR_ORPHAN_NODES := 14
const MONITOR_STATIC_MEMORY := 6
```

## Usage

```bash
# Run soak test (10 cycles)
bash dev/tools/soak_test.sh

# Run soak test (20 cycles)
bash dev/tools/soak_test.sh 20
```

## Acceptance Criteria

- [x] Soak test script runs multiple game cycles
- [x] Memory report generated
- [x] Memory test suite added to GUT tests
