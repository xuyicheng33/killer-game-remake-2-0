# 杀戮游戏复刻 2.0（Godot）

基于 Godot 的类杀戮尖塔复刻工程。当前重点是先把规则内核和流程架构打稳，再做创新机制和新卡扩展。

## 3 分钟上手

1. 用 Godot 4.5.1 打开本目录。
2. 运行主场景（当前入口在 `project.godot`）：
   - `res://runtime/scenes/app/app.tscn`
3. 预期最小流程：
   - 地图选点 -> 战斗 -> 结算/奖励 -> 返回流程

## 常用命令

- `make content-index`：重建参考资料索引。
- `make repo-structure-check`：检查目录规范（根目录与 docs 分层）。
- `make workflow-check TASK_ID=<task-id>`：提交前聚合门禁。
- `make ci-check`：执行 CI 同步门禁（结构 + 契约 + 类型；检测到 Godot 时附带最小冒烟测试）。
- `make install-hooks`：安装本地 hooks。
- `make new-task TASK_ID=<task-id>`：创建任务三件套模板。
- `make migration-draft`：输出 runtime/content/dev 大迁移草案命令。

## 目录说明（当前）

- `runtime/scenes/`：可运行页面与场景脚本。
- `runtime/modules/`：领域模块（规则、流程、存档、UI 壳层等）。
- `runtime/global/`：全局基础设施（事件、随机、音频播放器）。
- `content/art/`、`content/characters/`、`content/enemies/`、`content/effects/`、`content/custom_resources/`：运行时资源与资源脚本。
- `dev/tools/`：流程守门、内容导入与检查脚本。
- `docs/roadmap/`：路线图与阶段任务池。
- `docs/session/`：会话级计划与发现记录。
- `docs/tasks/`：按任务归档的 plan/handoff/verification。
- `references/`：只读参考资料库（不参与运行时加载）。

## 关键约束

- 架构约束：`docs/module_architecture.md`
- 架构真源索引：`docs/architecture_source_of_truth.md`
- 仓库规范：`docs/repo_conventions.md`
- 结构说明：`docs/repo_structure.md`
