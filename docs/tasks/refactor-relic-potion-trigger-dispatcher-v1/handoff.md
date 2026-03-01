# Handoff

## 变更摘要
- 新增 `runtime/modules/relic_potion/relic_trigger_dispatcher.gd`：
  - 统一处理 `run_state.relics` 遍历、runtime 解析、`handle_trigger` 调用。
- `relic_potion_system.gd` 接入 dispatcher：
  - `_fire_trigger()` 从“本地循环遍历”改为委托 `_trigger_dispatcher.dispatch_trigger(...)`。
  - `_init_services()` 增加 `_trigger_dispatcher` 初始化。
- 保持行为不变：
  - 仍先 `trigger_fired.emit(...)`。
  - 仍通过 `_get_or_create_relic_runtime` 复用 runtime cache。

## 改动文件
- `runtime/modules/relic_potion/relic_trigger_dispatcher.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/plan.md`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/verification.md`

## 风险
- 结构重构风险在于 trigger_owner/callable 透传；已由遗物单测和效果矩阵覆盖。
- `workflow_check` 仍受分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 继续把 `relic_potion_system.gd` 中 run_state/potion 写入分支拆到 command service，进一步降低主类职责。
