# 任务交接：chore-doc-baseline-sync-v1

## 基本信息

- 任务 ID：`chore-doc-baseline-sync-v1`
- 主模块：`docs`
- 提交人：`Codex`
- 日期：`2026-03-06`

## 改动摘要

- 更新 `README.md`：将当前重点切换为 Phase D 体验收口 + 非阻断工程问题清理，并补充 `make test` / `make ci-check` 的当前口径。
- 更新 `docs/roadmap/task_backlog.md`：把已进入真实基线的 A/B/C 任务状态改为 `done`，将 `art-ui-theme-rebuild-v1` 标记为 `in_progress`。
- 更新 `docs/session/findings.md`：新增 2026-03-06 文档口径说明，明确“当前真实基线”和“已知保留项”的统一表述方式。
- 补齐本任务三件套，便于后续审核与追踪。

## 变更文件

- `README.md`
- `docs/roadmap/task_backlog.md`
- `docs/session/findings.md`
- `docs/tasks/chore-doc-baseline-sync-v1/{plan,handoff,verification}.md`

## 验证结果

- [x] `make workflow-check TASK_ID=chore-doc-baseline-sync-v1`：通过
- [x] 关键文档口径已统一：README / task_backlog / findings

## 风险与影响范围

- 本次仅更新文档口径，不改变路线图任务定义，也不改变运行时代码行为。
- 后续若 Phase D 或工程清理继续推进，需要同步更新 `task_backlog` 和 `README` 当前重点。

## 建议提交信息

- `docs(roadmap): align baseline wording and backlog status（chore-doc-baseline-sync-v1）`
