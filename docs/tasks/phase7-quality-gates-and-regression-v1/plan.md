# 任务计划

## 基本信息

- 任务 ID：`phase7-quality-gates-and-regression-v1`
- 任务级别：`L2`
- 主模块：`ui_shell` + `run_flow` + `workflow`
- 负责人：Codex
- 日期：2026-02-17

## 目标

固化质量门禁（Quality Gate）：将 Phase 2~6 的关键约束变成可脚本化检查，并接入 `workflow-check`，形成“提交前必过”的静态规则与最小流程回归集。

## 范围边界

- 包含：
  - 新增 `dev/tools/ui_shell_contract_check.sh`，拦截 `scenes/ui` 直写核心状态入口并校验迁移页面 adapter/viewmodel 接入。
  - 扩展 `dev/tools/run_flow_contract_check.sh`，补 route 常量单点定义与关键 `next_route + payload` 键位回归检查。
  - 将上述脚本接入 `dev/tools/workflow_check.sh`，由 `make workflow-check TASK_ID=...` 一键触发。
  - 补齐 phase7 三件套与架构文档同步。
- 不包含：
  - 玩法规则语义改动。
  - 存档 schema / persistence 协议改动。
  - 大规模业务重构。
  - 新增 domain -> scenes 反向依赖。

## 改动白名单文件

- `dev/tools/ui_shell_contract_check.sh`
- `dev/tools/run_flow_contract_check.sh`
- `dev/tools/workflow_check.sh`
- `docs/tasks/phase7-quality-gates-and-regression-v1/plan.md`
- `docs/tasks/phase7-quality-gates-and-regression-v1/handoff.md`
- `docs/tasks/phase7-quality-gates-and-regression-v1/verification.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `modules/ui_shell/README.md`
- `modules/run_flow/README.md`
- `docs/session/task_plan.md`
- `docs/session/findings.md`
- `docs/session/progress.md`

## 实施步骤

1. 新增 `ui_shell` 契约脚本：落地“禁止 UI 直写 run_state 核心入口”与“stats/relic_potion adapter-viewmodel 接入”检查。
2. 扩展 `run_flow` 契约脚本：落地 route 常量单点定义检查与关键 payload 键位回归检查。
3. 接入 `workflow_check.sh`：将两类契约脚本作为 workflow 必过门禁。
4. 同步模块 README、架构文档与工作日志。
5. 执行门禁命令并记录验证结果。

## 验证方案

1. `bash dev/tools/ui_shell_contract_check.sh`
2. `bash dev/tools/run_flow_contract_check.sh`
3. `make workflow-check TASK_ID=phase7-quality-gates-and-regression-v1`

## 风险与回滚

- 风险：契约脚本误报可能阻塞正常提交。
- 风险：静态契约检查无法替代完整运行时回归。
- 回滚方式：回滚 `dev/tools/*contract_check.sh` 与 `dev/tools/workflow_check.sh` 改动，可恢复 Phase 6 提交流程。
