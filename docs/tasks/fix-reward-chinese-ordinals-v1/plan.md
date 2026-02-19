# Plan: fix-reward-chinese-ordinals-v1

## 任务元信息

- 任务ID: fix-reward-chinese-ordinals-v1
- 等级: L0（单文件UI修复）
- 主模块: ui_shell
- 优先级: P2（体验问题）

## 目标

修复奖励三选一界面中卡牌选项显示英文编号（1./2./3.）的问题，替换为中文或移除序号。

## 状态说明

此任务已在前期完成（feat-card-display-name-v1 提交）：
- 卡牌已实现 `display_name` 字段，支持中文名称
- `reward_ui_view_model.gd` 使用 `card.get_display_name()` 显示中文
- 不存在英文序号问题

## 白名单文件

- runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd
- runtime/scenes/reward/reward_screen.gd

## 验证命令

```bash
make test
```

## 状态: COMPLETED
