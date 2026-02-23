# Plan

- Task ID: `refactor-relic-potion-trigger-dispatcher-v1`
- 主模块：`relic_potion`
- 目标：
  1. 下沉遗物触发循环逻辑到独立 dispatcher 服务。
  2. 保持 `RelicPotionSystem._fire_trigger` 对外语义不变（仍发信号，再分发触发）。
  3. 降低 `relic_potion_system.gd` 的触发分发复杂度。

## 白名单改动
- `runtime/modules/relic_potion/relic_trigger_dispatcher.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/plan.md`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-trigger-dispatcher-v1/verification.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
