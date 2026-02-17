# 任务交接

## 基本信息

- 任务 ID：`feat-save-load-v1`
- 主模块：`seed_replay`
- 提交人：Codex
- 日期：2026-02-16

## 当前状态

- 阶段：`C1` 实现完成（待你确认提交）
- 状态：`已实现 + 已记录验证`

## 改动摘要

- 新增 `modules/persistence/save_service.gd`：单槽位本地存档/读档服务。
  - 存档覆盖字段：`seed/floor/gold/player_stats(hp/max_hp/deck)/map_* / map_graph / relics / potions`
  - 存档文件包含 `save_version`，读档时做版本校验。
  - 版本不匹配/格式错误时安全失败并返回错误信息，不崩溃。
- `scenes/app/app.gd` 接入最小流程：
  - 启动时优先尝试读取单槽存档。
  - 每次进入地图页自动做 checkpoint 存档。
  - 战败后清理单槽存档，避免“死亡继续”。
- 更新 `docs/contracts/run_state.md`，补充 C1 存档/版本兼容约束。
- 回填 `verification.md` 执行结果与可复验步骤。

## 变更文件

- `modules/persistence/save_service.gd`
- `modules/persistence/README.md`
- `scenes/app/app.gd`
- `docs/contracts/run_state.md`
- `docs/tasks/feat-save-load-v1/plan.md`
- `docs/tasks/feat-save-load-v1/handoff.md`
- `docs/tasks/feat-save-load-v1/verification.md`

## 验证结果

- [x] `make workflow-check TASK_ID=feat-save-load-v1`
- [x] `godot4.6 --version`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行；35 秒超时，日志见 verification）
- [ ] 主路径用例 1
- [ ] 主路径用例 2
- [ ] 边界用例 1

说明：功能用例当前为“未运行时实测”，已提供本机 GUI 可复验步骤。

## 风险与影响范围

- 当前环境 `godot4.6 --headless --quit` 仍挂起，影响运行时自动化闭环。
- 存档版本策略当前为严格等于 `save_version=1`；后续版本升级需补迁移逻辑。
- 目前仅保证“地图页 checkpoint”可恢复，不覆盖战斗中断点（符合本任务边界）。

## 建议提交信息（审批后实现完成再用）

- `feat(seed_replay): add single-slot local save/load with version guard (feat-save-load-v1)`
