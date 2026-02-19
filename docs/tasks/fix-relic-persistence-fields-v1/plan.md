# plan: fix-relic-persistence-fields-v1

## 目标
- 修复遗物扩展字段在存档链路中的丢失问题。
- 保证 `RelicData` 新字段序列化/反序列化完整。

## 变更边界
- `runtime/modules/persistence/save_service.gd`
- `dev/tests/unit/test_save_service.gd`

## 字段范围
- `on_enemy_killed_gold`
- `on_turn_start_block`
- `on_turn_end_heal`
- `shop_discount_percent`

## 验收标准
- 存档写入包含上述字段。
- 读档恢复包含上述字段。
- round-trip 测试通过。
