# Content Pipeline Schema

Schema 设计原则与版本管理文档。

## Schema 版本策略

### 版本号规则
- **MAJOR**: 不兼容的结构变更（如重命名字段、移除字段）
- **MINOR**: 向后兼容的扩展（如添加可选字段）
- **PATCH**: 文档修正，不影响验证

### 兼容性保证
- 导入器必须支持当前 MAJOR 版本的所有 MINOR 版本
- 遇到未知字段时发出警告但不报错（向前兼容）
- 缺失必需字段时报错（向后兼容检查）

## Schema 清单

| 内容类型 | Schema 文件 | 当前版本 | 状态 |
|---------|------------|---------|------|
| Cards | `card_schema.json` | v1 | 已实现导入器 |
| Enemies | `enemy_schema.json` | v1 | 待实现导入器 (Phase 7) |
| Relics | `relic_schema.json` | v1 | 待实现导入器 (Phase 7) |
| Events | `event_schema.json` | v1 | 待实现导入器 (Phase 7) |

## 错误报告规范

统一错误模型字段：

```json
{
  "source": "string",      // 来源文件路径
  "field": "string",       // 字段路径（如 enemies[0].max_health）
  "code": "string",        // 错误代码（大写下划线格式）
  "message": "string"      // 人类可读的错误描述
}
```

### 错误代码约定

| 代码 | 含义 | 示例 |
|------|------|------|
| `MISSING_REQUIRED` | 缺少必需字段 | enemies[0].id 是必需的 |
| `INVALID_TYPE` | 类型错误 | max_health 应为整数 |
| `INVALID_VALUE` | 值无效 | weight 应在 0-1000 范围内 |
| `INVALID_FORMAT` | 格式错误 | id 应符合小写下划线格式 |
| `DUPLICATE_ID` | ID 重复 | relic id 'red_skull' 重复定义 |
| `INVALID_REFERENCE` | 引用无效 | enemy_id 'unknown' 未定义 |
| `SCHEMA_VERSION_MISMATCH` | Schema 版本不匹配 | 期望 v1，得到 v2 |
| `UNKNOWN_FIELD` | 未知字段 | 非 schema 定义的字段 |

## 导入器契约

### Phase 7 导入器将实现：
1. **Enemy Importer**: 将 enemies/*.json 转换为 EnemyStats 资源 + AI 场景
2. **Relic Importer**: 将 relics/*.json 转换为 RelicData 资源
3. **Event Importer**: 将 events/*.json 合并到 EventCatalog

### 共享功能：
- JSON Schema 验证
- 错误收集与报告生成
- 资源路径解析与检查

## 文件命名约定

- 数据文件：`{content_type}_{descriptor}.json`
- 反例文件：`{descriptor}_invalid.json`
- 报告文件：`{content_type}_import_report.json`

## 扩展指南

添加新内容类型时：
1. 创建 `{type}_schema.json`，遵循 JSON Schema Draft-07
2. 在本文档更新清单
3. 提供至少 3 个正例和 3 个反例
4. 定义错误代码前缀（如 ENEMY_、RELIC_）
