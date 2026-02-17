# seed_replay

状态：
- 历史命名占位（当前无 `.gd` 实现）

职责（历史语义）：
- 存档、随机种子、复盘日志。

现状对齐：
- 存档能力：`runtime/modules/persistence/save_service.gd`
- 种子随机流：`runtime/global/run_rng.gd`
- 复盘日志：`runtime/global/repro_log.gd`

确定性洗牌实现（Phase 9）：
- CardPile 确定性洗牌：`content/custom_resources/card_pile.gd`
  - `shuffle_with_rng(stream_key)` 方法使用 RunRng 实现 Fisher-Yates 洗牌
- 战斗洗牌调用：`runtime/scenes/player/player_handler.gd`
  - 战斗开始：`battle_start_shuffle` 流
  - 弃牌堆重洗：`reshuffle_discard` 流
- 同一 seed 下抽牌序列可复现，读档后随机流连续

契约门禁（Phase 14）：
- 门禁脚本：`dev/tools/seed_rng_contract_check.sh`
- 检查项：
  - `card_pile.gd` 存在 `shuffle_with_rng(stream_key)` 方法
  - `shuffle_with_rng` 内使用 `RunRng.randi_range`（非系统默认 shuffle）
  - `player_handler.gd` 的 `start_battle` 使用 `shuffle_with_rng("battle_start_shuffle")`
  - `player_handler.gd` 的 `reshuffle_deck_from_discard` 使用 `shuffle_with_rng("reshuffle_discard")`
  - `run_lifecycle_service.gd` 存在 `restore_run_state` 逻辑
  - `run_lifecycle_service.gd` 存在 `begin_run` 回退逻辑
- 目的：防止后续改动破坏"确定性洗牌 + 读档随机流连续性"约束

约束：
- Phase 1 起不在本目录新增实现，避免与 `persistence` 双轨并行。
