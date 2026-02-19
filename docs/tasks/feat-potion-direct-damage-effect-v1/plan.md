# 任务计划

## 基本信息

- 任务 ID：`feat-potion-direct-damage-effect-v1`
- 主模块：`relic_potion`
- 日期：2026-02-19

## 目标

实现药水“对全体敌人伤害”效果类型并接入运行时执行。

## Phase 3 联动说明

- 该任务与 `content-potions-set2-v1` 联动执行。
- 依据 `docs/master_plan_v3.md` 第 7 章“Phase 3 联动执行补充（白名单例外）”，本任务白名单扩展到联动分支实际改动范围。

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/`
- `docs/`

## 验证

1. `make test`
2. 检查群伤药水命中所有敌方目标。
3. `make workflow-check TASK_ID=feat-potion-direct-damage-effect-v1`
