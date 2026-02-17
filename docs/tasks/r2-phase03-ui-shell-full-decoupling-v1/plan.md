# 任务计划

## 基本信息

- 任务 ID：`r2-phase03-ui-shell-full-decoupling-v1`
- 任务级别：`L2`
- 主模块：`ui_shell`
- 负责人：Claude
- 日期：2026-02-17

## 目标

将剩余核心页面（map/rest/shop/event/reward）迁移到 scene -> adapter -> viewmodel 壳层架构。

## 范围边界

- 包含：
  - 在 `modules/ui_shell` 新增 5 组 `viewmodel + adapter`。
  - 改造 `scenes/map/map_screen.gd`、`scenes/map/rest_screen.gd`、`scenes/shop/shop_screen.gd`、`scenes/events/event_screen.gd`、`scenes/reward/reward_screen.gd`，去除 UI 侧直接依赖 flow_service 与业务逻辑。
  - 同步模块边界与仓库结构文档。
  - 新增本任务三件套并通过 `workflow-check`。
- 不包含：
  - 玩法规则语义改动（数值、触发时机、奖励规则）。
  - flow_service 实现变更。
  - 新增 domain -> scenes 反向依赖。
  - 大规模 UI 重写。

## 改动白名单文件

- `runtime/modules/ui_shell/viewmodel/map_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/rest_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/event_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd`
- `runtime/modules/ui_shell/adapter/map_ui_adapter.gd`
- `runtime/modules/ui_shell/adapter/rest_ui_adapter.gd`
- `runtime/modules/ui_shell/adapter/shop_ui_adapter.gd`
- `runtime/modules/ui_shell/adapter/event_ui_adapter.gd`
- `runtime/modules/ui_shell/adapter/reward_ui_adapter.gd`
- `runtime/modules/ui_shell/README.md`
- `runtime/scenes/map/map_screen.gd`
- `runtime/scenes/map/rest_screen.gd`
- `runtime/scenes/shop/shop_screen.gd`
- `runtime/scenes/events/event_screen.gd`
- `runtime/scenes/reward/reward_screen.gd`
- `docs/work_logs/2026-02.md`
- `docs/tasks/r2-phase03-ui-shell-full-decoupling-v1/`

## 实施步骤

1. 基线扫描：识别 5 个场景脚本对 flow_service / 领域对象的直接依赖。
2. 新增 `MapUIViewModel + MapUIAdapter`，将地图节点投影计算与命令转发移出 `map_screen.gd`。
3. 新增 `RestUIViewModel + RestUIAdapter`，将休息界面投影计算与命令转发移出 `rest_screen.gd`。
4. 新增 `ShopUIViewModel + ShopUIAdapter`，将商店界面投影计算与命令转发移出 `shop_screen.gd`。
5. 新增 `EventUIViewModel + EventUIAdapter`，将事件界面投影计算与命令转发移出 `event_screen.gd`。
6. 新增 `RewardUIViewModel + RewardUIAdapter`，将奖励界面投影计算与命令转发移出 `reward_screen.gd`。
7. 更新 `ui_shell` README，记录完整架构映射。
8. 执行静态检索与 workflow 守门，输出验证记录。

## 验证方案

1. `grep -l "adapter" runtime/scenes/map/*.gd runtime/scenes/rest/*.gd runtime/scenes/shop/*.gd runtime/scenes/events/*.gd runtime/scenes/reward/*.gd`
2. `bash dev/tools/ui_shell_contract_check.sh`
3. `make workflow-check TASK_ID=r2-phase03-ui-shell-full-decoupling-v1`

## 风险与回滚

- 风险：adapter 信号接线遗漏可能导致 UI 不刷新或重复刷新。
- 风险：场景脚本 setter 未正确触发 adapter 刷新。
- 回滚方式：回滚 `modules/ui_shell/{viewmodel,adapter}` 与 5 个场景脚本改动，可恢复 Phase 2 路径。
