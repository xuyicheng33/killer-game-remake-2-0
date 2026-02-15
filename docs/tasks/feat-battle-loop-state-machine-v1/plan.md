# 任务计划

## 基本信息

- 任务 ID：`feat-battle-loop-state-machine-v1`
- 任务级别：`L2`
- 主模块：`battle_loop`
- 负责人：AI 协作执行
- 日期：2026-02-15

## 目标

将当前战斗流程改为“抽牌 -> 行动 -> 敌方 -> 结算”的阶段状态机驱动，并在 HUD 显示当前阶段与切换日志，保证整回合阶段顺序稳定可见。

## 范围边界

- 包含：战斗阶段枚举与状态流、`battle.gd` 对回合推进的状态机接入、HUD 阶段可视化、`BattleState` 契约同步。
- 不包含：效果队列（A3）、Buff 体系（A4）、牌区关键词重构（A2）、敌人意图规则约束（A5）。

## 改动白名单文件

- `docs/tasks/feat-battle-loop-state-machine-v1/**`
- `modules/battle_loop/**`
- `scenes/battle/**`
- `docs/contracts/battle_state.md`

## 实施步骤

1. 在 `modules/battle_loop` 新增阶段状态机脚本，定义阶段枚举、合法迁移与回合计数。
2. 改造 `scenes/battle/battle.gd`，将原有事件串联替换为状态机驱动的阶段推进。
3. 在 `scenes/battle/battle.tscn` 增加阶段 HUD（当前阶段 + 切换日志），并由 `battle.gd` 刷新显示。
4. 更新 `docs/contracts/battle_state.md`，记录阶段字段与迁移约束。
5. 产出 `docs/tasks/feat-battle-loop-state-machine-v1/verification.md`，给出可复验步骤与结果。

## 验证方案

1. 执行 `make workflow-check TASK_ID=feat-battle-loop-state-machine-v1`，确认改动文件全部在白名单内。
2. 运行战斗场景并完成至少 1 个整回合，确认 HUD 明确显示并按顺序出现：`DRAW -> ACTION -> ENEMY -> RESOLVE -> DRAW`。
3. 战斗中在敌人回合结束后，回合数自增且敌人下一行动已重置（可从意图刷新观察）。

## 风险与回滚

- 风险：现有战斗流程依赖事件链较多，若状态切换钩子接错，可能出现按钮状态异常或回合卡死。
- 回滚方式：按任务提交回滚；或先回退 `scenes/battle/**` 与 `modules/battle_loop/**`，再恢复契约文档。
