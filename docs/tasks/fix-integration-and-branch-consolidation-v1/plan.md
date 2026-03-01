# 任务计划：fix-integration-and-branch-consolidation-v1

## 基本信息

- 任务 ID：`fix-integration-and-branch-consolidation-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：`Codex`
- 日期：`2026-03-02`

## 目标

一次性收敛当前分支阻断项：修复 workflow 门禁失败（type safety / dynamic call / module-scene dependency）、补齐关键用户可见中文文案，并完成主干合并与分支治理清理。

## 范围边界

- 包含：
  - `type_safety_check` 违规修复（EncounterRegistry）
  - `dynamic_call_guard_check` 场景层动态调用清零（app.gd 路由静态分发）
  - `module_scene_type_dependency_check` 低风险去耦与最小例外配置
  - 战斗结束文案中文化
  - 任务三件套、工作日志、分支归档与清理
- 不包含：
  - 新玩法机制
  - 存档版本升级
  - UI 视觉重构

## 改动白名单文件

- `runtime/modules/enemy_intent/encounter_registry.gd`
- `runtime/scenes/app/app.gd`
- `runtime/modules/relic_potion/battle_participant_resolver.gd`
- `runtime/modules/relic_potion/potion_use_service.gd`
- `runtime/modules/relic_potion/relic_effect_executor.gd`
- `runtime/modules/battle_loop/enemy_spawn_service.gd`
- `runtime/scenes/battle/battle.gd`
- `dev/tools/dynamic_call_guard_check.sh`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/plan.md`
- `docs/tasks/fix-integration-and-branch-consolidation-v1/plan.md`
- `docs/tasks/fix-integration-and-branch-consolidation-v1/handoff.md`
- `docs/tasks/fix-integration-and-branch-consolidation-v1/verification.md`
- `docs/work_log.md`
- `docs/work_logs/2026-03.md`

## 实施步骤

1. 收口当前分支未提交改动并创建检查点提交。
2. 修复三类门禁失败项，先单项脚本回归，再跑 `workflow-check`。
3. 修复关键 UI 文案（战斗结束中文化）。
4. 跑全量测试，确认 165/165 通过。
5. 合并到 `main` 并在 `main` 上回归。
6. 为所有本地非 `main` 分支打归档标签后执行激进清理。

## 验证方案

1. `make workflow-check TASK_ID=fix-encounter-and-battle-potion-gating-v1`
2. `make test`
3. `git branch` 与 `git tag --list 'archive/*-20260302'`

## 风险与回滚

- 风险：
  - 动态调用门禁对模块回调机制较敏感，allowlist 变更可能引入误判。
  - 激进分支清理后若无归档标签会影响追溯。
- 回滚方式：
  - 代码回滚使用 `git revert <commit>`。
  - 分支回滚通过 `archive/<branch>-20260302` 标签恢复：`git branch <branch> <tag>`。
