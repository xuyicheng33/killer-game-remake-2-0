# 验证记录

## 基本信息

- 任务 ID：`feat-rest-shop-event-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-rest-shop-event-v1`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
  - 结果：35 秒内未退出（超时后手动终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439`
    - `Error received in message reply handler: Connection invalid`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
  - 说明：当前环境存在 headless 挂起现象（与此前任务一致）。

## 功能验证（审批后执行）

### 主路径用例 1：REST 节点二选一

- 前置：运行 `scenes/app/app.tscn`，从地图选择一个 `[可达]` 的 `REST` 节点
- 步骤：
  1. 进入营火页面，点击“休息（恢复 20% 生命，最低 6）”，返回地图。
  2. 再次进入另一 `REST` 节点，点击“升级（强化牌组第 1 张卡）”，返回地图。
- 期望：
  - 两次都只允许二选一且完成后回地图。
  - `RunState` 产生可见变化（生命变化或牌组第 1 张卡被强化/金币兜底变化）。
  - 楼层推进 +1，B2 可达节点继续正常更新。

### 主路径用例 2：SHOP / EVENT 节点回写与推进

- 前置：运行 `scenes/app/app.tscn`，地图存在可达 `SHOP`、`EVENT` 节点
- 步骤：
  1. 进入 `SHOP`：执行至少 1 次买卡和 1 次删卡，再点击“离开商店并继续”。
  2. 进入 `EVENT`：触发任一事件，点击一个选项并“继续前进”。
- 期望：
  - 商店中金币与牌组按操作正确变化，并可离开后继续地图推进。
  - 事件触发后至少一种状态（金币/生命/牌组/最大生命）发生变化。
  - 两类节点结束后都不破坏 B2 的可达性链路。

### 边界用例 1：金币不足或卡池边界下的商店行为

- 前置：运行 `scenes/app/app.tscn`，进入 `SHOP`
- 步骤：
  1. 将金币消耗到不足以支付删卡费用（75）或买卡费用（55）。
  2. 尝试点击对应操作按钮；再在牌组仅 1 张卡时尝试删卡。
- 期望：
  - 金币不足时对应操作不可成功，且不会出现负金币。
  - 牌组仅 1 张时删卡按钮不可用，避免把牌组删空。

## 备注

- 功能用例：当前环境未完成 Godot 运行时实测（headless CLI 挂起），以上为本机 GUI 可复验步骤。
