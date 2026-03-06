# 仓库规范（v3）

更新时间：2026-03-06

## 1. 根目录只放入口项

根目录允许：

- `project.godot`
- `Makefile`
- `.git*`、`.editorconfig`
- `AGENTS.md`
- `README.md`
- Godot 根资产：`addons`、`icon.svg`、`icon.svg.import`、`main_theme.tres`、`default_bus_layout.tres`
- 主目录：`runtime`、`content`、`dev`、`docs`、`references`

根目录禁止新增：

- 临时分析文档（统一放 `docs/session/`）
- 一次性脚本（统一放 `dev/tools/` 或 `docs/archive/`）
- 未声明用途的根目录漂移文件/目录（由 `dev/tools/repo_structure_check.sh` 拦截）

本地状态目录要求：

- `.godot/`、`.cursor/`、`.claude/`、`.ruff_cache/`、`.DS_Store` 仅允许作为本机缓存/状态存在，不得提交进 git。

## 2. docs 分层

- `docs/roadmap/`：阶段路线图、任务池、中长期规划。
- `docs/session/`：当前协作会话记录（`task_plan.md` / `findings.md` / `progress.md`）。
- `docs/tasks/<task-id>/`：单任务三件套（`plan.md` / `handoff.md` / `verification.md`）。
- `docs/archive/`：归档后的方案/评审/历史说明；新增文件使用小写蛇形命名，必要时追加 `_v2`、`_v3` 版本后缀。
- `docs/contracts/`：跨模块契约真源。
- `docs/work_logs/`：按月日志。

保留策略：

- `docs/tasks/` 保留完整历史，不做自动清理。
- `docs/archive/` 只新增归档文档，不承担活跃任务协作入口。

## 3. 依赖方向

允许：

- `runtime/scenes -> runtime/modules -> runtime/global`
- `runtime/scenes -> runtime/global`
- `runtime/modules -> runtime/global`

禁止新增：

- `runtime/modules -> runtime/scenes`
- `runtime/global -> runtime/scenes/runtime/modules` 的业务耦合
- UI 脚本直接写核心运行态（按 `dev/tools/ui_shell_contract_check.sh` 执行）

口径优先级：

- 依赖方向与模块边界冲突时，以 `docs/contracts/module_boundaries_v1.md` 为真源。
- 跨文档冲突处理流程见 `docs/architecture_source_of_truth.md`。

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
- `references/slay_the_spire_cn/` 是参考资料索引输入源，供 `make content-index` 使用。
- `references/tutorial_baseline/` 是只读人工对照工程，不接入日常运行时、测试或结构门禁白名单之外的业务目录。
- `references/` 顶层仅允许保留已声明参考子目录与说明文档，不放运行时代码、导入产物或临时输出。
- 允许独立外置或分仓；若移除，需同步调整 `dev/tools/content_index.sh` 与相关文档。
