# 验证记录

## 基本信息

- 任务 ID：`phase5-flow-context-and-contract-tests-v1`
- 日期：2026-02-17

## 静态检查

- [x] `rg -n "pending_node_type|pending_reward_gold" scenes/app/app.gd modules/run_flow`
  - 结果（节选）：
    - `scenes/app/app.gd` 仅通过 `run_flow_service.get_pending_*` 访问上下文，不再持有字段。
    - `modules/run_flow/flow_context.gd` 成为 `pending_*` 唯一承载对象。
- [x] `rg -n "ROUTE_(MAP|BATTLE|REWARD|REST|SHOP|EVENT|GAME_OVER)" modules/run_flow`
  - 结果：路由常量仅在 `modules/run_flow/route_dispatcher.gd` 定义，`battle_flow_service.gd` 不再重复定义。

## 契约测试（可脚本化）

- [x] `bash dev/tools/run_flow_contract_check.sh`
  - 结果：`[run_flow_contract] all checks passed.`
  - 覆盖：
    - map node type -> next_route 映射（battle/elite/boss/rest/shop/event）
    - battle win/lose 路由与关键 payload（`reward_gold` / `game_over_text`）
    - non-battle completion 的 `bonus_log` 契约键

## 自动化守门

- [x] `make workflow-check TASK_ID=phase5-flow-context-and-contract-tests-v1`
  - 结果：`[workflow-check] passed.`

## 行为等价核对（Phase 4 对齐）

### 用例 1：地图节点进入 -> 路由分发

1. 选择可达 BATTLE/REST/SHOP/EVENT/BOSS 节点。
2. 观察进入对应页面。

期望：分支目标与 Phase 4 等价。

### 用例 2：战斗胜负路由

1. 胜利后进入奖励页。
2. 失败后显示 game over。

期望：`battle -> reward` 与 `battle -> game_over` 行为等价。

### 用例 3：non-battle completion 的 bonus_log

1. 进入 SHOP/EVENT 并完成节点。
2. 检查返回 map 且日志含 `bonus_log`（REST 为空）。

期望：与 Phase 4 触发语义一致。
