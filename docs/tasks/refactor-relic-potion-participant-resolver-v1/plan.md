# Plan

- Task ID: `refactor-relic-potion-participant-resolver-v1`
- 主模块：`relic_potion`
- 目标：
  1. 下沉玩家/敌人/战斗上下文解析逻辑到独立 resolver。
  2. 保持 `RelicPotionSystem` 的 `_find_player/_find_enemies/_find_battle_context` 方法签名不变，兼容现有测试重写点。
  3. 降低 `RelicPotionSystem` 内部场景查询逻辑密度。

## 白名单改动
- `runtime/modules/relic_potion/battle_participant_resolver.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/plan.md`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-participant-resolver-v1/verification.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
