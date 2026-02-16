# 任务交接

## 基本信息

- 任务 ID：`feat-relic-potion-core-v1`
- 主模块：`relic_potion`
- 提交人：Codex
- 日期：2026-02-16

## 改动摘要

- 新增 `relic_potion` 核心系统：
  - 遗物触发链（战斗开始 / 出牌后 / 受击后）
  - 药水使用入口与触发日志
- 新增遗物/药水资源与示例内容：
  - 示例遗物：`余烬指环`
  - 示例药水：`治疗药水`、`铁肤药水`
- `RunState` 接入遗物/药水栏位与容量规则，并提供增删用原子接口。
- 接入奖励链路：
  - B1 战后奖励可发放遗物/药水并在奖励页展示
  - B3 节点（SHOP/EVENT）完成后发放最小遗物/药水奖励
- 新增右上角遗物/药水 UI 面板，显示栏位容量、持有内容、药水使用按钮、触发日志。

## 变更文件

- `docs/tasks/feat-relic-potion-core-v1/plan.md`
- `docs/tasks/feat-relic-potion-core-v1/handoff.md`
- `docs/tasks/feat-relic-potion-core-v1/verification.md`
- `docs/contracts/run_state.md`
- `modules/relic_potion/README.md`
- `modules/relic_potion/relic_potion_system.gd`
- `custom_resources/relics/relic_data.gd`
- `custom_resources/relics/ember_ring.tres`
- `custom_resources/potions/potion_data.gd`
- `custom_resources/potions/healing_potion.tres`
- `custom_resources/potions/iron_skin_potion.tres`
- `modules/run_meta/run_state.gd`
- `modules/reward_economy/README.md`
- `modules/reward_economy/reward_bundle.gd`
- `modules/reward_economy/reward_generator.gd`
- `scenes/reward/reward_screen.gd`
- `scenes/reward/reward_screen.tscn`
- `scenes/ui/relic_potion_ui.gd`
- `scenes/ui/relic_potion_ui.tscn`
- `scenes/app/app.gd`
- `scenes/app/app.tscn`

## 验证结果

- [x] `make workflow-check TASK_ID=feat-relic-potion-core-v1`
- [x] `godot4.6 --version`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行；35 秒超时，日志见 verification）
- [ ] 主路径用例 1（未运行时实测）
- [ ] 主路径用例 2（未运行时实测）
- [ ] 边界用例 1（未运行时实测）

## 风险与影响范围

- 环境中 Godot headless 命令仍挂起，影响自动化运行时验证闭环。
- 当前示例遗物/药水与触发效果为最小可用实现，数值与平衡尚未迭代。
- B3 节点奖励接入采用最小发放策略（SHOP/EVENT），后续可改为更细粒度掉落表。

## 建议提交信息

- `feat(relic_potion): relic potion core v1（feat-relic-potion-core-v1）`
