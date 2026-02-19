# plan: fix-signal-lifecycle-v1

## 文档状态
- 本任务文档为事后补写（backfill）。
- 对应代码修复已在 `fix-p0-battle-core-v1` 时期完成并复验。

## 目标（历史）
- 将场景层信号连接规范化为 `_ready` 连接、`_exit_tree` 断开。
- 消除不成对信号连接导致的生命周期问题。

## 参考
- 主验收记录：`docs/tasks/fix-p0-battle-core-v1/verification.md`
