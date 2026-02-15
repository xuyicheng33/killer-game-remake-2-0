# 模块目录索引

本目录用于按模块拆分实现。

## 模块清单

- `run_meta`：局外状态、开局、结算、跨战斗状态（已接入基础版）
- `map_event`：地图节点、事件入口、层数推进（已接入基础版）
- `battle_loop`：战斗阶段状态机
- `card_system`：牌区流转、出牌规则、目标系统
- `effect_engine`：效果队列与结算顺序
- `buff_system`：状态增减、回合时机触发
- `enemy_intent`：敌人意图生成与行为约束
- `reward_economy`：战后奖励、金币、商店经济
- `relic_potion`：遗物触发链、药水槽与消耗
- `save_seed_replay`：存档、随机种子、复盘日志
- `ui_shell`：纯展示UI与交互层
- `content_pipeline`：内容数据导入、校验、版本迁移

## 当前代码与模块映射（过渡期）

- `scenes/battle/` 当前由 `battle_loop` 承接
- `scenes/card_ui/` 当前由 `card_system` 承接
- `effects/` 当前由 `effect_engine` 承接
- `scenes/enemy/` + `enemies/` 当前由 `enemy_intent` 承接
- `scenes/ui/` 当前由 `ui_shell` 承接

说明：基础版仍保留部分 legacy 目录，后续任务按模块逐步迁移。
