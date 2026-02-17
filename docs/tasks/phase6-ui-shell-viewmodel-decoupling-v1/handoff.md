# 任务交接

## 基本信息

- 任务 ID：`phase6-ui-shell-viewmodel-decoupling-v1`
- 主模块：`ui_shell`
- 提交人：Codex
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 6（ui shell viewmodel decoupling v1）`
- 状态：`已完成`

## 改动摘要

1. 新增 `modules/ui_shell/viewmodel/stats_view_model.gd` 与 `modules/ui_shell/adapter/stats_ui_adapter.gd`：
   - 将 `Stats` -> UI 展示字段（block/health/status badges）投影移到 viewmodel。
   - 通过 adapter 监听 `stats_changed`，向 `stats_ui` 推送只读投影。
2. 新增 `modules/ui_shell/viewmodel/relic_potion_view_model.gd` 与 `modules/ui_shell/adapter/relic_potion_ui_adapter.gd`：
   - 将 `RunState` -> UI 文案/可见性/按钮列表投影移到 viewmodel。
   - adapter 统一监听 `RunState.changed` 与 `RelicPotionSystem.log_updated`，并转发“使用药水”命令。
3. 瘦身 `scenes/ui/stats_ui.gd`：
   - UI 不再直接调用 `BuffSystem` 拼装 badge 数据。
   - 改为读取 adapter 投影并纯渲染。
4. 瘦身 `scenes/ui/relic_potion_ui.gd`：
   - UI 不再直接遍历 `run_state` 组装文案与按钮状态。
   - UI 不再直接调用业务写入入口，改为调用 adapter 命令。
5. 文档同步：
   - `modules/ui_shell/README.md`
   - `docs/contracts/module_boundaries_v1.md`
   - `docs/module_architecture.md`
   - `docs/repo_structure.md`
   - `docs/work_logs/2026-02.md`

## 迁移了哪些 UI 逻辑

1. `stats_ui`：
   - 迁移逻辑：状态徽章数据获取与筛选、可见性与文本投影计算。
   - 保留逻辑：控件节点创建、文本赋值、布局与样式（font size override）。
2. `relic_potion_ui`：
   - 迁移逻辑：遗物/药水计数文本、遗物列表文本、药水按钮数据、空态提示、按钮可用性、日志文本投影。
   - 保留逻辑：按钮节点创建与绑定、容器清理与界面渲染。

## 哪些未动

1. `RelicPotionSystem` 与 `RunState` 规则实现未改（药水效果、遗物触发时机、奖励语义不变）。
2. `app.gd` 与 `run_flow` 契约未改（现有注入与调用点保持兼容）。
3. `battle_ui` 等其余 UI 尚未迁移到 viewmodel/adapter。

## 残余风险

1. 当前 adapter/viewmodel 仍采用 `Dictionary` 契约，缺少强类型约束，未来字段变更需配套契约测试。
2. UI 刷新依赖信号接线，若后续改动丢失连接，可能出现“数据变化但界面未刷新”。
3. 首批仅覆盖两个 UI，整体 UI Shell 化尚未完成。

## Phase7 建议（测试门禁固化）

1. 新增 `dev/tools/ui_shell_contract_check.sh`：
   - 校验 `scenes/ui` 中禁止模式（例如直接 `run_state.add_*/set_*/remove_*`）。
   - 校验目标 UI 必须引用 `viewmodel/adapter`。
2. 在 `workflow-check` 增加可选任务门禁：
   - 对 `phase7-*` 任务强制执行 `ui_shell_contract_check.sh`。
3. 为 adapter 增加最小脚本化回归用例：
   - `StatsUIAdapter`：`stats_changed` 后投影键值稳定。
   - `RelicPotionUIAdapter`：`use_potion` 后按钮列表与日志投影一致更新。

## 变更文件

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
- `docs/tasks/phase6-ui-shell-viewmodel-decoupling-v1/plan.md`
- `docs/tasks/phase6-ui-shell-viewmodel-decoupling-v1/handoff.md`
- `docs/tasks/phase6-ui-shell-viewmodel-decoupling-v1/verification.md`
