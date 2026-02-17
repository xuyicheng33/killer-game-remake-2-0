# 验证记录

## 基本信息

- 任务 ID：`phase9-seed-deterministic-draw-shuffle-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `make workflow-check TASK_ID=phase9-seed-deterministic-draw-shuffle-v1`
  - 结果：`[workflow-check] passed.`
  - repo-structure-check: passed
  - ui_shell_contract: passed
  - run_flow_contract: passed
  - 白名单边界检查通过（无非法文件改动）

## 人工回归步骤

### 测试 1：固定 seed 双次开局抽牌顺序一致性

1. 执行：`STS_RUN_SEED=20260217` 启动游戏，进入首场战斗。
2. 记录首回合手牌顺序（按 UI 从左到右）。
3. 重启游戏并再次执行步骤 1-2。
4. 期望：两次记录完全一致。

- [ ] 结果记录：待测试

### 测试 2：存档/读档后随机流连续性

1. 在战斗中推进若干抽牌后存档并退出。
2. 继续游戏读档，记录后续抽牌顺序。
3. 用相同 seed 重复流程，期望读档后的抽牌顺序一致且连续。

- [ ] 结果记录：待测试

## 代码改动验证

### CardPile.shuffle_with_rng() 实现

```gdscript
# Fisher-Yates 洗牌：从后往前遍历，随机交换
for i in range(cards.size() - 1, 0, -1):
    var j: int = RunRng.randi_range(stream_key, 0, i)
    var tmp: Card = cards[i]
    cards[i] = cards[j]
    cards[j] = tmp
```

- 使用 RunRng.randi_range() 获取确定性随机数
- stream_key 区分不同洗牌场景，避免串流

### PlayerHandler 洗牌调用点

| 位置 | stream_key | 场景 |
|------|------------|------|
| start_battle() | `battle_start_shuffle` | 战斗开始初始洗牌 |
| reshuffle_deck_from_discard() | `reshuffle_discard` | 弃牌堆洗回抽牌堆 |

## 前置依赖

- RunRng 必须在开局时初始化（RunRng.begin_run(seed)）
- 存档/读档必须调用 RunRng.export_run_state() / restore_run_state()
