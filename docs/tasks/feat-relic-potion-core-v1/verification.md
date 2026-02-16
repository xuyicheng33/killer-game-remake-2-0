# 验证记录

## 基本信息

- 任务 ID：`feat-relic-potion-core-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-relic-potion-core-v1`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行，环境挂起）
  - 结果：35 秒内未退出（超时后手动终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
    - `Error received in message reply handler: Connection invalid`
  - 说明：环境级挂起现象仍在，不在运行时代码里注入自动 `quit` 钩子。

## 功能验证（审批后执行）

### 主路径用例 1：遗物触发链与显示

- 前置：运行 `scenes/app/app.tscn`，通过战斗奖励获得示例遗物 `余烬指环`
- 步骤：
  1. 进入下一场战斗，观察右上角遗物/药水面板日志。
  2. 战斗开始时确认触发“战斗开始恢复生命”日志与生命变化。
  3. 玩家出牌达到 3 的倍数时确认触发“出牌后获得金币”日志。
  4. 玩家受击后确认触发“受击后获得格挡”日志。
- 期望：
  - 面板显示遗物栏计数与名称。
  - 至少命中一个规定触发链并出现可见数值或日志变化（本实现支持三类触发）。
- 结果：未运行时实测（受当前 headless 环境挂起影响）。

### 主路径用例 2：药水获取与使用

- 前置：运行 `scenes/app/app.tscn`，通过战斗奖励或 B3 节点奖励获得示例药水
- 步骤：
  1. 在任意场景右上角药水栏点击“使用：<药水名>”。
  2. 观察日志与状态变化（治疗药水应恢复生命；铁肤药水应提供格挡）。
  3. 确认药水使用后从栏位中移除。
- 期望：
  - 药水可用且效果可见（数值/日志）。
  - 使用后药水数量减少，显示与状态一致。
- 结果：未运行时实测（受当前 headless 环境挂起影响）。

### 边界用例 1：容量限制

- 前置：运行 `scenes/app/app.tscn`，将遗物/药水获取到接近容量上限
- 步骤：
  1. 在容量已满时继续触发奖励发放（战后奖励或 B3 节点奖励）。
  2. 观察栏位不超上限，且奖励按实现兜底为金币补偿。
- 期望：
  - `relics.size() <= relic_capacity`、`potions.size() <= potion_capacity`。
  - 超容量不崩溃，不会写入越界条目。
- 结果：未运行时实测（受当前 headless 环境挂起影响）。

## 备注

- 功能用例：当前环境未完成 Godot 运行时实测（headless CLI 挂起），以上为 GUI 可复验步骤。
