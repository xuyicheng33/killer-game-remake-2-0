# Handoff: phase16-scene-runstate-write-gate-v1

## 交付清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `dev/tools/scene_runstate_write_check.sh` | 场景层 RunState 写入门禁脚本 |
| `docs/tasks/phase16-scene-runstate-write-gate-v1/plan.md` | 任务计划 |
| `docs/tasks/phase16-scene-runstate-write-gate-v1/handoff.md` | 本文件 |
| `docs/tasks/phase16-scene-runstate-write-gate-v1/verification.md` | 验证指南 |

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `dev/tools/workflow_check.sh` | 新增 scene_runstate_write_check.sh 执行 |
| `docs/contracts/module_boundaries_v1.md` | 新增 Phase 16 门禁说明 |
| `docs/module_architecture.md` | 质量门禁章节补充 |
| `docs/work_logs/2026-02.md` | 新增 Phase 16 工作日志 |

## 验证命令

### 命令 1：运行门禁脚本

```bash
bash dev/tools/scene_runstate_write_check.sh
```

**预期输出摘要**：
```
[scene_runstate_write] checking forbidden run_state write patterns in runtime/scenes...
[scene_runstate_write] 1. 检查直接赋值操作...
[PASS] 无 run_state 直接赋值操作
[scene_runstate_write] 2. 检查复合赋值操作 (+=, -=, *=, /=, %=)...
[PASS] 无 run_state 复合赋值操作
[scene_runstate_write] 3. 检查集合修改操作 (append/erase/clear/push/pop)...
[PASS] 无 run_state 集合修改操作
[scene_runstate_write] 4. 检查禁止的方法调用 (set_/add_/remove_/clear_/advance_/mark_/apply_)...
[PASS] 无 run_state 禁止的方法调用
[scene_runstate_write] 5. 检查 player_stats 嵌套写入...
[PASS] 无 run_state.player_stats 直接赋值操作
[PASS] 无 run_state.player_stats 复合赋值操作

[scene_runstate_write] all checks passed.
[scene_runstate_write] 场景层未发现直接写入 RunState 的操作。
```

### 命令 2：运行 workflow-check

```bash
make workflow-check TASK_ID=phase16-scene-runstate-write-gate-v1
```

**预期输出摘要**：
```
[workflow-check] running quality gates...
[repo-structure-check] passed.
[ui_shell_contract] all checks passed.
[run_flow_contract] all checks passed.
[run_lifecycle_contract] all checks passed.
[persistence_contract] all checks passed.
[seed_rng_contract] all checks passed.
[scene_runstate_write] all checks passed.
[workflow-check] passed.
```

## 风险与回滚

### 风险

- 低风险：仅新增验证脚本和文档更新，不改玩法逻辑
- 无运行时影响：脚本是静态代码检查，不涉及运行时行为

### 回滚方案

如需回滚：

```bash
git checkout HEAD -- dev/tools/workflow_check.sh
git checkout HEAD -- docs/contracts/module_boundaries_v1.md
git checkout HEAD -- docs/module_architecture.md
git checkout HEAD -- docs/work_logs/2026-02.md
rm dev/tools/scene_runstate_write_check.sh
rm -rf docs/tasks/phase16-scene-runstate-write-gate-v1
```

## 建议 Commit Message

```
feat(run_meta): add scene runstate write gate to prevent direct writes (phase16)

- Add dev/tools/scene_runstate_write_check.sh with 5 check blocks:
  - Direct assignment (run_state.<field> =)
  - Compound assignment (+=, -=, *=, /=, %=)
  - Collection operations (append/erase/clear/push/pop)
  - Forbidden method calls (set_/add_/remove_/clear_/advance_/mark_/apply_)
  - Nested player_stats writes
- Integrate into workflow_check.sh as default quality gate
- Update architecture docs (module_boundaries_v1, module_architecture)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## 后续建议

1. 如发现误报（允许的写入被拦截），可在脚本中增加白名单例外
2. 可考虑扩展检查范围，覆盖 `map_graph`、`relics`、`potions` 等嵌套字段
