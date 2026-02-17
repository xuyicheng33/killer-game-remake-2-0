# 模块架构与边界（对齐代码现状）

更新时间：2026-02-16

## 1. 当前代码基线

本文件以仓库当前运行代码为准（不是 `references/tutorial_baseline`）：

- 运行编排入口：`scenes/app/app.gd`
- 核心运行态：`modules/run_meta/run_state.gd`
- 存档实现：`modules/persistence/save_service.gd`
- 全局随机与复盘：`global/run_rng.gd`、`global/repro_log.gd`

## 2. 模块总览（现状）

| 模块 | 主要文件 | 职责摘要 | 实现度 |
|---|---|---|---|
| `run_meta` | `modules/run_meta/run_state.gd` | 跨场景运行态与地图推进状态 | 部分 |
| `run_flow` | `modules/run_flow/run_flow_service.gd` | 应用层流程编排与页面命令服务（shop/event/rest + battle result/reward） | 部分 |
| `battle_loop` | `modules/battle_loop/battle_phase_state_machine.gd` | 战斗阶段状态机 | 已实现（最小） |
| `card_system` | `modules/card_system/card_zones_model.gd` | 牌区计数与关键词联动 | 部分 |
| `effect_engine` | `modules/effect_engine/effect_stack_engine.gd` | 效果队列与顺序结算 | 已实现（最小） |
| `buff_system` | `modules/buff_system/buff_system.gd` | 状态层规则与数值修正 | 部分 |
| `enemy_intent` | `modules/enemy_intent/intent_rules.gd` | 敌方意图规则选择 | 部分 |
| `map_event` | `modules/map_event/*.gd` | 地图图生成与事件效果 | 部分 |
| `reward_economy` | `modules/reward_economy/*.gd` | 奖励/商店生成与写回 | 部分 |
| `relic_potion` | `modules/relic_potion/relic_potion_system.gd` | 遗物触发与药水使用 | 部分 |
| `persistence` | `modules/persistence/save_service.gd` | 存档/读档/版本校验 | 已实现（最小） |
| `save_seed_replay` | `modules/save_seed_replay/README.md` | 历史命名占位目录 | 占位 |
| `content_pipeline` | `tools/content_import_cards.py` | 卡牌导入校验与生成 | 部分 |
| `ui_shell` | `scenes/ui/*.gd`（目录占位） | UI 展示与交互壳层 | 部分 |

## 3. 依赖方向（当前可见）

### 3.1 场景 -> 模块

- `scenes/app/app.gd` -> `run_flow`、`reward_economy`、`relic_potion`、`persistence`
- `scenes/shop/shop_screen.gd` -> `run_flow/shop_flow_service`
- `scenes/events/event_screen.gd` -> `run_flow/event_flow_service`
- `scenes/map/rest_screen.gd` -> `run_flow/rest_flow_service`
- `scenes/battle/battle.gd` -> `battle_loop`
- `scenes/reward/reward_screen.gd` -> `reward_economy/reward_generator`
- `scenes/ui/battle_ui.gd` -> `card_system`
- `scenes/ui/stats_ui.gd` -> `buff_system`

### 3.2 模块 -> 模块

- `run_meta` -> `map_event/map_generator`
- `run_flow` -> `reward_economy/shop_offer_generator/reward_generator`、`map_event/event_service`、`persistence/save_service`、`run_meta`
- `map_event/event_service` -> `reward_economy/reward_generator`（当前存在反向耦合）
- `persistence` -> `map_event/map_generator`
- `reward_economy/shop_offer_generator` -> `reward_economy/reward_generator`

### 3.3 模块 -> global

- `map_event`、`reward_economy`、`enemy_intent`、`persistence` -> `global/run_rng.gd`
- 多模块与场景共享 `global/events.gd` 事件总线

## 4. 当前边界偏差（本节仅记录当前偏差，不在本任务改代码）

1. `run_flow` 已完成 shop/event/rest + battle result/reward 编排；地图主流程仍主要在 `scenes/app/app.gd`。
2. `ui_shell` 目录未承载实现：UI 脚本实际在 `scenes/ui/`。
3. `save_seed_replay` 与 `persistence` 并存但只有后者有实现。
4. `scenes/app/app.gd` 仍有 `RunState` 写操作（`enter_map_node`、占位 `next_floor`），属于后续批次。
5. 部分模块存在对场景层 class_name 的存量类型依赖（`card_system`/`buff_system`/`enemy_intent`），当前按“禁止新增、存量待迁移”处理。

## 5. 命名与归属收口（Phase 1 决议）

1. `persistence` 为唯一存档模块名（当前真实实现目录）。
2. `save_seed_replay` 仅保留过渡占位，不新增实现。
3. `run_flow` 保留目录并定义为“应用服务编排层”的目标归属。

## 6. 变更规则（从本版本起）

1. 新增跨模块接口必须同步更新：`docs/contracts/module_boundaries_v1.md`。
2. 变更 `RunState` 字段或存档结构必须同步更新：`docs/contracts/run_state.md`。
3. 在 `run_flow` 未落地前，`scenes/app` 新增流程逻辑需在任务文档中注明“临时放置点”。
