# Phase A：核心规则内核拆分

## 阶段目标

完成战斗规则“可测试内核化”：阶段机、牌区、效果栈、状态系统、敌人意图规则。

## 阶段入口

- 当前基线可运行：`scenes/app/app.tscn` 可从地图进入战斗并回传。
- `docs/contracts/` 可随任务同步更新。

## 任务拆分

## A1 `feat-battle-loop-state-machine-v1`

- 级别：`L2`
- 主模块：`battle_loop`
- 依赖：无
- 关键改动路径：
  - `scenes/battle/**`
  - `modules/battle_loop/**`
  - `docs/contracts/battle_state.md`
- 子任务：
  1. 定义战斗阶段枚举与状态流（抽牌/行动/敌方/结算）。
  2. 将当前 `battle.gd + player_handler + enemy_handler` 迁移到阶段驱动。
  3. HUD 增加阶段显示与切换日志。
- 验收：打一整回合，阶段顺序稳定且可见。

## A3 `feat-effect-stack-v1`

- 级别：`L2`
- 主模块：`effect_engine`
- 依赖：A1
- 关键改动路径：
  - `effects/**`
  - `modules/effect_engine/**`
  - `docs/contracts/battle_state.md`
- 子任务：
  1. 引入效果队列（enqueue/process），替代即时生效。
  2. 支持多段伤害按序结算与日志记录。
  3. 提供最小调试可视（队列长度/当前结算条目）。
- 验收：多段攻击按段显示，不合并结算。

## A4 `feat-buff-system-core-v1`

- 级别：`L2`
- 主模块：`buff_system`
- 依赖：A3
- 关键改动路径：
  - `modules/buff_system/**`
  - `effects/**`
  - `scenes/ui/**`
  - `custom_resources/**`
- 子任务：
  1. 建立状态容器与触发时机（回合开始/结束、受击、出牌后）。
  2. 实现力量、敏捷、易伤、虚弱、中毒。
  3. 显示状态图标与层数，并与数值结算联动。
- 验收：施加虚弱后敌人伤害变化可观测。

## A2 `feat-card-zones-keywords-v1`

- 级别：`L2`
- 主模块：`card_system`
- 依赖：A1（建议同时具备 A3/A4）
- 关键改动路径：
  - `scenes/card_ui/**`
  - `modules/card_system/**`
  - `scenes/ui/**`
  - `custom_resources/card*.gd`
- 子任务：
  1. 统一四牌区模型：抽牌堆/弃牌堆/消耗堆/手牌。
  2. 增加关键词框架：消耗、保留、虚无、X费。
  3. UI 显示牌区计数，支持基础关键词行为。
- 验收：打出消耗测试牌后，消耗堆计数 +1。

## A5 `feat-enemy-intent-rules-v1`

- 级别：`L1`（若改 battle contract 升级为 `L2`）
- 主模块：`enemy_intent`
- 依赖：A1
- 关键改动路径：
  - `scenes/enemy/**`
  - `enemies/**`
  - `modules/enemy_intent/**`
- 子任务：
  1. 建立规则约束层（不可连续动作、条件优先）。
  2. 引入进阶参数（ascension）占位并可切换。
  3. 将规则结果映射到意图UI。
- 验收：同敌人多场战斗行为分布符合约束。

## 阶段出口

- 战斗规则链路变为“阶段驱动 + 效果队列 + 状态系统 + 规则化意图”。
- `docs/contracts/battle_state.md` 与实现一致。
- 至少有一组可重复回归步骤覆盖阶段切换、效果顺序、状态触发。
