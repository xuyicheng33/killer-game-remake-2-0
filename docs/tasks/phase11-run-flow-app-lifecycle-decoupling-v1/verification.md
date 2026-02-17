# 验证记录

## 基本信息

- 任务 ID：`phase11-run-flow-app-lifecycle-decoupling-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `make workflow-check TASK_ID=phase11-run-flow-app-lifecycle-decoupling-v1`
  - 结果：
    - `[repo-structure-check] passed`
    - `[ui_shell_contract] all checks passed`
    - `[run_flow_contract] all checks passed`
    - `[workflow-check] passed`

## 人工回归步骤

### 验证 1：新局主流程

1. 启动游戏，自动进入新局。
2. 在地图选择一个战斗节点，进入战斗。
3. 完成战斗后进入奖励页面，选择一张卡牌。
4. 返回地图页面。
5. 期望：流程路由与改造前一致。

- [ ] 结果记录：待补充

### 验证 2：存档/读档流程

1. 在地图页面退出游戏（触发 checkpoint 存档）。
2. 重新启动游戏，选择"继续游戏"。
3. 检查 `RunState`（楼层、金币、地图进度）是否正确恢复。
4. 期望：读档成功，状态与存档前一致。

- [ ] 结果记录：待补充

### 验证 3：失败结算流程

1. 进入战斗，故意输掉战斗（如不攻击让敌人击败玩家）。
2. 检查 Game Over 面板是否正确显示。
3. 点击"重新开始"按钮。
4. 期望：Game Over 面板显示正确文案，重开按钮可正常触发新局。

- [ ] 结果记录：待补充

## 回归检查项

- [ ] 新局初始化正常（种子生成、RNG 初始化、RunState 创建）
- [ ] 读档恢复正常（RunState 恢复、RNG 状态恢复）
- [ ] 地图 -> 战斗 -> 奖励 -> 地图 流程正常
- [ ] Game Over 流程正常
