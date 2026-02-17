# Enemy Source Files

敌人内容源文件目录。

## Schema
参考：`runtime/modules/content_pipeline/schemas/enemy_schema.json`

## 样例文件
- `examples/act1_enemies.json` - Act 1 普通敌人配置
- `examples/encounters.json` - 遭遇组合配置
- `examples/invalid/` - 反例（验证错误检测）

## 导入器
Phase 7 将实现敌人导入器，将 JSON 转换为 EnemyStats 资源。
