# Plan: phase9-strength-axis-cards-v1

## 任务概述

Phase 9: 力量爆发轴卡牌扩展 + UI 改造 + 配套遗物

## 任务范围

### 9-0: 修复遗物 Tooltip 描述不显示
- 问题：遗物悬停只显示名称，不显示效果描述
- 方案：移除固定高度限制，让 Tooltip 根据内容自动调整

### 9-1: 卡牌 UI 改造
- 要求：将图标显示改为名称+效果描述文本显示
- 方案：card_ui.tscn 替换 Icon 为 VBoxContainer(NameLabel + DescLabel)

### 9-2: 新增 10 张力量爆发轴卡牌
- 纯力量堆叠：爆发、极限突破、战意积蓄
- 多段攻击联动：连斩、旋身击、连环重击、风暴斩
- 生命值管理：背水狂攻、血誓打击、生存本能

### 9-3: 新增 2 个配合遗物
- 战怒之戒：ON_ATTACK_PLAYED 获得力量（每战上限）
- 淬炼石：ON_BATTLE_START 获得力量（中途获取后下场战斗生效）

## 改动白名单文件

### UI
- `runtime/scenes/ui/tooltip.tscn`
- `runtime/scenes/ui/tooltip.gd`
- `runtime/scenes/app/app.tscn`
- `runtime/scenes/card_ui/card_ui.tscn`
- `runtime/scenes/card_ui/card_ui.gd`

### 卡牌内容
- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
- `content/characters/warrior/cards/generated/*.gd`
- `content/characters/warrior/cards/generated/*.gd.uid`
- `content/characters/warrior/cards/generated/*.tres`
- `content/effects/*.gd`
- `content/effects/*.gd.uid`

### 遗物系统
- `content/custom_resources/relics/relic_data.gd`
- `runtime/modules/relic_potion/data_driven_relic.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/relic_potion/relic_catalog.gd`
- `runtime/modules/persistence/save_service.gd`
- `content/custom_resources/relics/rage_ring.tres`
- `content/custom_resources/relics/tempering_stone.tres`
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json`

### Buff 系统
- `runtime/modules/buff_system/buff_system.gd`

### 工具
- `dev/tools/content_import_cards.py`
- `dev/tools/content_import_relics.py`

### 报告与任务文档
- `runtime/modules/content_pipeline/reports/card_import_report.json`
- `runtime/modules/content_pipeline/reports/relic_import_report.json`
- `docs/tasks/phase9-strength-axis-cards-v1/plan.md`
- `docs/tasks/phase9-strength-axis-cards-v1/handoff.md`
- `docs/tasks/phase9-strength-axis-cards-v1/verification.md`
- `docs/tasks/phase9-review-prompt.md`

## 风险评估

- 低风险：UI 改造（仅展示层）
- 中风险：新效果类（需测试覆盖）
- 中风险：遗物新字段（需确保持久化）

## 验收标准

- [ ] 遗物 Tooltip 显示名称+描述
- [ ] 卡牌显示名称+效果描述
- [ ] 10 张新卡可获取、可打出
- [ ] 2 个新遗物可获取、正确触发
- [ ] `make test` 全部通过
