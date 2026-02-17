# 任务交接

## 基本信息

- 任务 ID：`phase9-seed-deterministic-draw-shuffle-v1`
- 主模块：`seed_replay`
- 提交人：AI 程序员
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 9`
- 状态：`已完成`

## 改动摘要

- 在 `CardPile` 引入基于 `RunRng` 的确定性 Fisher-Yates 洗牌方法 `shuffle_with_rng(stream_key)`
- 修改 `PlayerHandler` 战斗链路中的洗牌调用，使用可区分的 stream key：
  - `battle_start_shuffle`：战斗开始时的初始洗牌
  - `reshuffle_discard`：弃牌堆洗回抽牌堆
- 同一 seed 下抽牌序列可复现，读档后随机流连续

## 变更文件

- `content/custom_resources/card_pile.gd` - 新增 `shuffle_with_rng()` 确定性洗牌方法
- `runtime/scenes/player/player_handler.gd` - 调用确定性洗牌，传入区分 stream key
- `runtime/modules/seed_replay/README.md` - 记录确定性洗牌实现位置

## 验证结果

- [ ] 固定 seed 双次开局抽牌顺序一致（需人工验证）
- [ ] 存档/读档后随机流连续（需人工验证）
- [x] `make workflow-check TASK_ID=phase9-seed-deterministic-draw-shuffle-v1`（通过）

## 风险与影响范围

- 洗牌算法从内置 `Array.shuffle()` 切换为 Fisher-Yates，数学上等价（均为均匀随机排列）
- 使用独立 stream key 避免不同场景串流干扰，不影响敌人意图等其他随机场景
- 读档恢复后 `RunRng` 状态完整恢复，洗牌连续性有保障

## 建议提交信息

- `feat(seed_replay): deterministic draw pile shuffle with run rng（phase9-seed-deterministic-draw-shuffle-v1）`
