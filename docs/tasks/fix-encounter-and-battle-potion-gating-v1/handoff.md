# Handoff：fix-encounter-and-battle-potion-gating-v1

## 基本信息

- 任务 ID：`fix-encounter-and-battle-potion-gating-v1`
- 主模块：`run_flow`
- 提交人：`Codex`
- 日期：`2026-02-23`

## 本轮交付目标

在已完成“遭遇缺失显式失败 + 药水战斗态门禁”基础上，继续完成一次面向后续大规模功能开发的架构收口，重点降低场景层耦合、统一状态写入口、拆分持久化职责，并把关键约束固化为 workflow 门禁。

## 改动摘要

1. **App 编排解耦（run_flow orchestrator）**
   - 新增 `AppFlowOrchestrator`，把开局、读档、地图节点进入、战斗结算后路由、非战斗完成路由从 `app.gd` 下沉到 `run_flow`。
   - `app.gd` 进一步瘦身为“依赖注入 + 页面实例化 + 信号接线”薄层。

2. **战斗会话显式注入（relic_potion battle session port）**
   - 新增 battle session 契约对象，`battle.gd` 在战斗上下文就绪后构建并绑定。
   - `app.gd` 显式把 `relic_potion_system` 注入 battle scene，替代过去隐式轮询/反射式依赖。
   - `relic_potion_system` 新增 `on_battle_session_bound(...)`，并保留 `on_battle_scene_ready(...)` 兼容桥接。

3. **持久化拆分（SaveService Facade）**
   - `save_service.gd` 从“大而全实现”拆为 facade。
   - 新增：
     - `save_slot_gateway.gd`（文件读写）
     - `run_state_serializer.gd`（写盘序列化）
     - `run_state_deserializer.gd`（读档反序列化）
   - 存档版本升级为 `SAVE_VERSION=4`，最小兼容版本改为 `MIN_COMPAT_VERSION=4`（按审批执行破兼容）。

4. **RunState 写入口收口（command service）**
   - 新增 `RunStateCommandService`，统一封装常用 RunState 写操作。
   - `map_flow/shop_flow/event_flow/rest_flow` 改为通过 command service 落盘式写入，减少分散 set/add 调用。
   - 新增单测 `test_run_state_command_service.gd`。

5. **场景类型耦合清理（card_system）**
   - `card_zones_model.gd` 去除对 `Hand/CardUI` 的直接类型依赖，改为通用节点属性读取，降低 module -> scene 双向耦合。

6. **新增质量门禁并接入 workflow**
   - 新增：
     - `battle_relic_injection_contract_check.sh`
     - `module_scene_type_dependency_check.sh`
     - `dynamic_call_guard_check.sh`
   - 更新：
     - `workflow_check.sh`（串行纳入新门禁）
     - `run_lifecycle_contract_check.sh`（允许通过 orchestrator 的生命周期调用路径）
     - `persistence_contract_check.sh`（适配持久化拆分后的多文件契约）

## 变更文件

- 编排与流程：
  - `runtime/modules/run_flow/app_flow_orchestrator.gd`
  - `runtime/scenes/app/app.gd`
  - `runtime/modules/run_flow/map_flow_service.gd`
  - `runtime/modules/run_flow/shop_flow_service.gd`
  - `runtime/modules/run_flow/event_flow_service.gd`
  - `runtime/modules/run_flow/rest_flow_service.gd`
- 战斗会话注入：
  - `runtime/modules/relic_potion/contracts/battle_session_port.gd`
  - `runtime/scenes/battle/battle.gd`
  - `runtime/modules/relic_potion/relic_potion_system.gd`
- 持久化拆分：
  - `runtime/modules/persistence/save_service.gd`
  - `runtime/modules/persistence/save_slot_gateway.gd`
  - `runtime/modules/persistence/run_state_serializer.gd`
  - `runtime/modules/persistence/run_state_deserializer.gd`
  - `runtime/modules/persistence/README.md`
  - `docs/contracts/run_state.md`
- RunState 写入口收口：
  - `runtime/modules/run_meta/run_state_command_service.gd`
  - `dev/tests/unit/test_run_state_command_service.gd`
- 耦合清理：
  - `runtime/modules/card_system/card_zones_model.gd`
- 质量门禁：
  - `dev/tools/battle_relic_injection_contract_check.sh`
  - `dev/tools/module_scene_type_dependency_check.sh`
  - `dev/tools/dynamic_call_guard_check.sh`
  - `dev/tools/persistence_contract_check.sh`
  - `dev/tools/run_lifecycle_contract_check.sh`
  - `dev/tools/workflow_check.sh`

## 验证结果

- [x] `bash dev/tools/run_gut_tests.sh 120`（`157/157`）
- [x] `TASK_ID=fix-encounter-and-battle-potion-gating-v1 bash dev/tools/workflow_check.sh`
- [x] `bash dev/tools/module_scene_type_dependency_check.sh`
- [x] `bash dev/tools/dynamic_call_guard_check.sh`
- [x] `bash dev/tools/persistence_contract_check.sh`

## 风险与影响范围

- 影响模块：`run_flow`、`relic_potion`、`persistence`、`run_meta`、`card_system`、`app/battle scene`、`dev/tools`。
- 主要风险：
  - 存档破兼容（v4 only）后，旧档不可继续使用；已按审批执行。
  - orchestrator 新增后若后续绕过入口，可能出现生命周期调用分叉；已用 contract gate 约束。
  - battle session 注入链若被未来改动打断，遗物战斗触发可能失效；已用专项门禁覆盖。

## 建议提交信息

- `fix(run_flow): 架构收口并落地 battle session/持久化拆分（fix-encounter-and-battle-potion-gating-v1）`
