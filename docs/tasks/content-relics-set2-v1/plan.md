# 任务计划

## 基本信息

- 任务 ID：`content-relics-set2-v1`
- 任务级别：`L1`
- 主模块：`content/relics`
- 负责人：Codex
- 日期：2026-02-19

## 目标

在 3a 基础上将遗物扩展到 8 个，覆盖 `ON_SHOP_ENTER` 与 `ON_RUN_START` 语义。

## 范围边界

- 包含：
  - 新增 2 个遗物资源

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 新增 `trailblazer_emblem` 与 `merchant_seal`。
2. 更新任务文档并记录 `ON_RUN_START` 机制承接任务。

## 验证方案

1. `content/custom_resources/relics/*.tres` 数量为 8。
2. `make workflow-check TASK_ID=content-relics-set2-v1` 通过。
3. `make test` 通过。
4. 核验 `ON_RUN_START` 真实触发已落地且读档幂等。

## 风险与回滚

- 风险：涉及 `ON_RUN_START` 一次性触发，需重点复验读档幂等性。
- 回滚方式：回退新增遗物文件。
