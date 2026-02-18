# 任务交接：遗物/药水/事件内容池扩容

## 任务 ID
`r2-phase11-relic-potion-event-pack-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `runtime/modules/relic_potion/relic_catalog.gd` - 遗物池注册表
- `runtime/modules/relic_potion/potion_catalog.gd` - 药水池注册表
- `content/custom_resources/relics/burning_blood.tres` - 燃烧之血遗物
- `content/custom_resources/relics/golden_idol.tres` - 黄金神像遗物
- `content/custom_resources/relics/thorns_potion.tres` - 荆棘护符遗物
- `content/custom_resources/potions/fire_potion.tres` - 火焰药水
- `docs/tasks/r2-phase11-relic-potion-event-pack-v1/plan.md`
- `docs/tasks/r2-phase11-relic-potion-event-pack-v1/handoff.md`
- `docs/tasks/r2-phase11-relic-potion-event-pack-v1/verification.md`

### 修改文件
- `runtime/modules/reward_economy/reward_generator.gd` - 使用 Catalog 替代硬编码
- `runtime/modules/run_flow/map_flow_service.gd` - 传递 run_state 到 generate_b3_bonus
- `runtime/modules/map_event/event_catalog.gd` - 事件池从 10 扩充到 15

## 内容池扩容

### 遗物池（4个）
| ID | 名称 | 效果 |
|---|---|---|
| ember_ring | 余烬指环 | 战斗开始回复3HP，打牌获得金币，受击获得格挡 |
| burning_blood | 燃烧之血 | 战斗结束回复6HP |
| golden_idol | 黄金神像 | 每3张牌+5金币 |
| thorns_potion | 荆棘护符 | 格挡时反伤3点 |

### 药水池（3个）
| ID | 名称 | 效果 |
|---|---|---|
| healing_potion | 治疗药水 | 回复12HP |
| iron_skin_potion | 铁皮药水 | 获得8格挡 |
| fire_potion | 火焰药水 | 造成20伤害 |

### 事件池（15个）
新增事件：
- event_lucky_coin - 幸运硬币
- event_mysterious_shrine - 神秘祭坛
- event_card_trader - 卡牌商人
- event_healing_spring - 治愈之泉
- event_gambler - 赌徒

## 验证结果
- 门禁检查：已通过（`make workflow-check TASK_ID=r2-phase11-relic-potion-event-pack-v1`）
- 回归验证：已通过（`bash dev/tools/run_flow_regression_check.sh`）
- 冒烟验证：已通过（`bash dev/tools/save_load_replay_smoke.sh`）
- 手动验证：待在 Godot 编辑器中执行内容多样性实测

## 提交信息
```
feat(relic_potion): 遗物/药水/事件内容池扩容（r2-phase11-relic-potion-event-pack-v1）
```
