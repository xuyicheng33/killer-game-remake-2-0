# Task: chore-perf-memory-baseline-v1

**Task ID**: 7A-0
**Level**: L1
**Status**: COMPLETED

## Objective

Create baseline scripts to establish performance and memory metrics for future optimization work.

## Implementation Plan

### 1. Performance Baseline Script (`dev/tools/perf_baseline.sh`)

- Create executable shell script
- Run Godot with profiling enabled
- Capture frame timing data
- Output to baseline file

### 2. Memory Baseline Script (`dev/tools/memory_baseline.sh`)

- Create executable shell script
- Use Godot's built-in memory diagnostics
- Capture Static Memory, Object Count, Orphan Nodes
- Output to baseline file

## Files to Create

- `dev/tools/perf_baseline.sh` (new)
- `dev/tools/memory_baseline.sh` (new)
- `dev/tools/soak_test.sh` (new)
- `dev/tools/baselines/` directory for output

## Acceptance Criteria

- [x] perf_baseline.sh is executable and outputs baseline data
- [x] memory_baseline.sh is executable and outputs baseline data
- [x] Baseline data recorded to files

## Notes

- Use `HOME=/tmp` to avoid Godot log path crash
- Test resolution: 1920x1080
- Multiple runs (5x) for average
