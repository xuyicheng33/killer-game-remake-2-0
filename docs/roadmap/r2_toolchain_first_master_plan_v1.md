# R2 工具链优先主规划（Phase0 起步，v1）

更新时间：2026-02-17  
适用范围：`/Users/xuyicheng/杀戮游戏复刻2.0`

## 1. 规划目的

本规划用于替换“旧 phase 编号链路”后的执行混淆问题，建立一条全新的、可持续推进的任务主线：

1. 从 `Phase0` 重新编号，但与历史 `phase1~phase22` 明确区分。
2. 先完成工具链与门禁闭环，再推进内容扩容。
3. 视觉重制与资源替换放到最后阶段，避免前期高返工。

## 2. 新任务命名规范（与旧链路区分）

- 历史链路：`phase<数字>-...`
- 新链路（本规划）：`r2-phase<两位数字>-<scope>-v1`

示例：

- `r2-phase00-baseline-snapshot-v1`
- `r2-phase03-ui-shell-full-decoupling-v1`
- `r2-phase12-art-asset-replacement-v2`

分支建议：

- `feat/<module>-r2-phaseXX-...`
- `fix/<module>-r2-phaseXX-...`
- `chore/<scope>-r2-phaseXX-...`

## 3. 执行总原则

1. 一次只执行一个 `TASK_ID`。
2. 每个任务只允许一个主模块。
3. 改动必须在 `plan.md` 白名单内。
4. 每任务必须维护三件套：
   - `docs/tasks/<task-id>/plan.md`
   - `docs/tasks/<task-id>/handoff.md`
   - `docs/tasks/<task-id>/verification.md`
5. 提交前必须执行：`make workflow-check TASK_ID=<task-id>`。
6. `L2` 任务必须先审批（用户回复“批准”）后执行。

## 4. 当前基线快照（作为 R2 起点）

已具备能力：

1. `run_flow` 生命周期与路由已收口，核心契约门禁可运行。
2. `seed/RNG` 与 `save-load replay` 已有契约门禁与冒烟脚本。
3. `workflow-check` 已具备分支一致性与白名单（含 untracked）检查。

主要缺口：

1. UI 壳层只覆盖 `stats/relic_potion/battle_ui`，其他页面仍场景直连服务。
2. `run_flow` 回归门禁对 `rest/shop/event` 分支覆盖不完整。
3. `content_pipeline` 仅 cards 导入为实装，enemy/relic/event 仍占位。
4. 第二角色、敌人包、遗物药水事件内容池尚未形成可持续产能链。

## 5. R2 阶段总览

| R2 Phase | 任务 ID | 等级 | 主模块 | 目标摘要 | 状态 |
|---|---|---|---|---|---|
| 0 | `r2-phase00-baseline-snapshot-v1` | L0 | `run_meta` | 固化 R2 基线、状态面板、执行清单 | planned |
| 1 | `r2-phase01-workflow-gate-hardening-v1` | L1 | `run_meta` | 补齐 workflow-check 自检与跨环境稳定性 | planned |
| 2 | `r2-phase02-audit-pipeline-bootstrap-v1` | L1 | `run_meta` | 建立“发布-实现-审核-提交”标准闭环脚手架 | planned |
| 3 | `r2-phase03-ui-shell-full-decoupling-v1` | L2 | `ui_shell` | 完成 map/rest/shop/event/reward UI 壳层迁移 | planned |
| 4 | `r2-phase04-run-flow-regression-gate-v1` | L1 | `run_flow` | 扩展 run_flow 分支契约回归门禁 | planned |
| 5 | `r2-phase05-save-load-replay-runtime-smoke-v1` | L1 | `seed_replay` | 增强运行时冒烟，补齐主链路可复现检查 | planned |
| 6 | `r2-phase06-content-schema-expansion-v1` | L2 | `content_pipeline` | 设计 enemy/relic/event schema 与校验规则 | planned |
| 7 | `r2-phase07-content-importers-expansion-v1` | L2 | `content_pipeline` | 实装 enemy/relic/event 导入脚本与报告 | planned |
| 8 | `r2-phase08-content-pipeline-gate-integration-v1` | L1 | `content_pipeline` | 接入 workflow 或发布前强制门禁 | planned |
| 9 | `r2-phase09-character2-scaffold-v1` | L2 | `run_meta` | 第二角色骨架与开局接线 | planned |
| 10 | `r2-phase10-enemy-pack-v1` | L2 | `enemy_intent` | 数据驱动遭遇选择 + 普通/精英敌扩容 | planned |
| 11 | `r2-phase11-relic-potion-event-pack-v1` | L2 | `relic_potion` | 扩展遗物/药水/事件内容池与联动 | planned |
| 12 | `r2-phase12-art-asset-replacement-v2` | L1 | `ui_shell` | 最终资源替换轨道（最后执行） | planned |

说明：视觉资源替换轨道固定在最后（Phase12），本规划前半段全部围绕“工具链闭环 + 内容管线可持续产出”。

