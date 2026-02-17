# 任务计划

## 基本信息

- 任务 ID：`phase3-battle-flow-decoupling-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：Codex
- 日期：2026-02-16

## 目标

推进 battle domain 应用层收口，将 battle 结果处理、后续跳转判定、奖励入口编排从场景层迁移到 `run_flow` 服务层，保持行为等价。

## 范围边界

- 包含：
  - 在 `modules/run_flow/` 增加 battle 相关 flow service。
  - 迁移 `scenes/app/app.gd` battle 完成后的业务编排逻辑到 flow service。
  - 建立 battle -> reward -> map 命令返回契约（统一字典）。
  - 同步更新架构文档与工作日志。
- 不包含：
  - battle/reward 数值与触发规则语义改动。
  - 存档 schema 与持久化协议改动。
  - domain 反向依赖 `scenes/*`。
  - 跨模块大重构。

## 改动白名单文件

- `modules/run_flow/**`
- `scenes/app/app.gd`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/tasks/phase3-battle-flow-decoupling-v1/**`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 在 `run_flow` 新增 `battle_flow_service.gd`，定义 battle completion/reward apply 命令。
2. 更新 `run_flow_service.gd` 聚合入口，暴露 battle flow 子服务。
3. 改造 `scenes/app/app.gd`：
   - battle 结束分支判定迁移到服务层。
   - 奖励应用迁移到服务层。
   - app 保留注入、接线和 UI 路由动作。
4. 更新 `run_flow/README.md`、`module_boundaries`、`module_architecture`、`repo_structure`。
5. 补齐 phase3 三件套与 work log。
6. 执行静态检查与 `workflow-check`。

## 验证方案

1. `rg -n "run_state\\.(set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/app scenes/battle`
2. `rg -n "apply_post_battle_reward|clear_save\(" scenes/app/app.gd modules/run_flow`
3. `make workflow-check TASK_ID=phase3-battle-flow-decoupling-v1`

## 风险与回滚

- 风险：命令返回契约字段不一致会导致路由分支错误。
- 回滚：回滚 `run_flow` battle service 与 `app.gd` 接线变更即可恢复旧路径。
