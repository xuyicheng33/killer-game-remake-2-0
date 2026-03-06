# Progress Log

## 2026-02-15

- 完成参考库抽样深读，提炼出分阶段模块顺序。
- 在根目录导入教程 UI/交互层（作为 battle legacy 基线）。
- 新增 `RunState`、`MapNodeData`、`MapGenerator`、`MapScreen`、`GameApp`。
- 主场景切换到 `scenes/app/app.tscn`，形成地图到战斗的最小闭环。
- 改造 `BattleOverPanel` 与 `Events`，实现 battle 结果回传。
- 初始化 Git 仓库。
- 优化 workflow/new-task/install-hooks，并让 `make workflow-check TASK_ID=feat-bootstrap-v0-20260215` 通过。
- 新增文档：`docs/archive/module_build_order.md`、`docs/ui_asset_requirements.md`。
- 修复运行时报错（`RunState` 信号机制与教程目录重复类注册冲突）。
- 新增任务流水线文档：`docs/archive/build_execution_plan_v0.md`（含每任务可运行验收点）。
- 重构目录结构：新增 `references/`，并迁移教程基线与原版参考资料。
- 清理无用文件：删除 `.DS_Store` 与 `references/tutorial_baseline/.godot` 缓存目录。
- 新增文档：`docs/gap_analysis_2026-02-15_v2.md`、`docs/development_roadmap_v2.md`、`docs/resource_rebuild_backlog.md`、`docs/repo_structure.md`、`docs/assets_licenses.md`。

## 2026-02-17

- 启动任务 `phase6-ui-shell-viewmodel-decoupling-v1`。
- 完成基线扫描：确认 `stats_ui.gd` 与 `relic_potion_ui.gd` 的直接依赖与写入路径。
- 确认本次样板改造路径：`modules/ui_shell/viewmodel/*` + `modules/ui_shell/adapter/*`。
- 新增首批 ui_shell 组件：`StatsViewModel/StatsUIAdapter`、`RelicPotionViewModel/RelicPotionUIAdapter`。
- 完成 `scenes/ui/stats_ui.gd`、`scenes/ui/relic_potion_ui.gd` 瘦身改造（读投影 + 发命令）。
- 补齐任务三件套与架构文档同步。
- 完成验证：`rg` 静态检查通过，`make workflow-check TASK_ID=phase6-ui-shell-viewmodel-decoupling-v1` 通过。
- 启动任务 `phase7-quality-gates-and-regression-v1`。
- 新增 `dev/tools/ui_shell_contract_check.sh`，固化 UI 直写 `run_state` 拦截与 stats/relic_potion adapter/viewmodel 接线检查。
- 扩展 `dev/tools/run_flow_contract_check.sh`，增加 `ROUTE_*` 常量单点定义校验与关键 payload 键位回归检查。
- 更新 `dev/tools/workflow_check.sh`，接入 `ui_shell_contract_check + run_flow_contract_check` 聚合门禁。
- 同步 `modules/ui_shell/README.md`、`modules/run_flow/README.md`、`module_boundaries_v1/module_architecture/repo_structure/work_logs`。
- 新增任务三件套：`docs/tasks/phase7-quality-gates-and-regression-v1/{plan,handoff,verification}.md`。

## 2026-03-06

- 完成稳定性收口任务 `fix-stability-hardening-v1`，将项目基线从“可跑但不稳”收口到“本地与远端可验证”。
- `app.gd` 改为显式 battle 属性注入，移除对 `init_battle` 的场景层动态调用，`battle_relic_injection` 门禁恢复通过。
- 新增 `dev/tools/ensure_godot_import.sh`，并将 `run_gut_tests.sh` / `run_gut_test_file.sh` 接入 import 预热；干净副本下 smoke 可自动导入后通过。
- GitHub Actions 现在安装 Godot 4.5.1，并执行 project import + `ci-check` + `make test`，远端不再是“未装 Godot 的假绿”。
- `CharacterStats.create_instance`、`RunState.init_with_character` 补齐空资源容忍；`RunStateDeserializer`、`GameEffectExecutor` 相关回归恢复通过。
- `battle.gd` 增加敌人回收空父节点保护，修复 DOT/异步击杀链路的空引用风险。
- `BuffSystem` 保持注册式架构，同时补 `_trigger_poison` / `_trigger_burn` 兼容入口；旧集成测试链路恢复通过。
- `EnemySpawnService` 去除模块层 `Enemy` 场景类型依赖，`BattleParticipantResolver` 回退为“优先 session_port，失败时选当前有效 player 组节点”。
- 当前本地验证结果：`make ci-check` 通过、`make test` 通过（30 scripts / 284 tests / 284 passing）。
- 已知非阻断项保留：自动跑局仍有遭遇表 coverage warning（`floor=5 elite`、`floor=12 common`），以及既有 orphan/resource leak 告警；本轮未扩展到内容表深清理。
