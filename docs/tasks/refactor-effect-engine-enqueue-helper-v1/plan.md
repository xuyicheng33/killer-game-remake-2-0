# Plan

- Task ID: `refactor-effect-engine-enqueue-helper-v1`
- 主模块：`effect_engine`
- 目标：
  1. 抽取 effect 脚本重复的 `effect_stack.enqueue_effect` 模板为统一 helper。
  2. 在不改变玩法语义前提下，降低卡牌效果实现重复与后续维护成本。
  3. 补强 `lose_hp` 自损目标解析与 stats 读取的上下文兼容。

## 白名单改动
- `runtime/modules/effect_engine/effect_enqueue_helper.gd`
- `content/effects/damage_effect.gd`
- `content/effects/block_effect.gd`
- `content/effects/conditional_damage_effect.gd`
- `content/effects/draw_card_effect.gd`
- `content/effects/gain_energy_effect.gd`
- `content/effects/lose_hp_effect.gd`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/plan.md`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/handoff.md`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/verification.md`

## 验证
- `make test-effects-matrix`
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_battle_flow.gd 240`
- `make test`
- Godot MCP 运行态：`run_project` + `get_debug_output` + `stop_project`
