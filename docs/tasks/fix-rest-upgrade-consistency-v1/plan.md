# Plan: fix-rest-upgrade-consistency-v1

## 任务元信息

- 任务ID: fix-rest-upgrade-consistency-v1
- 等级: L1（单模块：run_meta）
- 主模块: run_meta
- 优先级: P1（内容设计一致性）

## 目标

修复营地升级逻辑与 Exhaust 升级逻辑不一致的问题，统一使用 `upgrade_to` 字段实现数据驱动。

## 状态说明

此任务已在前期实现：
- `run_state.gd:upgrade_card_in_deck_at()` 优先使用 `upgrade_to` 字段
- 如果 `upgrade_to` 为空，回退到硬编码行为（向后兼容）
- 集成测试已覆盖：`test_rest_screen_upgrade_uses_upgrade_to_field()`

## 白名单文件

- runtime/modules/run_meta/run_state.gd
- content/custom_resources/card.gd
- dev/tests/integration/test_battle_flow.gd

## 验证命令

```bash
make test
```

## 状态: COMPLETED
