# 任务计划：fix-stability-hardening-v1

## 基本信息

- 任务 ID：`fix-stability-hardening-v1`
- 任务级别：`L2`
- 主模块：`run_flow / battle_loop / persistence / engineering`
- 负责人：`Codex`
- 日期：`2026-03-06`

## 目标

将当前主干从“能跑但不稳”收口到“本地与远端都可验证”的状态：修复门禁阻断、恢复全量测试、补齐 import 预热链路，并同步进度/路线图文档与任务三件套。

## 范围边界

- 包含：
  - battle 场景显式注入替代动态 `call`
  - 本地/远端 Godot import 预热链路
  - `CharacterStats` / `RunState` 初始化容错
  - `battle.gd` 敌人回收空父节点保护
  - `BuffSystem` 最小兼容入口
  - `EnemySpawnService` 去场景类型依赖
  - `BattleParticipantResolver` 回退策略修复
  - `GameEffectExecutor` draw callable 路径修复
  - 进度、路线图、工作日志、任务三件套同步
- 不包含：
  - 遭遇表全量 coverage 扩编
  - orphan / resource leak 深度治理
  - Phase D 视觉/音频继续扩展

## 改动白名单文件

- `AGENTS.md`
- `.github/workflows/ci.yml`
- `content/custom_resources/character_stats.gd`
- `dev/tests/unit/test_game_effect_executor.gd`
- `dev/tests/unit/test_game_effect_executor.gd.uid`
- `dev/tests/unit/test_intent_rules.gd.uid`
- `dev/tests/unit/test_relic_condition_checker.gd.uid`
- `dev/tests/unit/test_run_state_deserializer.gd.uid`
- `dev/tests/unit/test_status_handler.gd.uid`
- `dev/tools/dynamic_call_guard_check.sh`
- `dev/tools/ensure_godot_import.sh`
- `dev/tools/run_gut_test_file.sh`
- `dev/tools/run_gut_tests.sh`
- `runtime/global/ui_layout.gd.uid`
- `runtime/modules/battle_loop/enemy_spawn_service.gd`
- `runtime/modules/buff_system/buff_system.gd`
- `runtime/modules/buff_system/combatant_role.gd.uid`
- `runtime/modules/buff_system/status_handler.gd.uid`
- `runtime/modules/card_system/hand_zone_port.gd.uid`
- `runtime/modules/effect_engine/game_effect_executor.gd`
- `runtime/modules/enemy_intent/intent_action_data.gd.uid`
- `runtime/modules/relic_potion/battle_participant_resolver.gd`
- `runtime/modules/run_meta/run_state.gd`
- `runtime/scenes/app/app.gd`
- `runtime/scenes/battle/battle.gd`
- `docs/session/progress.md`
- `docs/roadmap/README.md`
- `docs/work_logs/2026-03.md`
- `docs/tasks/fix-stability-hardening-v1/plan.md`
- `docs/tasks/fix-stability-hardening-v1/handoff.md`
- `docs/tasks/fix-stability-hardening-v1/verification.md`

## 实施步骤

1. 修复 battle 显式注入与测试 import 预热链路，恢复 `ci-check` 可运行。
2. 修复初始化链、死亡回收、BuffSystem 兼容、resolver 回退与模块层类型依赖，恢复失败聚类测试。
3. 跑 `make ci-check`、`make test`、失败聚类回归与干净副本 smoke。
4. 同步 `progress / roadmap / work_logs` 与任务三件套。

## 验证方案

1. `make ci-check`
2. `make test`
3. `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_battle_flow.gd 180`
4. `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_game_effect_executor.gd 180`
5. `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_run_state_deserializer.gd 180`
6. `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_runtime_contract_guards.gd 180`
7. 干净副本执行 `bash dev/tools/run_gut_test_file.sh res://dev/tests/test_gut_smoke.gd 120`

## 风险与回滚

- 风险：
  - `dynamic_call_guard` / `module_scene_type_dependency_check` 与新实现存在口径差异，allowlist 需要保持最小化。
  - import 预热引入额外耗时；若戳记逻辑失效，CI 时长可能上升。
  - 本轮保留的 encounter coverage warning 可能继续出现在 autoplay/test logs。
- 回滚方式：
  - 代码回滚使用 `git revert <commit>`。
  - 若 import 预热链路引发 CI 异常，可先回退 `.github/workflows/ci.yml` 与 `dev/tools/ensure_godot_import.sh`，保留运行态修复部分。

