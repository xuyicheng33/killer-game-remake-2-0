# 验证记录

## 步骤

1. 执行 `make ci-check`
2. 执行 `make test`
3. 执行聚类回归：
   - `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_battle_flow.gd 180`
   - `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_game_effect_executor.gd 180`
   - `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_run_state_deserializer.gd 180`
   - `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_runtime_contract_guards.gd 180`
4. 新建无 `.godot` 缓存的干净副本，执行：
   - `bash dev/tools/run_gut_test_file.sh res://dev/tests/test_gut_smoke.gd 120`

## 结果

- `make ci-check`：通过
  - contract / structure / type safety / scene write guards 全部通过
  - 引擎 smoke 与 `test_run_flow.gd` 通过
- `make test`：通过
  - 30 scripts
  - 284 tests
  - 284 passing
- 聚类回归：全部通过
- 干净副本 smoke：通过，测试脚本会自动 import project metadata 后再执行 GUT

## 已知告警（本轮保留）

- `test_full_run_autoplay` 与 `test_run_flow` 仍会打印 encounter coverage warning：
  - `floor=5 tags=["elite"]`
  - `floor=12 tags=["common"]`
- 测试尾部仍存在既有 orphan / resource leak 告警：
  - `test_enemy_actions.gd` 的 2 个 orphan
  - Godot 退出时的 resource / RID / ObjectDB leak 告警

## 结论

- 本轮目标达成：主干已恢复到“本地与远端都可验证”的稳定状态。
- 后续若继续收口，建议优先处理 encounter coverage warning 与 orphan/resource leak。
