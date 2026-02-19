# 任务交接

## 基本信息

- 任务 ID：`feat-card-exhaust-upgrade-on-consume-v1`
- 日期：2026-02-19
- 状态：`审核员复验通过（2026-02-19，允许提交）`

## 改动摘要

- `Card` 新增 `upgrade_to` 字段和升级副本构造函数。
- `CardZonesModel` 在消耗时追加升级副本到弃牌堆。
- 导入器生成 `.tres` 已写入 `upgrade_to`。
- `SaveService` 已覆盖 `upgrade_to` 存档往返。
- 新增单测覆盖机制行为与存档字段。

## 关键变更文件

- `content/custom_resources/card.gd`
- `runtime/modules/card_system/card_zones_model.gd`
- `dev/tools/content_import_cards.py`
- `runtime/modules/persistence/save_service.gd`
- `dev/tests/unit/test_card_zones.gd`
- `dev/tests/unit/test_save_service.gd`
- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
- `content/characters/warrior/cards/generated/warrior_finisher_attack.tres`
- `docs/tasks/feat-card-exhaust-upgrade-on-consume-v1/`

## 审核员结论

- 结论：通过（2026-02-19 复验，允许提交）。
