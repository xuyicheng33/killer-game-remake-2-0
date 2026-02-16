# 验证记录

## 基本信息

- 任务 ID：`phase2-scene-decoupling-v1`
- 日期：2026-02-16

## 静态验证

- [x] `scenes/shop/shop_screen.gd` 无直接 `RunState` 写操作（通过 `ShopFlowService` 命令执行）。
- [x] `scenes/events/event_screen.gd` 无直接 `RunState` 写操作（通过 `EventFlowService` 命令执行）。
- [x] `scenes/map/rest_screen.gd` 无直接 `RunState` 写操作（通过 `RestFlowService` 命令执行）。
- [x] `scenes/ui/stats_ui.gd` 不再使用 `theme_override_font_sizes` 直接属性访问（避免 `Label` 非法属性崩溃）。

## 行为等价验证（可复验步骤）

### 用例 1：商店流程

1. 进入商店节点。
2. 购买任一卡牌，确认金币减少、牌组增加、文案正常。
3. 删除任一卡牌，确认金币减少、牌组减少、文案正常。
4. 点击离开，确认楼层推进。

期望：与改造前结果一致。

### 用例 2：事件流程

1. 进入事件节点并选择任一选项。
2. 确认结果文案显示。
3. 点击继续，确认楼层推进。

期望：事件效果与楼层推进与改造前一致。

### 用例 3：营火流程

1. 进入营火，执行“休息”，确认回血并推进楼层。
2. 再次进入营火，执行“强化”，确认成功时提示一致。
3. 在无可强化卡场景下执行“强化”，确认获得 5 金币并推进楼层。

期望：数值与文案行为保持不变。

## 自动化检查

- [x] `make workflow-check TASK_ID=phase2-scene-decoupling-v1`
  - 结果：`[workflow-check] passed.`

## 关键命令记录

- [x] `rg -n "run_state\\.(spend_gold|add_card_to_deck|add_gold|remove_card_from_deck_at|next_floor|upgrade_card_in_deck_at|heal_player|damage_player|increase_max_health)" scenes/shop/shop_screen.gd scenes/events/event_screen.gd scenes/map/rest_screen.gd`
  - 结果：无匹配（三个场景无直接 `RunState` 写操作）。
- [x] `rg -n "theme_override_font_sizes" scenes/ui/stats_ui.gd`
  - 结果：无匹配（已改为 `add_theme_font_size_override`）。
