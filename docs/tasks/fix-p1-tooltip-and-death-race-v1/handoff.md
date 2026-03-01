# 任务交接：fix-p1-tooltip-and-death-race-v1

## 基本信息

- 任务 ID：`fix-p1-tooltip-and-death-race-v1`
- 主模块：`battle_loop`
- 提交人：`Codex`
- 日期：`2026-03-02`

## 改动摘要

- 修复遗物 tooltip 可见性问题：
  - `RelicPotionUI` 增加 tooltip 文本兜底（`Control.tooltip_text`）；
  - 遗物/药水按钮补全可悬停区域与手型光标，降低“悬停无反馈”概率；
  - 保留原有 `Events.relic_tooltip_requested` / `Events.potion_tooltip_requested` 自定义 tooltip 事件链。
- 修复死亡竞态链路：
  - 移除 `Player.take_damage` 与 `Enemy.take_damage` 内部 `queue_free()`；
  - 场景节点只发射死亡信号，节点释放统一由 battle 场景处理；
  - 增加 `_death_notified` 防重入，避免多重致死回调重复发信号。
- 新增 3 条回归测试，覆盖 tooltip 悬停事件与节点不自释放行为。

## 变更文件

- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/scenes/player/player.gd`
- `runtime/scenes/enemy/enemy.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/plan.md`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/handoff.md`
- `docs/tasks/fix-p1-tooltip-and-death-race-v1/verification.md`
- `docs/work_logs/2026-03.md`

## 验证结果

- [x] `make workflow-check TASK_ID=fix-p1-tooltip-and-death-race-v1`：通过
- [x] `make test`：通过（22 scripts / 168 tests / 168 passing）
- [x] 新增回归用例通过：
  - `test_relic_ui_emits_tooltip_on_hover`
  - `test_player_take_damage_does_not_queue_free_self`
  - `test_enemy_take_damage_does_not_queue_free_self`

## 风险与影响范围

- `Player/Enemy` 不再自释放后，若未来新增“非 battle 场景”复用这两个节点，需要在调用侧显式处理节点生命周期。
- tooltip 采用“双通道”（自定义事件 + 原生 tooltip 兜底），显示风格可能在极端情况下不完全一致，但可保证可见反馈。

## 建议提交信息

- `fix(battle_loop): 修复遗物tooltip与死亡竞态（fix-p1-tooltip-and-death-race-v1）`


> 自动填充任务ID：`fix-p1-tooltip-and-death-race-v1`
