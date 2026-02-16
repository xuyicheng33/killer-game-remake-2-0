# 验证记录

## 基本信息

- 任务 ID：`art-ui-theme-rebuild-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=art-ui-theme-rebuild-v1`
  - 输出：`[workflow-check] passed.`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
  - 结果：约 36 秒内未退出（手动 `Ctrl+C` 终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439 - https://godotengine.org`
    - `Error received in message reply handler: Connection invalid`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
  - 说明：当前环境的 headless 挂起问题；本任务未添加自动退出运行时逻辑。

## 功能验证（已执行）

### 主路径用例 1：地图 -> 战斗 -> 奖励 UI 一致性

- 步骤：
  1. 检查三页场景均接入 `main_theme.tres`。
  2. 检查按钮/面板/标签样式在三页是否来自同一主题。
  3. 检查战斗页 HUD、结束面板、右上角信息面板是否统一视觉语言。
- 结果：通过（资源链路与场景静态验证）。
  - 关键证据：
    - `scenes/map/map_screen.tscn:14` 已绑定主题
    - `scenes/reward/reward_screen.tscn:14` 已绑定主题
    - `scenes/battle/battle.tscn:85`、`scenes/battle/battle.tscn:109`、`scenes/battle/battle.tscn:122` 已绑定主题

### 主路径用例 2：1080p / 16:9 适配（不遮挡、不重叠、可读）

- 步骤：
  1. 检查地图/奖励/营火主容器改为统一 `PanelContainer + MarginContainer`，并使用可收缩边距。
  2. 检查战斗页手牌与回合按钮、阶段日志面板尺寸。
  3. 检查结束面板与提示文本在 16:9 下的最小尺寸与换行。
- 结果：通过（布局参数静态验证）。
  - 关键调整：
    - 地图页框体：`scenes/map/map_screen.tscn:46`
    - 奖励页框体：`scenes/reward/reward_screen.tscn:46`
    - 战斗手牌/按钮：`scenes/battle/battle.tscn:80`、`scenes/battle/battle.tscn:103`
    - 战斗结算面板：`scenes/ui/battle_over_panel.tscn:24`

### 边界用例 1：长文本 / 小窗口下不溢出

- 步骤：
  1. 检查地图提示、奖励提示、营火说明、结算文案和 tooltip 均启用自动换行或相对宽度约束。
  2. 检查动态卡牌按钮文本（奖励页）与地图节点按钮文本（地图页）换行行为。
- 结果：通过（静态配置验证）。
  - 关键证据：
    - `scenes/map/map_screen.tscn:93` (`autowrap_mode = 3`)
    - `scenes/reward/reward_screen.tscn:87`、`scenes/reward/reward_screen.tscn:93`
    - `scenes/ui/battle_over_panel.tscn:39`
    - `scenes/ui/tooltip.tscn:6`（相对宽度锚点）
    - `scenes/reward/reward_screen.gd:45`、`scenes/map/map_screen.gd:75`（按钮自动换行）

## 备注

- 本任务仅进行 UI/主题层改动，未触碰战斗规则、数值逻辑、存档逻辑。
