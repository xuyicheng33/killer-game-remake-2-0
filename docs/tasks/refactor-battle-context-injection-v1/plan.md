# plan: refactor-battle-context-injection-v1

## 目标
- 统一战斗相位驱动，移除状态机内部事件发射与自动跳相位。
- 让 `battle.gd` 使用 `BattleContext.phase_machine`，避免双状态机并存。

## 变更边界
- `runtime/modules/battle_loop/battle_phase_state_machine.gd`
- `runtime/scenes/battle/battle.gd`
- `dev/tests/unit/test_battle_context.gd`

## 执行步骤
1. 删除状态机内部的 turn 事件 emit 与 buff 私有钩子调用。
2. 删除状态机内部 DRAW->ACTION、ENEMY->RESOLVE 自动跳转。
3. `battle.gd` 改为使用 `_battle_context.phase_machine`，并在开战时 `bind_combatants`。
4. 调整 battle context 单测断言与事件行为测试。
5. 运行 `make test`。

## 验收标准
- `make test` 全部通过。
- `BattlePhaseStateMachine` 不直接发 turn 事件。
- `start()` 后阶段为 `DRAW`，后续由外部事件推进。
