# Phase D：资源替换与 UI 重构拆分

## 阶段目标

完成教程资源脱钩与统一视觉体验：界面主题、角色敌人资源、音频体系、中文本地化收尾。

## 阶段入口

- A/B/C 已完成，核心玩法与工程能力稳定。
- 允许将重心转移到内容生产与体验打磨。

## 任务拆分

## D1 `art-ui-theme-rebuild-v1`

- 级别：`L1`
- 主模块：`ui_shell`
- 依赖：C 阶段完成
- 关键改动路径：
  - `scenes/ui/**`
  - `main_theme.tres`
  - `art/ui/**`（新建）
- 子任务：
  1. 字体、色板、控件样式统一。
  2. 地图/战斗/奖励页视觉规范统一。
  3. 1080p 与 16:9 缩放适配。
- 验收：地图、战斗、奖励页样式一致且可读性达标。

## D2 `art-character-enemy-pack-v1`

- 级别：`L1`
- 主模块：`ui_shell`（资源协同 `enemy_intent`）
- 依赖：D1
- 关键改动路径：
  - `art/**`
  - `characters/**`
  - `enemies/**`
  - `scenes/enemy/**`
- 子任务：
  1. 第一批角色/敌人立绘与动画资源替换。
  2. 意图图标、状态图标替换。
  3. 清理教程原图残留引用。
- 验收：战斗场景无教程原图资源。

## D3 `audio-music-sfx-rebuild-v1`

- 级别：`L1`
- 主模块：`ui_shell`
- 依赖：D1
- 关键改动路径：
  - `art/audio/**`（新建）
  - `global/music_player.tscn`
  - `global/sfx_player.tscn`
  - `default_bus_layout.tres`
- 子任务：
  1. BGM/SFX 按场景与行为重建。
  2. 音量总线分组规范化（BGM/SFX/UI）。
  3. 设置页增加独立音量调节。
- 验收：关键交互均有对应音频并支持独立调节。

## D4 `localization-zh-polish-v1`

- 级别：`L0`（若牵涉大量 UI 动态逻辑则升 `L1`）
- 主模块：`ui_shell`
- 依赖：D1 + D2
- 关键改动路径：
  - `scenes/**`
  - `docs/glossary.md`
  - 文本资源文件（若引入 i18n 目录）
- 子任务：
  1. 术语统一（按 `docs/glossary.md`）。
  2. 标点、断行、长度控制、乱码清理。
  3. 全流程中文一致性回归。
- 验收：完整跑一局，不出现英文残留和乱码。

## 阶段出口

- 完成视觉、音频、文本三线收尾。
- 运行时资产不再依赖教程风格，项目具备独立风格标识。
