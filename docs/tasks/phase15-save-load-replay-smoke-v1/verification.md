# Verification: phase15-save-load-replay-smoke-v1

## 验证清单

### 1. 脚本存在且可执行

```bash
ls -la dev/tools/save_load_replay_smoke.sh
```

预期：文件存在且有执行权限

### 2. 冒烟脚本执行成功（必须）

```bash
bash dev/tools/save_load_replay_smoke.sh
```

预期输出：
- 所有检查项显示 `[PASS]`
- 最后一行显示 `[smoke] all checks passed.`
- 退出码为 0

### 3. workflow-check 通过（必须）

```bash
make workflow-check TASK_ID=phase15-save-load-replay-smoke-v1
```

预期输出：
- 所有契约门禁通过
- 最后一行显示 `[workflow-check] passed.`

### 4. 文档更新验证

```bash
grep -q "Phase 15" runtime/modules/seed_replay/README.md
grep -q "冒烟验证脚本" docs/module_architecture.md
grep -q "save_load_replay_smoke.sh" docs/contracts/module_boundaries_v1.md
grep -q "Phase 15" docs/work_logs/2026-02.md
```

预期：所有命令返回成功

### 5. 任务三件套完整性

```bash
ls docs/tasks/phase15-save-load-replay-smoke-v1/
```

预期：包含 `plan.md`、`handoff.md`、`verification.md`

## 强制执行项

由于冒烟脚本不默认接入 workflow-check，在 verification 阶段**必须手动执行**：

```bash
# 强制执行冒烟验证
bash dev/tools/save_load_replay_smoke.sh || exit 1
```

## 验收通过标准

1. 冒烟脚本执行成功，所有检查项通过
2. workflow-check 通过
3. 文档更新完整
4. 任务三件套齐全
5. 白名单文件检查通过（无超出白名单的改动）
