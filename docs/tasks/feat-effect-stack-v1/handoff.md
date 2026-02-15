# 任务交接

## 基本信息

- 任务 ID：`feat-effect-stack-v1`
- 主模块：`effect_engine`
- 提交人：AI 协作执行
- 日期：2026-02-15

## 改动摘要

- 在 `modules/effect_engine` 新增 `EffectStackEngine`，提供 `enqueue_effect/process` 队列化结算。
- 将 `DamageEffect`、`BlockEffect` 改为“构建条目并入队”，由队列按序执行。
- 增加最小调试可视：日志输出队列长度与当前处理条目，并提供读取接口。
- 更新 `docs/contracts/battle_state.md`，明确 `stack` 的 FIFO 语义与 A3 约束。

## 变更文件

- `modules/effect_engine/effect_stack_engine.gd`
- `modules/effect_engine/README.md`
- `effects/damage_effect.gd`
- `effects/block_effect.gd`
- `docs/contracts/battle_state.md`
- `docs/tasks/feat-effect-stack-v1/plan.md`
- `docs/tasks/feat-effect-stack-v1/handoff.md`
- `docs/tasks/feat-effect-stack-v1/verification.md`

## 验证结果

- [x] 用例 1：`make workflow-check TASK_ID=feat-effect-stack-v1` 通过
- [ ] 用例 2：运行时多段/按序结算（当前环境缺少 Godot CLI，待本机补测）
- [ ] 用例 3：运行时边界用例（空目标/无效目标，待本机补测）

## 风险与影响范围

- 影响范围限定在 `effect_engine` 与 `effects`，未触及 buff/关键词链路。
- 当前队列为同步处理模型（同帧按序），后续若改为异步逐帧处理需重新回归动画与手感。

## 建议提交信息

- `feat(effect_engine): 引入效果队列并接入多段按序结算（feat-effect-stack-v1）`
