# map_event

状态：
- Phase B / B3 `feat-rest-shop-event-v1`：已接入 REST/SHOP/EVENT 节点流程（最小可用）。

职责：
- 提供地图节点与图结构生成（节点类型、楼层、连线）。
- 提供“可达节点 -> 选择 -> 推进下一批可达节点”的状态基础。
- 提供事件模板与事件效果应用服务。

当前最小实现：
- `map_generator.gd`：生成 Act1 多层路径图（普通/精英/休息/事件/商店/Boss）。
- `map_graph_data.gd`：图数据容器与查询接口。
- `event_catalog.gd`：10 条基础事件模板。
- `event_service.gd`：事件抽取与效果应用（金币/生命/牌组变更等）。
