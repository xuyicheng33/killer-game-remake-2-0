# 任务交接

## 基本信息

- 任务 ID：`feat-battle-loop-state-machine-v1`
- 主模块：`battle_loop`
- 提交人：AI 协作执行
- 日期：2026-02-15

## 改动摘要

- 在 `modules/battle_loop` 新增 `BattlePhaseStateMachine`，定义阶段枚举、合法迁移与回合计数。
- 将 `scenes/battle/battle.gd` 从事件直连改为阶段机驱动，流程固定为 `DRAW -> ACTION -> ENEMY -> RESOLVE -> DRAW`。
- 在 `scenes/battle/battle.tscn` 新增阶段 HUD（当前阶段 + 迁移日志）。
- 更新 `docs/contracts/battle_state.md`，同步阶段字段与迁移约束。

## 变更文件

- `modules/battle_loop/battle_phase_state_machine.gd`
- `modules/battle_loop/README.md`
- `scenes/battle/battle.gd`
- `scenes/battle/battle.tscn`
- `docs/contracts/battle_state.md`
- `docs/tasks/feat-battle-loop-state-machine-v1/plan.md`
- `docs/tasks/feat-battle-loop-state-machine-v1/verification.md`
- `docs/tasks/feat-battle-loop-state-machine-v1/handoff.md`

## 验证结果

- [x] 用例 1：`make workflow-check TASK_ID=feat-battle-loop-state-machine-v1` 通过
- [ ] 用例 2：主路径回归（当前环境缺少 Godot CLI，待本机补测）
- [ ] 用例 3：边界用例回归（`ACTION` 阶段直接结束回合，待本机补测）

## 风险与影响范围

- 当前仅改动 `battle_loop` 与 `scenes/battle` 及对应文档，未扩展到其他模块。
- 风险：阶段迁移现依赖现有事件触发顺序，若后续改动 `player_handler/enemy_handler` 事件时序，需同步回归阶段机。

## 建议提交信息

- `feat(battle_loop): 接入战斗阶段状态机与HUD日志（feat-battle-loop-state-machine-v1）`
