# 验证记录

## 基本信息

- 任务 ID：`phase8-ui-shell-battle-ui-decoupling-v1`
- 日期：2026-02-17

## 自动化验证

- [x] `bash dev/tools/ui_shell_contract_check.sh`
  - 结果：全部通过
  ```
  [ui_shell_contract] all checks passed.
  ```
- [x] `make workflow-check TASK_ID=phase8-ui-shell-battle-ui-decoupling-v1`
  - 结果：`[workflow-check] passed.`

## 静态检查

- [x] `grep -E "card_system/card_zones_model" runtime/scenes/ui/battle_ui.gd`
  - 期望：无命中
  - 结果：无命中（符合预期）

## 人工回归步骤

1. 启动游戏并进入战斗。
2. 打出至少 1 张牌并结束回合。
3. 观察牌区计数（抽牌堆/手牌/弃牌堆/消耗堆）是否持续正确刷新。
4. 点击 `结束回合`，确认流程可进入敌方回合。

- [ ] 结果记录：待用户验证
