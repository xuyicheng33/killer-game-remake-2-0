# Task Plan

## Goal
在根目录建立可运行的基础版复刻框架：保留教程项目的 UI 与交互层优点，同时完成模块化拆分起步（run/map/battle 流程）、workflow 强化、Git 初始化。

## Scope
- 深读 `references/slay_the_spire_cn`，提炼开发顺序与架构约束
- 在根目录导入并接入战斗基线
- 新增 `run_meta` 与 `map_event` 最小模块
- 优化 workflow 脚本并初始化 Git
- 输出 UI 美术资源清单
- 重构目录结构与任务路线图，形成可派发模块化任务池

## Phases
1. `completed` 参考资料结构化阅读与抽样分析。
2. `completed` 导入教程 UI/交互层到根目录。
3. `completed` 新增 `app -> map -> battle` 基础流程与模块骨架。
4. `completed` 调整战斗结算回传机制（不再直接退出）。
5. `completed` 优化 workflow/new-task/install-hooks 并通过校验。
6. `completed` 输出模块顺序与 UI 资源需求文档。
7. `completed` 重构 references 目录与模块骨架目录，补齐V2路线图与缺口分析。

## Errors Encountered
| Error | Attempt | Resolution |
|---|---|---|
| `git rev-parse --abbrev-ref HEAD` 在新仓库无提交时报错 | 1 | 改用 `git symbolic-ref --short HEAD` |
| macOS Bash 3.2 不支持 `mapfile` | 1 | 改为 `while read` 数组收集 |
| macOS Bash 3.2 不支持 `globstar` | 1 | 移除该依赖，简化匹配逻辑 |
| 新仓库无 HEAD 时白名单校验误扫全量文件 | 1 | 改为“无 HEAD 仅检查 staged 文件” |

## 2026-02-17 Task: phase6-ui-shell-viewmodel-decoupling-v1

### Goal
推进 UI Shell 化：为 `stats_ui` 与 `relic_potion_ui` 引入轻量 viewmodel/adapter，收口 UI 对领域对象的直接依赖，保持行为等价。

### Scope
- 在 `modules/ui_shell` 新增 `viewmodel` 与 `adapter`。
- `scenes/ui/stats_ui.gd`、`scenes/ui/relic_potion_ui.gd` 改成“读投影 + 发命令”。
- 同步架构文档与任务三件套。
- 跑通 `workflow-check`。

### Phases
1. `completed` 梳理当前 UI 脚本直接依赖与业务写入点。
2. `completed` 新增 viewmodel/adapter 并改造 `stats_ui.gd`。
3. `completed` 新增 viewmodel/adapter 并改造 `relic_potion_ui.gd`。
4. `completed` 补齐任务三件套与架构文档同步。
5. `completed` 执行静态检索与 `workflow-check` 验证。

### Errors Encountered (This Task)
| Error | Attempt | Resolution |
|---|---|---|
| 暂无 | - | - |

## 2026-02-17 Task: phase7-quality-gates-and-regression-v1

### Goal
固化 Phase 2~6 关键约束为可脚本化质量门禁，并接入 `workflow-check`，实现“提交前必过”的最小回归集。

### Scope
- 新增 `tools/ui_shell_contract_check.sh`。
- 扩展 `tools/run_flow_contract_check.sh` 的 route 常量与 payload 契约检查。
- 在 `tools/workflow_check.sh` 中接入上述门禁脚本。
- 补齐 phase7 三件套与架构文档同步。

### Phases
1. `completed` 新增 `ui_shell` 契约门禁脚本并通过本地验证。
2. `completed` 扩展 `run_flow` 契约门禁脚本并通过本地验证。
3. `completed` 将两类门禁接入 `workflow-check` 聚合入口。
4. `completed` 补齐 phase7 三件套与相关模块/架构文档。
5. `completed` 执行 `ui_shell/run_flow/workflow-check` 三条验证命令并记录结果。

### Errors Encountered (This Task)
| Error | Attempt | Resolution |
|---|---|---|
| 暂无 | - | - |
