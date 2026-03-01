# Handoff

## 变更摘要
- 新增 `runtime/modules/relic_potion/battle_start_trigger_coordinator.gd`：
  - 定义 `Action` 枚举与两个决策入口：`evaluate_immediate`、`evaluate_deferred`。
  - 统一描述 pending/battle_active/context_ready/retry_count 对应的下一步动作。
- `relic_potion_system.gd` 接入 coordinator：
  - `_try_fire_battle_start_trigger()` 与 `_deferred_try_fire_battle_start_trigger()` 改为“收集状态 -> 调 coordinator -> 执行动作”。
  - 新增 `_handle_battle_start_action(action, timed_out)` 负责具体副作用（defer/complete/abort/retry/warning）。
  - `_init_services()` 注入 coordinator 实例。
- 外部行为保持不变：超时 warning、重试计数、pending 清理与触发时机均与原实现一致。

## 改动文件
- `runtime/modules/relic_potion/battle_start_trigger_coordinator.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/plan.md`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/verification.md`

## 风险
- 为“结构等价重构”，主要风险在 action 映射遗漏；已通过 `test_relic_potion` 中 battle start 重试专项用例覆盖。
- `workflow_check` 仍受当前分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 将 battle_start 相关状态字段（pending/retry_count）进一步封装到 coordinator state，`RelicPotionSystem` 只保留生命周期事件输入。
