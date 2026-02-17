# 任务计划

## 基本信息

- 任务 ID：`feat-bootstrap-v0-20260215`
- 任务级别：`L2`
- 主模块：`run_meta`
- 负责人：AI 协作执行
- 日期：2026-02-15

## 目标

在根目录建立“可运行的模块化基础版”，形成 `地图 -> 战斗 -> 结算` 的最小闭环，并同步强化 workflow + Git 守门。

## 范围边界

- 包含：根目录模块骨架、基础流程场景、workflow 脚本升级、Git 初始化。
- 不包含：完整商店系统、完整事件库、完整遗物/药水触发链、数值平衡。

## 改动白名单文件

- `.editorconfig`
- `.gitattributes`
- `.gitignore`
- `AGENTS.md`
- `icon.svg`
- `icon.svg.import`
- `art/**`
- `characters/**`
- `custom_resources/**`
- `references/tutorial_baseline/**`
- `effects/**`
- `enemies/**`
- `global/**`
- `references/slay_the_spire_cn/**`
- `modules/**`
- `scenes/**`
- `main_theme.tres`
- `default_bus_layout.tres`
- `project.godot`
- `Makefile`
- `docs/**`
- `tools/**`
- `docs/session/task_plan.md`
- `docs/session/findings.md`
- `docs/session/progress.md`

## 实施步骤

1. 复制教程项目 UI 与交互层到根目录，建立可运行资源基线。
2. 新增 `run_meta`、`map_event`、`app` 模块并串联流程。
3. 调整战斗结束回调，改为回到流程而非直接退出程序。
4. 强化 `workflow-check`、`new-task`、`install-hooks` 与 `Makefile`。
5. 初始化 Git 仓库并执行流程校验。

## 验证方案

1. 打开根目录 Godot 项目，确认主场景进入地图界面，点击节点可进入战斗并回传结算。
2. 执行 `make workflow-check TASK_ID=feat-bootstrap-v0-20260215` 通过。

## 风险与回滚

- 风险：一次性导入 legacy 资源目录，初次提交体量较大。
- 回滚方式：按任务提交回滚，或逐目录回退到本任务前版本。
