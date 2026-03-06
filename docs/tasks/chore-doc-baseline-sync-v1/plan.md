# 任务计划：chore-doc-baseline-sync-v1

## 基本信息

- 任务 ID：`chore-doc-baseline-sync-v1`
- 任务级别：`L0`
- 主模块：`docs`
- 负责人：`Codex`
- 日期：`2026-03-06`

## 目标

统一 README、路线图任务池与会话 findings 的口径，使其与 2026-03-06 当前真实基线一致，避免继续把已落地能力描述为“骨架”或“待启动”。

## 范围边界

- 包含：
  - README 当前重点与常用命令说明
  - `docs/roadmap/task_backlog.md` 的状态与建议推进项
  - `docs/session/findings.md` 增补当前文档口径约束
  - 任务三件套与验证记录
- 不包含：
  - 新功能开发
  - 路线图任务定义重写
  - 内容表或运行时代码调整

## 改动白名单文件

- `README.md`
- `docs/roadmap/task_backlog.md`
- `docs/session/findings.md`
- `docs/tasks/chore-doc-baseline-sync-v1/plan.md`
- `docs/tasks/chore-doc-baseline-sync-v1/handoff.md`
- `docs/tasks/chore-doc-baseline-sync-v1/verification.md`

## 实施步骤

1. 扫描 README、路线图、进度与 findings 中的旧基线描述。
2. 更新 README 当前重点、命令说明与测试口径。
3. 更新 `task_backlog` 状态与建议推进项。
4. 增补 findings，明确文档统一口径。
5. 执行 `make workflow-check TASK_ID=chore-doc-baseline-sync-v1`。

## 验证方案

1. `make workflow-check TASK_ID=chore-doc-baseline-sync-v1`
2. `rg -n "骨架阶段|ready|blocked|2026-02-15" README.md docs/roadmap/task_backlog.md docs/session/findings.md`

## 风险与回滚

- 风险：若文档更新过度，可能把“路线图定义”与“当前实现状态”混为一谈。
- 回滚方式：`git revert <commit>`。
