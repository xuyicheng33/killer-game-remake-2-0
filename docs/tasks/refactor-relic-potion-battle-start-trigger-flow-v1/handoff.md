# Handoff

## 变更摘要
- 对 battle start 触发链路做结构收敛，新增并复用以下方法：
  - `_can_continue_pending_battle_start_trigger()`
  - `_complete_pending_battle_start_trigger()`
  - `_abort_pending_battle_start_trigger()`
  - `_schedule_battle_start_retry()`
- `_try_fire_battle_start_trigger()` 与 `_deferred_try_fire_battle_start_trigger()` 统一复用上述 helper，去除重复的 pending/battle_active 分支与重复触发代码。
- 行为保持一致：
  - 上下文就绪时触发 `ON_BATTLE_START`。
  - 超过 `MAX_BATTLE_START_RETRIES` 后放弃并 warning。
  - battle 不活跃时清理 pending。

## 改动文件
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/plan.md`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/verification.md`

## 风险
- 改动属于“同义重构”，风险点在于 pending 生命周期处理遗漏；已通过 battle start 相关单测覆盖。
- `workflow_check` 受当前分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 将 battle start 触发编排抽为独立 coordinator/service，并在 `RelicPotionSystem` 中仅保留状态接线。
