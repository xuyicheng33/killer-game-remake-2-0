# RunState 契约（v0.3.0）

## 目的

定义跨战斗持久状态字段，确保存档与流程一致。

## 当前核心字段（实现对齐）

| 字段 | 类型 | 描述 |
|---|---|---|
| `seed` | `int` | 本局随机种子 |
| `act` | `int` | 当前章节 |
| `floor` | `int` | 当前层数（从 0 开始） |
| `gold` | `int` | 金币 |
| `player_stats` | `CharacterStats` | 运行时玩家状态容器（含 `health/max_health/deck/draw_pile/discard` 等） |
| `map_graph` | `MapGraphData` | 当前章节地图图结构（运行时对象） |
| `map_current_node_id` | `String` | 当前已进入节点 ID |
| `map_reachable_node_ids` | `PackedStringArray` | 当前可选择节点 ID 集合 |
| `map_visited_node_ids` | `PackedStringArray` | 已走过节点 ID 集合 |
| `relic_capacity` | `int` | 遗物栏容量（B4） |
| `potion_capacity` | `int` | 药水栏容量（B4） |
| `relics` | `Array[RelicData]` | 已持有遗物列表（B4） |
| `potions` | `Array[PotionData]` | 已持有药水列表（B4） |

## B2 地图推进约束（feat-map-graph-progression-v1）

- 节点类型至少包含：`BATTLE` / `ELITE` / `REST` / `SHOP` / `EVENT` / `BOSS`。
- 仅允许选择 `map_reachable_node_ids` 内节点。
- 成功进入节点后：
  - `map_current_node_id` 更新为该节点 ID
  - 该节点写入 `map_visited_node_ids`
  - `map_reachable_node_ids` 更新为该节点的 `next_node_ids`
- 楼层推进由节点流程完成时触发（如战斗胜利奖励后、休息/事件/商店占位流程后）。

## B4 遗物/药水约束（feat-relic-potion-core-v1）

- 容量规则：
  - `relics.size() <= relic_capacity`
  - `potions.size() <= potion_capacity`
- 写入行为：
  - 超容量写入返回失败（不直接崩溃）
  - 可在奖励链路按业务策略回退为金币或跳过
- 药水使用：
  - 使用成功后从 `potions` 移除对应条目
  - 具体效果由 `PotionData.effect_type/value` 决定并立即作用于 `RunState`

## C1 存档/读档约束（feat-save-load-v1）

- 存档范围（单槽位最小可用）至少覆盖：
  - `seed` / `act` / `floor` / `gold`
  - `player_stats`：`health` / `max_health` / `deck`
  - 地图推进：`map_current_node_id` / `map_reachable_node_ids` / `map_visited_node_ids` / `map_graph`
  - `relic_capacity` / `potion_capacity` / `relics` / `potions`
- 存档文件需包含 `save_version` 字段。
- 版本不匹配时必须安全失败并给出提示，不允许崩溃或写坏当前运行态。
- 当前范围不含“战斗中断点恢复”，仅保证恢复后可继续局外流程推进。

## 兼容说明

- 本版本新增遗物/药水字段，属于兼容性扩展（MINOR）。
- 旧存档无上述字段时，应使用默认值：
  - `map_current_node_id = ""`
  - `map_reachable_node_ids = []`
  - `map_visited_node_ids = []`
  - `map_graph = null`（可在开局时重建）
  - `relic_capacity = 6`
  - `potion_capacity = 2`
  - `relics = []`
  - `potions = []`

## 变更规则

- 存档字段变更默认按 L2 处理。
- 新增字段需给出向后兼容策略（默认值或迁移逻辑）。
