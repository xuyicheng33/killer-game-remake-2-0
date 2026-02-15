# 任务交接

## 基本信息

- 任务 ID：`feat-reward-flow-v1`
- 主模块：`reward_economy`
- 提交人：Codex
- 日期：2026-02-15

## 改动摘要

- 新增战后奖励页（金币展示 + 三选一卡 + 可跳过）。
- 胜利流转从“胜利后直接回地图”改为“奖励页 -> 地图”，奖励选择后写回本局状态并推进楼层。
- 最小奖励生成与应用逻辑落在 `reward_economy` 模块（当前卡池为 warrior 的 3 张示例卡）。

## 变更文件

- `docs/tasks/feat-reward-flow-v1/plan.md`
- `docs/tasks/feat-reward-flow-v1/handoff.md`
- `docs/tasks/feat-reward-flow-v1/verification.md`
- `modules/reward_economy/README.md`
- `modules/reward_economy/reward_bundle.gd`
- `modules/reward_economy/reward_generator.gd`
- `scenes/reward/reward_screen.gd`
- `scenes/reward/reward_screen.tscn`
- `scenes/app/app.gd`

## 验证结果

- [ ] 用例 1：胜利后进入奖励页并获得金币（未运行时实测；步骤见 `verification.md`）
- [ ] 用例 2：三选一卡并写回牌组（未运行时实测；步骤见 `verification.md`）
- [ ] 边界用例：卡池为空兜底（未运行时实测；步骤见 `verification.md`）
- [x] `make workflow-check TASK_ID=feat-reward-flow-v1`

## 风险与影响范围

- 当前卡池为 warrior 的 3 张示例卡（非内容管线）；后续多角色/稀有度/随机种子需要扩展生成逻辑。
- “写回牌组”的实现落在 `run_state.player_stats.deck`（当前 RunState 结构如此）；若未来 RunState deck 独立字段，需要迁移应用点。

## 建议提交信息

- `feat(reward_economy): reward flow v1（feat-reward-flow-v1）`
