# 任务计划

## 基本信息

- 任务 ID：`feat-relic-potion-core-v1`
- 任务级别：`L2`
- 主模块：`relic_potion`
- 负责人：Codex
- 日期：2026-02-16

## 目标

实现 Phase B / B4 最小可用能力：遗物栏与药水栏（含容量规则）、基础触发链（战斗开始/出牌后/受击后）、示例遗物/药水可获得并在流程中可见生效。

## 审批门槛（必须）

- 本任务为 `L2`，先完成文档后停在审批点。
- 在你回复“批准”前，不进行任何代码实现。

## 范围边界

- 包含：
  - 遗物栏 + 药水栏（容量规则）
  - 基础触发链：战斗开始 / 出牌后 / 受击后
  - 至少一组示例遗物与示例药水（可获得、可显示、可生效）
  - 接入当前奖励链路（B1/B3）发放遗物/药水并写回 run 状态
- 不包含：
  - C 阶段存档/种子/内容管线
  - D 阶段视觉重构
  - 大规模内容平衡

## 改动白名单文件

- `docs/tasks/feat-relic-potion-core-v1/**`
- `modules/relic_potion/**`
- `custom_resources/relics/**`
- `custom_resources/potions/**`
- `scenes/ui/**`
- `scenes/reward/**`
- `scenes/app/**`
- `modules/reward_economy/**`
- `modules/run_meta/**`
- `docs/contracts/run_state.md`
- `docs/contracts/battle_state.md`

## 实施步骤（审批后执行）

1. 盘点现有 B1/B3 奖励链路与 `RunState` 字段，确认遗物/药水最小写回接口。
2. 建立 `relic_potion` 核心模块：栏位容量、持有列表、触发入口、药水使用入口。
3. 新增示例遗物与示例药水资源并接入触发链（战斗开始/出牌后/受击后至少命中一个可见反馈）。
4. 在 UI 接入遗物栏/药水栏显示与容量限制反馈。
5. 在奖励链路接入遗物/药水发放（B1/B3 中可触发）。
6. 补齐契约文档（如需）与验证记录。

## 验证方案（审批后执行）

1. `make workflow-check TASK_ID=feat-relic-potion-core-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
4. 功能验证：至少 2 条主路径 + 1 条边界用例。

## 风险与回滚

- 风险：
  - 触发链接入 battle 事件时，可能与现有效果/状态流程交叉导致重复触发。
  - 奖励链路接入遗物/药水发放时，若写回点不统一可能出现显示与状态不一致。
  - 容量规则若未统一校验，可能出现超容量写入或 UI 与实际持有不一致。
- 回滚方式：
  - 回滚本任务提交，恢复到 B3 前的无遗物/药水核心流程。

