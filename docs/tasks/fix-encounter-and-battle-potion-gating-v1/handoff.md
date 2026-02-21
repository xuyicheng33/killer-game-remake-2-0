# Handoff：fix-encounter-and-battle-potion-gating-v1

## 基本信息

- 任务 ID：`fix-encounter-and-battle-potion-gating-v1`
- 主模块：`run_flow`
- 提交人：`Codex`
- 日期：`2026-02-21`

## 改动摘要

本任务完成三项收口：
1. **遭遇缺失显式失败**：战斗节点遭遇解析失败时，返回 `accepted=false + error_code/error_text`，并阻止地图推进，避免静默回退。
2. **药水战斗态门禁**：药水仅允许战斗中使用；战斗外调用会被拒绝并写日志，UI 按钮同步禁用并显示提示。
3. **战斗开始触发时序收口**：遗物系统改为由战斗场景 ready 后显式通知 battle runtime，减少轮询依赖并清晰化生命周期。
4. **交付边界收口**：恢复 4 个 `content_pipeline/reports` 时间戳文件，确保任务仅包含本需求相关改动。

## 变更文件

- `runtime/modules/run_flow/map_flow_service.gd`
  - 战斗节点进入前先解析 encounter，缺失则返回拒绝结果。
  - 新增 `_resolve_battle_encounter()`，统一 encounter 解析与错误返回。
- `runtime/scenes/app/app.gd`
  - 处理 map_flow 拒绝结果，输出失败日志。
  - 移除 `_open_battle()` 中对 `start_battle()` 的提前调用。
- `runtime/scenes/battle/battle.gd`
  - `_inject_effect_stack_to_relic_system()` 增加 `on_battle_scene_ready()` 显式通知；保留向后兼容 fallback。
- `runtime/modules/relic_potion/relic_potion_system.gd`
  - `use_potion()` 新增战斗态校验（战斗外拒绝）。
  - 新增 `battle_state_changed` 信号、`is_battle_active()`、`on_battle_scene_ready()`。
  - `bind_run_state()` / `end_battle()` 补齐 battle runtime 清理。
- `runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd`
  - 监听 battle 状态变化并刷新投影。
  - 按 battle 状态启停药水按钮，补充 battle-only hint 字段。
- `runtime/scenes/ui/relic_potion_ui.gd`
  - 渲染“药水仅可在战斗中使用”提示。
- `runtime/modules/run_flow/README.md`
  - 文档补充 `encounter_missing` 失败语义。
- `dev/tests/unit/test_run_flow.gd`
  - 新增遭遇缺失拒绝路径测试。
  - 新增 battle 路由返回 `encounter_id` 测试。
- `dev/tests/unit/test_relic_potion.gd`
  - 新增战斗外药水拒绝测试。
  - 新增 UI adapter 战斗态按钮启停测试。

## 验证结果

- [x] `make test`（151/151 passed）
- [x] `make workflow-check TASK_ID=fix-encounter-and-battle-potion-gating-v1`
- [x] `bash dev/tools/save_load_replay_smoke.sh`（9 组检查全部通过）

## 风险与影响范围

- 影响模块：
  - `run_flow`：战斗节点进入失败语义变化（从静默 fallback 改为显式拒绝）。
  - `relic_potion`/`ui_shell`：药水交互门禁及 UI 行为变化。
- 主要风险：
  - 若内容管线缺失 encounter，玩家会停留地图页并收到失败提示（符合预期但暴露配置问题）。
  - 若 battle-ready 通知链断裂，会导致战斗开始触发延迟或缺失（已由现有单测与集成测试覆盖关键链路）。

## 建议提交信息

- `fix(run_flow): 收口遭遇缺失与药水战斗态门禁（fix-encounter-and-battle-potion-gating-v1）`
