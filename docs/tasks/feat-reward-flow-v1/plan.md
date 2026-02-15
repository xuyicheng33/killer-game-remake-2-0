# 任务计划

## 基本信息

- 任务 ID：`feat-reward-flow-v1`
- 任务级别：`L1`（默认；若必须变更 `RunState` 契约或跨模块接口，立刻升级 `L2` 并停在审批点）
- 主模块：`reward_economy`
- 负责人：Codex
- 日期：2026-02-15

## 目标

实现 Phase B / B1 的战后奖励页流程：

- 战斗胜利后不直接回地图，先进入奖励页。
- 奖励页包含：金币结算展示 + 三选一卡。
- 选择一张卡后写回当前 `RunState.deck`，再返回地图。

## 范围边界

- 包含：
  - 奖励页 scene（最小可用 UI）
  - 奖励生成与写回逻辑（金币、三选一卡、写回牌组）
  - app 流程：胜利 -> 奖励页 -> 地图
- 不包含：
  - 商店/事件/休息（B3）
  - 地图图结构推进（B2）
  - 遗物/药水（B4）
  - 视觉重构（UI 先最小可用）

## 改动白名单文件

- `docs/tasks/feat-reward-flow-v1/**`
- `modules/reward_economy/**`
- `scenes/reward/**`（可新建）
- `scenes/app/**`
- `modules/run_meta/**`
- `characters/**`（仅当三选一卡样本需要）
- `docs/contracts/run_state.md`（仅必要时；触发则升级 L2 并停）

## 实施步骤

1. 盘点现有流程：战斗胜利后 app 如何回地图、RunState 如何持有与写回。
2. 在 `modules/reward_economy/**` 实现最小奖励模型与生成器：
   - `gold_reward`（常量或基于配置）
   - `card_choices`（三选一卡，来源可先用固定样本或从角色卡池抽样）
3. 新建 `scenes/reward/**`：
   - Reward 页面 UI：展示金币、3 张卡按钮（可复用 CardUI 或最简文本占位）
   - 用户选卡后发出事件/回调，写回 `RunState.deck`，并返回地图
4. 在 `scenes/app/**` / `modules/run_meta/**` 串起流程：
   - 胜利信号 -> 打开 Reward
   - Reward 完成 -> 返回 Map，RunState 已更新
5. 补齐任务文档：交接、验证（2 主路径 + 1 边界）。

## 验证方案

1. `make workflow-check TASK_ID=feat-reward-flow-v1`
2. 主路径用例 x2 + 边界用例 x1（若无 Godot 则记录“未运行时实测”，并给出本机复验步骤）

## 风险与回滚

- 风险：
  - app 场景切换链路与现有地图/战斗切换耦合，可能引入返回地图时状态丢失。
  - 三选一卡的卡资源来源若不稳定，可能导致 Reward 页面空列表或资源缺失。
- 回滚方式：
  - 仅回滚本任务提交；恢复“胜利后直接回地图”的旧链路。

