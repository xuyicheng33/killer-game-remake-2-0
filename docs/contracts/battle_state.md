# BattleState 契约（v0.2.0）

## 目的

统一战斗流程读取/写入字段，降低模块间耦合。

## 核心字段

| 字段 | 类型 | 描述 |
|---|---|---|
| `turn` | `int` | 当前回合数（从 1 开始） |
| `phase` | `String` | 当前阶段：`DRAW` / `ACTION` / `ENEMY` / `RESOLVE` |
| `player` | `Dictionary` | 玩家实时状态（HP、格挡、能量、状态） |
| `enemies` | `Array[Dictionary]` | 敌人列表状态 |
| `draw_pile` | `Array` | 抽牌堆 |
| `hand` | `Array` | 手牌 |
| `discard_pile` | `Array` | 弃牌堆 |
| `exhaust_pile` | `Array` | 消耗堆 |
| `stack` | `Array` | 待结算效果队列/栈 |

## 阶段迁移约束（A1）

唯一合法迁移顺序：

`DRAW -> ACTION -> ENEMY -> RESOLVE -> DRAW`

- `DRAW`：开始玩家回合，重置玩家资源并抽牌。
- `ACTION`：玩家可打牌或结束回合。
- `ENEMY`：敌方按顺序执行行动。
- `RESOLVE`：回合收尾，刷新下一轮敌方行动并切回 `DRAW`。

## 变更规则

- 新字段默认 MINOR 变更。
- 删除/重命名字段为 MAJOR 变更，默认按 L2 处理。
