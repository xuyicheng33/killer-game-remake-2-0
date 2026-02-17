# 任务交接

## 基本信息

- 任务 ID：`phase8-ui-shell-battle-ui-decoupling-v1`
- 主模块：`ui_shell`
- 提交人：AI 程序员
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 8`
- 状态：`已完成`

## 改动摘要

将 `runtime/scenes/ui/battle_ui.gd` 迁移到 `scene -> adapter -> viewmodel` 接入模式：

1. 新增 `BattleUIViewModel`：将牌区计数投影为文案展示数据。
2. 新增 `BattleUIAdapter`：订阅 `CardZonesModel.zone_counts_changed` 与 `Events.player_hand_drawn`，向场景推送投影；提供 `request_end_turn()` 命令转发。
3. 改造 `battle_ui.gd`：移除对 `CardZonesModel` 的直接依赖，改为仅消费 adapter 投影和命令入口。
4. 扩展契约检查脚本：新增 `battle_ui` 接线校验。

## 变更文件

| 文件 | 操作 |
|------|------|
| `runtime/modules/ui_shell/viewmodel/battle_ui_view_model.gd` | 新增 |
| `runtime/modules/ui_shell/adapter/battle_ui_adapter.gd` | 新增 |
| `runtime/scenes/ui/battle_ui.gd` | 修改 |
| `dev/tools/ui_shell_contract_check.sh` | 修改 |
| `runtime/modules/ui_shell/README.md` | 修改 |
| `docs/module_architecture.md` | 修改 |
| `docs/contracts/module_boundaries_v1.md` | 修改 |
| `docs/work_logs/2026-02.md` | 修改 |

## 验证结果

- [x] `bash dev/tools/ui_shell_contract_check.sh`
- [x] `make workflow-check TASK_ID=phase8-ui-shell-battle-ui-decoupling-v1`
- [ ] 人工战斗流程回归（牌区计数 + 结束回合）

## 风险与影响范围

- 影响范围：仅 `battle_ui.gd`，不影响战斗规则或其他 UI。
- 风险点：adapter 事件接线遗漏可能导致牌区计数不刷新或按钮状态异常。
- 回滚方式：整体回滚本任务白名单文件，恢复 `battle_ui.gd` 原接线。

## 建议提交信息

- `feat(ui_shell): battle_ui adapter/viewmodel decoupling（phase8-ui-shell-battle-ui-decoupling-v1）`
