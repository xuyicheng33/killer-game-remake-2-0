# 任务规划：content importers 扩展

## 任务 ID
`r2-phase07-content-importers-expansion-v1`

## 目标
落地 enemy/relic/event 导入器，形成批量导入链路。

## 技术方案

### 复用模式
基于 `content_import_cards.py` 已建立的模式：
1. ValidationError 数据类（字段级错误定位）
2. 命令行参数解析（--input, --report）
3. JSON 解析与结构化验证
4. 统一报告输出格式

### 导入器职责边界

#### content_import_enemies.py
- 验证 enemy 数组（id, max_health, intents 必填）
- 验证 encounters 数组（id, enemies 必填，引用敌人 ID）
- 验证 intent 结构（name, type, effects 必填）
- 验证 effect 结构（op 必填，按 op 类型验证参数）
- ID 格式验证（^[a-z][a-z0-9_]*$）
- 遭遇中敌人 ID 引用验证

#### content_import_relics.py
- 验证 relic 数组（id, title 必填）
- ID 格式验证
- effects 对象结构验证
- rarity 枚举验证

#### content_import_events.py
- 验证 event 数组（id, title, description, options 必填）
- 验证 option 结构（label, effect 必填）
- effect 枚举验证（13 种类型）
- 依赖字段验证（effect 与 value/hp/gold/cost 配对）

### 输出报告结构
```json
{
  "generated_at": "ISO8601",
  "source": "repo-relative path",
  "summary": {
    "total_items": N,
    "valid_items": N,
    "error_count": N
  },
  "outputs": [],
  "errors": [
    {
      "source_file": "path",
      "item_index": N,
      "item_id": "id",
      "field": "field.path",
      "code": "ERROR_CODE",
      "message": "human readable"
    }
  ]
}
```

### 错误代码约定
- ENEMY_MISSING_REQUIRED, ENEMY_INVALID_ID_FORMAT, ENEMY_INVALID_INTENT
- ENEMY_INVALID_EFFECT, ENEMY_DUPLICATE_ID, ENEMY_UNKNOWN_REFERENCE
- RELIC_MISSING_REQUIRED, RELIC_INVALID_ID_FORMAT, RELIC_INVALID_RARITY
- EVENT_MISSING_REQUIRED, EVENT_INVALID_OPTION, EVENT_UNKNOWN_EFFECT_TYPE

## 文件清单
1. `dev/tools/content_import_enemies.py` - 敌人导入器
2. `dev/tools/content_import_relics.py` - 遗物导入器
3. `dev/tools/content_import_events.py` - 事件导入器
4. `docs/tasks/r2-phase07-content-importers-expansion-v1/plan.md`
5. `docs/tasks/r2-phase07-content-importers-expansion-v1/handoff.md`
6. `docs/tasks/r2-phase07-content-importers-expansion-v1/verification.md`

## 白名单文件
- dev/tools/content_import_enemies.py
- dev/tools/content_import_relics.py
- dev/tools/content_import_events.py
- runtime/modules/content_pipeline/reports/
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase07-content-importers-expansion-v1/

## 风险评估
- 低风险：仅新增脚本，不修改现有代码
- Schema 版本检查：导入器应验证 schema_version 兼容性

## 验证步骤
1. 正例验证：三个导入器对各自 examples/ 下的有效数据通过
2. 反例验证：导入器对 invalid/ 目录数据报告正确错误
3. 回归验证：cards 导入器仍然正常工作
4. 门禁验证：make workflow-check 通过
