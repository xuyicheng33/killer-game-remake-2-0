# Progress Log

## 2026-02-15

- 完成参考库抽样深读，提炼出分阶段模块顺序。
- 在根目录导入教程 UI/交互层（作为 battle legacy 基线）。
- 新增 `RunState`、`MapNodeData`、`MapGenerator`、`MapScreen`、`GameApp`。
- 主场景切换到 `scenes/app/app.tscn`，形成地图到战斗的最小闭环。
- 改造 `BattleOverPanel` 与 `Events`，实现 battle 结果回传。
- 初始化 Git 仓库。
- 优化 workflow/new-task/install-hooks，并让 `make workflow-check TASK_ID=feat-bootstrap-v0-20260215` 通过。
- 新增文档：`docs/module_build_order.md`、`docs/ui_asset_requirements.md`。
- 修复运行时报错（`RunState` 信号机制与教程目录重复类注册冲突）。
- 新增任务流水线文档：`docs/build_execution_plan_v0.md`（含每任务可运行验收点）。
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
- 新增 `tools/ui_shell_contract_check.sh`，固化 UI 直写 `run_state` 拦截与 stats/relic_potion adapter/viewmodel 接线检查。
- 扩展 `tools/run_flow_contract_check.sh`，增加 `ROUTE_*` 常量单点定义校验与关键 payload 键位回归检查。
- 更新 `tools/workflow_check.sh`，接入 `ui_shell_contract_check + run_flow_contract_check` 聚合门禁。
- 同步 `modules/ui_shell/README.md`、`modules/run_flow/README.md`、`module_boundaries_v1/module_architecture/repo_structure/work_logs`。
- 新增任务三件套：`docs/tasks/phase7-quality-gates-and-regression-v1/{plan,handoff,verification}.md`。
