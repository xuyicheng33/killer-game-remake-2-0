# ui_shell

状态：
- 完整实现（所有核心页面已引入 `viewmodel/adapter` 架构）

职责：
- 承载 UI 展示与交互壳层。
- 读取模块输出并刷新界面，不拥有核心业务状态。

目录：
- `runtime/modules/ui_shell/viewmodel/`
  - `stats_view_model.gd`：将 `Stats` 投影为 block/health/statuses 展示数据。
  - `relic_potion_view_model.gd`：将 `RunState` 投影为遗物/药水文案与可见性数据。
  - `battle_ui_view_model.gd`：将牌区计数投影为文案展示数据。
  - `map_ui_view_model.gd`：将 `RunState` / `MapGraphData` 投影为地图节点展示数据。
  - `rest_ui_view_model.gd`：将 `RunState` 投影为休息界面展示数据。
  - `shop_ui_view_model.gd`：将 `RunState` / 商店商品投影为商店界面展示数据。
  - `event_ui_view_model.gd`：将事件模板投影为事件界面展示数据。
  - `reward_ui_view_model.gd`：将 `RewardBundle` 投影为奖励界面展示数据。
- `runtime/modules/ui_shell/adapter/`
  - `stats_ui_adapter.gd`：监听 `stats.stats_changed`，向 `stats_ui` 推送只读投影。
  - `relic_potion_ui_adapter.gd`：监听 `RunState.changed` 与 `RelicPotionSystem.log_updated`，向 `relic_potion_ui` 推送只读投影并转发"使用药水"命令。
  - `battle_ui_adapter.gd`：监听 `CardZonesModel.zone_counts_changed` 与 `Events.player_hand_drawn`，向 `battle_ui` 推送牌区计数投影并转发"结束回合"命令。
  - `map_ui_adapter.gd`：监听 `RunState.changed`，向 `map_screen` 推送地图投影并转发节点选择/重启命令。
  - `rest_ui_adapter.gd`：监听 `RunState.changed`，向 `rest_screen` 推送休息界面投影并转发休息/升级命令。
  - `shop_ui_adapter.gd`：监听 `RunState.changed`，向 `shop_screen` 推送商店投影并转发购买/移除/离开命令。
  - `event_ui_adapter.gd`：向 `event_screen` 推送事件投影并转发选项选择/继续命令。
  - `reward_ui_adapter.gd`：向 `reward_screen` 推送奖励投影并转发卡牌选择/跳过命令。

现状映射：
- `runtime/scenes/ui/battle_ui.gd`：通过 `BattleUIAdapter` 展示回合 UI + 牌区计数。
- `runtime/scenes/ui/stats_ui.gd`：读取 `StatsUIAdapter` 投影并渲染属性与状态徽章。
- `runtime/scenes/ui/relic_potion_ui.gd`：读取 `RelicPotionUIAdapter` 投影并发送"使用药水"交互命令。
- `runtime/scenes/map/map_screen.gd`：读取 `MapUIAdapter` 投影并发送节点选择/重启命令。
- `runtime/scenes/map/rest_screen.gd`：读取 `RestUIAdapter` 投影并发送休息/升级命令。
- `runtime/scenes/shop/shop_screen.gd`：读取 `ShopUIAdapter` 投影并发送购买/移除/离开命令。
- `runtime/scenes/events/event_screen.gd`：读取 `EventUIAdapter` 投影并发送选项选择/继续命令。
- `runtime/scenes/reward/reward_screen.gd`：读取 `RewardUIAdapter` 投影并发送卡牌选择/跳过命令。

边界约束：
- 禁止在 UI 脚本中新增效果结算、敌方决策、存档读写逻辑。
- UI 命令入口优先走 adapter/service，不直接调用领域对象写接口。

契约门禁（Phase 7/8）：
- `bash dev/tools/ui_shell_contract_check.sh`
  - 禁止 `runtime/scenes/ui/*.gd` 直接调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`。
  - 强制 `stats_ui.gd`、`relic_potion_ui.gd`、`battle_ui.gd` 维持 `scene -> adapter -> viewmodel` 接入链路。
  - 禁止 `battle_ui.gd` 直接导入 `card_system/card_zones_model`。
- `make workflow-check TASK_ID=<task-id>`
  - 默认会串行执行 `ui_shell_contract_check.sh`，作为提交流程必过项。
