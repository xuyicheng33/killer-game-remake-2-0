# 任务计划：fix-p1-tooltip-and-death-race-v1

## 基本信息

- 任务 ID：`fix-p1-tooltip-and-death-race-v1`
- 任务级别：`L2`
- 主模块：`battle_loop`
- 负责人：`Codex`
- 日期：`2026-03-02`

## 目标

一次性修复剩余 P1：补齐遗物悬停 tooltip 用户可见反馈，并将死亡处理链路彻底收口到战斗场景层，消除节点自释放导致的时序竞态。

## 范围边界

- 包含：
  - `RelicPotionUI` 悬停提示链路修复与兜底展示。
  - `Player/Enemy` 致死后的节点生命周期治理（移除节点自 `queue_free()`）。
  - 针对上述改动补充自动化回归测试。
  - 任务三件套、工作日志更新。
- 不包含：
  - 新增遗物/药水/敌人玩法内容。
  - 全量 UI 文案本地化重构。
  - 战斗状态机契约结构调整。

## 改动白名单文件

- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/scenes/player/player.gd`
- `runtime/scenes/enemy/enemy.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/plan.md`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/handoff.md`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/verification.md`
- `docs/work_logs/2026-03.md`
- `docs/work_log.md`

## 实施步骤

1. 为遗物/药水按钮补充 tooltip 兜底显示与悬停可用性增强。
2. 移除 `Player/Enemy.take_damage` 中的自释放逻辑，仅发射死亡信号并加防重入。
3. 补充测试覆盖：遗物 tooltip 事件发射、Player/Enemy 致死后不自释放。
4. 跑门禁与全量测试，更新交接与验证文档。

## 验证方案

1. `make workflow-check TASK_ID=fix-p1-tooltip-and-death-race-v1`
2. `make test`
3. 手动冒烟：启动 `runtime/scenes/app/app.tscn`，进入战斗后悬停遗物名称可见 tooltip。

## 风险与回滚

- 风险：
  - `Player/Enemy` 生命周期改动涉及动画完成回调，若遗漏会导致死亡事件不触发或重复触发。
  - tooltip 双通道（自定义事件 + 原生 `tooltip_text`）可能造成风格不一致。
- 回滚方式：
  - 按提交执行 `git revert <commit>`。
  - 若仅 UI 回归异常，可单独回滚 `runtime/scenes/ui/relic_potion_ui.gd` 改动。


> 自动填充任务ID：`fix-p1-tooltip-and-death-race-v1`
