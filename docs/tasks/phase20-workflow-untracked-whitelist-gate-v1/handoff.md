# Handoff: phase20-workflow-untracked-whitelist-gate-v1

## 交付清单

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `dev/tools/workflow_check.sh` | 白名单检查纳入 untracked 文件 |
| `docs/work_logs/2026-02.md` | 新增 Phase 20 工作日志 |

### 新增文件

| 文件 | 说明 |
|------|------|
| `docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/plan.md` | 任务计划 |
| `docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/handoff.md` | 本文件 |
| `docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/verification.md` | 验证指南 |

## 变更详情

### workflow_check.sh 修改

**修改前**（第 88-105 行）：
```bash
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  changed_files=()
  while IFS= read -r line; do
    changed_files+=("$line")
  done < <(
    {
      git -c core.quotepath=false diff --name-only --cached
      git -c core.quotepath=false diff --name-only
    } | sed '/^$/d' | sort -u
  )
else
  ...
fi
```

**修改后**：
```bash
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  changed_files=()
  while IFS= read -r line; do
    changed_files+=("$line")
  done < <(
    {
      git -c core.quotepath=false diff --name-only --cached
      git -c core.quotepath=false diff --name-only
      git -c core.quotepath=false ls-files --others --exclude-standard
    } | sed '/^$/d' | sort -u
  )
else
  ...
fi
```

## 验证命令

### 命令 1：正常通过

```bash
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
```

**预期**：所有门禁通过

### 命令 2：负例测试（白名单外新建文件）

```bash
# 创建临时文件（不在白名单内）
echo "test" > runtime/test_untracked.txt

# 验证 workflow-check 失败
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
# 预期：[workflow-check] failed: 'runtime/test_untracked.txt' is outside whitelist...

# 清理临时文件
rm runtime/test_untracked.txt

# 再次验证通过
make workflow-check TASK_ID=phase20-workflow-untracked-whitelist-gate-v1
# 预期：[workflow-check] passed.
```

## 风险与回滚

### 风险

- 低风险：仅修复白名单检查漏洞
- 无运行时影响：修改的是 CI/提交前检查脚本

### 回滚方案

```bash
git checkout HEAD -- dev/tools/workflow_check.sh
git checkout HEAD -- docs/work_logs/2026-02.md
rm -rf docs/tasks/phase20-workflow-untracked-whitelist-gate-v1
```

## 建议 Commit Message

```
fix(dev_tools): include untracked files in workflow-check whitelist (phase20)

- Add `git ls-files --others --exclude-standard` to changed_files detection
- Previously only checked staged and unstaged changes, missing untracked files
- Ensures new files outside whitelist are also caught before commit

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
