# Handoff: phase19-runflow-result-shape-gate-v1

## 交付清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `dev/tools/run_flow_result_shape_check.sh` | run_flow 结果结构统一门禁脚本 |
| `docs/tasks/phase19-runflow-result-shape-gate-v1/plan.md` | 任务计划 |
| `docs/tasks/phase19-runflow-result-shape-gate-v1/handoff.md` | 本文件 |
| `docs/tasks/phase19-runflow-result-shape-gate-v1/verification.md` | 验证指南 |

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `dev/tools/workflow_check.sh` | 新增 run_flow_result_shape_check.sh 执行 |
| `docs/contracts/module_boundaries_v1.md` | 新增 Phase 19 门禁说明 |
| `docs/module_architecture.md` | 质量门禁章节补充 |
| `docs/work_logs/2026-02.md` | 新增 Phase 19 工作日志 |

## 验证命令

### 命令 1：运行门禁脚本

```bash
bash dev/tools/run_flow_result_shape_check.sh
```

**预期输出摘要**：
```
[run_flow_result_shape] checking run_flow result shape contracts...
[run_flow_result_shape] 1. 检查 route_dispatcher.make_result 存在...
[PASS] route_dispatcher.make_result 函数存在且签名正确
[run_flow_result_shape] 2. 检查 make_result 返回包含 next_route...
[PASS] make_result 返回包含 next_route
[run_flow_result_shape] 3. 检查 map_flow 所有返回通过 make_result...
[PASS] map_flow 通过 make_result 构造返回
[run_flow_result_shape] 4. 检查 battle_flow 所有返回通过 _result...
[PASS] battle_flow 通过 _result 构造返回
[run_flow_result_shape] 5. 检查 battle_flow._result 调用 make_result...
[PASS] battle_flow._result 调用 make_result
[run_flow_result_shape] 6. 禁止 map_flow 直接返回手写字典...
[PASS] map_flow 无直接返回手写字典
[run_flow_result_shape] 7. 禁止 battle_flow 直接返回手写字典...
[PASS] battle_flow 无直接返回手写字典
[run_flow_result_shape] 8. 禁止直接包含 next_route 的手写字典...
[PASS] map_flow 无直接返回 next_route 字典
[PASS] battle_flow 无直接返回 next_route 字典

[run_flow_result_shape] all checks passed.
[run_flow_result_shape] run_flow 结果结构统一，所有返回通过 helper 构造。
```

### 命令 2：运行 workflow-check

```bash
make workflow-check TASK_ID=phase19-runflow-result-shape-gate-v1
```

**预期输出摘要**：
```
[workflow-check] running quality gates...
[repo-structure-check] passed.
[ui_shell_contract] all checks passed.
[run_flow_contract] all checks passed.
[run_flow_payload_contract] all checks passed.
[run_flow_result_shape] all checks passed.
[run_lifecycle_contract] all checks passed.
[persistence_contract] all checks passed.
[seed_rng_contract] all checks passed.
[scene_runstate_write] all checks passed.
[scene_nested_state_write] all checks passed.
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
rm dev/tools/run_flow_result_shape_check.sh
rm -rf docs/tasks/phase19-runflow-result-shape-gate-v1
```

## 建议 Commit Message

```
feat(run_flow): add result shape gate to enforce unified return construction (phase19)

- Add dev/tools/run_flow_result_shape_check.sh with 8 check blocks:
  - route_dispatcher.make_result existence and signature
  - make_result returns next_route field
  - map_flow returns through route_dispatcher.make_result
  - battle_flow returns through _result helper
  - _result calls make_result internally
  - forbid direct return of hand-written dictionaries in map_flow
  - forbid direct return of hand-written dictionaries in battle_flow
  - forbid direct return with next_route key
- Integrate into workflow_check.sh as default quality gate
- Update architecture docs (module_boundaries_v1, module_architecture)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## 后续建议

1. 新增 run_flow 服务方法时，需通过 `make_result` 构造返回
2. 如需扩展返回字段，修改 `make_result` 即可统一生效
