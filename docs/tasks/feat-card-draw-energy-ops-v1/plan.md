# 任务计划

## 基本信息

- 任务 ID：`feat-card-draw-energy-ops-v1`
- 主模块：`content_pipeline/cards`
- 日期：2026-02-19

## 目标

为卡牌补齐 `draw/回能量` 可执行机制，确保数据、导入与运行时语义一致。

## Phase 3 联动说明

- 该任务与 `content-cards-warrior-set2-v1` 联动执行。
- 依据 `docs/master_plan_v3.md` 第 7 章“Phase 3 联动执行补充（白名单例外）”，本任务白名单扩展到联动分支实际改动范围。

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/`
- `docs/`

## 验证

1. `python3 dev/tools/content_import_cards.py --input runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
2. `make test`
3. `make workflow-check TASK_ID=feat-card-draw-energy-ops-v1`
