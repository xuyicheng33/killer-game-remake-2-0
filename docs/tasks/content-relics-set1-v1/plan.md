# 任务计划

## 基本信息

- 任务 ID：`content-relics-set1-v1`
- 任务级别：`L1`
- 主模块：`content/relics`
- 负责人：Codex
- 日期：2026-02-19

## 目标

按 `docs/master_plan_v3.md` Phase 3a 任务 3a-2，遗物从 4 扩到 6，新增触发时机覆盖：`ON_TURN_START` 与 `ON_ENEMY_KILLED`。

## 范围边界

- 包含：新增遗物资源 `.tres`（仅内容层）。
- 不包含：修改遗物运行时触发系统、抽取目录、奖励逻辑。

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 新增 `dawn_bulwark.tres`，使用 `on_turn_start_block` 字段。
2. 新增 `bounty_emblem.tres`，使用 `on_enemy_killed_gold` 字段。
3. 核验 `content/custom_resources/relics/*.tres` 数量达到 6。
4. 更新任务文档。

## 验证方案

1. 文件存在且可由 `RelicData` 脚本加载。
2. 遗物资源文件总数达到 6。
3. `make workflow-check TASK_ID=content-relics-set1-v1` 通过。
4. `make test` 通过，并记录运行时接线结果。

## 风险与回滚

- 风险：遗物数量扩容后，出现分布需要人工抽样复验。
- 回滚方式：删除新增遗物资源文件并回退任务文档。
