# Plan: fix-card-stuck-on-screen-v1

## 任务元信息

- 任务ID: fix-card-stuck-on-screen-v1
- 等级: L1（单模块：card_ui）
- 主模块: card_ui
- 优先级: P1（严重体验 Bug）

## 目标

修复拖动出牌后卡牌卡在屏幕中央的问题，确保无论是否成功播放，卡牌 UI 都被正确移除。

## 必做项

- [x] 修改 `card_ui.gd:play()` 在所有返回路径上调用 `queue_free()`

## 白名单文件

- runtime/scenes/card_ui/card_ui.gd

## 状态: COMPLETED
