# 任务计划

## 基本信息

- 任务 ID：`phase6-ui-shell-viewmodel-decoupling-v1`
- 任务级别：`L2`
- 主模块：`ui_shell`
- 负责人：Codex
- 日期：2026-02-17

## 目标

推进 UI Shell 化：为 `stats_ui`、`relic_potion_ui` 引入轻量 `viewmodel/adapter`，将 UI 层收敛为“读投影 + 发命令”，保持行为等价。

## 范围边界

- 包含：
  - 在 `modules/ui_shell` 新增首批 `viewmodel + adapter`。
  - 改造 `scenes/ui/stats_ui.gd`、`scenes/ui/relic_potion_ui.gd`，去除 UI 侧业务投影拼装与直接写入路径。
  - 同步模块边界与仓库结构文档。
  - 新增本任务三件套并通过 `workflow-check`。
- 不包含：
  - 玩法规则语义改动（数值、触发时机、奖励规则）。
  - 存档 schema 与 persistence 协议变更。
  - 新增 domain -> scenes 反向依赖。
  - 大规模 UI 重写。

## 改动白名单文件

- `modules/ui_shell/viewmodel/stats_view_model.gd`
- `modules/ui_shell/viewmodel/relic_potion_view_model.gd`
- `modules/ui_shell/adapter/stats_ui_adapter.gd`
- `modules/ui_shell/adapter/relic_potion_ui_adapter.gd`
- `scenes/ui/stats_ui.gd`
- `scenes/ui/relic_potion_ui.gd`
- `modules/ui_shell/README.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase6-ui-shell-viewmodel-decoupling-v1/`
- `task_plan.md`
- `findings.md`
- `progress.md`

## 实施步骤

1. 基线扫描：识别 `stats_ui` / `relic_potion_ui` 对领域对象的直接依赖与写入路径。
2. 新增 `StatsViewModel + StatsUIAdapter`，将属性/状态徽章投影计算移出 `stats_ui.gd`。
3. 新增 `RelicPotionViewModel + RelicPotionUIAdapter`，将遗物/药水展示拼装与命令转发移出 `relic_potion_ui.gd`。
4. 更新 `ui_shell` 与架构文档，记录“首批样板已迁移、其余 UI 待迁移”现状。
5. 执行静态检索与 workflow 守门，输出验证记录。

## 验证方案

1. `rg -n "run_state\\.(set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/ui`
2. `rg -n "ViewModel|view_model|adapter" scenes/ui modules`
3. `make workflow-check TASK_ID=phase6-ui-shell-viewmodel-decoupling-v1`

## 风险与回滚

- 风险：adapter 信号接线遗漏可能导致 UI 不刷新或重复刷新。
- 风险：当前仅覆盖两处 UI，其他 UI 仍可能保留存量直连。
- 回滚方式：回滚 `modules/ui_shell/{viewmodel,adapter}` 与两个 UI 脚本改动，可恢复 Phase 5 路径。
