# 任务计划

## 基本信息

- 任务 ID：`feat-seed-deterministic-v1`
- 任务级别：`L2`
- 主模块：`save_seed_replay`（按本任务白名单落地）
- 负责人：Codex
- 日期：2026-02-16

## 目标

实现 C2 固定种子最小可用能力：统一 RNG 入口并接入关键随机链路，使同 seed 下前 3 层节点与首战敌方行为链路可复现，并产出最小复现日志。

## 审批门槛（必须）

- 本任务为 `L2`，先完成三件套文档后停在审批点。
- 在你回复“批准”前，不进行任何业务代码实现。

## 范围边界

- 包含：
  - 建立统一 RNG 入口，避免模块各自 `RandomNumberGenerator.new()`、`randf()`、`pick_random()` 直接散落调用破坏复现
  - 地图生成与敌人意图/奖励等随机行为接入同一 seed 体系（最小可用）
  - 增加最小复现日志，至少包含：`seed`、`floor`、`node`、`enemy`
  - 验收口径：同 seed 开两局，前 3 层节点与首战敌方行为链路一致（按当前可观测项验证）
- 不包含：
  - 多存档槽
  - 回放系统完整实现
  - 战斗中断点恢复
  - UI 美化与非必要重构
  - C3 内容管线改造

## 改动白名单文件

- `modules/persistence/**`
- `modules/map_event/**`
- `modules/enemy_intent/**`
- `modules/reward_economy/**`
- `global/**`
- `scenes/app/**`
- `scenes/enemy/**`
- `docs/contracts/run_state.md`
- `docs/tasks/feat-seed-deterministic-v1/**`

## 实施步骤（审批后执行）

1. 盘点现有随机调用点，确定统一 RNG 服务接口与 seed 传递路径。
2. 接入地图生成、敌方意图/行为随机点、奖励随机点到统一 RNG。
3. 增加最小复现日志写入点（seed/floor/node/enemy）。
4. 回归同 seed 双 run 对比，验证前 3 层节点与首战敌方行为链路一致。
5. 更新契约与任务文档验证记录。

## 验证方案（审批后执行）

1. `make workflow-check TASK_ID=feat-seed-deterministic-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志并标注环境问题）
4. 功能验证：2 条主路径 + 1 条边界用例。

## 风险与回滚

- 风险：
  - 随机入口收敛不完整会导致“部分可复现、部分不可复现”。
  - 地图/敌方/奖励随机顺序若耦合不当，可能引入链路回归。
  - 日志粒度不足会影响复现定位效率。
- 回滚方式：
  - 回滚本任务提交，恢复到 C1 状态。

