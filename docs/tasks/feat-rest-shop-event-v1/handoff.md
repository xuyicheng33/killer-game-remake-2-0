# 任务交接

## 基本信息

- 任务 ID：`feat-rest-shop-event-v1`
- 主模块：`map_event`
- 提交人：Codex
- 日期：2026-02-16

## 改动摘要

- 接入 B3 三类节点最小可用流程：
  - `REST`：营火二选一（休息 / 升级）
  - `SHOP`：买卡 / 删卡
  - `EVENT`：统一事件框架 + 10 条基础事件模板
- 所有节点完成后均回写 `RunState` 并调用楼层推进，返回地图后继续沿 B2 可达性推进。
- 事件与商店涉及的卡牌供货复用 `reward_economy` 卡池接口。

## 变更文件

- `docs/tasks/feat-rest-shop-event-v1/plan.md`
- `docs/tasks/feat-rest-shop-event-v1/handoff.md`
- `docs/tasks/feat-rest-shop-event-v1/verification.md`
- `modules/map_event/README.md`
- `modules/map_event/event_catalog.gd`
- `modules/map_event/event_service.gd`
- `modules/reward_economy/README.md`
- `modules/reward_economy/reward_generator.gd`
- `modules/reward_economy/shop_offer_generator.gd`
- `modules/run_meta/run_state.gd`
- `scenes/app/app.gd`
- `scenes/map/rest_screen.gd`
- `scenes/map/rest_screen.tscn`
- `scenes/shop/shop_screen.gd`
- `scenes/shop/shop_screen.tscn`
- `scenes/events/event_screen.gd`
- `scenes/events/event_screen.tscn`

## 验证结果

- [x] `make workflow-check TASK_ID=feat-rest-shop-event-v1`
- [x] `godot4.6 --version`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（35 秒超时，日志见 verification）
- [ ] 主路径用例 1（未运行时实测）
- [ ] 主路径用例 2（未运行时实测）
- [ ] 边界用例 1（未运行时实测）

## 风险与影响范围

- 当前环境 `godot4.6 --headless --quit` 挂起，影响自动化运行时闭环。
- REST 升级当前固定强化牌组第 1 张卡（最小可用）；后续可扩展为选卡升级。
- SHOP/事件当前使用基础卡池与固定定价，后续平衡性需迭代。

## 建议提交信息

- `feat(map_event): rest shop event flow v1（feat-rest-shop-event-v1）`
