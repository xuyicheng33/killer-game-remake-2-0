# 任务计划

## 基本信息

- 任务 ID：`feat-map-graph-progression-v1`
- 任务级别：`L2`
- 主模块：`map_event`
- 负责人：Codex
- 日期：2026-02-16

## 目标

实现 Phase B / B2 的地图图推进：从单层候选改为多层路径图，包含节点类型、可达性/已走路径状态，以及与楼层推进联动。

## 审批门槛（必须）

- 本任务为 `L2`，仅完成前置文档后停在审批点。
- 在你回复“批准”前，不进行任何代码实现与契约修改。

## 范围边界

- 包含：
  - 多层路径图（普通/精英/休息/事件/商店/Boss）
  - 节点可达性与已走路径状态
  - 楼层推进与 map 选择流程联动
- 不包含：
  - B3（休息/商店/事件具体交互内容）
  - B4（遗物/药水）
  - C/D 阶段内容

## 改动白名单文件

- `docs/tasks/feat-map-graph-progression-v1/**`
- `modules/map_event/**`
- `scenes/map/**`
- `modules/run_meta/**`
- `scenes/app/**`
- `docs/contracts/run_state.md`

## 实施步骤（审批后执行）

1. 盘点当前 map 数据结构与 app 流转，确认最小变更点。
2. 设计并实现多层图结构（节点、边、可达性、已走状态）。
3. 接入地图 UI 与交互：仅允许选择当前可达节点；选择后推进状态。
4. 联动 `RunState` 与楼层推进逻辑，保证战斗/奖励回写后可继续下一层。
5. 完成验证与交接文档。

## 验证方案（审批后执行）

1. `make workflow-check TASK_ID=feat-map-graph-progression-v1`
2. Godot 4.6 CLI：
   - `godot4.6 --version`
   - `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
3. 功能验证：至少 2 条主路径 + 1 条边界用例。

## 风险与回滚

- 风险：
  - 地图图状态与现有 `RunState`/app 流转耦合，可能引入“不可达节点仍可点选”或“楼层推进不同步”。
  - 若需新增/调整 `RunState` 契约字段，影响存档兼容与跨模块读取。
- 回滚方式：
  - 单任务提交回滚，恢复到 B1 的单层节点流程。