## 6. 各阶段详细任务卡

### R2 Phase 0

- 任务 ID：`r2-phase00-baseline-snapshot-v1`
- 等级：`L0`
- 主模块：`run_meta`
- 目标：建立 R2 的统一基线快照与进度看板，避免后续“做了但不可审计”。
- 必做项：
  1. 产出 R2 任务总表（状态、依赖、负责人、最近一次验证）。
  2. 明确当前“可复现命令集”与执行顺序。
  3. 在工作日志记录“R2 基线启动时间点”。
- 验证命令：
  - `git status --short`
  - `make workflow-check TASK_ID=r2-phase00-baseline-snapshot-v1`
- 退出条件：R2 任务总表可用于后续每一轮发布/审核。

### R2 Phase 1

- 任务 ID：`r2-phase01-workflow-gate-hardening-v1`
- 等级：`L1`
- 主模块：`run_meta`
- 目标：增强 `workflow-check` 的“稳定性 + 自检能力”，降低环境差异误报。
- 必做项：
  1. 对关键脚本补 `rg` 缺失降级策略（统一成 `rg -> grep`）。
  2. 补一个自检脚本，覆盖分支命名、TASK_ID 对齐、白名单阻断场景。
  3. 更新门禁文档与故障排查说明。
- 验证命令：
  - `bash dev/tools/workflow_branch_gate_selfcheck.sh`
  - `make workflow-check TASK_ID=r2-phase01-workflow-gate-hardening-v1`
- 风险：脚本误报导致提交流程中断。
- 回滚：仅回滚 `dev/tools/*workflow*` 与对应文档。

### R2 Phase 2

- 任务 ID：`r2-phase02-audit-pipeline-bootstrap-v1`
- 等级：`L1`
- 主模块：`run_meta`
- 目标：把“发布者 + 审核员”流程固化成可复用模板。
- 必做项：
  1. 统一审核输出模板（Finding、命令复跑、提交信息、下阶段提示词）。
  2. 统一程序员任务卡模板（目标、白名单、验证、回滚）。
  3. 明确“通过后立即提交 + 推进下一任务”触发规则。
- 验证命令：
  - `make workflow-check TASK_ID=r2-phase02-audit-pipeline-bootstrap-v1`
- 退出条件：后续每个 phase 可直接套模板执行。

### R2 Phase 3

- 任务 ID：`r2-phase03-ui-shell-full-decoupling-v1`
- 等级：`L2`（跨模块，需审批）
- 主模块：`ui_shell`
- 目标：将剩余核心页面迁移到 `scene -> adapter -> viewmodel`。
- 迁移范围（首批必须完成）：
  1. `map_screen.gd`
  2. `rest_screen.gd`
  3. `shop_screen.gd`
  4. `event_screen.gd`
  5. `reward_screen.gd`
- 必做项：
  1. 每页新增对应 adapter/viewmodel。
  2. 页面保留“渲染 + 事件转发”，不直接写领域状态。
  3. 扩展 `dev/tools/ui_shell_contract_check.sh` 覆盖新页面。
- 验证命令：
  - `bash dev/tools/ui_shell_contract_check.sh`
  - `make workflow-check TASK_ID=r2-phase03-ui-shell-full-decoupling-v1`
- 退出条件：上述页面都通过壳层接线门禁。

### R2 Phase 4

- 任务 ID：`r2-phase04-run-flow-regression-gate-v1`
- 等级：`L1`
- 主模块：`run_flow`
- 目标：补齐 `rest/shop/event` 分支 payload 契约回归。
- 必做项：
  1. 新增或扩展门禁脚本，覆盖三条非战斗分支的返回键位与路由一致性。
  2. 校验这些分支的返回也统一通过 helper 构造。
  3. 接入 `workflow-check`。
- 验证命令：
  - `bash dev/tools/run_flow_regression_check.sh`（若新建）
  - `make workflow-check TASK_ID=r2-phase04-run-flow-regression-gate-v1`
- 退出条件：run_flow 所有主分支均有脚本化契约保护。

### R2 Phase 5

- 任务 ID：`r2-phase05-save-load-replay-runtime-smoke-v1`
- 等级：`L1`
- 主模块：`seed_replay`
- 目标：把现有结构性冒烟升级为更接近运行时场景的冒烟组合。
- 必做项：
  1. 保留 fixed seed / rng continuity / map-battle-reward-map 主链。
  2. 增加至少一个“异常路径”检查（如 restore 失败 fallback）。
  3. 明确是否接入 workflow；若不接入，文档强制发布前手动执行。
- 验证命令：
  - `bash dev/tools/save_load_replay_smoke.sh`
  - `make workflow-check TASK_ID=r2-phase05-save-load-replay-runtime-smoke-v1`

### R2 Phase 6

