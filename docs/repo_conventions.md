# 仓库规范（v2）

更新时间：2026-02-17

## 1. 根目录只放入口项

根目录允许：

- `project.godot`
- `Makefile`
- `.git*`、`.editorconfig`
- `README.md`
- 主目录：`runtime`、`content`、`dev`、`docs`、`references`

根目录禁止新增：

- 临时分析文档（统一放 `docs/session/`）
- 一次性脚本（统一放 `dev/tools/` 或 `docs/archive/`）

## 2. docs 分层

- `docs/roadmap/`：阶段路线图、任务池、中长期规划。
- `docs/session/`：当前协作会话记录（`task_plan.md` / `findings.md` / `progress.md`）。
- `docs/tasks/<task-id>/`：单任务三件套（`plan.md` / `handoff.md` / `verification.md`）。
- `docs/contracts/`：跨模块契约真源。
- `docs/work_logs/`：按月日志。

## 3. 依赖方向

允许：

- `runtime/scenes -> runtime/modules -> runtime/global`
- `runtime/scenes -> runtime/global`
- `runtime/modules -> runtime/global`

禁止新增：

- `runtime/modules -> runtime/scenes`
- `runtime/global -> runtime/scenes/runtime/modules` 的业务耦合
- UI 脚本直接写核心运行态（按 `dev/tools/ui_shell_contract_check.sh` 执行）

## 4. 命名收口

- 存档主模块统一为 `runtime/modules/persistence`。
- `runtime/modules/seed_replay` 只作为占位，不新增业务实现。
- 同一内容的“手写版 + generated 版”必须明确唯一真源，并在任务文档中声明。
- 当前铁甲战士卡牌真源固定为 `content/characters/warrior/cards/generated/`。

## 5. 提交流程

1. 开始任务前准备 `docs/tasks/<task-id>/` 三件套。
2. 变更完成后执行：
   - `bash dev/tools/repo_structure_check.sh`
   - `bash dev/tools/ui_shell_contract_check.sh`
   - `bash dev/tools/run_flow_contract_check.sh`
   - `make workflow-check TASK_ID=<task-id>`
3. 通过后再提交。

## 6. references 目录定位

- `references/` 是只读外部参考库，不参与运行时加载。
- 允许独立外置或分仓；若移除，需同步调整 `dev/tools/content_index.sh` 与相关文档。
