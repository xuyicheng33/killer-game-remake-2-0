# 验证记录

## 基本信息

- 任务 ID：`phase12-run-flow-lifecycle-contract-gate-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `bash dev/tools/run_lifecycle_contract_check.sh`
  - 结果：
    - `[run_lifecycle_contract] checking forbidden direct dependencies in app.gd...`
    - `[PASS] app.gd must not directly preload save_service.gd`
    - `[PASS] app.gd must not directly preload save_service.tscn`
    - `[PASS] app.gd must not directly preload run_rng.gd`
    - `[PASS] app.gd must not directly preload repro_log.gd`
    - `[PASS] app.gd must not directly instantiate SaveService`
    - `[PASS] app.gd must not directly instantiate RunRng`
    - `[PASS] app.gd must not directly instantiate ReproLog`
    - `[run_lifecycle_contract] checking lifecycle service calls through run_flow_service...`
    - `[PASS] app.gd must call start_new_run through run_flow_service.lifecycle_service`
    - `[PASS] app.gd must call try_load_saved_run through run_flow_service.lifecycle_service`
    - `[PASS] app.gd must call save_checkpoint through run_flow_service.lifecycle_service`
    - `[run_lifecycle_contract] all checks passed.`
- [x] `make workflow-check TASK_ID=phase12-run-flow-lifecycle-contract-gate-v1`
  - 结果：
    - `[repo-structure-check] passed.`
    - `[ui_shell_contract] all checks passed.`
    - `[run_flow_contract] all checks passed.`
    - `[run_lifecycle_contract] all checks passed.`
    - `[workflow-check] passed.`

## 门禁功能验证

### 验证 1：禁止直接依赖检查

1. `run_lifecycle_contract_check.sh` 应检测到 `app.gd` 不得直接 preload `save_service.gd`、`run_rng.gd`、`repro_log.gd`。
2. 当前 `app.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - 7 项禁止依赖检查全部 PASS

### 验证 2：生命周期服务调用检查

1. `run_lifecycle_contract_check.sh` 应检测到 `app.gd` 必须通过 `run_flow_service.lifecycle_service` 调用生命周期方法。
2. 当前 `app.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - 3 项生命周期调用检查全部 PASS

### 验证 3：总门禁集成

1. `make workflow-check TASK_ID=phase12-run-flow-lifecycle-contract-gate-v1` 应串行执行所有门禁脚本。
2. 所有门禁应通过。

- [x] 结果记录：通过 - 所有门禁脚本串行执行并全部通过

## 回归检查项

- [x] `run_lifecycle_contract_check.sh` 输出风格与现有门禁脚本一致（PASS/FAIL，可读错误信息）
- [x] `workflow_check.sh` 正确串行执行新门禁
- [x] 文档同步更新完成
