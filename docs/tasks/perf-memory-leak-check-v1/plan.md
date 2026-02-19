# Task: perf-memory-leak-check-v1

**Task ID**: 8-2a
**Level**: L1
**Status**: COMPLETED

## Objective

Create memory leak detection scripts using Godot's built-in diagnostics.

## Implementation Plan

### 1. Soak Test Script (`dev/tools/soak_test.sh`)

- Run 10 consecutive game sessions
- Record memory snapshot after each session
- Output memory usage report

### 2. Scene Switch Memory Test (`dev/tests/perf/test_scene_switch_memory.gd`)

- Test scene creation/destruction cycles
- Check for orphan nodes
- Verify object count stability

## Files to Create

- `dev/tools/soak_test.sh`
- `dev/tests/perf/test_scene_switch_memory.gd`

## Acceptance Criteria

- [x] Soak test script runs multiple game cycles
- [x] Memory report generated
- [x] Potential leak points identified (if any)
