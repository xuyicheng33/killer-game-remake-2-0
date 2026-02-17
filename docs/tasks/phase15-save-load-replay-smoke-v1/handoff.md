# Handoff: phase15-save-load-replay-smoke-v1

## 交付清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `dev/tools/save_load_replay_smoke.sh` | 冒烟验证脚本 |
| `docs/tasks/phase15-save-load-replay-smoke-v1/plan.md` | 任务计划 |
| `docs/tasks/phase15-save-load-replay-smoke-v1/handoff.md` | 本文件 |
| `docs/tasks/phase15-save-load-replay-smoke-v1/verification.md` | 验证指南 |

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `runtime/modules/seed_replay/README.md` | 新增 Phase 15 冒烟验证章节 |
| `docs/module_architecture.md` | 新增 Section 8 冒烟验证脚本章节 |
| `docs/contracts/module_boundaries_v1.md` | seed_replay 模块新增冒烟验证说明 |
| `docs/work_logs/2026-02.md` | 新增 Phase 15 工作日志 |

## 验证命令

### 命令 1：运行冒烟脚本

```bash
bash dev/tools/save_load_replay_smoke.sh
```

**预期输出摘要**：
```
[smoke] 1. fixed-seed bootstrap check
[PASS] RunRng.begin_run(seed) 方法存在
...
[smoke] 2. save/load rng continuity check
[PASS] RunRng.export_run_state() 方法存在
...
[smoke] 3. battle->reward->map route smoke check
[PASS] ROUTE_MAP 常量存在
...
[smoke] 4. deterministic shuffle smoke check
[PASS] CardPile.shuffle_with_rng(stream_key) 方法存在
...
[smoke] all checks passed.
```

### 命令 2：运行 workflow-check

```bash
make workflow-check TASK_ID=phase15-save-load-replay-smoke-v1
```

**预期输出摘要**：
```
[workflow-check] running quality gates...
[ui_shell_contract] ...
[run_flow_contract] ...
[run_lifecycle_contract] ...
[persistence_contract] ...
[seed_rng_contract] ...
[workflow-check] passed.
```

## 风险与回滚

### 风险

- 低风险：仅新增验证脚本和文档更新，不改玩法逻辑
- 无运行时影响：脚本是静态代码检查，不涉及运行时行为

### 回滚方案

如需回滚：

```bash
git checkout HEAD -- dev/tools/save_load_replay_smoke.sh
git checkout HEAD -- runtime/modules/seed_replay/README.md
git checkout HEAD -- docs/module_architecture.md
git checkout HEAD -- docs/contracts/module_boundaries_v1.md
git checkout HEAD -- docs/work_logs/2026-02.md
rm -rf docs/tasks/phase15-save-load-replay-smoke-v1
```

## 建议 Commit Message

```
feat(seed_replay): add smoke test script for save/load/replay validation (phase15)

- Add dev/tools/save_load_replay_smoke.sh with 4 check blocks:
  - fixed-seed bootstrap check
  - save/load rng continuity check
  - battle->reward->map route smoke check
  - deterministic shuffle smoke check
- Not integrated into workflow-check by default (documented reason)
- Update seed_replay README and architecture docs

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## 后续建议

1. 在每次发布前手动执行冒烟验证
2. 如需更全面的运行时测试，可考虑集成 GUT (Godot Unit Test) 框架
3. 未来可扩展冒烟脚本，增加更多核心流程验证项
