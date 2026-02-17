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

冒烟验证（Phase 15）：
- 冒烟脚本：`dev/tools/save_load_replay_smoke.sh`
- 检查项：
  - fixed-seed bootstrap check：RunRng/RunLifecycleService 支持固定种子新局
  - save/load rng continuity check：RunRng 状态导出/恢复、SaveService 存档/读档集成
  - battle->reward->map route smoke check：路由常量与核心流程方法
  - deterministic shuffle smoke check：CardPile/PlayerHandler 确定性洗牌
- 用法：`bash dev/tools/save_load_replay_smoke.sh`
- 注意：此脚本不默认接入 workflow-check，因与现有契约门禁有部分重叠，建议在 verification 阶段手动执行

约束：
- Phase 1 起不在本目录新增实现，避免与 `persistence` 双轨并行。
