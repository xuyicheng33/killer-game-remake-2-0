# Handoff

## 变更摘要
- 新增 `runtime/modules/relic_potion/battle_participant_resolver.gd`：
  - `resolve_player(session_port)`
  - `resolve_battle_context(session_port, cached_context)`
  - `resolve_enemies(session_port)`
- `relic_potion_system.gd` 接入 resolver 服务：
  - `_find_player()` 改为委托 resolver。
  - `_find_battle_context()` 改为委托 resolver。
  - `_find_enemies()` 改为委托 resolver。
  - `_init_services()` 增加 resolver 初始化。
- 保持 `_find_player/_find_battle_context` 方法存在，确保测试子类重写行为兼容。

## 改动文件
- `runtime/modules/relic_potion/battle_participant_resolver.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/plan.md`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/verification.md`

## 风险
- 当前为结构收敛改动，风险主要在 resolver 对组节点读取的一致性；已由单测与矩阵回归覆盖。
- `workflow_check` 仍受当前分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 将 resolver 与 battle-start coordinator 进一步组合为 battle session facade，继续缩短 `RelicPotionSystem` 编排体积。
