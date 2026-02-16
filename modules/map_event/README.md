# map_event

状态：
- Phase B / B2 `feat-map-graph-progression-v1`：已接入多层路径图与可达性推进。

职责：
- 提供地图节点与图结构生成（节点类型、楼层、连线）。
- 提供“可达节点 -> 选择 -> 推进下一批可达节点”的状态基础。

当前最小实现：
- `map_generator.gd`：生成 Act1 多层路径图（普通/精英/休息/事件/商店/Boss）。
- `map_graph_data.gd`：图数据容器与查询接口。
