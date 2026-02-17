# 验证报告：prompts 文件清理

## 任务 ID
`chore-prompts-cleanup-v1`

## 验证命令
```bash
ls docs/prompts/r2_task_publisher_reviewer_prompts_v1.md
```

**预期结果**: 文件不存在

## 验证命令
```bash
git status --short
```

**预期结果**: 工作区干净（或仅有其他任务文件）
