# Handoff: fix-relic-tooltip-hover-v1

## 交付摘要

实现了遗物悬停 Tooltip 功能。遗物现在显示为可悬停的按钮，鼠标悬停时显示名称和效果描述。

## 改动文件

- `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`
  - `relic_list_text` 改为 `relic_items` 数组
- `runtime/scenes/ui/relic_potion_ui.gd`
  - 新增 `_render_relics()` 方法
  - 新增 `_on_relic_button_mouse_entered/exited()` 方法
- `runtime/scenes/ui/relic_potion_ui.tscn`
  - `RelicListLabel` 从 Label 改为 VBoxContainer

## 建议提交信息

`fix(ui): add relic tooltip on hover（fix-relic-tooltip-hover-v1）`
