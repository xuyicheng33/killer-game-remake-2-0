# battle_loop

状态：
- A1 `feat-battle-loop-state-machine-v1` 进行中

职责：
- 提供战斗回合阶段状态机（`DRAW -> ACTION -> ENEMY -> RESOLVE`）。
- 维护回合计数与阶段迁移约束。
- 提供敌人生成服务（`enemy_spawn_service.gd`），将战斗场景中的敌人生成细节下沉到模块层。
