# 任务规划：content pipeline 门禁集成

## 任务 ID
`r2-phase08-content-pipeline-gate-integration-v1`

## 等级
L1

## 目标
建立内容管线门禁策略，决定是否接入 workflow-check 或发布前强制执行。

## 现状分析

### 当前 workflow-check 耗时
运行 `make workflow-check` 包含 12 个契约检查脚本，但尚未包含内容导入器验证。

### 内容导入器耗时评估
- `content_import_cards.py`: ~0.5s
- `content_import_enemies.py`: ~0.3s
- `content_import_relics.py`: ~0.3s
- `content_import_events.py`: ~0.3s
- **总计**: ~1.4s

### 决策
内容导入器总耗时约 1.4s，可接受。建议采用双层策略：
1. **日常提交**: 执行现有 workflow-check（不含内容导入）
2. **发布前**: 执行 `content_pipeline_check.sh`（聚合所有内容导入器）

## 白名单文件
- dev/tools/content_pipeline_check.sh
- dev/tools/workflow_check.sh
- runtime/modules/content_pipeline/README.md
- runtime/modules/content_pipeline/reports/
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase08-content-pipeline-gate-integration-v1/

## 计划交付物

### 1. content_pipeline_check.sh
聚合调用所有内容导入器，输出统一报告。

### 2. README.md 更新
更新 content_pipeline 状态表和命令说明。

### 3. 门禁策略文档
双层执行策略说明。

## 验证步骤
1. `bash dev/tools/content_pipeline_check.sh` - 验证聚合脚本
2. `make workflow-check TASK_ID=r2-phase08-content-pipeline-gate-integration-v1` - 验证门禁

## 提交信息格式
```
tools(content_pipeline): 建立内容管线门禁策略（r2-phase08-content-pipeline-gate-integration-v1）
```
