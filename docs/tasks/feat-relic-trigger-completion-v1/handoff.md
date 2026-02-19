# handoff: feat-relic-trigger-completion-v1

## 已完成
- `RelicPotionSystem._process_relic_trigger()` 新增：
  - `ON_TURN_START -> on_turn_start_block`
  - `ON_TURN_END -> on_turn_end_heal`
  - `ON_SHOP_ENTER -> shop_discount_percent`（日志/事件）
- `app.gd` 打开商店前调用 `relic_potion_system.on_shop_enter()`。
- `ShopOfferGenerator` 新增折扣计算与价格应用，覆盖：
  - 购卡报价
  - 购遗物报价
  - 购药水报价
  - 删卡价格
- `ShopUIViewModel` 改为使用折扣后的删卡价格。
- 新增/更新 GUT 用例覆盖 turn-start/turn-end/shop-enter/商店折扣。

## 说明
- 折扣按遗物字段总和计算并上限截断（90%）。
- 折扣为报价层逻辑，不依赖临时状态字段。
