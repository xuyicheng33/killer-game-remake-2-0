# 验证记录

## 基本信息

- 任务 ID：`feat-map-graph-progression-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-map-graph-progression-v1`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
  - 结果：35 秒内未退出（超时后手动终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
    - `Error received in message reply handler: Connection invalid`
  - 备注：同机在非项目目录执行 `godot4.6 --headless --quit` 也复现同类挂起，判断为当前运行环境问题（非本任务脚本语法报错）。

## 功能验证（审批后执行）

### 主路径用例 1：多层图可达节点推进

- 前置：运行 `scenes/app/app.tscn`，新开一局
- 步骤：
  1. 进入地图后确认展示多层节点（含普通/精英/休息/事件/商店/Boss 层）。
  2. 在第 1 层选择一个标记 `[可达]` 的节点完成流程并返回地图。
  3. 观察下一次地图显示中，第 2 层仅节点子集标记为 `[可达]`。
- 期望：
  - 节点可达性按连线推进，不能自由选择任意节点。

### 主路径用例 2：战斗节点完成后继续图推进

- 前置：运行 `scenes/app/app.tscn`，地图上选择可达的 `BATTLE/ELITE/BOSS` 节点
- 步骤：
  1. 完成战斗并进入奖励页，选择（或跳过）奖励后返回地图。
  2. 观察 `RunLabel` 层数 +1；同时可达节点切换为刚进入节点的后继。
- 期望：
  - 楼层推进与路径推进同步，战斗完成后可继续在图上推进。

### 边界用例 1：不可达节点选择限制

- 前置：运行 `scenes/app/app.tscn`，进入地图
- 步骤：
  1. 在地图上尝试点击标记 `[未达]` 或 `[已走]` 的节点按钮。
  2. 再点击一个 `[可达]` 节点。
- 期望：
  - 不可达/已走节点按钮不可触发流程；仅可达节点能进入。

## 备注

- 功能用例：当前环境未完成运行时实测（headless CLI 挂起导致阻塞），已提供本机 GUI 复验步骤。
