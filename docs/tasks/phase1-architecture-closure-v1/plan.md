# 任务计划

## 基本信息

- 任务 ID：`phase1-architecture-closure-v1`
- 任务级别：`L2`（跨模块边界定义与命名决策）
- 主模块：`architecture/docs`
- 负责人：Codex
- 日期：2026-02-16

## 目标

仅完成 Phase 1「架构收口」文档交付：

1. 模块职责与依赖边界清晰可执行。
2. 文档与代码现状对齐。
3. 统一命名与目录策略（重点：`persistence / seed_replay / run_flow`）。
4. 输出 Phase 2 前置任务清单。

## 严格边界

- 包含：
  - 文档更新：`docs/**`
  - 模块说明更新：`modules/**/README.md`
- 不包含：
  - 新功能实现
  - 业务代码重构
  - 战斗/地图/商店/事件逻辑改动
  - Phase 2 及以后实现

## 代码 vs 文档差异清单（先行盘点）

1. `docs/module_architecture.md` 仍以 `references/tutorial_baseline/` 为描述基线，但当前运行入口在 `scenes/app/app.gd`，并且真实存档实现在 `modules/persistence/save_service.gd`。
2. `docs/module_architecture.md` 与 `modules/README.md` 均将 `seed_replay` 视作存档主模块，但代码中 `seed_replay` 无实现，真实能力分布在 `modules/persistence` + `global/run_rng.gd` + `global/repro_log.gd`。
3. `docs/repo_structure.md` 未体现 `modules/run_flow` 空目录和 `modules/persistence` 已落地状态，目录策略缺少“当前 vs 目标”的分层描述。
4. `modules/run_meta/README.md` 为 TODO，但 `modules/run_meta/run_state.gd` 已承载核心运行态。
5. `modules/ui_shell/README.md` 为 TODO，但 `scenes/ui/*.gd` 已实际承接 UI 壳层。
6. `scenes/map/rest_screen.gd`、`scenes/shop/shop_screen.gd`、`scenes/events/event_screen.gd` 仍直接写 `RunState`，与文档“场景只编排不写核心状态”的目标存在阶段性偏差（应记录为 Phase 2 待迁移，不在本任务修改代码）。
7. `modules/map_event/event_service.gd` 反向依赖 `modules/reward_economy/reward_generator.gd`（复用加牌池），现有文档未标注该临时耦合。

## 改动白名单文件

- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/tasks/phase1-architecture-closure-v1/**`
- `docs/work_logs/2026-02.md`
- `modules/README.md`
- `modules/run_meta/README.md`
- `modules/run_flow/README.md`
- `modules/seed_replay/README.md`
- `modules/ui_shell/README.md`

## 实施步骤

1. 盘点代码与文档差异并落地本文件。
2. 新增 `docs/contracts/module_boundaries_v1.md`（逐模块契约）。
3. 回填 `docs/module_architecture.md` 与 `docs/repo_structure.md`。
4. 更新关键模块 README，消除 TODO/过期描述。
5. 填写 `handoff.md`、`verification.md`、`docs/work_logs/2026-02.md`。
6. 运行 `make workflow-check TASK_ID=phase1-architecture-closure-v1`。

## 验证方案

1. `make workflow-check TASK_ID=phase1-architecture-closure-v1`
2. 抽样核对契约文档与代码：
   - `scenes/app/app.gd`
   - `modules/run_meta/run_state.gd`
   - `modules/persistence/save_service.gd`
   - `modules/map_event/event_service.gd`
   - `scenes/shop/shop_screen.gd` / `scenes/map/rest_screen.gd`

## 风险与回滚

- 风险：
  - 命名决策若未冻结，后续任务会重复分叉 `seed_replay` 与 `persistence`。
  - 边界规则写得过理想化会与代码脱节，导致任务拆分失真。
- 回滚：
  - 本任务仅文档变更，可直接回滚对应文档文件。
