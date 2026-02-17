# 验证记录

## 基本信息

- 任务 ID：`phase10-persistence-status-serialization-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `make workflow-check TASK_ID=phase10-persistence-status-serialization-v1`
  - 结果：`[workflow-check] passed.`
    - `[repo-structure-check] passed`
    - `[ui_shell_contract] all checks passed`
    - `[run_flow_contract] all checks passed`

## 人工回归步骤

### 验证 1：状态层存档/读档一致性

1. 启动游戏，进入战斗。
2. 使用卡牌或敌人攻击给玩家叠加至少 2 种状态（如 `vulnerable` 与 `poison`）。
3. 记录当前状态类型与层数（可在 UI 状态徽章查看）。
4. 存档并退出游戏。
5. 重新启动游戏，选择"继续游戏"读档。
6. 检查状态类型与层数是否与存档前一致。

- [ ] 结果记录：待补充

### 验证 2：v1 存档兼容读取

1. 准备一个 v1 版本的存档文件（无 `statuses` 字段）。
   - 可手动编辑 `user://save_slot_1.json`，将 `save_version` 改为 1，删除 `player_stats.statuses` 字段。
2. 启动游戏，选择"继续游戏"读档。
3. 期望：读档成功，不崩溃，状态层为空（默认值）。

- [ ] 结果记录：待补充

## 回归检查项

- [ ] 存档主流程正常（开局 -> 存档 -> 读档 -> 继续）
- [ ] 读档后进入战斗无异常
- [ ] 读档后状态层 UI 显示正确
