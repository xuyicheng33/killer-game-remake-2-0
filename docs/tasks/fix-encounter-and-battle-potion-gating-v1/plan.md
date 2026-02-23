# 任务计划：fix-encounter-and-battle-potion-gating-v1

## 基本信息

- 任务 ID：`fix-encounter-and-battle-potion-gating-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：`Codex`
- 日期：`2026-02-23`

## 目标

在已完成“遭遇缺失显式失败 + 药水战斗态门禁”基础上，执行一次架构收口，作为后续功能开发新基线：

1. `app.gd` 进一步瘦身，生命周期与路由编排下沉到 `run_flow`。
2. battle -> relic/potion 依赖改为显式 battle session 注入，移除隐式发现。
3. `SaveService` 拆分为“读写网关 + 序列化 + 反序列化 + façade”，降低单文件复杂度。
4. 引入 `RunStateCommandService` 统一 RunState 写入口，减少分散写操作。
5. 清理模块层对场景具体类型依赖。
6. 将关键约束固化为 workflow 门禁，避免后续回归。

## 范围边界

- 包含：
  - `run_flow` 应用编排下沉与 `app.gd` 瘦身
  - `relic_potion` battle session 显式契约与注入
  - `persistence` 模块职责拆分与存档版本策略调整
  - `map/shop/event/rest` 对 RunState 写入口收口
  - 场景类型依赖清理（限定在 `card_system` 现有耦合点）
  - 新增/更新质量门禁与对应测试
- 不包含：
  - 新增卡牌/敌人/遗物玩法内容
  - UI 视觉改版
  - 新存档兼容迁移器（本次按审批直接破兼容）

## 改动白名单文件

- `runtime/modules/run_flow/`
- `runtime/modules/relic_potion/`
- `runtime/modules/run_meta/`
- `runtime/modules/persistence/`
- `runtime/modules/card_system/card_zones_model.gd`
- `runtime/scenes/app/app.gd`
- `runtime/scenes/battle/battle.gd`
- `runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd`
- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/modules/run_flow/README.md`
- `dev/tools/`
- `dev/tests/unit/test_run_flow.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `dev/tests/unit/test_run_state_command_service.gd`
- `docs/contracts/run_state.md`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/plan.md`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/handoff.md`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 新增 `AppFlowOrchestrator`，迁移 app 生命周期与路由编排调用。
2. 引入 battle session port，完成 `app -> battle -> relic_potion` 显式注入链。
3. 拆分 `SaveService` 为 gateway/serializer/deserializer/facade。
4. 新增 `RunStateCommandService` 并改造 `map/shop/event/rest` 写入调用。
5. 清理 `card_zones_model` 对场景类型的直接依赖。
6. 增加门禁脚本并接入 `workflow_check.sh`。
7. 回归验证并更新任务三件套与工作日志。

## 验证方案

1. `bash dev/tools/run_gut_tests.sh 120`
2. `TASK_ID=fix-encounter-and-battle-potion-gating-v1 bash dev/tools/workflow_check.sh`
3. `bash dev/tools/module_scene_type_dependency_check.sh`
4. `bash dev/tools/dynamic_call_guard_check.sh`
5. `bash dev/tools/persistence_contract_check.sh`

## 风险与回滚

- 风险：
  - 存档版本升级到 v4-only 后旧档不可继续读。
  - 编排入口迁移后若有人绕过 orchestrator，可能出现生命周期分叉。
  - battle session 注入链断裂会影响遗物战斗触发时序。
- 回滚方式：
  - 按提交粒度执行 `git revert <commit>`。
