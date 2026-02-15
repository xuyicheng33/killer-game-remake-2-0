# BattleState 契约（v0.5.0）

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
| `stack` | `Array` | 待结算效果队列（FIFO）。每项至少包含 `effect`、`target`、`id` |
| `player.statuses` | `Dictionary` | 玩家状态层数，键示例：`strength/dexterity/vulnerable/weak/poison` |
| `enemies[].statuses` | `Dictionary` | 敌人状态层数，键与玩家一致 |

## 阶段迁移约束（A1）

唯一合法迁移顺序：

`DRAW -> ACTION -> ENEMY -> RESOLVE -> DRAW`

- `DRAW`：开始玩家回合，重置玩家资源并抽牌。
- `ACTION`：玩家可打牌或结束回合。
- `ENEMY`：敌方按顺序执行行动。
- `RESOLVE`：回合收尾，刷新下一轮敌方行动并切回 `DRAW`。

## 效果队列约束（A3）

- 入队接口：`enqueue_effect(effect_name, targets, apply_callable)`。
- 结算顺序：严格按入队顺序逐条处理，不合并多段伤害。
- 调试最小可视：可读取队列长度与当前处理条目（用于 HUD/日志）。

## 状态系统约束（A4）

- 状态容器：按实体维护状态层数字典，最低为 0，不允许负层。
- 核心状态：`strength`、`dexterity`、`vulnerable`、`weak`、`poison`。
- 触发时机：
  - 回合开始：预留钩子（可扩展状态触发）。
  - 回合结束：`weak`/`vulnerable` 衰减，`poison` 结算并衰减。
  - 受击：预留钩子（当前 A4 用于联通受击触发链）。
  - 出牌后：预留钩子（当前 A4 用于联通出牌后触发链）。
- 数值联动：
  - 伤害：`strength` 影响攻击方，`weak` 降低攻击方伤害，`vulnerable` 放大受击方承伤。
  - 格挡：`dexterity` 影响格挡获得量。

## 牌区与关键词约束（A2）

- 四牌区模型：`draw_pile`、`hand`、`discard_pile`、`exhaust_pile`。
- 最小关键词字段：
  - `keyword_exhaust`（消耗）：打出后进入 `exhaust_pile`。
  - `keyword_retain`（保留）：回合结束时保留在 `hand`。
  - `keyword_void` / `keyword_ethereal`（虚无）：回合结束时若仍在 `hand`，进入 `exhaust_pile`。
  - `keyword_x_cost`（X费）：打出时消耗当前全部能量，`last_x_value` 记录本次消耗值。
- 边界规则：
  - 抽牌堆与弃牌堆都为空时，抽牌操作返回空，不允许崩溃。
  - 未显式配置关键词时使用默认值（`false` 或 `0`），不改变既有流程稳定性。

## 变更规则

- 新字段默认 MINOR 变更。
- 删除/重命名字段为 MAJOR 变更，默认按 L2 处理。
