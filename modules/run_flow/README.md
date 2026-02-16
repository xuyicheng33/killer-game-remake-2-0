# run_flow

状态：
- Phase 2 第一批已落地（shop/event/rest 场景去业务化）

目标职责：
- 承接应用服务层流程编排：地图 -> 战斗 -> 奖励 -> 地图，以及 REST/SHOP/EVENT 分支。
- 统一场景切换决策、流程事件接线、checkpoint 触发点。

当前实现：
- `run_flow_service.gd`：应用层服务聚合入口，向场景注入子服务。
- `shop_flow_service.gd`：商店命令（购买/移除/离开）写状态入口。
- `event_flow_service.gd`：事件命令（应用选项/继续）写状态入口。
- `rest_flow_service.gd`：营火命令（休息/强化）写状态入口。

现状说明：
- `scenes/shop|events|map/rest` 已改为“收输入 + 调服务 + 刷界面”。
- `scenes/app/app.gd` 仍保留主流程编排，后续继续向 `run_flow` 迁移。
