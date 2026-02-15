# RunState 契约（v0.1.0）

## 目的

定义跨战斗持久状态字段，确保存档与流程一致。

## 建议字段

| 字段 | 类型 | 描述 |
|---|---|---|
| `seed` | `int` | 本局随机种子 |
| `act` | `int` | 当前章节 |
| `map_node_id` | `String` | 当前地图节点 |
| `deck` | `Array` | 当前牌组 |
| `relics` | `Array` | 持有遗物 |
| `potions` | `Array` | 持有药水 |
| `gold` | `int` | 金币 |
| `hp` | `int` | 当前生命 |
| `max_hp` | `int` | 最大生命 |
| `ascension` | `int` | 进阶等级 |

## 变更规则

- 存档字段变更默认按 L2 处理。
- 新增字段需给出向后兼容策略（默认值或迁移逻辑）。
