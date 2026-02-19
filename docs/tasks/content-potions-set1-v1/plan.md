# 任务计划

## 基本信息

- 任务 ID：`content-potions-set1-v1`
- 任务级别：`L1`
- 主模块：`content/potions`
- 负责人：Codex
- 日期：2026-02-19

## 目标

按 `docs/master_plan_v3.md` Phase 3a 任务 3a-3，药水从 3 扩到 4。

## 范围边界

- 包含：新增 1 个药水 `.tres` 资源（仅内容层）。
- 不包含：新增药水效果类型、修改药水运行时分发逻辑。

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 基于 `PotionData` 既有字段新增 1 个药水资源。
2. 核验药水资源总数达到 4。
3. 更新任务文档与验证记录。

## 验证方案

1. `content/custom_resources/potions/*.tres` 数量达到 4。
2. `make workflow-check TASK_ID=content-potions-set1-v1` 通过。
3. `make test` 通过。
4. 记录运行时目录接线结果。

## 风险与回滚

- 风险：药水扩容后，出现分布需要人工抽样复验。
- 回滚方式：删除新增药水资源文件并回退任务文档。
