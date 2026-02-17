# 路线图拆分总览（基于 `docs/development_roadmap_v2.md`）

## 1. 目标

将 V2 路线图从“方向描述”拆成可派发、可验收、可回滚的阶段任务，并与当前项目真实基线对齐。

## 2. 当前基线（2026-02-15）

已完成：
- `feat-bootstrap-v0-20260215` 已落地，形成 `地图 -> 战斗 -> 结算回传` 最小闭环。
- `run_meta`、`map_event` 基础接入，`scenes/app/app.tscn` 已作为流程入口。
- 协作流程（`make workflow-check`、任务三件套）已可用。

未完成（主缺口）：
- `battle_loop` 仍为 legacy 编排，缺明确阶段状态机。
- `effect_engine` 未队列化，`buff_system` 基本缺失。
- `reward_economy`、`relic_potion`、`seed_replay`、`content_pipeline` 仍处于骨架阶段。
- `ui_shell` 视觉与资源仍是教程基线。

## 3. 拆分原则

1. 保持路线图四大阶段不变：A 核心规则、B 一局流程、C 工程化复现、D 资源与UI重构。
2. 每个任务必须能独立验收，并产出 `docs/tasks/<task-id>/` 三件套。
3. 先解“规则内核正确性”（A），再扩“流程长度”（B），最后做“复现能力 + 资产替换”（C/D）。
4. 涉及跨模块接口或存档结构的任务，默认按 `L2` 处理。

## 4. 阶段与文档索引

- Phase A：`docs/roadmap/phase_A_core_kernel.md`
- Phase B：`docs/roadmap/phase_B_run_flow.md`
- Phase C：`docs/roadmap/phase_C_engineering.md`
- Phase D：`docs/roadmap/phase_D_content_ui.md`
- 统一任务池与执行顺序：`docs/roadmap/task_backlog.md`
- R2 工具链优先主规划（Phase0 起步）：`docs/roadmap/r2_toolchain_first_master_plan_v1.md`

## 5. 推荐启动顺序（结合当前缺口）

在不偏离 V2 路线图的前提下，建议先做：
1. `A1 feat-battle-loop-state-machine-v1`
2. `A3 feat-effect-stack-v1`
3. `A4 feat-buff-system-core-v1`
4. `A2 feat-card-zones-keywords-v1`
5. `A5 feat-enemy-intent-rules-v1`

说明：`docs/gap_analysis_2026-02-15_v2.md` 明确指出 effect/buff 为第一优先，故把 A3/A4 提前到 A2 之前执行，能减少后续返工。

## 6. 每阶段出口定义

- Phase A 出口：战斗核心规则具备可观察、可扩展、可回归的基础能力。
- Phase B 出口：一局可连续推进（地图、奖励、休息、商店、事件、遗物/药水）。
- Phase C 出口：可保存、可复现、可通过内容管线增量扩展。
- Phase D 出口：完成教程资产脱钩，形成统一视觉和中文体验。
