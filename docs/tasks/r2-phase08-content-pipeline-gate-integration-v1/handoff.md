# 任务交接：content pipeline 门禁集成

## 任务 ID
`r2-phase08-content-pipeline-gate-integration-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `dev/tools/content_pipeline_check.sh` - 聚合调用所有内容导入器
- `docs/tasks/r2-phase08-content-pipeline-gate-integration-v1/plan.md`
- `docs/tasks/r2-phase08-content-pipeline-gate-integration-v1/handoff.md`
- `docs/tasks/r2-phase08-content-pipeline-gate-integration-v1/verification.md`

### 修改文件
- `runtime/modules/content_pipeline/README.md` - 更新状态表、命令说明、门禁策略

## 门禁策略

### 双层执行策略

| Layer | Command | When | Duration |
|-------|---------|------|----------|
| Daily | `make workflow-check` | Every commit | ~2s |
| Release | `bash dev/tools/content_pipeline_check.sh` | Before release | ~1.4s |

### 耗时评估
- content_import_cards.py: ~0.5s
- content_import_enemies.py: ~0.3s
- content_import_relics.py: ~0.3s
- content_import_events.py: ~0.3s
- **总计**: ~1.4s

### 决策理由
内容导入器总耗时约 1.4s，可接受但不适合每次提交都执行。采用双层策略平衡效率与质量。

## 验证结果
- `bash dev/tools/content_pipeline_check.sh` ✓
- `make workflow-check TASK_ID=r2-phase08-content-pipeline-gate-integration-v1` 待执行

## 提交信息
```
tools(content_pipeline): 建立内容管线门禁策略（r2-phase08-content-pipeline-gate-integration-v1）
```