- 任务 ID：`r2-phase06-content-schema-expansion-v1`
- 等级：`L2`（契约扩展）
- 主模块：`content_pipeline`
- 目标：定义 enemy/relic/event 的数据 schema 与错误模型。
- 必做项：
  1. 为 `sources/enemies|relics|events` 增加 schema 文档与样例（正例/反例）。
  2. 统一错误报告字段（source/field/code/message）。
  3. 更新模块契约文档，声明新增内容类型。
- 验证命令：
  - `python3 dev/tools/content_import_cards.py --input ...`（回归不破坏 cards）
  - schema 校验脚本（新增后纳入 verification）

### R2 Phase 7

- 任务 ID：`r2-phase07-content-importers-expansion-v1`
- 等级：`L2`
- 主模块：`content_pipeline`
- 目标：落地 enemy/relic/event 导入器，形成批量导入链路。
- 必做项：
  1. 新增导入脚本（可拆分多个脚本）。
  2. 输出统一报告到 `runtime/modules/content_pipeline/reports/`。
  3. 保证失败时可定位到字段级错误。
- 验证命令：
  - 每类内容至少 1 组正例 + 1 组反例
  - 输出报告中 summary 与 error 明确。

### R2 Phase 8

- 任务 ID：`r2-phase08-content-pipeline-gate-integration-v1`
- 等级：`L1`
- 主模块：`content_pipeline`
- 目标：建立内容管线门禁策略（默认接入或发布前强制执行）。
- 必做项：
  1. 新增 `content_pipeline_check.sh`（或等价脚本）。
  2. 评估接入 `workflow-check` 的耗时成本并给出结论。
  3. 形成“日常提交/发布前”的双层执行策略。
- 验证命令：
  - `bash dev/tools/content_pipeline_check.sh`
  - `make workflow-check TASK_ID=r2-phase08-content-pipeline-gate-integration-v1`（若接入）

### R2 Phase 9

- 任务 ID：`r2-phase09-character2-scaffold-v1`
- 等级：`L2`
- 主模块：`run_meta`
- 目标：第二角色可运行骨架（无美术依赖）。
- 必做项：
  1. 新建角色资源与起始牌组。
  2. 加入开局角色接线（配置/环境变量均可）。
  3. 确保存档读档可兼容第二角色。
- 验证命令：
  - 新角色开局 -> 战斗 -> 奖励 -> 地图
  - 存档退出 -> 继续游戏

### R2 Phase 10

- 任务 ID：`r2-phase10-enemy-pack-v1`
- 等级：`L2`
- 主模块：`enemy_intent`
- 目标：敌人包扩容并移除 battle 固定敌人硬编码。
- 必做项：
  1. 引入数据驱动遭遇池（普通/精英）。
  2. map 节点类型与敌组选择接线。
  3. 敌方意图规则兼容新增敌人动作。
- 验证命令：
  - 普通节点与精英节点出现不同敌组
  - 战后奖励与主流程正常回路

### R2 Phase 11

- 任务 ID：`r2-phase11-relic-potion-event-pack-v1`
- 等级：`L2`
- 主模块：`relic_potion`
- 目标：扩充遗物/药水/事件内容池并保持可回归。
- 必做项：
  1. 内容池扩容并接入随机选择。
  2. 事件效果与 run_state 写入通过模块公开接口执行。
  3. 为关键触发链补日志与最小回归样例。
- 验证命令：
  - map/event/shop/reward 场景中可观察到新内容进入主流程

### R2 Phase 12（最后执行）

- 任务 ID：`r2-phase12-art-asset-replacement-v2`
- 等级：`L1`
- 主模块：`ui_shell`
- 前置输入（必须）：
  1. 资源包（图像/音频/字体）
  2. 映射表（旧路径 -> 新路径）
- 目标：替换视觉资源，不破坏功能链路。
- 必做项：
  1. 批量替换与断链检查脚本。
  2. 替换报告（覆盖率、缺失项、回滚点）。
  3. 关键页面与关键战斗场景冒烟复验。

## 7. 推荐执行顺序

1. `r2-phase00` -> `r2-phase01` -> `r2-phase02`
2. `r2-phase03` -> `r2-phase04` -> `r2-phase05`
3. `r2-phase06` -> `r2-phase07` -> `r2-phase08`
4. `r2-phase09` -> `r2-phase10` -> `r2-phase11`
5. `r2-phase12`（最后）

## 8. 审核/提交统一门禁

每个 R2 任务在“允许提交”前必须满足：

1. `git status --short` 仅包含白名单文件。
2. `verification.md` 的命令已被审核员复跑。
3. `handoff.md` 的 workflow-check 状态与实际一致。
4. `make workflow-check TASK_ID=<task-id>` 通过。
5. 工作区提交后保持干净。

## 9. 进度跟踪建议

建议在每次完成后维护一行状态：

- `status`: `planned|in_progress|reviewing|done|blocked`
- `last_verified_at`: 日期
- `owner`: AI 名称/负责人
- `next_action`: 下一步动作

可挂载位置：

- `docs/tasks/<task-id>/handoff.md`
- `docs/work_logs/2026-02.md`

