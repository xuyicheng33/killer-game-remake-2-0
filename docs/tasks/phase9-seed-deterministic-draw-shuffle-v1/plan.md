# 任务计划

## 基本信息

- 任务 ID：`phase9-seed-deterministic-draw-shuffle-v1`
- 任务级别：`L1`
- 主模块：`seed_replay`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

修复抽牌堆洗牌的非确定性来源，使同一 seed 下的抽牌序列可复现，并在读档后保持随机流连续性。

## 范围边界

- 包含：
  - 将卡堆洗牌逻辑改为基于 `RunRng` 的确定性洗牌。
  - 替换战斗链路中的相关调用，确保不再依赖 `Array.shuffle()` 的隐式随机。
  - 补充最小验证记录（固定 seed 的抽牌顺序可复现）。
- 不包含：
  - 敌人意图权重规则改动。
  - 奖励/事件随机规则改动。
  - 存档 schema 结构变更。

## 改动白名单文件

- `content/custom_resources/card_pile.gd`
- `runtime/scenes/player/player_handler.gd`
- `runtime/modules/seed_replay/README.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase9-seed-deterministic-draw-shuffle-v1/plan.md`
- `docs/tasks/phase9-seed-deterministic-draw-shuffle-v1/handoff.md`
- `docs/tasks/phase9-seed-deterministic-draw-shuffle-v1/verification.md`

## 实施步骤

1. 在 `CardPile` 引入基于 `RunRng` 的 Fisher-Yates 洗牌实现（保留原接口兼容性）。
2. 修改战斗相关洗牌调用点，使用可区分的 stream key（避免不同场景串流干扰）。
3. 确认读档恢复后继续使用同一随机流，不引入重置副作用。
4. 更新模块文档与任务三件套。

## 验证方案

1. 使用固定 seed（如 `STS_RUN_SEED=20260217`）启动两次新局。
2. 记录首场战斗首回合抽到的手牌顺序，期望两次一致。
3. 在首场战斗内存档并读档，继续抽牌，期望顺序连续且可复验。
4. `make workflow-check TASK_ID=phase9-seed-deterministic-draw-shuffle-v1`

## 风险与回滚

- 风险：洗牌算法切换可能影响现有数值体验（但不应改变规则语义）。
- 回滚方式：回滚本任务白名单文件，恢复原 `shuffle` 行为。
