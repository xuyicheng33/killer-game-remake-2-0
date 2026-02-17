# 任务交接

## 基本信息

- 任务 ID：`phase14-seed-rng-contract-gate-v1`
- 主模块：`seed_replay`
- 提交人：AI 程序员
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 14`
- 状态：`已完成（待用户验证）`

## 改动摘要

1. 新增 `dev/tools/seed_rng_contract_check.sh`：
   - 校验 `card_pile.gd` 存在 `shuffle_with_rng(stream_key)` 方法。
   - 校验 `shuffle_with_rng` 内使用 `RunRng.randi_range`（非系统默认 shuffle）。
   - 校验 `player_handler.gd` 的 `start_battle` 使用 `shuffle_with_rng("battle_start_shuffle")`。
   - 校验 `player_handler.gd` 的 `reshuffle_deck_from_discard` 使用 `shuffle_with_rng("reshuffle_discard")`。
   - 校验 `run_lifecycle_service.gd` 存在 `restore_run_state` 逻辑。
   - 校验 `run_lifecycle_service.gd` 存在 `begin_run` 回退逻辑。
   - 目的：防止后续改动破坏"确定性洗牌 + 读档随机流连续性"约束。
2. 更新 `dev/tools/workflow_check.sh`，串行纳入 `seed_rng_contract_check.sh`。
3. 同步更新 `modules/seed_replay/README.md` 与架构文档（`module_boundaries_v1` / `module_architecture` / `work_logs`）。

## 变更文件

| 文件 | 变更类型 |
|---|---|
| `dev/tools/seed_rng_contract_check.sh` | 新增 |
| `dev/tools/workflow_check.sh` | 修改 |
| `runtime/modules/seed_replay/README.md` | 修改 |
| `docs/module_architecture.md` | 修改 |
| `docs/contracts/module_boundaries_v1.md` | 修改 |
| `docs/work_logs/2026-02.md` | 修改 |

## 验证结果

- [x] 代码改动完成
- [x] `bash dev/tools/seed_rng_contract_check.sh`（已通过）
- [x] `make workflow-check TASK_ID=phase14-seed-rng-contract-gate-v1`（已通过）

## 风险与影响范围

- **风险**：无（本任务只新增门禁脚本，不修改业务代码）。
- **影响范围**：仅影响工作流检查脚本，不影响游戏运行时逻辑。
- **回滚方案**：回滚本任务所有白名单文件。

## 建议提交信息

- `feat(seed_replay): add contract gate to protect deterministic shuffle and rng continuity（phase14-seed-rng-contract-gate-v1）`
