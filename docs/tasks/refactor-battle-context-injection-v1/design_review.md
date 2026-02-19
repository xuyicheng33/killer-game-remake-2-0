# design_review: refactor-battle-context-injection-v1

## 背景
- 当前 `battle.gd` 持有独立 `BattlePhaseStateMachine` 实例。
- `BattleContext` 也持有一套 `phase_machine`，但战斗主流程未使用。
- `BattlePhaseStateMachine` 内部曾直接发射 turn 事件并自动跳相位，和 `PlayerHandler/EnemyHandler/BattleUIAdapter` 的事件链并存。

## 当前相位驱动链（改造前）
1. `battle.gd` 调用 `_battle_phase_machine.start()`。
2. 状态机在 `_enter_draw_phase()` 内部发 `player_hand_drawn` 并自动转 `ACTION`。
3. `PlayerHandler.start_turn()` 绘牌完成后也发 `player_hand_drawn`。
4. 玩家点结束回合由 `BattleUIAdapter` 发 `player_turn_ended`；状态机 `_exit_action_phase()` 也会发一次。
5. `PlayerHandler` 弃牌完成发 `player_hand_discarded`；状态机 `_enter_enemy_phase()` 也会发一次并自动转 `RESOLVE`。
6. `EnemyHandler` 敌方行动完发 `enemy_turn_ended`；状态机 `_enter_enemy_phase()` 也会发一次。

## 风险结论
- turn-start 与 turn-end 都存在双路触发风险。
- `BuffSystem` 基于 `Events` 监听钩子，双路事件会造成状态重复结算。

## 改造决策
1. `BattlePhaseStateMachine` 退化为“纯状态机”：
- 不直接发 turn 事件。
- 不直接调用 `BuffSystem` 私有钩子。
- 不自动跨阶段跳转。
2. `battle.gd` 使用 `BattleContext.phase_machine` 作为唯一状态机实例。
3. `BattleContext.bind_battle_context()` 负责牌区首次绑定；不再在每回合 DRAW 重绑。
4. 相位推进继续由异步事件驱动：
- 绘牌结束 (`player_hand_drawn`) -> `ACTION`
- 弃牌结束 (`player_hand_discarded`) -> `ENEMY`
- 敌方行动结束 (`enemy_turn_ended`) -> `RESOLVE`
- `RESOLVE` 结束后由 `battle.gd` 转回 `DRAW`

## 测试策略
- 更新 `test_battle_context.gd`，去掉对自动跳相位的旧断言。
- 新增断言：状态机自身不直接发 `player_hand_drawn/player_hand_discarded/player_turn_ended/enemy_turn_ended`。
