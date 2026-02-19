# 任务计划

## 基本信息

- 任务 ID：`feat-card-exhaust-upgrade-on-consume-v1`
- 主模块：`card_system`
- 日期：2026-02-19

## 目标

实现“消耗后升级”机制闭环，并补齐导入与存档字段对齐。

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/`
- `docs/`

## 验证

1. `python3 dev/tools/content_import_cards.py --input runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
2. `make test`
3. `make workflow-check TASK_ID=feat-card-exhaust-upgrade-on-consume-v1`
