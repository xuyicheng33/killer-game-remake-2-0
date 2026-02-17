# Handoff: phase18-runflow-payload-contract-gate-v1

## 交付清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `dev/tools/run_flow_payload_contract_check.sh` | run_flow payload 契约门禁脚本 |
| `docs/tasks/phase18-runflow-payload-contract-gate-v1/plan.md` | 任务计划 |
| `docs/tasks/phase18-runflow-payload-contract-gate-v1/handoff.md` | 本文件 |
| `docs/tasks/phase18-runflow-payload-contract-gate-v1/verification.md` | 验证指南 |

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `dev/tools/workflow_check.sh` | 新增 run_flow_payload_contract_check.sh 执行 |
| `docs/contracts/module_boundaries_v1.md` | 新增 Phase 18 门禁说明 |
| `docs/module_architecture.md` | 质量门禁章节补充 |
| `docs/work_logs/2026-02.md` | 新增 Phase 18 工作日志 |

## 验证命令

### 命令 1：运行门禁脚本

```bash
bash dev/tools/run_flow_payload_contract_check.sh
```

**预期输出摘要**：
```
[run_flow_payload_contract] checking run_flow payload contracts...
[run_flow_payload_contract] 1. 检查 make_result 函数签名与返回结构...
[PASS] make_result 函数签名正确
[PASS] make_result 返回包含 next_route
[run_flow_payload_contract] 2. 检查 map_flow enter_map_node payload...
[PASS] enter_map_node 返回包含 accepted
[PASS] enter_map_node 成功时包含 node_id
[PASS] enter_map_node 成功时包含 node_type
[PASS] enter_map_node 成功时包含 reward_gold
[run_flow_payload_contract] 3. 检查 map_flow resolve_non_battle_completion payload...
[PASS] resolve_non_battle_completion 返回包含 node_type
[PASS] resolve_non_battle_completion 返回包含 bonus_log
[run_flow_payload_contract] 4. 检查 battle_flow resolve_battle_completion payload...
[PASS] battle win 返回包含 reward_gold
[PASS] battle lose 返回包含 game_over_text
[run_flow_payload_contract] 5. 检查 battle_flow apply_battle_reward payload...
[PASS] reward apply 返回包含 reward_log
[run_flow_payload_contract] 6. 检查返回构造通过 make_result...
[PASS] map_flow 通过 make_result 构造返回
[PASS] battle_flow 通过 make_result 构造返回

[run_flow_payload_contract] all checks passed.
[run_flow_payload_contract] run_flow payload 契约完整。
```

### 命令 2：运行 workflow-check

```bash
make workflow-check TASK_ID=phase18-runflow-payload-contract-gate-v1
```

**预期输出摘要**：
```
[workflow-check] running quality gates...
[repo-structure-check] passed.
[ui_shell_contract] all checks passed.
[run_flow_contract] all checks passed.
[run_flow_payload_contract] all checks passed.
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
rm dev/tools/run_flow_payload_contract_check.sh
rm -rf docs/tasks/phase18-runflow-payload-contract-gate-v1
```

## 建议 Commit Message

```
feat(run_flow): add payload contract gate to protect route return structure (phase18)

- Add dev/tools/run_flow_payload_contract_check.sh with 6 check blocks:
  - make_result function signature validation
  - map_flow.enter_map_node payload fields (accepted/node_id/node_type/reward_gold)
  - map_flow.resolve_non_battle_completion payload fields (node_type/bonus_log)
  - battle_flow.resolve_battle_completion payload fields (reward_gold/game_over_text)
  - battle_flow.apply_battle_reward payload fields (reward_log)
  - return construction through make_result
- Integrate into workflow_check.sh as default quality gate
- Update architecture docs (module_boundaries_v1, module_architecture)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## 后续建议

1. 如新增路由方法，需同步更新门禁脚本
2. 如 payload 字段变更，需同步更新门禁脚本
