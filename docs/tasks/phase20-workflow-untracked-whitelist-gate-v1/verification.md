# Verification: phase20-workflow-untracked-whitelist-gate-v1

## 验证清单

### 1. 正常通过检查

```bash
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
```

预期：所有门禁通过，最后一行显示 `[workflow-check] passed.`

### 2. 负例测试：白名单外新建文件必须被拦截（必须）

```bash
# 步骤 1：创建临时文件（不在白名单内）
echo "test" > runtime/test_untracked.txt

# 步骤 2：验证 workflow-check 失败
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
```

**预期输出**：
```
[workflow-check] failed: 'runtime/test_untracked.txt' is outside whitelist in docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/plan.md.
```

```bash
# 步骤 3：清理临时文件
rm runtime/test_untracked.txt

# 步骤 4：再次验证通过
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
```

**预期输出**：`[workflow-check] passed.`

### 3. 文档更新验证

```bash
grep -q "Phase 20" docs/work_logs/2026-02.md
```

预期：命令返回成功

### 4. 任务三件套完整性

```bash
ls docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/
```

预期：包含 `plan.md`、`handoff.md`、`verification.md`

### 5. git status 验证

```bash
git status --short
```

预期：只显示白名单内的文件变更

## 验收通过标准

1. workflow-check 正常通过
2. 白名单外新建文件被正确拦截
3. 删除临时文件后 workflow-check 恢复通过
4. 任务三件套齐全
5. 白名单文件检查通过（无超出白名单的改动）
