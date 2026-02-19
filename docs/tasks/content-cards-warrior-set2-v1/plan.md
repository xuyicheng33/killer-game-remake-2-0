# 任务计划

## 基本信息

- 任务 ID：`content-cards-warrior-set2-v1`
- 任务级别：`L1`
- 主模块：`content/cards`
- 负责人：Codex
- 日期：2026-02-19

## 目标

按 Phase 3b 要求将战士卡牌扩容到 20 张，并完成联动机制后的语义一致性验证。

## 范围边界

- 包含：
  - 卡牌数据扩容（20 张）
  - 生成卡资源文件
  - 与依赖机制任务的联动验收记录
- 不包含：
  - 跨任务机制实现代码（由独立机制任务承接）

## 依赖任务

- `feat-card-draw-energy-ops-v1`
- `feat-card-exhaust-upgrade-on-consume-v1`

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/`
- `docs/`

## 实施步骤

1. 将 `warrior_cards.json` 扩容到 20 张并满足类型分布目标。
2. 运行卡牌导入器生成 `.gd/.tres` 资源。
3. 与依赖机制任务联动，确认关键词语义均为可执行行为。
4. 更新任务文档，记录联动范围与验证结果。

## 验证方案

1. `content_import_cards.py` 通过，输出 `cards: 20`。
2. `content/characters/warrior/cards/generated/*.tres` 数量为 20。
3. `make workflow-check TASK_ID=content-cards-warrior-set2-v1` 通过。
4. `make test` 通过。
5. 核验“抽牌/回能量/消耗后升级”语义均已落地。

## 风险与回滚

- 风险：导入脚本覆盖手工改动导致行为回归。
- 回滚方式：回退 `warrior_cards.json` 与生成资源。
