# 任务计划

## 基本信息

- 任务 ID：`content-cards-warrior-set1-v1`
- 任务级别：`L1`
- 主模块：`content_pipeline/cards`
- 负责人：Codex
- 日期：2026-02-19

## 目标

按 `docs/master_plan_v3.md` Phase 3a 任务 3a-1，在现有基础上补齐 4 张卡（格挡技能/能力牌/消耗牌/X费牌），并保持“数据源 + 导入生成”流程。

## 范围边界

- 包含：
  - 更新 `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
  - 运行导入脚本生成卡牌资源
  - 更新本任务三件套文档
- 不包含：
  - 新增 `draw/energy` 等 effect op
  - 修改奖励池、商店选牌等运行时接线

## 改动白名单文件

- `content/`
- `runtime/`
- `runtime/modules/content_pipeline/sources/`
- `dev/tools/`
- `dev/tests/`
- `docs/tasks/`
- `docs/master_plan_v3.md`

## 实施步骤

1. 在卡牌数据源中补齐 4 张目标卡。
2. 运行 `content_import_cards.py` 生成资源。
3. 修正生成脚本签名，保持 `battle_context` 透传兼容。
4. 更新 `plan.md`、`handoff.md`、`verification.md`、`design_proposal.md`。

## 验证方案

1. 4 张目标卡 ID 存在：`warrior_guard_stance`、`warrior_berserker_form`、`warrior_last_stand`、`warrior_whirlwind_x`。
2. 导入命令通过（当前集成分支为 20 张卡总量）。
3. `make workflow-check TASK_ID=content-cards-warrior-set1-v1` 通过。
4. `make test` 通过。

## 风险与回滚

- 风险：导入器模板变更后若未重生资源，可能造成脚本与数据不一致。
- 回滚方式：回退 `warrior_cards.json` 与新增/生成资源文件。
