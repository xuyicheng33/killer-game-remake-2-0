# 任务计划

## 基本信息

- 任务 ID：`chore-ai-planner-reviewer-character-prompts-v1`
- 任务级别：`L1`
- 主模块：`docs / prompts`
- 负责人：Codex
- 日期：2026-02-17

## 目标

建立一套可直接执行的“AI 规划 + 审核 + 角色提示词”协作资产，支持后续你派工给 AI 工程师并进行标准化复审。

## 范围边界

- 包含：
  - 新增 Planner/Reviewer 执行手册
  - 新增 AI 工程师 RPI 提示词模板
  - 新增角色提示词套件 V2（霜北刀/离恨烟/埋骨钱）
  - 回填本任务三件套与工作日志
- 不包含：
  - 任何玩法逻辑、场景脚本、资源二进制替换
  - 存档结构、战斗结算链路改动

## 改动白名单文件

- `docs/ai_planner_reviewer_playbook.md`
- `docs/prompts/README.md`
- `docs/prompts/engineering_rpi_prompts.md`
- `docs/prompts/character_portrait_prompts/README.md`
- `docs/prompts/character_portrait_prompts/20_角色提示词套件_v2.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/plan.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/handoff.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 梳理现有协作规范、任务流水线、人物提示词现状。
2. 产出统一执行手册与 RPI 提示词模板，确保可直接投喂 AI 工程师。
3. 产出角色提示词 V2（含批量生成与二次修正模板）。
4. 回填任务三件套、更新工作日志。
5. 执行 `make workflow-check TASK_ID=chore-ai-planner-reviewer-character-prompts-v1`。

## 验证方案

1. `make workflow-check TASK_ID=chore-ai-planner-reviewer-character-prompts-v1` 通过。
2. 人工检查提示词文档是否“可直接复制使用”（工程提示词 + 角色提示词）。

## 风险与回滚

- 风险：文档可执行性不足，导致 AI 工程师理解歧义。
- 回滚方式：按文件回滚本任务新增/改动文档，不影响运行时代码。
