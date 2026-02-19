# 任务计划

## 基本信息

- 任务 ID：`feat-relic-on-run-start-trigger-v1`
- 主模块：`relic_potion`
- 日期：2026-02-19

## 目标

实现遗物 `ON_RUN_START` 真触发，并确保读档场景幂等。

## Phase 3 联动说明

- 该任务与 `content-relics-set2-v1` 联动执行。
- 依据 `docs/master_plan_v3.md` 第 7 章“Phase 3 联动执行补充（白名单例外）”，本任务白名单扩展到联动分支实际改动范围。

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/`
- `docs/`

## 验证

1. `make test`
2. 检查 `trailblazer_emblem` 开局触发字段生效。
3. `make workflow-check TASK_ID=feat-relic-on-run-start-trigger-v1`
