# 任务计划

## 基本信息

- 任务 ID：`phase8-ui-shell-battle-ui-decoupling-v1`
- 任务级别：`L1`
- 主模块：`ui_shell`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

把 `runtime/scenes/ui/battle_ui.gd` 迁移到 `scene -> adapter -> viewmodel` 接入模式，避免场景脚本直接依赖 `card_system`，并保持当前战斗 UI 行为等价。

## 范围边界

- 包含：
  - 新增 `battle_ui` 对应的 `viewmodel` 与 `adapter`。
  - 改造 `battle_ui.gd`：只做渲染与交互转发，不直接依赖 `CardZonesModel`。
  - 扩展 `ui_shell` 契约检查脚本，防止 `battle_ui` 回退到直连模式。
- 不包含：
  - 卡牌交互状态机改写（`runtime/scenes/card_ui/**`）。
  - 战斗规则改动（`card_system/effect_engine/buff_system` 逻辑语义）。
  - UI 视觉风格重做。

## 改动白名单文件

- `runtime/modules/ui_shell/viewmodel/battle_ui_view_model.gd`
- `runtime/modules/ui_shell/adapter/battle_ui_adapter.gd`
- `runtime/scenes/ui/battle_ui.gd`
- `dev/tools/ui_shell_contract_check.sh`
- `runtime/modules/ui_shell/README.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase8-ui-shell-battle-ui-decoupling-v1/plan.md`
- `docs/tasks/phase8-ui-shell-battle-ui-decoupling-v1/handoff.md`
- `docs/tasks/phase8-ui-shell-battle-ui-decoupling-v1/verification.md`

## 实施步骤

1. 新建 `battle_ui_view_model.gd`：统一产出牌区计数文案、按钮状态等只读投影。
2. 新建 `battle_ui_adapter.gd`：负责订阅 `CardZonesModel` 与 `Events`，向场景推送 projection；提供结束回合命令转发。
3. 改造 `battle_ui.gd`：删除对 `CardZonesModel` 的直接依赖，改为仅消费 adapter 投影。
4. 更新 `ui_shell_contract_check.sh`：增加 `battle_ui` 接线校验（必须通过 adapter/viewmodel）。
5. 同步更新相关文档与任务三件套。

## 验证方案

1. `bash dev/tools/ui_shell_contract_check.sh`
2. `rg -n "card_system/card_zones_model" runtime/scenes/ui/battle_ui.gd`
   - 期望：无命中。
3. 运行一场战斗，验证：
   - 牌区计数刷新正常。
   - `结束回合` 按钮行为与改造前一致。
4. `make workflow-check TASK_ID=phase8-ui-shell-battle-ui-decoupling-v1`

## 风险与回滚

- 风险：adapter 事件接线遗漏会导致牌区计数不刷新或按钮状态异常。
- 回滚方式：整体回滚本任务白名单文件，恢复 `battle_ui.gd` 原接线。
