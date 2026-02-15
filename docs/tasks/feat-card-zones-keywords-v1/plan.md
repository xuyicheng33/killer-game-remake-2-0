# 任务计划

## 基本信息

- 任务 ID：`feat-card-zones-keywords-v1`
- 任务级别：`L2`
- 主模块：`card_system`
- 负责人：AI 协作执行
- 日期：2026-02-15

## 目标

仅完成 A2 最小可用范围：统一四牌区模型（抽牌堆/手牌/弃牌堆/消耗堆）、建立关键词框架（消耗/保留/虚无/X费）、并实现牌区计数 UI 联动。

## 范围边界

- 包含：
  - 四牌区数据模型与流转规则。
  - 关键词框架最小实现：`exhaust`、`retain`、`ethereal`、`x_cost`。
  - UI 显示四牌区计数并与流转实时联动。
- 不包含：
  - `buff_system` 扩展（A4 后续增强）。
  - `enemy_intent` 规则重构（A5）。
  - 奖励/地图/B 阶段内容。

## 改动白名单文件

- `docs/tasks/feat-card-zones-keywords-v1/**`
- `modules/card_system/**`
- `scenes/card_ui/**`
- `scenes/ui/**`
- `custom_resources/card*.gd`
- `custom_resources/card_pile.gd`
- `docs/contracts/battle_state.md`

## 实施步骤

1. 在 `modules/card_system` 建立四牌区统一模型与基础操作接口（抽/弃/消耗/回收）。
2. 接入现有战斗与手牌流程，使出牌、回合结束、抽牌重洗按四牌区模型驱动。
3. 在 `custom_resources/card*.gd` 增加关键词字段与默认值，落最小关键词行为。
4. 在 `scenes/card_ui/**` 与 `scenes/ui/**` 增加/更新牌区计数显示，并绑定模型变化事件。
5. 更新 `docs/contracts/battle_state.md` 的牌区与关键词字段契约。
6. 回填 `verification.md` 与 `handoff.md`。

## 验证方案

1. `make workflow-check TASK_ID=feat-card-zones-keywords-v1` 通过。
2. 主路径：打出“消耗测试牌”后，消耗堆计数 `+1`。
3. 主路径：回合结束后，非保留手牌正确流转至弃牌堆。
4. 边界用例：空抽牌堆/空弃牌堆/关键词默认值情况下流程不崩溃。

## 风险与回滚

- 风险：当前手牌流程与牌区模型耦合较深，切换时可能出现计数不同步或回合结束流转异常。
- 回滚方式：按任务提交回滚；或回退白名单代码并恢复契约文档。
