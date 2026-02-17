# persistence

状态：
- Phase C / C1 `feat-save-load-v1`：单槽位本地存档/读档最小可用。
- Phase 10 `phase10-persistence-status-serialization-v1`：玩家状态层存档支持与版本兼容。

职责：
- `RunState` 关键进度字段序列化与反序列化。
- 存档版本校验（`save_version`）与不兼容安全失败。
- 单槽位本地文件读写与清理。
- 玩家状态层（`strength/dexterity/vulnerable/weak/poison`）序列化与恢复。

当前实现：
- `save_service.gd`：提供 `save_run_state` / `load_run_state` / `clear_save` / `has_save`。

存档版本：
- 当前版本：v2
- 最低兼容版本：v1
- v1 -> v2 兼容策略：`statuses` 字段缺失时使用空字典默认值。
