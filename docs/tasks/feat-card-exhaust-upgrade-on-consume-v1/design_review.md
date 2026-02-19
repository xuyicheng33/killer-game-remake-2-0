# 设计复核

## 任务 ID
`feat-card-exhaust-upgrade-on-consume-v1`

## 当前实现位置（文件 + 关键点）

- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
  - `warrior_finisher_attack` 已声明 `upgrade_to`，但仅是数据字段。
- `dev/tools/content_import_cards.py`
  - 只校验 `upgrade_to`，未把字段写入 `.tres` 运行时资源。
- `content/custom_resources/card.gd`
  - 当前无 `upgrade_to` 运行时字段。
- `runtime/modules/card_system/card_zones_model.gd`
  - 仅处理 `keyword_exhaust` 进消耗堆，没有“消耗后升级”执行逻辑。

## 当前数据结构与限制

- `upgrade_to` 不能进入运行时对象，导致“消耗后升级”仅停留在文案。
- `SaveService` 未序列化 `upgrade_to`，即使后续落地机制也会在存档读档后丢失。

## 可复用点

- `Card.duplicate(true)` 可作为升级副本构造基础。
- `CardZonesModel` 已有“出牌后处理 + 消耗堆管理”入口。
- `content_import_cards.py` 已做 `upgrade_to` 校验，数据侧无需新 schema。

## 风险点

- 若升级副本进入错误牌堆，会造成抽牌循环异常。
- 若不限制链式升级，可能无限生成升级副本。
- 若遗漏存档字段，读档后机制退化。
