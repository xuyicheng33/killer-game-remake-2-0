# 任务计划

## 基本信息

- 任务 ID：`phase2-scene-decoupling-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：Codex
- 日期：2026-02-16

## 目标

执行 Phase 2 第一批：场景去业务化。

1. 建立 `run_flow` 应用服务骨架。
2. 将 `shop/event/rest` 场景中的 `RunState` 写操作迁入服务命令接口。
3. 场景保留“收输入 + 调服务 + 刷界面”。
4. 不改玩法规则、不改数值结果、不改存档结构。

## 范围边界

- 包含：
  - 新增 `modules/run_flow/*.gd` 服务脚本
  - 改造 `scenes/shop/shop_screen.gd`
  - 改造 `scenes/events/event_screen.gd`
  - 改造 `scenes/map/rest_screen.gd`
  - 允许少量接线改动 `scenes/app/app.gd`
  - 同步更新契约/架构文档与任务三件套
- 不包含：
  - battle 规则链路改动
  - reward_economy 业务规则改动
  - 存档 schema 改动
  - 跨模块大重构

## 改动白名单文件

- `modules/run_flow/**`
- `scenes/app/app.gd`
- `scenes/shop/shop_screen.gd`
- `scenes/events/event_screen.gd`
- `scenes/map/rest_screen.gd`
- `scenes/ui/stats_ui.gd`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/tasks/phase2-scene-decoupling-v1/**`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 新增 `run_flow` 聚合服务与 `shop/event/rest` 命令服务。
2. 将 `shop/event/rest` 场景写状态逻辑迁入服务调用。
3. 在 `app.gd` 注入并下发 run_flow 服务。
4. 更新模块边界与架构文档，使描述与代码一致。
5. 补齐任务三件套与工作日志。
6. 修复联调发现的 UI 崩溃问题（`Label` 字体 override 非法访问）。
7. 执行 `make workflow-check TASK_ID=phase2-scene-decoupling-v1`。

## 验证方案

1. 静态验证：
   - `scenes/shop|events|map/rest` 不再出现 `run_state.spend_gold/add_gold/add_card_to_deck/remove_card_from_deck_at/heal_player/upgrade_card_in_deck_at/next_floor` 写操作。
2. 流程等价验证（手工可复验）：
   - 商店购买/删卡/离开与改造前一致。
   - 事件选项应用与继续推进楼层行为一致。
   - 营火休息/强化（含强化失败+5 金币回退）行为一致。
3. `make workflow-check TASK_ID=phase2-scene-decoupling-v1`。

## 风险与回滚

- 风险：服务返回值与场景 UI 状态同步不完整，可能出现提示文案或按钮状态异常。
- 回滚：本任务改动集中于 `run_flow` 与三个场景，可按文件粒度回滚。
