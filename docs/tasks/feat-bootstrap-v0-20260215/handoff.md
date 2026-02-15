# 任务交接

## 基本信息

- 任务 ID：`feat-bootstrap-v0-20260215`
- 主模块：`run_meta`
- 提交人：AI 协作执行
- 日期：2026-02-15

## 改动摘要

- 在根目录导入教程的 UI/交互基础层作为战斗基线。
- 新增 `run_meta`、`map_event`、`app` 模块，形成 `地图 -> 战斗 -> 结算` 闭环。
- 修改战斗结束行为：从“退出游戏”改为“回传 run 流程”。
- 强化 workflow：`TASK_ID` 强制、白名单校验、模板一致性、pre-commit 规则。
- 初始化 Git 仓库（`main` 分支）。

## 变更文件

- `modules/run_meta/run_state.gd`
- `modules/map_event/map_node_data.gd`
- `modules/map_event/map_generator.gd`
- `scenes/app/app.gd`
- `scenes/app/app.tscn`
- `scenes/map/map_screen.gd`
- `scenes/map/map_screen.tscn`
- `global/events.gd`
- `scenes/battle/battle.gd`
- `scenes/ui/battle_over_panel.gd`
- `project.godot`
- `tools/workflow_check.sh`
- `tools/new_task.sh`
- `tools/install_hooks.sh`
- `Makefile`
- 以及导入的 legacy 目录（`art/`, `characters/`, `custom_resources/`, `effects/`, `enemies/`, `global/`, `scenes/*`）

## 验证结果

- [x] `make workflow-check TASK_ID=feat-bootstrap-v0-20260215`：通过
- [ ] Godot headless 启动验证：当前环境未检测到 `godot/godot4` CLI，待本机补测

## 风险与影响范围

- 首次导入 legacy 资源体量较大，后续建议按模块拆分提交。
- 当前 battle 仍是 legacy 内核，后续应逐步替换为模块化规则层。

## 建议提交信息

- `feat(run_meta): 建立基础版流程闭环并接入模块骨架（feat-bootstrap-v0-20260215）`
