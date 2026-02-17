# 任务计划

## 基本信息

- 任务 ID：`feat-save-load-v1`
- 任务级别：`L2`
- 主模块：`seed_replay`（落地白名单按本任务卡执行）
- 负责人：Codex
- 日期：2026-02-16

## 目标

实现 C1 最小可用单槽位存档/读档：可保存并恢复 `RunState` 核心进度，包含版本字段与基础兼容失败兜底。

## 审批门槛（必须）

- 本任务为 `L2`，先完成三件套文档后停在审批点。
- 在你回复“批准”前，不进行任何业务代码实现。

## 范围边界

- 包含：
  - 单槽位本地存档/读档（最小可用）
  - 保存并恢复字段：`seed`、`floor`、`gold`、`player_stats`（`hp/max_hp/deck`）、地图推进状态（`map_current_node_id` / `map_reachable_node_ids` / `map_visited_node_ids` / `map_graph`）、`relics`、`potions`
  - `save_version` 字段与基础兼容处理（版本不匹配时安全失败并提示）
- 不包含：
  - 多存档槽
  - 跨设备同步/云存档
  - 复杂冲突合并
  - 战斗中断点恢复（仅恢复到可继续流程）
  - 视觉美化与 UI 重构

## 改动白名单文件

- `modules/run_meta/**`
- `modules/persistence/**`
- `scenes/app/**`
- `docs/contracts/run_state.md`
- `docs/tasks/feat-save-load-v1/**`

## 实施步骤（审批后执行）

1. 盘点 `RunState` 当前可序列化字段与最小恢复落点，定义单槽存档数据结构（含 `save_version`）。
2. 在 `modules/persistence` 建立存档读写入口与版本校验逻辑（不匹配时返回失败状态与错误信息）。
3. 在 `modules/run_meta`/`scenes/app` 接入最小保存与加载流程，恢复成功后可继续地图推进。
4. 如有必要，补充 `docs/contracts/run_state.md` 的存档兼容说明。
5. 完成验证记录并补齐交接文档。

## 验证方案（审批后执行）

1. `make workflow-check TASK_ID=feat-save-load-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志并标注环境问题）
4. 功能验证：2 条主路径 + 1 条边界用例。

## 风险与回滚

- 风险：
  - `RunState` 字段序列化遗漏会造成读档后状态不一致。
  - 版本兼容处理不足可能导致旧档误读或崩溃。
  - 地图图结构恢复若不完整，可能破坏 B2/B3/B4 推进链路。
- 回滚方式：
  - 回滚本任务提交，恢复到无 C1 存档接入状态。

