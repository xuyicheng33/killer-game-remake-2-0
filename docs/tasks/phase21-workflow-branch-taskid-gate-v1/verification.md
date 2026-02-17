# Verification: phase21-workflow-branch-taskid-gate-v1

## 验证清单

### 1. 正例：当前分支包含 TASK_ID（必须）

```bash
make workflow-check TASK_ID=phase21-workflow-branch-taskid-gate-v1
```

**预期输出**：所有门禁通过，最后一行显示 `[workflow-check] passed.`

### 2. 负例：TASK_ID 不在分支名中（必须）

```bash
# 使用一个不在当前分支名中的 TASK_ID
make workflow-check TASK_ID=wrong-task-id-xxx 2>&1 || true
```

**预期输出**：
```
[workflow-check] failed: branch 'feat/dev_tools-phase21-workflow-branch-taskid-gate-v1' does not contain TASK_ID 'wrong-task-id-xxx'.
```

### 3. 特例：main 分支跳过检查

如果在 main 分支上执行：
```bash
git checkout main
make workflow-check TASK_ID=any-task-id
```

**预期**：跳过 TASK_ID 一致性检查（但需要其他条件满足）

### 4. git status 验证

```bash
git status --short
```

预期：只显示白名单内的文件变更

### 5. 任务三件套完整性

```bash
ls docs/tasks/phase21-workflow-branch-taskid-gate-v1/
```

预期：包含 `plan.md`、`handoff.md`、`verification.md`

## 验收通过标准

1. 正例测试通过：当前分支包含 TASK_ID 时 workflow-check 成功
2. 负例测试通过：TASK_ID 不在分支名中时 workflow-check 失败
3. 文档更新完整
4. 任务三件套齐全
5. 白名单文件检查通过（无超出白名单的改动）

## 本次实测结果摘要（2026-02-17）

1. `make workflow-check TASK_ID=phase21-workflow-branch-taskid-gate-v1`：通过。
2. `make workflow-check TASK_ID=wrong-task-id-xxx`：按预期失败，提示分支不包含 TASK_ID。
