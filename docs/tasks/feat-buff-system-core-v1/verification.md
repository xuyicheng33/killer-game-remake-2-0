# 验证记录

## 执行环境

- 日期：2026-02-15
- 分支：`main`
- Godot CLI：未检测到 `godot/godot4` 可执行文件（当前终端环境）

## 执行步骤与结果

1. 执行 `make workflow-check TASK_ID=feat-buff-system-core-v1`  
   结果：通过。
2. 自动化主路径：施加虚弱后验证敌人伤害修正  
   结果：受限于当前环境缺少 Godot CLI，未执行运行时验证。
3. 自动化主路径：施加中毒后验证回合时机扣血与层数衰减  
   结果：受限于当前环境缺少 Godot CLI，未执行运行时验证。
4. 边界用例：空/无效目标与 0 层状态处理  
   结果：通过代码路径校验：`ApplyStatusEffect` 与 `BuffSystem` 均跳过无效输入，状态容器不允许负层；运行时未执行。

## 结果

- 已完成：白名单与流程守门校验（`workflow-check` 通过）。
- 待补测：Godot 运行时主路径与边界用例。

## 可复验步骤（本机）

1. `make workflow-check TASK_ID=feat-buff-system-core-v1`
2. 打开 `res://scenes/app/app.tscn` 进入战斗。
3. 在调试台执行：`BuffSystem.get_instance().apply_status_to_target(<enemy>, BuffSystem.STATUS_WEAK, 1)`，结束玩家回合后观察该敌人伤害下降（弱化生效）。
4. 在调试台执行：`BuffSystem.get_instance().apply_status_to_target(<enemy>, BuffSystem.STATUS_POISON, 3)`，推进到敌方回合结束，观察中毒扣血并从 `3 -> 2` 衰减。
5. 边界：执行 `ApplyStatusEffect.execute([])` 或对无效目标施加状态，确认不崩溃；将状态减至 0 后 UI 不显示负层。
