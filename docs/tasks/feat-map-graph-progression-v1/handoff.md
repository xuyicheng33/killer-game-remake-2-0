# 任务交接

## 基本信息

- 任务 ID：`feat-map-graph-progression-v1`
- 主模块：`map_event`
- 提交人：Codex
- 日期：2026-02-16

## 改动摘要

- `map_event` 从“单层候选”升级为“多层路径图”：
  - 新增图结构 `MapGraphData`
  - 节点扩展到 `BATTLE/ELITE/REST/SHOP/EVENT/BOSS`
  - 节点包含 `floor/lane/next_node_ids`
- `RunState` 增加地图推进状态：
  - `map_current_node_id`
  - `map_reachable_node_ids`
  - `map_visited_node_ids`
  - `map_graph`（运行时）
- `MapScreen` 改为按楼层渲染整张图，并按可达性控制可点击性。
- `App` 流程接入“进入节点 -> 推进可达状态 -> 执行节点流程”，实现 B2 可持续推进。
- 更新 `docs/contracts/run_state.md` 到 v0.2.0，记录 B2 新字段与约束。

## 变更文件

- `docs/tasks/feat-map-graph-progression-v1/plan.md`
- `docs/tasks/feat-map-graph-progression-v1/handoff.md`
- `docs/tasks/feat-map-graph-progression-v1/verification.md`
- `docs/contracts/run_state.md`
- `modules/map_event/README.md`
- `modules/map_event/map_node_data.gd`
- `modules/map_event/map_graph_data.gd`
- `modules/map_event/map_generator.gd`
- `modules/run_meta/run_state.gd`
- `scenes/map/map_screen.gd`
- `scenes/app/app.gd`

## 验证结果

- [x] `make workflow-check TASK_ID=feat-map-graph-progression-v1`
- [x] `godot4.6 --version`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（35 秒超时未退出，日志见 verification）
- [ ] 主路径用例 1（未运行时实测）
- [ ] 主路径用例 2（未运行时实测）
- [ ] 边界用例 1（未运行时实测）

## 风险与影响范围

- 当前环境下 `godot4.6 --headless --quit` 出现挂起，影响自动化运行时验证闭环。
- `RunState` 新增地图推进字段后，若未来接入存档读写，需要提供迁移默认值。
- `SHOP` 节点仍为 B2 占位推进，不含 B3 交易逻辑（符合任务边界）。

## 建议提交信息

- `feat(map_event): map graph progression v1（feat-map-graph-progression-v1）`
