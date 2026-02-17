# 模块架构与边界（对齐代码现状）

更新时间：2026-02-17

## 1. 当前代码基线

本文件以仓库当前运行代码为准（不是 `references/tutorial_baseline`）：

- 运行编排入口：`runtime/scenes/app/app.gd`
- 核心运行态：`runtime/modules/run_meta/run_state.gd`
- 存档实现：`runtime/modules/persistence/save_service.gd`
- 全局随机与复盘：`runtime/global/run_rng.gd`、`runtime/global/repro_log.gd`

## 2. 模块总览（现状）

| 模块 | 主要文件 | 职责摘要 | 实现度 |
|---|---|---|---|
| `run_meta` | `runtime/modules/run_meta/run_state.gd` | 跨场景运行态与地图推进状态 | 部分 |
| `run_flow` | `runtime/modules/run_flow/run_flow_service.gd` + `run_lifecycle_service.gd` | 应用层流程编排、生命周期管理与页面命令服务 | 部分 |
| `battle_loop` | `runtime/modules/battle_loop/battle_phase_state_machine.gd` | 战斗阶段状态机 | 已实现（最小） |
| `card_system` | `runtime/modules/card_system/card_zones_model.gd` | 牌区计数与关键词联动 | 部分 |
| `effect_engine` | `runtime/modules/effect_engine/effect_stack_engine.gd` | 效果队列与顺序结算 | 已实现（最小） |
| `buff_system` | `runtime/modules/buff_system/buff_system.gd` | 状态层规则与数值修正 | 部分 |
| `enemy_intent` | `runtime/modules/enemy_intent/intent_rules.gd` | 敌方意图规则选择 | 部分 |
| `map_event` | `runtime/modules/map_event/*.gd` | 地图图生成与事件效果 | 部分 |
| `reward_economy` | `runtime/modules/reward_economy/*.gd` | 奖励/商店生成与写回 | 部分 |
| `relic_potion` | `runtime/modules/relic_potion/relic_potion_system.gd` | 遗物触发与药水使用 | 部分 |
| `persistence` | `runtime/modules/persistence/save_service.gd` | 存档/读档/版本校验 | 已实现（最小） |
| `seed_replay` | `runtime/modules/seed_replay/README.md` | 历史命名占位目录 | 占位 |
| `content_pipeline` | `dev/tools/content_import_cards.py` | 卡牌导入校验与生成 | 部分 |
| `ui_shell` | `runtime/modules/ui_shell/{viewmodel,adapter}/*.gd` + `runtime/scenes/ui/*.gd` | UI 展示与交互壳层 | 部分 |

## 3. 依赖方向（当前可见）

### 3.1 场景 -> 模块

- `runtime/scenes/app/app.gd` -> `run_flow`、`relic_potion`
- `runtime/scenes/shop/shop_screen.gd` -> `run_flow/shop_flow_service`
- `runtime/scenes/events/event_screen.gd` -> `run_flow/event_flow_service`
- `runtime/scenes/map/rest_screen.gd` -> `run_flow/rest_flow_service`
- `runtime/scenes/battle/battle.gd` -> `battle_loop`
- `runtime/scenes/reward/reward_screen.gd` -> `reward_economy/reward_generator`
- `runtime/scenes/ui/battle_ui.gd` -> `ui_shell/adapter/battle_ui_adapter`
- `runtime/scenes/ui/stats_ui.gd` -> `ui_shell/adapter/stats_ui_adapter`
- `runtime/scenes/ui/relic_potion_ui.gd` -> `ui_shell/adapter/relic_potion_ui_adapter`

### 3.2 模块 -> 模块

- `run_meta` -> `map_event/map_generator`
- `run_flow` -> `reward_economy/shop_offer_generator/reward_generator`、`map_event/event_service`、`persistence/save_service`、`run_meta`
- `map_event/event_service` -> `reward_economy/reward_generator`（当前存在反向耦合）
- `persistence` -> `map_event/map_generator`
- `reward_economy/shop_offer_generator` -> `reward_economy/reward_generator`
- `ui_shell/viewmodel/stats_view_model` -> `buff_system`
- `ui_shell/adapter/relic_potion_ui_adapter` -> `relic_potion/relic_potion_system`
- `ui_shell/adapter/battle_ui_adapter` -> `card_system/card_zones_model`

### 3.3 模块 -> global

- `map_event`、`reward_economy`、`enemy_intent`、`persistence` -> `runtime/global/run_rng.gd`
- 多模块与场景共享 `runtime/global/events.gd` 事件总线

## 4. 当前边界偏差（本节仅记录当前偏差，不在本任务改代码）

1. `run_flow` 已承接地图节点进入、placeholder 跳转、shop/event/rest/battle/reward 路由决策，且通过 `flow_context` 承接跨页面流程上下文；`runtime/scenes/app/app.gd` 保留页面实例化与事件接线。
2. `run_flow` 已承接生命周期管理（新局初始化、读档恢复、checkpoint 存档、复盘日志），`runtime/scenes/app/app.gd` 不再直接调用 `persistence`、`run_rng`、`repro_log`。
3. `ui_shell` 已有首批实现（`viewmodel + adapter`），`stats_ui`、`relic_potion_ui`、`battle_ui` 已完成迁移。
4. `seed_replay` 与 `persistence` 并存但只有后者有实现。
5. 部分模块存在对场景层 class_name 的存量类型依赖（`card_system`/`buff_system`/`enemy_intent`），当前按"禁止新增、存量待迁移"处理。

## 5. 命名与归属收口（Phase 1 决议）

1. `persistence` 为唯一存档模块名（当前真实实现目录）。
2. `seed_replay` 仅保留过渡占位，不新增实现。
3. `run_flow` 保留目录并定义为“应用服务编排层”的目标归属。

