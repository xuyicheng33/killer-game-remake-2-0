# Plan: phase20-workflow-untracked-whitelist-gate-v1

## 任务概述

- 任务ID：phase20-workflow-untracked-whitelist-gate-v1
- 等级：L1
- 主模块：dev_tools
- 目标：修复 workflow-check 白名单检查未覆盖 untracked 文件的问题，确保"白名单外新文件"也会阻断提交

## 背景

`workflow_check.sh` 当前白名单检查逻辑：
```bash
git diff --name-only --cached  # 已暂存的修改
git diff --name-only           # 未暂存的修改
```

问题：未覆盖 untracked 文件（新建但未 `git add` 的文件）。

这意味着：
- 开发者可以在白名单外创建新文件
- 如果不 `git add`，workflow-check 不会拦截
- 提交时可能意外包含不该提交的文件

## 设计决策

### 修改方案

在 `changed_files` 收集逻辑中新增：
```bash
git ls-files --others --exclude-standard  # untracked 文件
```

### 保持兼容

- 现有已跟踪文件检查逻辑不变
- untracked 文件同样走白名单匹配逻辑

## 白名单文件

- `dev/tools/workflow_check.sh`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase20-workflow-untracked-whitelist-gate-v1/`

## 风险评估

- 低风险：仅修复白名单检查漏洞，不改其他逻辑
- 回滚：还原 workflow_check.sh 修改即可

## 验收标准

1. workflow-check 正常通过（当前改动在白名单内）
2. 在白名单外创建临时文件后 workflow-check 必须失败
3. 删除临时文件后 workflow-check 必须通过
4. 任务三件套齐全
