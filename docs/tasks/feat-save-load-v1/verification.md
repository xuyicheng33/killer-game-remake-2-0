# 验证记录

## 基本信息

- 任务 ID：`feat-save-load-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-save-load-v1`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行，环境挂起）
  - 结果：35 秒内未退出（超时后手动终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
    - `Error received in message reply handler: Connection invalid`
  - 说明：该环境下仍是历史一致的 headless 挂起现象；本任务未在运行时代码中加入自动 `quit` 钩子。

## 功能验证（可复验步骤）

### 主路径用例 1：存档并恢复核心进度

- 前置：运行 `scenes/app/app.tscn`，进入地图并推进至少 1 个节点，使 `floor/gold/deck/map_*` 发生变化。
- 步骤：
  1. 回到地图页（本实现会在地图页自动写入单槽存档）。
  2. 退出游戏并重新启动 `scenes/app/app.tscn`。
  3. 观察启动流程优先尝试读档并回到地图。
  4. 对比恢复后的 `seed/floor/gold/player_stats/deck/map_*` 是否与保存时一致。
- 期望：
  - 读取成功后可继续流程推进。
  - 关键字段与保存时一致。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。

### 主路径用例 2：遗物与药水状态恢复

- 前置：当前 run 内已获得至少 1 个遗物和 1 个药水并回到地图页（触发自动存档）。
- 步骤：
  1. 退出并重启游戏。
  2. 触发自动读档进入地图。
  3. 检查 `relics/potions` 数量与条目内容是否恢复。
  4. 尝试使用药水或触发遗物，确认行为与恢复状态一致。
- 期望：
  - 遗物栏/药水栏与保存时一致，容量约束仍有效。
  - 恢复后可继续流程推进。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。

### 边界用例 1：版本不匹配安全失败

- 前置：准备一个 `save_version` 不匹配的单槽存档文件。
- 步骤：
  1. 将 `user://save_slot_1.json` 中 `save_version` 改为非 `1` 的值。
  2. 重新加载存档。
  3. 观察读档失败提示与回退行为（不崩溃、可进入新局）。
- 期望：
  - 版本不匹配时安全失败并给出提示（日志消息）。
  - 不发生崩溃，不污染当前运行状态。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。