## 6. 变更规则（从本版本起）

1. 新增跨模块接口必须同步更新：`docs/contracts/module_boundaries_v1.md`。
2. 变更 `RunState` 字段或存档结构必须同步更新：`docs/contracts/run_state.md`。
3. `runtime/scenes/app` 新增流程逻辑默认应落在 `run_flow`；如临时留在场景层，任务文档必须注明迁移计划。

## 7. 质量门禁（Phase 7/12/13/14/16/17）

1. UI 壳层契约门禁：`bash dev/tools/ui_shell_contract_check.sh`
   - 拦截 `runtime/scenes/ui` 直接调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`。
   - 校验 `stats_ui`、`relic_potion_ui`、`battle_ui` 仍通过 adapter/viewmodel 接入。
   - 禁止 `battle_ui` 直接导入 `card_system/card_zones_model`。
2. run_flow 契约门禁：`bash dev/tools/run_flow_contract_check.sh`
   - 校验 `ROUTE_*` 常量单点定义仍在 `route_dispatcher.gd`。
   - 校验 map/battle 关键 `next_route + payload` 键位不回归。
3. 生命周期契约门禁（Phase 12 新增）：`bash dev/tools/run_lifecycle_contract_check.sh`
   - 禁止 `runtime/scenes/app/app.gd` 直接 preload/use `persistence/save_service.gd`、`run_rng.gd`、`repro_log.gd`。
   - 强制 `app.gd` 通过 `run_flow_service.lifecycle_service` 调用 `start_new_run/try_load_saved_run/save_checkpoint`。
   - 目的：防止后续回归把生命周期逻辑再次耦合到入口场景。
4. persistence 契约门禁（Phase 13 新增）：`bash dev/tools/persistence_contract_check.sh`
   - 校验 `SAVE_VERSION` 与 `MIN_COMPAT_VERSION` 常量存在。
   - 校验 `_serialize_player_stats` 包含 `statuses` 字段（来自 `get_status_snapshot`）。
   - 校验 `_apply_player_stats` 包含 `statuses` 恢复逻辑（调用 `set_status`）。
   - 校验读取 `statuses` 时对旧存档有默认空字典兜底（兼容 v1）。
   - 目的：防止后续改动破坏 phase10 的"状态层存档兼容"能力。
5. seed/RNG 契约门禁（Phase 14 新增）：`bash dev/tools/seed_rng_contract_check.sh`
   - 校验 `card_pile.gd` 存在 `shuffle_with_rng(stream_key)` 方法。
   - 校验 `shuffle_with_rng` 内使用 `RunRng.randi_range`（非系统默认 shuffle）。
   - 校验 `player_handler.gd` 的 `start_battle` 使用 `shuffle_with_rng("battle_start_shuffle")`。
   - 校验 `player_handler.gd` 的 `reshuffle_deck_from_discard` 使用 `shuffle_with_rng("reshuffle_discard")`。
   - 校验 `run_lifecycle_service.gd` 存在 `restore_run_state` 逻辑。
   - 校验 `run_lifecycle_service.gd` 存在 `begin_run` 回退逻辑。
   - 目的：防止后续改动破坏"确定性洗牌 + 读档随机流连续性"约束。
6. 场景层 RunState 写入门禁（Phase 16 新增）：`bash dev/tools/scene_runstate_write_check.sh`
   - 禁止 `runtime/scenes/**/*.gd` 直接写入 `run_state` 字段（赋值、复合赋值、集合操作）。
   - 禁止调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_` 方法。
   - 禁止写入 `run_state.player_stats` 嵌套字段。
   - 允许只读访问（如 `run_state.gold` 读取）。
   - 目的：防止后续回归把状态写入散落回 scenes。
7. 场景层嵌套状态写入门禁（Phase 17 新增）：`bash dev/tools/scene_nested_state_write_check.sh`
   - 禁止调用 `run_state.player_stats.(set_|add_|remove_|clear_|apply_|heal|take_damage|gain_block|set_status)` 方法。
   - 禁止调用 `run_state.map_graph.(set_|add_|remove_|clear_|advance_)` 方法。
   - 禁止对 `run_state.(relics|potions|deck|discard|exhausted|consumables)` 执行集合操作。
   - 禁止对 `run_state.player_stats.(deck|discard|draw_pile|exhausted|consumables)` 执行集合操作。
   - 目的：防止通过嵌套状态方法调用绕过 Phase 16 门禁。
8. 聚合入口：`make workflow-check TASK_ID=<task-id>`
   - `workflow_check.sh` 已串行执行上述脚本，作为提交前必过检查。

## 8. 冒烟验证脚本（Phase 15）

冒烟验证脚本用于快速验证核心流程的代码结构完整性，与契约门禁互补：

1. 冒烟脚本：`bash dev/tools/save_load_replay_smoke.sh`
   - fixed-seed bootstrap check：验证 RunRng/RunLifecycleService 支持固定种子新局初始化
   - save/load rng continuity check：验证 RunRng 状态导出/恢复与 SaveService 存档/读档集成
   - battle->reward->map route smoke check：验证路由常量定义与核心流程方法存在
   - deterministic shuffle smoke check：验证 CardPile/PlayerHandler 确定性洗牌实现
2. 与契约门禁的区别：
   - 契约门禁：检查代码是否符合架构约束（禁止/强制规则）
   - 冒烟验证：检查核心功能所需的方法/字段是否存在
3. 不默认接入 workflow-check 的原因：
   - 与 seed_rng_contract_check.sh、persistence_contract_check.sh 有部分重叠
   - 冒烟验证更适合在 verification 阶段或发布前手动执行
