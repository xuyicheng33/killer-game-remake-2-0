# 验证记录

## 基本信息

- 任务 ID：`phase7-quality-gates-and-regression-v1`
- 日期：2026-02-17

## 自动化门禁命令

- [x] `bash tools/ui_shell_contract_check.sh`
  - 结果：通过（`[ui_shell_contract] all checks passed.`）。
- [x] `bash tools/run_flow_contract_check.sh`
  - 结果：通过（`[run_flow_contract] all checks passed.`）。
- [x] `make workflow-check TASK_ID=phase7-quality-gates-and-regression-v1`
  - 结果：通过（`[workflow-check] passed.`）。

## 可人工复验步骤（最小）

1. 在 `scenes/ui/*.gd` 任意位置临时加入 `run_state.add_gold(1)`。
2. 运行 `bash tools/ui_shell_contract_check.sh`。
3. 期望结果：门禁失败，并输出命中的文件与行号。
4. 回滚临时改动后再次运行，期望恢复通过。

1. 在 `modules/run_flow/battle_flow_service.gd` 临时改动关键 payload 键名（例如将 `reward_gold` 改成其他名称）。
2. 运行 `bash tools/run_flow_contract_check.sh`。
3. 期望结果：门禁失败，并提示缺失的契约键位。
4. 回滚临时改动后再次运行，期望恢复通过。

1. 执行 `make workflow-check TASK_ID=phase7-quality-gates-and-regression-v1`。
2. 期望结果：白名单校验 + `ui_shell_contract_check` + `run_flow_contract_check` 全部通过。
