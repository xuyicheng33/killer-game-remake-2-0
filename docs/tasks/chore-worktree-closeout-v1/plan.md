# Task: chore-worktree-closeout-v1

**Task ID**: chore-worktree-closeout-v1
**Level**: L1
**Status**: COMPLETED

## Objective

Close out the mixed worktree so it is directly verifiable and ready for task-based commits.

## Scope

- Fix default `make test` compatibility in `dev/tools/run_gut_tests.sh`
- Align task plans with actual delivery status and whitelist scope
- Add ignore rule for noisy baseline outputs
- Add closeout documentation and verification trail

## Files to Modify

- `.gitignore`
- `dev/tools/run_gut_tests.sh`
- `docs/tasks/feat-card-display-name-v1/plan.md`
- `docs/tasks/content-cards-chinese-v1/plan.md`
- `docs/tasks/feat-tooltip-extension-v1/plan.md`
- `docs/tasks/fix-tooltip-event-signature-v1/plan.md`
- `docs/tasks/chore-perf-memory-baseline-v1/plan.md`
- `docs/tasks/perf-memory-leak-check-v1/plan.md`
- `docs/tasks/perf-hotspot-optimization-v1/plan.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/chore-worktree-closeout-v1/plan.md`
- `docs/tasks/chore-worktree-closeout-v1/handoff.md`
- `docs/tasks/chore-worktree-closeout-v1/verification.md`

## Acceptance Criteria

- [x] `make test` passes without manual `HOME=/tmp`
- [x] Task plan statuses are aligned with completed work
- [x] Tooltip extension plan whitelist includes all touched files
- [x] Baseline output text files are ignored by git
- [x] Workflow gate and tests are re-verified
