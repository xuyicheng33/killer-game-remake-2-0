# handoff: fix-relic-persistence-fields-v1

## 已完成
- `SaveService._serialize_relics()` 补齐 4 个扩展字段写入。
- `SaveService._deserialize_relics()` 补齐 4 个扩展字段恢复。
- 新增 `test_save_service.gd`，覆盖字段写入、恢复和 round-trip。

## 影响
- 避免读档后遗物触发能力退化。
- 为 Phase 3a 遗物内容扩容提供稳定数据基础。
