# 验证记录

## 基本信息

- 任务 ID：`chore-ai-planner-reviewer-character-prompts-v1`
- 日期：2026-02-17

## 自动化检查

1. 执行：
   - `make workflow-check TASK_ID=chore-ai-planner-reviewer-character-prompts-v1`
2. 期望：
   - 白名单校验通过
   - `ui_shell_contract_check` 与 `run_flow_contract_check` 通过

## 文档可用性检查

1. 工程提示词检查：
   - 打开 `docs/prompts/engineering_rpi_prompts.md`
   - 确认包含 `Research/Plan/Implement/Self Review/Handoff` 五段可复制模板
2. 人物提示词检查：
   - 打开 `docs/prompts/character_portrait_prompts/20_角色提示词套件_v2.md`
   - 确认包含三角色正负提示词、批量生成模板、失败回合修正模板

## 结果

- `make workflow-check TASK_ID=chore-ai-planner-reviewer-character-prompts-v1`：通过（`[workflow-check] passed.`）
- 工程提示词模板检查：通过（静态）
- 角色提示词模板检查：通过（静态）
