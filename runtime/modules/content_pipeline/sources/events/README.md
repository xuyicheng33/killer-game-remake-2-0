# Event Source Files

事件内容源文件目录。

## Schema
参考：`runtime/modules/content_pipeline/schemas/event_schema.json`

## 样例文件
- `examples/baseline_events.json` - 10 个基础事件配置
- `examples/invalid/` - 反例（验证错误检测）

## 导入器
Phase 7 将实现事件导入器，将 JSON 合并到 EventCatalog。
