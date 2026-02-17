# seed_replay

状态：
- 历史命名占位（当前无 `.gd` 实现）

职责（历史语义）：
- 存档、随机种子、复盘日志。

现状对齐：
- 存档能力：`modules/persistence/save_service.gd`
- 种子随机流：`global/run_rng.gd`
- 复盘日志：`global/repro_log.gd`

约束：
- Phase 1 起不在本目录新增实现，避免与 `persistence` 双轨并行。
