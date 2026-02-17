# 任务计划

## 基本信息

- 任务 ID：`phase13-persistence-contract-gate-v1`
- 任务级别：`L1`
- 主模块：`persistence`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

新增 persistence 契约门禁，防止后续改动破坏 phase10 的"状态层存档兼容"能力。本任务只做门禁与文档回填，不改玩法逻辑。

## 范围边界

- 包含：
  - 新增脚本：`dev/tools/persistence_contract_check.sh`
  - 接入总门禁：修改 `dev/tools/workflow_check.sh`
  - 文档同步：`persistence/README.md`、`run_state.md`、`module_architecture.md`、`module_boundaries_v1.md`、`work_logs/2026-02.md`
- 不包含：
  - 玩法改动
  - 业务代码修改
  - 新存档格式设计

## 改动白名单文件

- `dev/tools/persistence_contract_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `runtime/modules/persistence/README.md`
- `docs/contracts/run_state.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase13-persistence-contract-gate-v1/plan.md`
- `docs/tasks/phase13-persistence-contract-gate-v1/handoff.md`
- `docs/tasks/phase13-persistence-contract-gate-v1/verification.md`

## 实施步骤

1. 新增 `persistence_contract_check.sh`：
   - 检查 `SAVE_VERSION` 与 `MIN_COMPAT_VERSION` 常量存在。
   - 检查 `_serialize_player_stats` 包含 `statuses` 字段。
   - 检查 `_apply_player_stats` 包含 `statuses` 恢复逻辑。
   - 检查读取 `statuses` 时对旧存档有默认空字典兜底。
2. 修改 `workflow_check.sh`，串行纳入新门禁。
3. 更新相关文档回填门禁说明。

## 验证方案

1. `bash dev/tools/persistence_contract_check.sh`
2. `make workflow-check TASK_ID=phase13-persistence-contract-gate-v1`

## 风险与回滚

- 风险：无（本任务只新增门禁脚本，不修改业务代码）。
- 回滚方式：回滚本任务白名单文件。
