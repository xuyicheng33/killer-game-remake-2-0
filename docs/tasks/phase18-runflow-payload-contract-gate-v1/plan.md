# Plan: phase18-runflow-payload-contract-gate-v1

## 任务概述

- 任务ID：phase18-runflow-payload-contract-gate-v1
- 等级：L1
- 主模块：run_flow
- 目标：增强 run_flow 契约门禁，补齐关键 payload 字段类型/键存在性检查，防止路由返回结构被悄悄改坏

## 背景

Phase 5 新增了 `run_flow_contract_check.sh`，主要检查路由常量单点定义和关键 payload 键位。但该门禁存在不足：
- 未检查 `make_result` 函数签名是否符合契约
- 未检查各方法的 payload 字段是否完整
- 未检查所有返回是否通过 `make_result` 构造

本任务补齐这些检查，确保路由返回结构稳定。

## 设计决策

### 门禁脚本设计

`run_flow_payload_contract_check.sh` 检查以下契约：

1. **make_result 函数签名**
   - 签名：`func make_result(next_route: String, payload: Dictionary = {}) -> Dictionary:`
   - 返回包含 `next_route` 字段

2. **map_flow.enter_map_node payload**
   - 成功时包含：`accepted/node_id/node_type/reward_gold`

3. **map_flow.resolve_non_battle_completion payload**
   - 包含：`node_type/bonus_log`

4. **battle_flow.resolve_battle_completion payload**
   - 胜利时包含：`reward_gold`
   - 失败时包含：`game_over_text`

5. **battle_flow.apply_battle_reward payload**
   - 包含：`reward_log`

6. **返回构造方式**
   - 所有返回必须通过 `route_dispatcher.make_result` 构造

### 集成决策

**默认接入 workflow-check**，因为：
1. 这是 run_flow 契约的增强检查
2. 与现有 `run_flow_contract_check.sh` 互补，不重叠
3. 违反此约束会导致路由契约被破坏

## 白名单文件

- `dev/tools/run_flow_payload_contract_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase18-runflow-payload-contract-gate-v1/`

## 风险评估

- 低风险：仅新增验证脚本，不改玩法逻辑
- 回滚：删除新增脚本和文档修改即可

## 验收标准

1. 门禁脚本执行成功，输出 `[run_flow_payload_contract] all checks passed.`
2. workflow-check 包含新门禁并通过
3. 文档更新完整
4. 任务三件套齐全
