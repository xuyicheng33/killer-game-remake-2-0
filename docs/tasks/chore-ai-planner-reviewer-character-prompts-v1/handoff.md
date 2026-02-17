# 任务交接

## 基本信息

- 任务 ID：`chore-ai-planner-reviewer-character-prompts-v1`
- 主模块：`docs / prompts`
- 提交人：Codex
- 日期：2026-02-17

## 改动摘要

- 新增 Planner + Reviewer 协作执行手册：`docs/ai_planner_reviewer_playbook.md`。
- 新增 AI 工程师 RPI 提示词模板：`docs/prompts/engineering_rpi_prompts.md`。
- 新增角色提示词套件 V2（含批量生成与二次修正）：`docs/prompts/character_portrait_prompts/20_角色提示词套件_v2.md`。
- 更新 prompts 索引：`docs/prompts/README.md` 与 `docs/prompts/character_portrait_prompts/README.md`。

## 变更文件

- `docs/ai_planner_reviewer_playbook.md`
- `docs/prompts/README.md`
- `docs/prompts/engineering_rpi_prompts.md`
- `docs/prompts/character_portrait_prompts/README.md`
- `docs/prompts/character_portrait_prompts/20_角色提示词套件_v2.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/plan.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/handoff.md`
- `docs/tasks/chore-ai-planner-reviewer-character-prompts-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 验证结果

- [x] 用例 1：`make workflow-check TASK_ID=chore-ai-planner-reviewer-character-prompts-v1` 通过。
- [x] 用例 2：提示词资产可直接复制使用（工程 RPI + 三角色美术）。

## 风险与影响范围

- 本任务仅改文档层，不影响运行时代码。
- 若后续新增角色，需要按同模板补充新角色提示词并更新索引。

## 建议提交信息

- `chore(docs): add planner-reviewer playbook and character prompt kit v2 (chore-ai-planner-reviewer-character-prompts-v1)`
