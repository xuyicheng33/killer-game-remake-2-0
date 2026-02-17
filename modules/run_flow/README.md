# run_flow

状态：
- Phase 3 第一批已落地（shop/event/rest + battle result/reward 编排）

目标职责：
- 承接应用服务层流程编排：地图 -> 战斗 -> 奖励 -> 地图，以及 REST/SHOP/EVENT 分支。
- 统一场景切换决策、流程事件接线、checkpoint 触发点。

当前实现：
- `run_flow_service.gd`：应用层服务聚合入口，向场景注入子服务。
- `shop_flow_service.gd`：商店命令（购买/移除/离开）写状态入口。
- `event_flow_service.gd`：事件命令（应用选项/继续）写状态入口。
- `rest_flow_service.gd`：营火命令（休息/强化）写状态入口。
- `battle_flow_service.gd`：战斗完成判定与奖励应用命令入口。

命令返回契约（统一字典）：
- 必含：`next_route`（`reward` / `game_over` / `map`）。
- 可选：
  - `reward_gold`：进入奖励页时的金币基数。
  - `game_over_text`：失败文案。
  - `reward_log`：奖励写回日志。

现状说明：
- `scenes/shop|events|map/rest` 已改为“收输入 + 调服务 + 刷界面”。
- `scenes/app/app.gd` 的 battle 结果处理与奖励应用已迁到 `BattleFlowService`，主流程其余部分后续继续迁移。
