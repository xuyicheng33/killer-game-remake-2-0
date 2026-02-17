# 任务计划

## 基本信息

- 任务 ID：`phase10-persistence-status-serialization-v1`
- 任务级别：`L2`
- 主模块：`persistence`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

补齐玩家状态层（力量/敏捷/易伤/虚弱/中毒）的存档与读档，避免读档后 buff 丢失导致的规则偏差。

## 范围边界

- 包含：
  - `SaveService` 增加状态层序列化与反序列化。
  - 升级存档版本并提供向后兼容读取（至少兼容 v1 -> v2）。
  - 同步更新 `run_state` 契约文档。
- 不包含：
  - 敌人状态快照持久化。
  - 存档槽位数量扩展。
  - UI 展示文案改动。

## 改动白名单文件

- `runtime/modules/persistence/save_service.gd`
- `docs/contracts/run_state.md`
- `runtime/modules/persistence/README.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase10-persistence-status-serialization-v1/plan.md`
- `docs/tasks/phase10-persistence-status-serialization-v1/handoff.md`
- `docs/tasks/phase10-persistence-status-serialization-v1/verification.md`

## 实施步骤

1. 设计状态层存档字段（建议：`player_stats.statuses` 字典）。
2. 在 `save_service.gd` 写入状态层序列化与恢复逻辑。
3. 升级 `SAVE_VERSION`，实现旧版本存档兼容恢复路径。
4. 补文档：存档字段、版本兼容策略、影响范围。

## 验证方案

1. 人工造状态：给玩家叠加若干状态后存档并退出。
2. 读档后确认状态层仍存在且数值一致。
3. 使用旧版本（v1）存档回归读取，确认不会崩溃且有合理默认值。
4. `make workflow-check TASK_ID=phase10-persistence-status-serialization-v1`

## 风险与回滚

- 风险：版本处理不当会导致旧存档读档失败。
- 风险：状态恢复顺序错误可能引起数值异常。
- 回滚方式：回滚本任务白名单文件并恢复旧 `SAVE_VERSION` 逻辑。
