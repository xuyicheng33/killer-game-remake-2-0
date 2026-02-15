# BattleState 契约（v0.1.0）

## 目的

统一战斗流程读取/写入字段，降低模块间耦合。

## 建议字段

| 字段 | 类型 | 描述 |
|---|---|---|
| `turn` | `int` | 当前回合数（从 1 开始） |
| `phase` | `String` | 当前阶段：`player_turn` / `enemy_turn` / `resolve` |
| `player` | `Dictionary` | 玩家实时状态（HP、格挡、能量、状态） |
| `enemies` | `Array[Dictionary]` | 敌人列表状态 |
| `draw_pile` | `Array` | 抽牌堆 |
| `hand` | `Array` | 手牌 |
| `discard_pile` | `Array` | 弃牌堆 |
| `exhaust_pile` | `Array` | 消耗堆 |
| `stack` | `Array` | 待结算效果队列/栈 |

## 变更规则

- 新字段默认 MINOR 变更。
- 删除/重命名字段为 MAJOR 变更，默认按 L2 处理。
