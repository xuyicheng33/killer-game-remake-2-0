# 任务计划

## 基本信息

- 任务 ID：`feat-effect-stack-v1`
- 任务级别：`L2`
- 主模块：`effect_engine`
- 负责人：AI 协作执行
- 日期：2026-02-15

## 目标

在不引入 buff/关键词改造的前提下，将当前即时生效的 Effect 改为队列化结算（enqueue/process），支持多段伤害按序执行并提供最小调试可视（队列长度与当前条目）。

## 范围边界

- 包含：效果队列核心结构、`DamageEffect` / `BlockEffect` 的入队化、多段伤害按段日志、最小调试可视。
- 不包含：`buff_system`、卡牌关键词（消耗/保留/虚无/X费）、敌人意图规则重构。

## 改动白名单文件

- `docs/tasks/feat-effect-stack-v1/**`
- `effects/**`
- `modules/effect_engine/**`
- `docs/contracts/battle_state.md`

## 实施步骤

1. 在 `modules/effect_engine` 实现效果队列（enqueue/process）与当前处理条目追踪。
2. 将 `effects/damage_effect.gd` 与 `effects/block_effect.gd` 从即时执行改为“构建条目并入队”。
3. 增加按条目结算日志，确保多段伤害逐段结算、不合并。
4. 在 `modules/effect_engine` 内提供最小调试可视：显示队列长度和当前结算条目。
5. 更新 `docs/contracts/battle_state.md` 的 `stack` 字段说明，明确其为效果队列语义。
6. 补齐 `verification.md` 实测结果与可复验步骤。

## 验证方案

1. 执行 `make workflow-check TASK_ID=feat-effect-stack-v1`，确认改动在白名单内。
2. 运行战斗，触发蝙蝠双段攻击，确认日志按两段独立结算（非合并）。
3. 观察调试可视，确认队列长度在入队/出队时变化且显示当前条目。
4. 边界用例：传入空目标或无效目标时，不崩溃、不阻塞队列。

## 风险与回滚

- 风险：现有动作动画与效果生效时机耦合，若队列处理时序不当可能导致体感延迟或日志错位。
- 回滚方式：按任务提交回滚；或回退 `effects/**` 与 `modules/effect_engine/**` 并恢复契约文档。
