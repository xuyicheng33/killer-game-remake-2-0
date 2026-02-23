# Plan

- Task ID: `fix-battle-tooltip-and-event-card-localization-v1`
- 主模块：`map_event`
- 关联模块：`ui_shell`（仅战斗手牌悬停行为收敛）
- 目标：
  1. 关闭战斗手牌悬停 tooltip（保留卡面文案展示）。
  2. 事件结果文案中卡牌显示名改为中文优先（`Card.get_display_name()`），缺失时回退 `id`。
  3. 为事件卡牌名映射新增单测覆盖。

## 白名单改动
- `runtime/scenes/card_ui/card_states/card_base_state.gd`
- `runtime/modules/map_event/event_service.gd`
- `dev/tests/unit/test_event_service.gd`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/plan.md`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/handoff.md`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 验证
- `make test`
- `make test-effects-matrix`
- Godot MCP：`run_project` + `get_debug_output` + `stop_project`
