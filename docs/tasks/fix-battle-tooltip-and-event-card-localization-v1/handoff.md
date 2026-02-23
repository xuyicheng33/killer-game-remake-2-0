# Handoff

## 变更摘要
- 关闭战斗手牌悬停 tooltip：
  - `runtime/scenes/card_ui/card_states/card_base_state.gd` 的 `on_mouse_entered` 不再发出 `Events.card_tooltip_requested`。
  - 卡牌 hover 样式仍保留，离开时 `tooltip_hide_requested` 逻辑保持不变。
- 事件卡牌文案中文化：
  - `runtime/modules/map_event/event_service.gd` 新增 `_card_display_name(card)`。
  - `add_card/add_card_for_hp/buy_card/upgrade_card/upgrade_for_hp/remove_card/cards_for_hp` 的卡牌结果文案统一使用显示名。
  - 规则：`Card.get_display_name()` 优先，空时回退 `id`。
- 新增事件服务单测：`dev/tests/unit/test_event_service.gd`
  - 覆盖显示名优先、id 回退、升级/移除文案返回显示名。

## 改动文件
- `runtime/scenes/card_ui/card_states/card_base_state.gd`
- `runtime/modules/map_event/event_service.gd`
- `dev/tests/unit/test_event_service.gd`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/plan.md`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/handoff.md`
- `docs/tasks/fix-battle-tooltip-and-event-card-localization-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 风险
- 战斗手牌 tooltip 关闭是行为改动；若后续想恢复，可在 `card_base_state.gd` 做配置开关化。
- `workflow_check` 仍受当前分支名与 TASK_ID 不匹配影响（见 verification）。

## 建议下一步
- 统一梳理所有“卡牌名字展示”入口，后续可抽到统一格式化 helper，避免多处文案策略分叉。
