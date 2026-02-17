# 任务交接：content schema 扩展

## 任务 ID
`r2-phase06-content-schema-expansion-v1`

## 完成状态
已完成（已审批）

## 改动文件

### 新增文件

#### Schema 文档
- `runtime/modules/content_pipeline/schemas/enemy_schema.json` - 敌人数据 schema
- `runtime/modules/content_pipeline/schemas/relic_schema.json` - 遗物数据 schema
- `runtime/modules/content_pipeline/schemas/event_schema.json` - 事件数据 schema
- `runtime/modules/content_pipeline/schemas/README.md` - Schema 设计原则与版本管理

#### 正例样例
- `runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json` - Act 1 敌人配置
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json` - 常见遗物配置
- `runtime/modules/content_pipeline/sources/events/examples/baseline_events.json` - 10 个基础事件

#### 反例样例（验证错误检测）
- `runtime/modules/content_pipeline/sources/enemies/examples/invalid/missing_required_fields.json`
- `runtime/modules/content_pipeline/sources/enemies/examples/invalid/missing_intent_weight.json`
- `runtime/modules/content_pipeline/sources/enemies/examples/invalid/invalid_id_format.json`
- `runtime/modules/content_pipeline/sources/relics/examples/invalid/negative_values.json`
- `runtime/modules/content_pipeline/sources/relics/examples/invalid/missing_id.json`
- `runtime/modules/content_pipeline/sources/events/examples/invalid/unknown_effect_type.json`
- `runtime/modules/content_pipeline/sources/events/examples/invalid/missing_option_label.json`

#### README 更新
- `runtime/modules/content_pipeline/sources/enemies/README.md`
- `runtime/modules/content_pipeline/sources/relics/README.md`
- `runtime/modules/content_pipeline/sources/events/README.md`

### 修改文件
- `runtime/modules/content_pipeline/README.md` - 更新内容类型状态
- `docs/module_architecture.md` - 更新 content_pipeline 条目

## Schema 设计概览

### Enemy Schema
- 支持单个敌人定义（id, name, max_health, art_path, ai_scene_path, intents, tags）
- 支持遭遇组合定义（encounters: id, enemies, weight, floor_range, tags）
- 意图系统：conditional（条件型）和 chance_based（权重型）
- 效果定义：damage, block, apply_status, heal

### Relic Schema
- 基础字段：id, title, description, art_path, rarity, starter
- 效果字段：on_battle_start_heal, on_card_played_gold, card_play_interval, on_player_hit_block
- 标签：starter, obtainable, special

### Event Schema
- 基础字段：id, title, description, art_path, options
- 选项字段：label, effect, value/hp/gold/cost/heal/count
- 支持 13 种效果类型：gold, heal, gold_for_hp, add_card, add_card_for_hp, buy_card, upgrade_card, upgrade_for_hp, remove_card, heal_for_gold, max_hp, cards_for_hp, none
- 扩展字段：requires_relic, excludes_relics

## 错误报告规范

统一错误模型字段：
- `source`: 来源文件路径
- `field`: 字段路径（如 enemies[0].max_health）
- `code`: 错误代码（MISSING_REQUIRED, INVALID_TYPE, INVALID_VALUE, INVALID_FORMAT, DUPLICATE_ID, INVALID_REFERENCE, SCHEMA_VERSION_MISMATCH, UNKNOWN_FIELD）
- `message`: 人类可读的错误描述

## 为 Phase 7 导入器奠定的契约基础

1. **Schema 版本策略**: 已定义 MAJOR/MINOR/PATCH 规则
2. **验证规则**: JSON Schema Draft-07 格式，可直接用于验证库
3. **错误代码**: 统一前缀约定（ENEMY_, RELIC_, EVENT_）
4. **正例/反例**: 提供测试数据，可用于导入器单元测试
5. **数据映射**: Schema 字段与现有 Godot 资源类（EnemyStats, RelicData）对齐

## 提交信息

```
docs(content_pipeline): 定义 enemy/relic/event schema（r2-phase06-content-schema-expansion-v1）
```
