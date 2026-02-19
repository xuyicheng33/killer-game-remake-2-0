# 任务交接

## 基本信息

- 任务 ID：`feat-card-display-name-v1`
- 主模块：`content/custom_resources/card.gd`
- 提交人：Codex
- 日期：2026-02-19

## 当前状态

- 状态：`已完成`

## 改动摘要

- 为 Card 类添加 `display_name` 字段和 `get_display_name()` 方法
- 更新内容导入脚本，将 JSON `name` 映射到 `display_name`
- 更新 Shop/Reward ViewModel 使用 `get_display_name()` 显示中文名称
- 更新存档服务以序列化/反序列化 `display_name` 字段

## 变更文件

- `content/custom_resources/card.gd`
- `dev/tools/content_import_cards.py`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd`
- `runtime/modules/persistence/save_service.gd`

## 风险与影响范围

- 存档兼容性：旧存档缺失 `display_name` 时将使用空字符串默认值
- 所有卡牌显示逻辑统一使用 `get_display_name()`

## 建议提交信息

- `feat(card): add display_name field and integrate with content pipeline`

## 审核员结论

- 结论：通过，卡牌显示名功能已完成。
