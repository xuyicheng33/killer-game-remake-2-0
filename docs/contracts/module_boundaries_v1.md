# 模块边界契约 V1（Phase 1 架构收口）

更新时间：2026-02-17  
适用代码基线：`/Users/xuyicheng/杀戮游戏复刻2.0`

## 1. 目标与范围

本文件只做 Phase 1：

1. 明确“谁负责什么”。
2. 明确“谁可以依赖谁、谁禁止依赖谁”。
3. 对齐当前代码现状，标记已实现/部分实现/占位。
4. 为 Phase 2 拆任务提供契约基线。

不包含：玩法改动、业务重构、跨模块代码迁移。

## 2. 全局依赖规则（Contract First）

### 2.1 允许方向（V1）

1. `scenes/*` 可以调用 `modules/*` 对外接口。
2. 规则链路允许 `battle_loop -> card_system/effect_engine/enemy_intent`。
3. `effect_engine` 与 `buff_system` 可协作处理数值修正与状态衰减。
4. `map_event`、`reward_economy`、`relic_potion` 可读写 `run_meta.RunState`。
5. `persistence` 负责 `RunState + RNG` 的存取；`global/run_rng.gd` 提供随机流实现。

### 2.2 禁止方向（V1）

1. `ui_shell` 禁止直接调用 `effect_engine`、`buff_system`、`enemy_intent` 执行规则；允许通过 viewmodel 读取只读投影（如状态徽章）。
2. 禁止新增模块对 `scenes/*` 的直接依赖（类型或脚本）；存量依赖列入迁移清单，按 Phase 2+ 逐步清理。
3. 禁止新增 `seed_replay` 与 `persistence` 双写存档逻辑。
4. 禁止在 `run_meta` 之外新增“局内全局状态真源”。
5. 禁止新增“跨模块随意写 `RunState` 字段”的隐式入口（必须通过模块公开接口）。

### 2.3 现状偏差（已知，留到 Phase 2/4 处理）

1. `scenes/app/app.gd` 仍承担持久化接线、复盘日志写入与页面实例化（地图主流程编排已迁至 `run_flow`）。
2. `map_event/event_service.gd` 反向依赖 `reward_economy`（事件加牌复用奖励卡池）。
3. 模块层仍存在对场景层 class_name 的存量类型依赖（禁止新增，待迁移）：
   - `card_system` -> `Hand` / `CardUI`（`modules/card_system/card_zones_model.gd:10`、`modules/card_system/card_zones_model.gd:111`）
   - `buff_system` -> `Enemy` / `Player`（`modules/buff_system/buff_system.gd:21`、`modules/buff_system/buff_system.gd:141`、`modules/buff_system/buff_system.gd:263`）
   - `enemy_intent` -> `EnemyAction`（`modules/enemy_intent/intent_rules.gd:13`）

### 2.4 Phase 7 质量门禁（可脚本化）

