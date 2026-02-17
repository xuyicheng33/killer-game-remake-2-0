# ui_shell

状态：
- 部分实现（已引入首批 `viewmodel/adapter`，场景脚本仍在 `runtime/scenes/ui/*.gd`）

职责：
- 承载 UI 展示与交互壳层。
- 读取模块输出并刷新界面，不拥有核心业务状态。

目录：
- `runtime/modules/ui_shell/viewmodel/`
  - `stats_view_model.gd`：将 `Stats` 投影为 block/health/statuses 展示数据。
  - `relic_potion_view_model.gd`：将 `RunState` 投影为遗物/药水文案与可见性数据。
- `runtime/modules/ui_shell/adapter/`
  - `stats_ui_adapter.gd`：监听 `stats.stats_changed`，向 `stats_ui` 推送只读投影。
  - `relic_potion_ui_adapter.gd`：监听 `RunState.changed` 与 `RelicPotionSystem.log_updated`，向 `relic_potion_ui` 推送只读投影并转发“使用药水”命令。

现状映射：
- `runtime/scenes/ui/battle_ui.gd`：展示回合 UI + 牌区计数。
- `runtime/scenes/ui/stats_ui.gd`：读取 `StatsUIAdapter` 投影并渲染属性与状态徽章。
- `runtime/scenes/ui/relic_potion_ui.gd`：读取 `RelicPotionUIAdapter` 投影并发送“使用药水”交互命令。

边界约束：
- 禁止在 UI 脚本中新增效果结算、敌方决策、存档读写逻辑。
- UI 命令入口优先走 adapter/service，不直接调用领域对象写接口。

契约门禁（Phase 7）：
- `bash dev/tools/ui_shell_contract_check.sh`
  - 禁止 `runtime/scenes/ui/*.gd` 直接调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`。
  - 强制 `stats_ui.gd`、`relic_potion_ui.gd` 维持 `scene -> adapter -> viewmodel` 接入链路。
- `make workflow-check TASK_ID=<task-id>`
  - 默认会串行执行 `ui_shell_contract_check.sh`，作为提交流程必过项。
