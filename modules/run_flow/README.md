# run_flow

状态：
- Phase 7 已落地（route 常量单点定义 + payload 键位门禁）

目标职责：
- 承接应用服务层流程编排：地图 -> 战斗 -> 奖励 -> 地图，以及 REST/SHOP/EVENT 分支。
- 统一场景切换决策、流程事件接线、checkpoint 触发点。

当前实现：
- `run_flow_service.gd`：应用层服务聚合入口，向场景注入子服务。
- `flow_context.gd`：跨页面流程上下文（`pending_node_type` / `pending_reward_gold`）统一承载对象。
- `route_dispatcher.gd`：统一路由常量与命令返回构造（`next_route + payload`）。
- `map_flow_service.gd`：地图节点进入、placeholder 楼层推进、非战斗节点完成后路由决策。
- `shop_flow_service.gd`：商店命令（购买/移除/离开）写状态入口。
- `event_flow_service.gd`：事件命令（应用选项/继续）写状态入口。
- `rest_flow_service.gd`：营火命令（休息/强化）写状态入口。
- `battle_flow_service.gd`：战斗完成判定与奖励应用命令入口。

命令返回契约（统一字典）：
- 必含：`next_route`（`battle` / `reward` / `rest` / `shop` / `event` / `game_over` / `map`）。
- 可选：
  - `accepted`：地图节点进入是否成功。
  - `node_type`：当前节点类型。
  - `reward_gold`：进入战斗/奖励页时的金币基数。
  - `bonus_log`：B3 商店/事件离开后的额外奖励日志。
  - `game_over_text`：失败文案。
  - `reward_log`：奖励写回日志。

现状说明：
- `scenes/shop|events|map/rest` 已改为“收输入 + 调服务 + 刷界面”。
- `scenes/app/app.gd` 已收敛为“事件接线 + 场景实例化 + 路由执行”；地图节点进入、placeholder 跳转、非战斗节点完成决策迁移到 `MapFlowService`，`pending_*` 上下文迁移到 `RunFlowService.flow_context`。

最小契约测试（可脚本化）：
- `bash tools/run_flow_contract_check.sh`
  - 覆盖 `ROUTE_*` 常量单点定义（仅允许 `route_dispatcher.gd` 定义）。
  - 覆盖 `map node type -> next_route` 映射
  - 覆盖 `next_route` 结果键与 map/battle 关键 payload 键位（`accepted/node_id/node_type/reward_gold/bonus_log/game_over_text/reward_log`）
- `make workflow-check TASK_ID=<task-id>`
  - 默认会串行执行 `run_flow_contract_check.sh`，作为提交流程必过项。
