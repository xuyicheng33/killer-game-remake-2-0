# 任务交接

## 基本信息

- 任务 ID：`feat-relic-on-run-start-trigger-v1`
- 日期：2026-02-19
- 状态：`审核员复验通过（2026-02-19，允许提交）`

## 改动摘要

- 新增遗物开局字段并接入 `RelicPotionSystem`。
- 增加一次性触发保护 `run_start_relics_applied`。
- 存档读写已覆盖新增字段。
- 任务文档已补 Phase 3 联动白名单扩展，以匹配当前联动分支改动范围。

## 分支门禁处理

- 本任务采用“拆分分支复验策略”：使用包含 task-id 的分支名执行 `workflow-check`。
- 复验分支：`feat/runtime-feat-relic-on-run-start-trigger-v1`

## 关键文件

- `content/custom_resources/relics/relic_data.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/run_meta/run_state.gd`
- `runtime/modules/persistence/save_service.gd`
- `docs/tasks/feat-relic-on-run-start-trigger-v1/`

## 审核员结论

- 结论：通过（2026-02-19 复验，允许提交）。
