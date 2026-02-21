# 任务计划：fix-encounter-and-battle-potion-gating-v1

## 基本信息

- 任务 ID：`fix-encounter-and-battle-potion-gating-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：`Codex`
- 日期：`2026-02-21`

## 目标

修复两类高优先级稳定性问题：
1. 战斗节点遭遇缺失时不再静默回退为默认敌组，改为显式拒绝并透出原因。
2. 药水严格限定为“仅战斗可用”，并在 UI 层反映可用状态。

同时收口 battle start 触发时序：由战斗场景就绪后显式启动遗物战斗开始触发，减少轮询依赖。

## 范围边界

- 包含：
  - `MapFlowService.enter_map_node` 遭遇选择流程收口（先校验遭遇，再写入地图推进状态）
  - `GameApp` 对 map_flow 拒绝结果的用户可见反馈
  - `RelicPotionSystem` 战斗可用约束（仅战斗可用）、战斗上下文显式绑定入口
  - `Battle` 场景对遗物系统的 battle-ready 显式通知
  - `RelicPotionUIAdapter/UI` 战斗外药水按钮禁用与提示
  - 对应单测回归
- 不包含：
  - 新增卡牌/敌人/遗物内容
  - 存档结构调整
  - 视觉主题改版

## 改动白名单文件

- `runtime/modules/run_flow/map_flow_service.gd`
- `runtime/scenes/app/app.gd`
- `runtime/scenes/battle/battle.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd`
- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/modules/run_flow/README.md`
- `runtime/modules/content_pipeline/reports/`
- `dev/tools/content_import_cards.py`
- `dev/tools/content_import_enemies.py`
- `dev/tools/content_import_relics.py`
- `dev/tools/content_import_events.py`
- `dev/tests/unit/test_run_flow.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/plan.md`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/handoff.md`
- `docs/tasks/fix-encounter-and-battle-potion-gating-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 调整 `map_flow_service.gd`：战斗节点先完成遭遇解析，缺失则返回 rejected + error payload，不推进 run_state。
2. 调整 `app.gd`：处理 rejected 结果并通过日志/UI 输出提示。
3. 调整 `relic_potion_system.gd`：增加 battle-ready 显式绑定入口、仅战斗可用约束、battle 状态查询接口。
4. 调整 `battle.gd`：战斗场景 ready 后显式通知 relic system 并启动 battle trigger。
5. 调整 `relic_potion_ui_adapter.gd` 与 `relic_potion_ui.gd`：战斗外禁用药水按钮并显示“仅战斗可用”提示。
6. 补充单测：run_flow 遭遇缺失拒绝路径、药水按钮启用状态和 battle-only 行为。
7. 执行验证命令并更新任务文档/工作日志。

## 验证方案

1. `make test`
2. `make workflow-check TASK_ID=fix-encounter-and-battle-potion-gating-v1`
3. `bash dev/tools/save_load_replay_smoke.sh`

## 风险与回滚

- 风险：
  - 遭遇缺失改为拒绝后，若内容管线短时异常，玩家会看到无法进入战斗节点。
  - battle-ready 改为显式通知，若通知链断裂将导致战斗开始触发缺失。
- 回滚方式：
  - 按提交执行 `git revert <commit>`。
