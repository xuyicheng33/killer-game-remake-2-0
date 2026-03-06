# 任务交接：fix-stability-hardening-v1

## 基本信息

- 任务 ID：`fix-stability-hardening-v1`
- 主模块：`run_flow / battle_loop / persistence / engineering`
- 提交人：`Codex`
- 日期：`2026-03-06`

## 改动摘要

- `app.gd` 改为显式 battle 属性注入，移除场景层动态 `call` 初始化，恢复 `battle_relic_injection` 门禁。
- 新增 `dev/tools/ensure_godot_import.sh`，`run_gut_tests.sh` / `run_gut_test_file.sh` 支持 import 预热与缓存戳记；GitHub Actions 同步安装 Godot 4.5.1 并执行 import + `ci-check` + `make test`。
- `CharacterStats.create_instance` 与 `RunState.init_with_character` 变为“空资源容忍”，修复最小测试夹具下的空 deck / 空 stats 问题。
- `battle.gd` 的敌人死亡回收增加空父节点保护，DOT/异步击杀链路不再因 `remove_child(null)` 崩溃。
- `BuffSystem` 保持 `StatusHandler` 注册式架构，同时补 `_trigger_poison` / `_trigger_burn` 兼容入口，旧测试链路恢复通过。
- `EnemySpawnService` 去除模块层 `Enemy` 场景类型依赖，改为 `Node` + `set()` 注入；`BattleParticipantResolver` 调整为优先 session_port，失败时回退当前有效 `player` 组节点。
- `GameEffectExecutor` 修复 draw callable 路径，并将对应单测改为字典可变引用写法，避免 GDScript 闭包捕获误判。
- 同步 `docs/session/progress.md`、`docs/roadmap/README.md`、`docs/work_logs/2026-03.md` 到当前真实基线。

## 变更文件

- `.github/workflows/ci.yml`
- `content/custom_resources/character_stats.gd`
- `dev/tests/unit/test_game_effect_executor.gd`
- `dev/tools/dynamic_call_guard_check.sh`
- `dev/tools/ensure_godot_import.sh`
- `dev/tools/run_gut_test_file.sh`
- `dev/tools/run_gut_tests.sh`
- `runtime/modules/battle_loop/enemy_spawn_service.gd`
- `runtime/modules/buff_system/buff_system.gd`
- `runtime/modules/effect_engine/game_effect_executor.gd`
- `runtime/modules/relic_potion/battle_participant_resolver.gd`
- `runtime/modules/run_meta/run_state.gd`
- `runtime/scenes/app/app.gd`
- `runtime/scenes/battle/battle.gd`
- `docs/session/progress.md`
- `docs/roadmap/README.md`
- `docs/work_logs/2026-03.md`
- `docs/tasks/fix-stability-hardening-v1/{plan,handoff,verification}.md`
- 若干 Godot `.uid` 同步文件（见 plan 白名单）

## 验证结果

- [x] `make ci-check`：通过
- [x] `make test`：通过（30 scripts / 284 tests / 284 passing）
- [x] 聚类回归：
  - `res://dev/tests/integration/test_battle_flow.gd`
  - `res://dev/tests/unit/test_game_effect_executor.gd`
  - `res://dev/tests/unit/test_run_state_deserializer.gd`
  - `res://dev/tests/unit/test_runtime_contract_guards.gd`
- [x] 干净副本 smoke：自动 import 后通过

## 风险与影响范围

- `ensure_godot_import.sh` 会在源文件更新后重新执行 import，首次跑测试或干净副本验证会更慢；后续依赖戳记跳过重复 import。
- 远端 CI 现在真实运行 Godot，引擎测试失败将直接反映在 GitHub Actions，不再被“未安装 Godot”掩盖。
- encounter coverage warning 与 orphan/resource leak 仍为已知保留项，本轮未上升为失败条件。

## 建议提交信息

- `fix(stability): harden gates, init flow and engine validation（fix-stability-hardening-v1）`

