# verification: refactor-battle-context-injection-v1

## 自动验证
- 命令：`make test`
- 结果：通过（59/59）

## 关键检查
1. `BattlePhaseStateMachine._enter_draw_phase/_enter_enemy_phase/_exit_action_phase` 不再 emit turn 事件。
2. `BattlePhaseStateMachine` 不再直接调用 `buff_system` 私有钩子。
3. `battle.gd` 使用 `BattleContext.phase_machine`，且战斗开始时已绑定 combatants。
4. `test_phase_machine_does_not_emit_turn_events_directly()` 通过。
