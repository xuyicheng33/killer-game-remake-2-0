# Plan

- Task ID: `refactor-relic-potion-battle-start-coordinator-v1`
- 主模块：`relic_potion`
- 目标：
  1. 新增独立 coordinator，承接 battle start 触发重试流程的决策状态机。
  2. `RelicPotionSystem` 保留状态与回调执行，减少条件分支密度。
  3. 保持现有测试依赖字段与行为语义不变。

## 白名单改动
- `runtime/modules/relic_potion/battle_start_trigger_coordinator.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/plan.md`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-battle-start-coordinator-v1/verification.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
