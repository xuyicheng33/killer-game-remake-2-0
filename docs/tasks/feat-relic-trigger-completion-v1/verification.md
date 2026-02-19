# verification: feat-relic-trigger-completion-v1

## 自动验证
- 命令：`make test`
- 结果：通过（63/63）

## 覆盖点
1. `test_turn_start_relic_grants_block()`：验证 `ON_TURN_START`。
2. `test_turn_end_relic_heals_player()`：验证 `ON_TURN_END`。
3. `test_shop_enter_trigger_is_emitted()`：验证 `ON_SHOP_ENTER`。
4. `test_shop_discount_applies_to_card_and_remove_prices()`：验证 `shop_discount_percent` 对报价与删卡价格生效。