1. UI 壳层门禁：`dev/tools/ui_shell_contract_check.sh`
   - 禁止 `scenes/ui` 直接调用 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`。
   - 强制 `stats_ui`、`relic_potion_ui` 维持 `scene -> adapter -> viewmodel` 接入链路。
2. run_flow 契约门禁：`dev/tools/run_flow_contract_check.sh`
   - 路由常量 `ROUTE_*` 必须单点定义在 `modules/run_flow/route_dispatcher.gd`。
   - `next_route + payload` 关键键位必须稳定（map_flow/battle_flow 最小回归集）。
3. 总门禁入口：`make workflow-check TASK_ID=<task-id>`
   - 默认串行执行上述两个脚本，作为提交前必过项。

## 3. 模块边界清单

## `run_meta`

- 职责：维护跨场景运行态（`RunState`），包括 seed、楼层、金币、牌组、地图推进、遗物/药水等。
- 输入：`CharacterStats` 模板、地图节点选择、奖励/事件/商店结果、药水使用请求。
- 输出：`RunState.changed` 事件、可读运行态字段、地图可达状态。
- 状态所有权：拥有 `RunState` 主状态（唯一真源）。
- 允许依赖：`map_event`（用于地图初始化）。
- 禁止依赖：`scenes/*`、`ui_shell`、`seed_replay`。
- 当前实现度：`部分`（`run_state.gd` 已可用，但流程编排尚在场景层）。

## `run_flow`

- 职责：应用服务层流程编排（地图 -> 战斗 -> 奖励 -> 地图；REST/SHOP/EVENT 分支）。
- 输入：节点选择、战斗结果、页面完成事件、存档读档请求。
- 输出：统一命令结果字典（至少含 `next_route`，可扩展 `reward_gold`/`game_over_text`/`reward_log` 等）、流程日志、检查点存档触发。
- 状态所有权：不拥有领域状态，只编排并调用其他模块。
- 允许依赖：`run_meta`、`map_event`、`reward_economy`、`relic_potion`、`persistence`、`ui_shell`。
- 禁止依赖：战斗细节实现（`card/effect/buff/enemy` 内部细节）、`content_pipeline`。
- 当前实现度：`部分`（`run_flow_service.gd` + `flow_context.gd` + `route_dispatcher.gd` + `map/shop/event/rest/battle` 命令服务已接入；app 层保留场景接线与页面实例化）。
- 契约门禁：`dev/tools/run_flow_contract_check.sh`（`ROUTE_*` 单点定义 + 关键 `next_route/payload` 键位）。

## `battle_loop`

- 职责：维护战斗阶段机（`DRAW -> ACTION -> ENEMY -> RESOLVE`）与回合计数。
- 输入：阶段切换请求、战斗开始/结束触发。
- 输出：`phase_changed` 信号、阶段名与回合号。
- 状态所有权：拥有战斗阶段状态机内部状态。
- 允许依赖：无强依赖（纯领域状态机）。
- 禁止依赖：`run_meta`、`persistence`、`ui_shell`。
- 当前实现度：`已实现（最小）`。

## `card_system`

- 职责：维护四牌区投影（抽牌/手牌/弃牌/消耗）与关键词最小行为联动（exhaust/retain/ethereal）。
- 输入：`CharacterStats`、`Hand`、全局出牌与回合事件。
- 输出：牌区计数信号、玩家行动窗口状态。
- 状态所有权：拥有牌区“投影状态”（不拥有卡牌资源源数据）。
- 允许依赖：`global/events`。
- 禁止依赖：`persistence`、`map_event`、`reward_economy`。
- 当前实现度：`部分`。

## `effect_engine`

- 职责：效果入队与 FIFO 结算，输出最小调试状态。
- 输入：`enqueue_effect(effect_name, targets, callable)`。
- 输出：目标执行结果、副作用调用、调试信号。
- 状态所有权：拥有 effect queue 与当前处理项。
- 允许依赖：无（以 `Callable` 注入实际效果）。
- 禁止依赖：`ui_shell`、`persistence`、`run_flow`。
- 当前实现度：`已实现（最小）`。

## `buff_system`

- 职责：状态层管理（strength/dexterity/vulnerable/weak/poison）与伤害/格挡修正。
- 输入：实体节点或 `Stats`、全局战斗时机事件。
- 输出：修正后的数值、状态徽章数据、状态衰减副作用。
- 状态所有权：不拥有角色本体状态，仅拥有状态规则与触发队列。
- 允许依赖：`global/events`。
- 禁止依赖：`map_event`、`reward_economy`、`persistence`。
- 当前实现度：`部分`（核心状态规则已接入，部分钩子保留）。

## `enemy_intent`

- 职责：敌方动作意图规则选择（条件优先、权重、软性禁止连续）。
- 输入：动作集合、上一动作、难度、随机流 key。
- 输出：下一动作 `EnemyAction`。
- 状态所有权：规则层本身无持久状态。
- 允许依赖：`global/run_rng.gd`。
- 禁止依赖：`run_meta`、`persistence`、`ui_shell`。
- 当前实现度：`部分`（规则层可用，扩展参数仍占位）。

## `map_event`

- 职责：地图图生成、节点数据、事件模板与事件效果应用。
- 输入：seed、当前 `RunState`、事件选项。
- 输出：`MapGraphData/MapNodeData`、事件文本、对 `RunState` 的修改结果。
- 状态所有权：拥有地图与事件模板规则；不拥有全局运行态。
- 允许依赖：`global/run_rng.gd`、`reward_economy`（当前实现复用卡池）。
- 禁止依赖：`persistence`、`ui_shell`、`battle_loop`。
- 当前实现度：`部分`（B2/B3 最小可用）。

## `reward_economy`

- 职责：战后奖励生成/应用、商店供货生成、B3 节点额外奖励。
- 输入：`RunState`、节点类型、奖励选择。
- 输出：`RewardBundle`、商店 offer、奖励应用日志。
- 状态所有权：拥有奖励生成规则与定价规则；不拥有 `RunState`。
- 允许依赖：`global/run_rng.gd`。
- 禁止依赖：`persistence`、`ui_shell`、`battle_loop`。
- 当前实现度：`部分`。

## `relic_potion`

- 职责：遗物触发链与药水使用入口，输出可读日志。
- 输入：`RunState`、战斗开始/结束、出牌与受击事件。
- 输出：遗物/药水效果写回、UI 日志信号。
- 状态所有权：拥有触发会话状态（battle_active、cards_played）；不拥有背包真源。
- 允许依赖：`global/events`、`run_meta`。
- 禁止依赖：`persistence`、`map_event`、`content_pipeline`。
- 当前实现度：`部分`。

## `persistence`

- 职责：单槽位存档读档、版本校验、`RunState + RNG` 序列化/反序列化。
- 输入：`RunState`、角色模板、存档文件。
- 输出：`save/load/clear/has_save` 结果字典、恢复后的 `RunState` 与 RNG state。
- 状态所有权：拥有持久化 schema（`save_version`）与文件格式。
- 允许依赖：`run_meta`、`map_event`（地图回填）、`global/run_rng.gd`。
- 禁止依赖：`ui_shell`、`battle_loop`、`seed_replay`。
- 当前实现度：`已实现（最小可用）`。

## `seed_replay`

- 职责：命名上意图承载“存档/seed/replay”，但当前无代码实现。
- 输入：无。
- 输出：无。
- 状态所有权：当前无。
- 允许依赖：无（占位目录）。
- 禁止依赖：禁止新增与 `persistence` 重叠实现。
- 当前实现度：`占位`。

## `content_pipeline`

- 职责：内容源校验、导入生成、错误报告（当前为 cards 最小链路）。
- 输入：`modules/content_pipeline/sources/cards/*.json`。
- 输出：生成卡脚本/资源、起始牌组、导入报告 JSON。
- 状态所有权：拥有内容 schema 与导入报告格式。
- 允许依赖：`dev/tools/content_import_cards.py` 与 `modules/content_pipeline/sources/**`。
- 禁止依赖：运行时场景、`run_meta` 持久状态。
- 当前实现度：`部分`（cards 已实现；enemy/relic/event 为占位）。

## `ui_shell`

- 职责：UI 展示与交互壳层（HUD、牌区显示、遗物药水显示、节点按钮等）。
- 输入：`RunState`、模块信号、只读投影数据。
- 输出：用户操作事件（按钮、选择）、展示刷新。
- 状态所有权：仅拥有临时 UI 状态。
- 允许依赖：`run_meta`（只读）、`card_system`、`buff_system`、`relic_potion`。
- 禁止依赖：直接写战斗规则、直接执行效果结算、直接读写存档、绕过 adapter 直接调用领域写接口。
- 当前实现度：`部分`（`modules/ui_shell/viewmodel + adapter` 已用于 `stats_ui`、`relic_potion_ui`，其余 UI 仍待迁移）。
- 契约门禁：`dev/tools/ui_shell_contract_check.sh`（禁止 UI 直写 `run_state.*` 核心入口 + 强制迁移页面 adapter/viewmodel 接线）。

## 4. 命名与归属决策（Phase 1 基线）

1. `persistence`：保留为唯一存档模块名（当前真实实现已在该目录）。
2. `seed_replay`：定义为过渡占位名，Phase 2 前不新增实现；Phase 4 决定是并入 `persistence` 子域还是删除目录。
3. `run_flow`：作为应用编排模块的目标目录名，后续承接 `scenes/app/app.gd` 的流程编排职责。

## 5. Phase 2 前置清单（可执行）

1. 补 `run_flow` 接口草案（`contract.md` 或同等文档，不改业务代码）。
2. 把 `scenes/*` 直接写 `RunState` 的入口做成清单，逐项迁到服务函数。
3. 为 `map_event -> reward_economy` 当前反向依赖补“临时例外”注释，准备后续拆分卡池查询接口。
4. 为 `persistence` 增补“禁止双实现”检查（文档门禁即可）。
5. 新任务如果改跨模块接口，必须同步更新本契约与 `docs/contracts/run_state.md`。
6. 提交前必须执行 `make workflow-check TASK_ID=<task-id>`，其内置质量门禁脚本不得跳过。
