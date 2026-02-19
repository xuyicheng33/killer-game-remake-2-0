# 任务计划

## 基本信息

- 任务 ID：`content-potions-set2-v1`
- 任务级别：`L1`
- 主模块：`content/potions`
- 负责人：Codex
- 日期：2026-02-19

## 目标

在 3a 基础上将药水扩展到 5 个，并补齐数据侧验证。

## 范围边界

- 包含：
  - 新增 1 个药水资源

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 新增第 5 个药水资源。
2. 更新任务文档并记录效果类型能力边界。

## 验证方案

1. `content/custom_resources/potions/*.tres` 数量为 5。
2. `make workflow-check TASK_ID=content-potions-set2-v1` 通过。
3. `make test` 通过。
4. 核验“爆炸药水伤害语义”已由依赖机制任务落地。

## 风险与回滚

- 风险：全体伤害药水需重点复验多敌战斗下的表现与日志。
- 回滚方式：回退新增药水文件。
