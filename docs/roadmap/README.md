# 路线图拆分总览（基于 `docs/development_roadmap_v2.md`）

## 1. 目标

将 V2 路线图从“方向描述”拆成可派发、可验收、可回滚的阶段任务，并与当前项目真实基线对齐。

## 2. 当前基线（2026-03-06）

已完成（当前真实基线）：
- `app -> map -> battle -> reward -> map` 主流程已可运行，`rest/shop/event` 已接入到 run flow。
- `battle_loop / effect_engine / buff_system / enemy_intent / card_system` 均已落地到可测试内核，不再是纯骨架。
- `relic_potion`、`persistence`、`seed replay`、`content pipeline` 已具备可运行实现与回归测试。
- `ui_shell` 已完成 battle/map/reward/rest/shop/event 等主要页面的 adapter/viewmodel 化；Phase D 视觉重建已启动。
- 协作流程现状：本地 `ci-check`、全量 `make test`、干净副本 auto-import smoke、远端 Godot CI 均已打通。

当前主缺口（非阻断）：
- 遭遇表 coverage 仍不完整，自动跑局存在 `elite/common` 某些楼层 fallback warning。
- 测试尾部仍有既有 orphan/resource leak 告警，尚未作为本轮收口目标。
- Phase D 仍处于起步阶段，资源替换、音频重建与中文 polish 还未完成。

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

在不偏离 V2 路线图的前提下，当前建议优先做：
1. `art-ui-theme-rebuild-v1` 的继续收口（Phase D 主题统一、视觉细节补完）
2. 遭遇表 coverage / autoplay warning 清理（内容侧稳定性）
3. orphan/resource leak 定位与收口（工程质量）

说明：A/B/C 阶段的主链能力已经具备，当前优先级从“补骨架”切换为“稳定性 + Phase D 体验完善”。

## 6. 每阶段出口定义

- Phase A 出口：战斗核心规则具备可观察、可扩展、可回归的基础能力。
- Phase B 出口：一局可连续推进（地图、奖励、休息、商店、事件、遗物/药水）。
- Phase C 出口：可保存、可复现、可通过内容管线增量扩展。
- Phase D 出口：完成教程资产脱钩，形成统一视觉和中文体验。
