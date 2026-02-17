# Plan: phase19-runflow-result-shape-gate-v1

## 任务概述

- 任务ID：phase19-runflow-result-shape-gate-v1
- 等级：L1
- 主模块：run_flow
- 目标：新增"结果结构统一门禁"，强制 run_flow 服务返回的字典在所有出口都通过统一 helper 构造，减少手写字典导致的键漂移

## 背景

Phase 18 新增了 `run_flow_payload_contract_check.sh`，主要检查 payload 字段完整性。但该门禁未检查返回字典的构造方式：

- 可以直接 `return { "next_route": "map", ... }` 手写字典
- 键名可能拼错（如 `next_rout` 而非 `next_route`）
- 返回结构不统一，增加维护成本

本任务强制所有返回必须通过统一 helper 构造，减少键漂移。

## 设计决策

### 门禁脚本设计

`run_flow_result_shape_check.sh` 检查以下契约：

1. **route_dispatcher.make_result 存在**
   - 函数签名：`func make_result(next_route: String, payload: Dictionary = {}) -> Dictionary:`
   - 返回包含 `next_route` 字段

2. **map_flow 返回构造方式**
   - 所有 `return Dictionary` 必须通过 `route_dispatcher.make_result(...)`
   - 禁止 `return { ... }` 手写字典

3. **battle_flow 返回构造方式**
   - 所有 `return Dictionary` 必须通过 `_result(...)`
   - `_result` 内部调用 `route_dispatcher.make_result`

4. **禁止直接返回包含 next_route 的字典**
   - 禁止 `return { "next_route": ... }` 模式

### 集成决策

**默认接入 workflow-check**，因为：
1. 这是 run_flow 契约的增强检查
2. 与 Phase 18 payload 契约互补
3. 违反此约束会导致键漂移和结构不一致

## 白名单文件

- `dev/tools/run_flow_result_shape_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase19-runflow-result-shape-gate-v1/`

## 风险评估

- 低风险：仅新增验证脚本，不改玩法逻辑
- 回滚：删除新增脚本和文档修改即可

## 验收标准

1. 门禁脚本执行成功，输出 `[run_flow_result_shape] all checks passed.`
2. workflow-check 包含新门禁并通过
3. 文档更新完整
4. 任务三件套齐全
