# Plan

- Task ID: `refactor-relic-potion-battle-start-trigger-flow-v1`
- 主模块：`relic_potion`
- 目标：
  1. 收口战斗开始触发器延迟重试流程中的重复分支。
  2. 明确 pending 触发器生命周期（继续 / 完成 / 中止 / 重试调度）。
  3. 保持 battle start 触发语义与重试计数行为不变。

## 白名单改动
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/plan.md`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-battle-start-trigger-flow-v1/verification.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
