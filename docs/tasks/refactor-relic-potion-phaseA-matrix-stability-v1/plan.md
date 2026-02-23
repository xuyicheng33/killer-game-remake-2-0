# Plan

- Task ID: `refactor-relic-potion-phaseA-matrix-stability-v1`
- 主模块：`relic_potion`
- 目标：
  1. 增加卡牌/遗物/药水矩阵统一入口与报告。
  2. 提升 GUT headless 运行稳定性。
  3. 将 `relic_potion_system` 拆分为缓存/执行/药水服务，保持外部 API 不变。

## 白名单改动
- `Makefile`
- `dev/tools/run_gut_tests.sh`
- `dev/tools/run_gut_test_file.sh`
- `dev/tools/run_effect_matrix.sh`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/relic_potion/relic_runtime_cache.gd`
- `runtime/modules/relic_potion/relic_effect_executor.gd`
- `runtime/modules/relic_potion/potion_use_service.gd`
- `runtime/modules/relic_potion/README.md`
- `docs/work_logs/2026-02.md`

## 验证
- 运行 `make test-effects-matrix`。
- 运行 `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`。
