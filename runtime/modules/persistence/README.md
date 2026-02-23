# persistence

状态：
- Phase C / C1 `feat-save-load-v1`：单槽位本地存档/读档最小可用。
- Phase 10 `phase10-persistence-status-serialization-v1`：玩家状态层存档支持与版本兼容。
- Phase 13 `phase13-persistence-contract-gate-v1`：契约门禁保护。
- Phase 21 `feat-save-v4-break-compat-v1`：存档结构拆分与断兼容升级（v4 起）。

职责：
- `RunState` 关键进度字段序列化与反序列化。
- 存档版本校验（`save_version`）与不兼容安全失败。
- 单槽位本地文件读写与清理。
- 玩家状态层（`strength/dexterity/vulnerable/weak/poison`）序列化与恢复。

当前实现：
- `save_service.gd`：外观层（façade），提供 `save_run_state` / `load_run_state` / `clear_save` / `has_save`。
- `run_state_serializer.gd`：序列化逻辑。
- `run_state_deserializer.gd`：反序列化与模板恢复逻辑。
- `save_slot_gateway.gd`：本地文件 I/O 与 JSON 读写。

存档版本：
- 当前版本：v4
- 最低兼容版本：v4
- 兼容策略：v4 起不再兼容 v1~v3，读到旧版本直接返回 `version_mismatch`。

契约门禁（Phase 13 新增）：
- `bash dev/tools/persistence_contract_check.sh`
  - 校验 `SAVE_VERSION` 与 `MIN_COMPAT_VERSION` 常量存在。
  - 校验 `_serialize_player_stats` 包含 `statuses` 字段（来自 `get_status_snapshot`）。
  - 校验 `_apply_player_stats` 包含 `statuses` 恢复逻辑（调用 `set_status`）。
  - 校验读取 `statuses` 的默认空字典兜底逻辑仍存在（反序列化健壮性）。
  - 目的：防止后续改动破坏状态层读写与 v4 存档稳定性。
