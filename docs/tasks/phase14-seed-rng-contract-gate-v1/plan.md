# 任务计划

## 基本信息

- 任务 ID：`phase14-seed-rng-contract-gate-v1`
- 任务级别：`L1`
- 主模块：`seed_replay`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

新增 seed/RNG 契约门禁，保护"确定性洗牌 + 读档随机流连续性"的关键约束，避免后续回归。本任务只做门禁与文档回填，不改玩法逻辑。

## 范围边界

- 包含：
  - 新增脚本：`dev/tools/seed_rng_contract_check.sh`
  - 接入总门禁：修改 `dev/tools/workflow_check.sh`
  - 文档同步：`seed_replay/README.md`、`module_architecture.md`、`module_boundaries_v1.md`、`work_logs/2026-02.md`
- 不包含：
  - 玩法改动
  - 业务代码修改
  - 新随机流设计

## 改动白名单文件

- `dev/tools/seed_rng_contract_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `runtime/modules/seed_replay/README.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase14-seed-rng-contract-gate-v1/plan.md`
- `docs/tasks/phase14-seed-rng-contract-gate-v1/handoff.md`
- `docs/tasks/phase14-seed-rng-contract-gate-v1/verification.md`

## 实施步骤

1. 新增 `seed_rng_contract_check.sh`：
   - 检查 `card_pile.gd` 存在 `shuffle_with_rng(stream_key)` 方法。
   - 检查 `shuffle_with_rng` 内使用 `RunRng.randi_range`（非系统默认 shuffle）。
   - 检查 `player_handler.gd` 的 `start_battle` 使用 `shuffle_with_rng("battle_start_shuffle")`。
   - 检查 `player_handler.gd` 的 `reshuffle_deck_from_discard` 使用 `shuffle_with_rng("reshuffle_discard")`。
   - 检查 `run_lifecycle_service.gd` 存在 `restore_run_state` 逻辑。
   - 检查 `run_lifecycle_service.gd` 存在 `begin_run` 回退逻辑。
2. 修改 `workflow_check.sh`，串行纳入新门禁。
3. 更新相关文档回填门禁说明。

## 验证方案

1. `bash dev/tools/seed_rng_contract_check.sh`
2. `make workflow-check TASK_ID=phase14-seed-rng-contract-gate-v1`

## 风险与回滚

- 风险：无（本任务只新增门禁脚本，不修改业务代码）。
- 回滚方式：回滚本任务白名单文件。
