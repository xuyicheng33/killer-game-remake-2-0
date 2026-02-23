# Plan

- Task ID: `refactor-relic-potion-trigger-guard-v1`
- 主模块：`relic_potion`
- 目标：
  1. 收口 `relic_potion_system` 内重复的 battle/run 触发 guard 逻辑。
  2. 以 helper 方式统一触发派发入口，降低重复代码与后续回归风险。
  3. 保持外部 API 与现有测试行为不变。

## 白名单改动
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/plan.md`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/handoff.md`
- `docs/tasks/refactor-relic-potion-trigger-guard-v1/verification.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
