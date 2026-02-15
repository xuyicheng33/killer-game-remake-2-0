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
