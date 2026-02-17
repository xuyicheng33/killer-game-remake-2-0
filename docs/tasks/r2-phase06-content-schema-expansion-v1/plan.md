# 任务规划：content schema 扩展（审批请求）

## 任务 ID
`r2-phase06-content-schema-expansion-v1`

## 等级
L2（需审批）

## 目标
定义 enemy/relic/event 的数据 schema 与错误模型，为后续导入器提供契约基础。

## 现有分析

### Cards Schema（已存在）
```json
{
  "schema_version": 1,
  "character_id": "warrior",
  "cards": [...]
}
```
卡片字段：id, name, type, rarity, cost, target, text, icon, sound, effects, tags, starter_copies

### 错误报告格式（已存在）
```json
{
  "generated_at": "...",
  "source": "...",
  "summary": {...},
  "outputs": [...],
  "errors": []
}
```

### Enemy 数据结构（从代码推导）
- EnemyStats: max_health, ai (PackedScene), art (Texture2D)
- EnemyAction: name, type (CONDITIONAL/CHANCE_BASED), weight, condition_fn, perform_action
- 需要定义：遭遇配置（敌人组合、权重）、意图规则

### Relic 数据结构（从代码推导）
- RelicData: id, title, description, on_battle_start_heal, on_card_played_gold, card_play_interval, on_player_hit_block

### Event 数据结构（从代码推导）
- EventCatalog 模板：id, title, description, options[]
- Option: label, effect, value, hp, gold, cost, count等
- Effects: none, gold, heal, gold_for_hp, add_card, add_card_for_hp, buy_card, upgrade_card, upgrade_for_hp, remove_card, heal_for_gold, max_hp, cards_for_hp

## 范围边界

### 包含
- 为 `sources/enemies|relics|events` 增加 schema 文档与样例（正例/反例）
- 统一错误报告字段（source/field/code/message）
- 更新模块契约文档，声明新增内容类型
- 新增任务三件套并通过门禁

### 不包含
- 不实现导入器逻辑（Phase 7 任务）
- 不改动现有 cards 导入器

## 计划交付物

### 1. Schema 文档
```
runtime/modules/content_pipeline/schemas/
├── enemy_schema.json        # Enemy 数据定义
├── relic_schema.json        # Relic 数据定义
├── event_schema.json        # Event 数据定义
└── README.md                # Schema 设计原则与版本管理
```

### 2. 样例数据（正例）
```
runtime/modules/content_pipeline/sources/
├── enemies/
│   ├── examples/
│   │   ├── act1_enemies.json      # 普通/精英敌人配置
│   │   └── encounters.json        # 遭遇组合配置
│   └── README.md
├── relics/
│   ├── examples/
│   │   └── common_relics.json     # 常见遗物
│   └── README.md
└── events/
    ├── examples/
    │   └── baseline_events.json   # 10个基础事件
    └── README.md
```

### 3. 样例数据（反例）
```
runtime/modules/content_pipeline/sources/
├── enemies/examples/invalid/
│   ├── missing_required_fields.json
│   ├── invalid_intent_weights.json
│   └── unknown_action_type.json
├── relics/examples/invalid/
│   ├── negative_values.json
│   └── missing_id.json
└── events/examples/invalid/
    ├── unknown_effect_type.json
    └── missing_option_label.json
```

### 4. 错误报告规范
统一错误模型：
```json
{
  "source": "enemies/act1_enemies.json",
  "field": "enemies[0].max_health",
  "code": "INVALID_TYPE",
  "message": "Expected integer, got string"
}
```

### 5. 模块契约更新
- `docs/module_architecture.md`: 声明 content_pipeline 支持的内容类型
- `docs/contracts/module_boundaries_v1.md`: 更新 content_pipeline 边界

## 白名单文件
- runtime/modules/content_pipeline/schemas/
- runtime/modules/content_pipeline/sources/enemies/
- runtime/modules/content_pipeline/sources/relics/
- runtime/modules/content_pipeline/sources/events/
- runtime/modules/content_pipeline/README.md
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase06-content-schema-expansion-v1/
- docs/module_architecture.md
- docs/contracts/module_boundaries_v1.md

## 验证计划
1. `python3 dev/tools/content_import_cards.py --input runtime/modules/content_pipeline/sources/cards/warrior_cards.json --report /tmp/cards_check.json`（确保 cards 不受影响）
2. `make workflow-check TASK_ID=r2-phase06-content-schema-expansion-v1`

## 风险
- 低：仅新增文档和样例数据，不改动业务逻辑
- 风险点：schema 设计可能与后续导入器实现不匹配（可在 Phase 7 调整）

## 提交信息格式
```
docs(content_pipeline): 定义 enemy/relic/event schema（r2-phase06-content-schema-expansion-v1）
```

---

**请回复"批准"以继续执行此 L2 任务。**
