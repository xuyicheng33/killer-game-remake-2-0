# plan: feat-relic-trigger-completion-v1

## 目标
- 补齐遗物触发链：`ON_TURN_START`、`ON_TURN_END`、`ON_SHOP_ENTER`。
- 明确并实现 `shop_discount_percent` 的生效路径。

## 设计决策
- 折扣实现采用方案（a）：商店报价时直接读取 `run_state.relics[*].shop_discount_percent`。
- `ON_SHOP_ENTER` 保留为触发事件与日志入口，不走 EffectStack（商店场景无 player target，不适合效果派发）。

## 变更边界
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/reward_economy/shop_offer_generator.gd`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/scenes/app/app.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `dev/tests/unit/test_reward_economy.gd`

## 验收标准
- 回合开始遗物可加格挡。
- 回合结束遗物可回血。
- 进入商店触发 `ON_SHOP_ENTER`。
- 商店卡牌与删卡价格受 `shop_discount_percent` 影响。
