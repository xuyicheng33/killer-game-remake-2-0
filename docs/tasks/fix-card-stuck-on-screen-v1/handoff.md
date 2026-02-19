# Handoff: fix-card-stuck-on-screen-v1

## 交付摘要

修复了卡牌播放后卡在屏幕的问题。现在无论播放是否成功（条件不满足、无目标等），卡牌 UI 都会被正确移除。

## 改动文件

- `runtime/scenes/card_ui/card_ui.gd`
  - `play()` 方法在所有提前返回路径上添加 `queue_free()`

## 建议提交信息

`fix(card_ui): remove card UI even if play fails（fix-card-stuck-on-screen-v1）`
