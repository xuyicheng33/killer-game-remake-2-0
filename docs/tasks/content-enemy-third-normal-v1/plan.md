# 任务计划

## 基本信息

- 任务 ID：`content-enemy-third-normal-v1`
- 任务级别：`L1`
- 主模块：`content/enemies`
- 负责人：Codex
- 日期：2026-02-19

## 目标

新增第 3 种普通敌人（施毒型）及其内容资源，并完成数据侧校验。

## 范围边界

- 包含：
  - 新敌人资源、行为脚本、AI 场景
  - 遭遇数据扩容
- 不包含：
  - 敌人意图规则引擎改造

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 新增 `viper` 敌人内容资源与动作脚本。
2. 扩展 `act1_enemies.json` 增加 `viper` 定义与安全遭遇配置。
3. 更新任务文档与验证记录。

## 验证方案

1. `content_import_enemies.py` 校验通过。
2. JSON 中普通敌人数为 3（`crab/bat/viper`）。
3. `make workflow-check TASK_ID=content-enemy-third-normal-v1` 通过。
4. `make test` 通过。

## 风险与回滚

- 风险：新增遭遇组合后，普通战斗分布需要人工抽样复验。
- 回滚方式：删除 `viper` 资源并回退遭遇数据。
