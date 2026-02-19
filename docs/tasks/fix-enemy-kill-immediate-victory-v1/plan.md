# Plan: fix-enemy-kill-immediate-victory-v1

## 任务元信息

- 任务ID: fix-enemy-kill-immediate-victory-v1
- 等级: L2（跨模块：buff_system + battle_loop）
- 主模块: battle_loop
- 优先级: P1（核心流程 Bug）

## 目标

修复击杀所有敌人后战斗不立即结束的问题，确保 DOT 击杀也能正确触发胜利判定。

## 边界定义

- 仅修改死亡信号处理与战斗结束判定逻辑
- 不涉及 BuffSystem 的其他功能
- 不涉及战斗状态机的正常阶段转换

## 必做项

- [x] 修改 `battle.gd:_on_enemy_died()` 立即检查战斗结束
- [x] 修改 `battle.gd:_on_player_died()` 立即触发失败
- [x] 新增 GUT 测试验证修复

## 白名单文件

- runtime/scenes/battle/battle.gd
- dev/tests/unit/test_battle_context.gd

## 验证命令

```bash
make test
```

## 禁止项

- 不修改 BuffSystem 的死亡信号发射逻辑
- 不修改战斗阶段转换规则
- 不修改敌人/玩家的属性计算

## 状态: COMPLETED
