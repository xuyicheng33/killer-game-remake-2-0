# 验证记录

## 基本信息

- 任务 ID：`phase14-seed-rng-contract-gate-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `bash dev/tools/seed_rng_contract_check.sh`
  - 结果：
    - `[seed_rng_contract] checking card_pile.gd shuffle_with_rng implementation...`
    - `[PASS] card_pile.gd must have shuffle_with_rng(stream_key: String) method`
    - `[PASS] shuffle_with_rng must use RunRng.randi_range with stream_key`
    - `[seed_rng_contract] checking player_handler.gd battle shuffle calls...`
    - `[PASS] player_handler.start_battle must use shuffle_with_rng("battle_start_shuffle")`
    - `[PASS] player_handler.reshuffle_deck_from_discard must use shuffle_with_rng("reshuffle_discard")`
    - `[seed_rng_contract] checking run_lifecycle_service.gd RNG restore logic...`
    - `[PASS] run_lifecycle_service.try_load_saved_run must call restore_run_state`
    - `[PASS] run_lifecycle_service must have begin_run fallback when restore fails`
    - `[seed_rng_contract] all checks passed.`
- [x] `make workflow-check TASK_ID=phase14-seed-rng-contract-gate-v1`
  - 结果：
    - `[repo-structure-check] passed.`
    - `[ui_shell_contract] all checks passed.`
    - `[run_flow_contract] all checks passed.`
    - `[run_lifecycle_contract] all checks passed.`
    - `[persistence_contract] all checks passed.`
    - `[seed_rng_contract] all checks passed.`
    - `[workflow-check] passed.`

## 门禁功能验证

### 验证 1：CardPile 洗牌方法检查

1. `seed_rng_contract_check.sh` 应检测到 `card_pile.gd` 存在 `shuffle_with_rng(stream_key)` 方法。
2. 当前 `card_pile.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - CardPile 洗牌方法检查 PASS

### 验证 2：RunRng 使用检查

1. `seed_rng_contract_check.sh` 应检测到 `shuffle_with_rng` 内使用 `RunRng.randi_range`。
2. 当前 `card_pile.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - RunRng 使用检查 PASS

### 验证 3：战斗洗牌调用检查

1. `seed_rng_contract_check.sh` 应检测到 `player_handler.gd` 的 `start_battle` 使用 `shuffle_with_rng("battle_start_shuffle")`。
2. `seed_rng_contract_check.sh` 应检测到 `player_handler.gd` 的 `reshuffle_deck_from_discard` 使用 `shuffle_with_rng("reshuffle_discard")`。
3. 当前 `player_handler.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - 战斗洗牌调用检查 PASS

### 验证 4：RNG 恢复逻辑检查

1. `seed_rng_contract_check.sh` 应检测到 `run_lifecycle_service.gd` 存在 `restore_run_state` 逻辑。
2. `seed_rng_contract_check.sh` 应检测到 `run_lifecycle_service.gd` 存在 `begin_run` 回退逻辑。
3. 当前 `run_lifecycle_service.gd` 已符合规范，门禁应通过。

- [x] 结果记录：通过 - RNG 恢复逻辑检查 PASS

### 验证 5：总门禁集成

1. `make workflow-check TASK_ID=phase14-seed-rng-contract-gate-v1` 应串行执行所有门禁脚本。
2. 所有门禁应通过。

- [x] 结果记录：通过 - 所有门禁脚本串行执行并全部通过

## 回归检查项

- [x] `seed_rng_contract_check.sh` 输出风格与现有门禁脚本一致（PASS/FAIL，可读错误信息）
- [x] `workflow_check.sh` 正确串行执行新门禁
- [x] 文档同步更新完成
