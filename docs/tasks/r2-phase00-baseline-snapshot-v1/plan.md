# 任务计划

## 基本信息

- 任务 ID：`r2-phase00-baseline-snapshot-v1`
- 任务级别：`L0`
- 主模块：`run_meta`
- 负责人：AI 审核员 + 规划员
- 日期：2026-02-17

## 目标

建立 R2（工具链优先）全新阶段规划与审核提示词基线，解决旧 `phase*` 编号混淆，并让后续任务具备可直接派发与审查的标准模板。

## 范围边界

- 包含：
  - 新增 R2 主规划文档（Phase0 起步，工具链闭环优先）。
  - 新增“任务发布者 + 审核员”提示词套件。
  - 回填 roadmap/prompts 索引与工作日志。
  - 维护本任务三件套。
- 不包含：
  - 任何玩法逻辑、运行时模块代码、存档结构改动。
  - 视觉资源替换与 UI 视觉重构。

## 改动白名单文件

- `docs/roadmap/r2_toolchain_first_master_plan_v1.md`
- `docs/prompts/r2_task_publisher_reviewer_prompts_v1.md`
- `docs/roadmap/README.md`
- `docs/prompts/README.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/plan.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/handoff.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/verification.md`

## 实施步骤

1. 基于当前实现现状整理 R2 阶段链路（`r2-phase00` 起）。
2. 编写可执行的审核/发布提示词套件，覆盖“恢复上下文 -> 派发 -> 审核 -> 提交 -> 推进下一任务”。
3. 更新索引与工作日志，保证文档可追踪。
4. 执行 `workflow-check` 并记录验证结果。

## 验证方案

1. `git status --short`：确认改动仅在白名单文件。
2. `make workflow-check TASK_ID=r2-phase00-baseline-snapshot-v1`：验证门禁通过。

## 风险与回滚

- 风险：规划命名与既有任务链路不一致导致理解偏差。
- 风险：提示词模板未覆盖真实审查流程，后续执行时返工。
- 回滚方式：仅回滚本任务白名单文件。
