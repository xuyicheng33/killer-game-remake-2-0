# 任务交接：content importers 扩展

## 任务 ID
`r2-phase07-content-importers-expansion-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `dev/tools/content_import_enemies.py` - 敌人数据导入器
- `dev/tools/content_import_relics.py` - 遗物数据导入器
- `dev/tools/content_import_events.py` - 事件数据导入器
- `docs/tasks/r2-phase07-content-importers-expansion-v1/plan.md`
- `docs/tasks/r2-phase07-content-importers-expansion-v1/handoff.md`
- `docs/tasks/r2-phase07-content-importers-expansion-v1/verification.md`

### 未修改文件
- `dev/tools/content_import_cards.py` - 无改动（回归验证通过）
- `runtime/modules/content_pipeline/schemas/*.json` - 无改动（复用 Phase 6 定义）

## 导入器设计

### 统一模式
三个导入器遵循 `content_import_cards.py` 已建立的模式：
1. ValidationError 数据类（字段级错误定位）
2. 命令行参数解析（--input, --report）
3. JSON 解析与结构化验证
4. 统一报告输出格式

### 敌人导入器
- 验证 enemy 数组（id, max_health, intents 必填）
- 验证 encounters 数组（id, enemies 必填，引用敌人 ID）
- 验证 intent 结构（name, type, effects 必填）
- 验证 effect 结构（op 必填，按 op 类型验证参数）
- ID 格式验证（^[a-z][a-z0-9_]*$）
- 遭遇中敌人 ID 引用验证

### 遗物导入器
- 验证 relic 数组（id, title 必填）
- ID 格式验证
- effects 对象结构验证
- rarity 枚举验证

### 事件导入器
- 验证 event 数组（id, title, description, options 必填）
- 验证 option 结构（label, effect 必填）
- effect 枚举验证（13 种类型）
- 依赖字段验证（effect 与 value/hp/gold/cost 配对）

## 错误代码

### 敌人
- ENEMY_MISSING_REQUIRED, ENEMY_INVALID_ID_FORMAT, ENEMY_INVALID_INTENT
- ENEMY_INVALID_EFFECT, ENEMY_DUPLICATE_ID, ENEMY_UNKNOWN_REFERENCE
- ENEMY_INVALID_TYPE, ENEMY_INVALID_VALUE

### 遗物
- RELIC_MISSING_REQUIRED, RELIC_INVALID_ID_FORMAT, RELIC_INVALID_RARITY
- RELIC_DUPLICATE_ID, RELIC_INVALID_TYPE, RELIC_INVALID_VALUE, RELIC_INVALID_EFFECT

### 事件
- EVENT_MISSING_REQUIRED, EVENT_INVALID_ID_FORMAT, EVENT_INVALID_OPTION
- EVENT_UNKNOWN_EFFECT_TYPE, EVENT_DUPLICATE_ID, EVENT_INVALID_TYPE, EVENT_INVALID_VALUE

## 验证结果

### 正例验证
- `python3 dev/tools/content_import_enemies.py --input runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json --report /tmp/enemies_check.json` ✓
- `python3 dev/tools/content_import_relics.py --input runtime/modules/content_pipeline/sources/relics/examples/common_relics.json --report /tmp/relics_check.json` ✓
- `python3 dev/tools/content_import_events.py --input runtime/modules/content_pipeline/sources/events/examples/baseline_events.json --report /tmp/events_check.json` ✓

### 反例验证
- missing_required_fields.json → ENEMY_MISSING_REQUIRED ✓
- missing_intent_weight.json → ENEMY_INVALID_INTENT ✓
- missing_id.json → RELIC_MISSING_REQUIRED ✓
- unknown_effect_type.json → EVENT_UNKNOWN_EFFECT_TYPE ✓

### 回归验证
- `python3 dev/tools/content_import_cards.py` ✓

## 提交信息

```
feat(content_pipeline): 实现 enemy/relic/event 导入器（r2-phase07-content-importers-expansion-v1）
```
