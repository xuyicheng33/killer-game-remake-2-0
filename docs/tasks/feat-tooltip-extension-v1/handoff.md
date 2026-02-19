# 任务交接

## 基本信息

- 任务 ID：`feat-tooltip-extension-v1`
- 主模块：`runtime/global/events.gd`, `runtime/scenes/ui/tooltip.gd`
- 提交人：Codex
- 日期：2026-02-20

## 当前状态

- 状态：`已完成`

## 改动摘要

- 新增 `relic_tooltip_requested` 和 `potion_tooltip_requested` 信号
- 扩展 Tooltip 组件以支持遗物和药水的悬浮提示
- 在 Shop/Reward/RelicPotionUI 场景中集成 Tooltip 功能

## 变更文件

- `runtime/global/events.gd`
- `runtime/scenes/ui/tooltip.gd`
- `runtime/scenes/reward/reward_screen.gd`
- `runtime/scenes/shop/shop_screen.gd`
- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`

## 风险与影响范围

- Tooltip 需要在 app.tscn 中全局挂载以支持非战斗场景
- 遗物列表为文本展示，暂不支持单独 Tooltip

## 建议提交信息

- `feat(ui): extend tooltip support to shop/reward/relic-potion scenes`

## 审核员结论

- 结论：通过，Tooltip 扩展功能已完成。
