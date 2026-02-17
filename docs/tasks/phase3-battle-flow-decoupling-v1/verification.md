# 验证记录

## 基本信息

- 任务 ID：`phase3-battle-flow-decoupling-v1`
- 日期：2026-02-16

## 静态检查

- [x] `rg -n "run_state\\.(set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/app scenes/battle`
  - 结果：无匹配（battle 相关场景未命中该类核心写入模式）。
- [x] `rg -n "apply_post_battle_reward|clear_save\\(" scenes/app/app.gd modules/run_flow`
  - 结果：
    - `modules/run_flow/battle_flow_service.gd:24: SAVE_SERVICE_SCRIPT.clear_save()`
    - `modules/run_flow/battle_flow_service.gd:37: apply_post_battle_reward(...)`
  - 说明：相关业务入口已迁移到 `run_flow`，`scenes/app/app.gd` 不再直接命中这两类调用。

## 行为等价验证（可复验步骤）

### 用例 1：战斗胜利 -> 奖励 -> 地图

1. 进入任意战斗节点并胜利。
2. 进入奖励页，选择卡牌或跳过。
3. 返回地图。

期望：与改造前路径一致，奖励写回与日志文案一致。

### 用例 2：战斗失败 -> 失败面板

1. 进入战斗并失败。
2. 检查失败面板显示层数/金币。
3. 重启后验证存档已按旧逻辑清理。

期望：失败处理行为与改造前一致。

## 自动化检查

- [x] `make workflow-check TASK_ID=phase3-battle-flow-decoupling-v1`
  - 结果：`[workflow-check] passed.`

## 结果记录

- 已完成本任务范围内静态与流程门禁检查。
