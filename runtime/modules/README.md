# 模块目录索引

更新时间：2026-02-16

本目录用于按领域拆分实现，当前处于“模块化过渡期”。

## 模块清单（按现状）

- `run_meta`：运行态真源（`RunState`）
- `run_flow`：应用编排目标模块（当前占位）
- `battle_loop`：战斗阶段状态机
- `card_system`：牌区与关键词最小联动
- `effect_engine`：效果入队与顺序结算
- `buff_system`：状态层规则与数值修正
- `enemy_intent`：敌方意图规则选择
- `map_event`：地图生成与事件效果
- `reward_economy`：奖励与商店供货规则
- `relic_potion`：遗物触发与药水入口
- `persistence`：存档读档（已落地）
- `seed_replay`：历史命名占位（当前无实现）
- `content_pipeline`：内容导入/校验（cards 最小链路）
- `ui_shell`：UI 壳层（实现当前在 `runtime/scenes/ui`）

## 当前映射（过渡期）

- `runtime/scenes/app/app.gd` 当前承担 `run_flow` 编排职责。
- `runtime/scenes/ui/` 当前承担 `ui_shell` 实现职责。
- `runtime/modules/persistence/` 是当前唯一存档实现目录。

## 命名收口

1. 存档主模块统一使用 `persistence`。
2. `seed_replay` 不新增实现，等待后续阶段做并入或移除决策。
3. `run_flow` 保留为后续流程编排落地目录。
