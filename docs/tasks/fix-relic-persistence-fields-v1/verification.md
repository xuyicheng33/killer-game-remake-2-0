# verification: fix-relic-persistence-fields-v1

## 自动验证
- 命令：`make test`
- 结果：通过（66/66）

## 关键验证
1. `test_serialize_relics_includes_extended_fields()`
2. `test_deserialize_relics_restores_extended_fields()`
3. `test_relic_extended_fields_round_trip()`
