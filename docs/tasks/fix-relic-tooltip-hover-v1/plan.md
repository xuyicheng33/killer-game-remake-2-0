# Plan: fix-relic-tooltip-hover-v1

## 任务元信息

- 任务ID: fix-relic-tooltip-hover-v1
- 等级: L1（单模块：ui_shell）
- 主模块: ui_shell
- 优先级: P1（功能缺失）

## 目标

修复遗物悬停无 Tooltip 显示的问题，为每个遗物添加可悬停的按钮，显示名称和效果描述。

## 必做项

- [x] 修改 viewmodel 将遗物列表改为数组结构
- [x] 修改场景文件将 Label 改为 VBoxContainer
- [x] 修改 UI 代码渲染遗物按钮并连接 tooltip 信号

## 白名单文件

- runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd
- runtime/scenes/ui/relic_potion_ui.gd
- runtime/scenes/ui/relic_potion_ui.tscn

## 状态: COMPLETED
