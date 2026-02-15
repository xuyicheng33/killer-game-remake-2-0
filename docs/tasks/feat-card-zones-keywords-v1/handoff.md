# 任务交接

## 基本信息

- 任务 ID：`feat-card-zones-keywords-v1`
- 主模块：`card_system`
- 提交人：AI 协作执行
- 日期：2026-02-15

## 改动摘要

- 在 `modules/card_system` 增加四牌区模型 `CardZonesModel`，接入抽牌堆/手牌/弃牌堆/消耗堆计数与流转。
- 在 `custom_resources/card.gd` 增加关键词框架（消耗/保留/虚无/X费）与最小行为接口。
- 在 `custom_resources/card_pile.gd` 增加空堆安全处理与移除卡牌接口，补齐边界稳定性。
- 在 `scenes/ui/battle_ui.gd` 增加牌区计数 UI（抽/手牌/弃/消）并联动刷新。
- 在 `scenes/card_ui/card_ui.gd` 接入 X费显示与关键词下可打判定。
- 修复保留牌越阶段出牌：在规则层增加“可出牌窗口”硬限制，并在 `CardUI.play()` 二次校验。
- 更新 `docs/contracts/battle_state.md`，同步 A2 契约字段与边界规则。

## 变更文件

- `modules/card_system/card_zones_model.gd`
- `modules/card_system/README.md`
- `custom_resources/card.gd`
- `custom_resources/card_pile.gd`
- `scenes/ui/hand.gd`
- `scenes/ui/battle_ui.gd`
- `scenes/card_ui/card_ui.gd`
- `docs/contracts/battle_state.md`
- `docs/tasks/feat-card-zones-keywords-v1/plan.md`
- `docs/tasks/feat-card-zones-keywords-v1/handoff.md`
- `docs/tasks/feat-card-zones-keywords-v1/verification.md`

## 验证结果

- [x] 用例 1：`make workflow-check TASK_ID=feat-card-zones-keywords-v1` 通过
- [ ] 用例 2：主路径运行时验证（消耗测试牌后消耗堆计数 +1，当前环境缺少 Godot CLI，待本机补测）
- [ ] 用例 3：边界用例运行时验证（空抽牌堆/空弃牌堆/关键词默认值，待本机补测）

## 风险与影响范围

- 影响范围严格限制在 A2 白名单内，未触及 A4/A5/B 阶段模块。
- 由于未改 `player_handler`，保留/虚无/消耗行为由 `CardZonesModel` 通过事件后处理接入；后续若改事件时序需做回归。

## 建议提交信息

- `feat(card_system): 接入四牌区模型与关键词最小可用框架（feat-card-zones-keywords-v1）`
