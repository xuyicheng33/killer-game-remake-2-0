# Handoff

## 变更摘要
- 在 `relic_potion_system.gd` 新增触发辅助方法：
  - `_can_process_battle_trigger()`
  - `_emit_battle_trigger(trigger_type, context)`
  - `_emit_run_trigger(trigger_type, context)`
- 将以下方法的重复 guard + `_fire_trigger` 调用统一为 helper 调用：
  - `_on_card_played`
  - `_on_player_hit`
  - `_on_player_block_applied`
  - `_on_enemy_died`
  - `_on_player_turn_start`
  - `_on_player_turn_end`
  - `on_shop_enter`
  - `on_boss_killed`
- 该改动不涉及触发时机与 payload 语义变化，属于纯结构收敛。

## 改动文件
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/plan.md`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/verification.md`

## 风险
- 当前是“逻辑等价重构”，风险主要在于触发路径遗漏；已通过遗物单测 + 矩阵回归覆盖。
- `workflow_check` 仍受当前分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 继续将 battle start retry 相关流程下沉为独立 coordinator，进一步缩短 `relic_potion_system.gd` 文件长度。
