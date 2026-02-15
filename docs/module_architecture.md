# 模块架构与边界

## 1. 代码根目录约定

- 项目协作根：`/Users/xuyicheng/杀戮游戏复刻2.0`
- 当前玩法代码基线：`references/tutorial_baseline/`
- 下文模块路径均默认相对该基线目录。

## 2. 模块边界总览

| 模块 | 职责 | 推荐目录 |
|---|---|---|
| `run_meta` | 局外开局、角色、种子、难度、结算 | `scenes/run/`, `scenes/menu/`, `global/run_*` |
| `battle_loop` | 回合状态机、阶段切换、行动窗口 | `scenes/battle/` |
| `card_system` | 卡牌实体、手牌/抽牌/弃牌/消耗流转 | `scenes/card_ui/`, `custom_resources/cards/` |
| `effect_engine` | 效果调度、结算栈、触发时机 | `effects/`, `global/effect_*` |
| `buff_system` | 力量/敏捷/易伤/虚弱等状态系统 | `effects/`, `characters/*_stats*` |
| `enemy_intent` | 敌人行为脚本、意图展示与刷新 | `scenes/enemy/`, `enemies/`, `scenes/ui/intent_*` |
| `map_event` | 地图节点、事件、路线推进 | `scenes/map/`, `scenes/events/` |
| `reward_economy` | 金币、战后奖励、商店、删卡 | `scenes/reward/`, `scenes/shop/` |
| `relic_potion` | 遗物触发链、药水使用与容量 | `custom_resources/relics/`, `custom_resources/potions/` |
| `save_seed_replay` | 存档、随机数种子、复盘日志 | `global/save_*`, `global/rng_*` |
| `content_pipeline` | 内容表、平衡参数、导入导出 | `custom_resources/`, `tools/content_*` |
| `ui_shell` | UI 展示层与输入表现，不承载规则 | `scenes/ui/` |

## 3. 层次规则

1. `ui_shell` 只读状态，不直接改核心规则状态。
2. `battle_loop` 作为编排层，不直接实现具体效果细节。
3. `effect_engine` 通过明确接口调用 `buff_system` 与实体状态。
4. `enemy_intent` 只产出“动作意图”，最终执行由 `battle_loop/effect_engine` 驱动。
5. 共享状态结构变更必须更新 `docs/contracts/`。

## 4. 跨模块依赖白名单

- 允许：`battle_loop -> card_system -> effect_engine -> buff_system`
- 允许：`battle_loop -> enemy_intent`
- 允许：`battle_loop -> ui_shell`（只推送显示数据）
- 禁止：`ui_shell -> effect_engine` 的直接规则调用
- 禁止：`map_event` 直接写战斗运行时对象（应通过 `run_meta` 中转）

## 5. 变更级别判定

- L0：UI 文案、纯文档、注释、低风险单文件。
- L1：单模块内部逻辑调整，外部接口不变。
- L2：跨模块接口变更、存档结构变更、战斗结算链路变更。
