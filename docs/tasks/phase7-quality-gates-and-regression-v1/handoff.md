# 任务交接

## 基本信息

- 任务 ID：`phase7-quality-gates-and-regression-v1`
- 主模块：`ui_shell` + `run_flow` + `workflow`
- 提交人：Codex
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 7（quality gates and regression v1）`
- 状态：`已完成`

## 改动摘要

1. 新增 `dev/tools/ui_shell_contract_check.sh`：
   - 拦截 `scenes/ui/*.gd` 直接调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`。
   - 强制校验 `stats_ui.gd` 与 `relic_potion_ui.gd` 的 `scene -> adapter -> viewmodel` 接入链路。
2. 扩展 `dev/tools/run_flow_contract_check.sh`：
   - 新增 `ROUTE_*` 常量单点定义校验（仅允许 `route_dispatcher.gd` 定义）。
   - 扩展 map_flow/battle_flow 关键 `next_route + payload` 键位检查（`accepted/node_id/node_type/reward_gold/bonus_log/game_over_text/reward_log`）。
3. 更新 `dev/tools/workflow_check.sh`：
   - 在白名单检查后串行执行 `ui_shell_contract_check.sh` 与 `run_flow_contract_check.sh`。
   - `make workflow-check TASK_ID=phase7-quality-gates-and-regression-v1` 可一键触发全套门禁。
4. 文档同步：
   - `modules/ui_shell/README.md`
   - `modules/run_flow/README.md`
   - `docs/contracts/module_boundaries_v1.md`
   - `docs/module_architecture.md`
   - `docs/repo_structure.md`
   - `docs/work_logs/2026-02.md`
5. 新增任务三件套：
   - `docs/tasks/phase7-quality-gates-and-regression-v1/{plan,handoff,verification}.md`

## 哪些逻辑刻意未动

1. 玩法规则语义（数值、触发时机、奖励规则）未改。
2. 存档 schema 与 persistence 协议未改。
3. 未新增 domain -> scenes 反向依赖。
4. 未做大规模业务重构，仅增强门禁与回归验证能力。

## 变更文件

- `dev/tools/ui_shell_contract_check.sh`
- `dev/tools/run_flow_contract_check.sh`
- `dev/tools/workflow_check.sh`
- `modules/ui_shell/README.md`
- `modules/run_flow/README.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase7-quality-gates-and-regression-v1/plan.md`
- `docs/tasks/phase7-quality-gates-and-regression-v1/handoff.md`
- `docs/tasks/phase7-quality-gates-and-regression-v1/verification.md`

## 残余风险

1. 当前门禁以静态契约为主，无法覆盖全部 UI 运行时交互场景。
2. `ui_shell` 门禁目前强约束的是已迁移页面（stats/relic_potion），其余页面需后续逐步纳入。
