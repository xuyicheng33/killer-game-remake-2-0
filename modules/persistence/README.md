# persistence

状态：
- Phase C / C1 `feat-save-load-v1`：单槽位本地存档/读档最小可用。

职责：
- `RunState` 关键进度字段序列化与反序列化。
- 存档版本校验（`save_version`）与不兼容安全失败。
- 单槽位本地文件读写与清理。

当前实现：
- `save_service.gd`：提供 `save_run_state` / `load_run_state` / `clear_save` / `has_save`。
