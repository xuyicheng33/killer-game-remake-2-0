# 验证记录

## 执行环境

- 日期：2026-02-15
- 分支：`main`
- Godot CLI：未检测到 `godot/godot4` 可执行文件（当前终端环境）

## 执行步骤与结果

1. 执行 `make workflow-check TASK_ID=feat-card-zones-keywords-v1`  
   结果：通过。
2. 自动化主路径：打出“消耗测试牌”后检查消耗堆计数 `+1`  
   结果：受限于当前环境缺少 Godot CLI，未执行运行时验证。
3. 自动化主路径：验证四牌区计数随抽牌/弃牌/消耗实时联动  
   结果：受限于当前环境缺少 Godot CLI，未执行运行时验证。
4. 边界用例：空抽牌堆/空弃牌堆/关键词默认值不崩溃  
   结果：通过代码路径校验：`CardPile.draw_card()` 空堆返回 `null`，`Hand.add_card()` 对 `null` 安全跳过，关键词默认值均为 `false` 或 `0`；运行时未执行。
5. 回归用例：保留牌在敌人回合不可出牌（越阶段保护）  
   结果：通过代码路径校验：`CardZonesModel` 在 `player_turn_ended` 关闭可出牌窗口，`Card.can_play()` 强制检查窗口，`CardUI.play()` 再做硬校验；运行时未执行。

## 结果

- 已完成：白名单与流程守门校验（`workflow-check` 通过）。
- 待补测：Godot 运行时主路径与边界用例。

## 可复验步骤（本机）

1. `make workflow-check TASK_ID=feat-card-zones-keywords-v1`
2. 在 Godot 打开 `res://runtime/scenes/app/app.tscn` 并进入战斗。
3. 准备一张 `keyword_exhaust = true` 的“消耗测试牌”，打出后观察右上角牌区计数：`消` 增加 1。
4. 结束回合，观察 `抽/手牌/弃/消` 四牌区计数持续联动变化。
5. 边界：将抽牌堆与弃牌堆都清空后触发抽牌，确认不崩溃；未设置关键词的普通牌仍按默认流程运行。
6. 回归：结束回合后保留牌回手，在敌人回合尝试拖拽/释放，确认无法打出。
