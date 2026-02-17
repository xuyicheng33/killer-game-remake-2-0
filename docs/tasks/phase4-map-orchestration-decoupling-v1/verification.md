# 验证记录

## 基本信息

- 任务 ID：`phase4-map-orchestration-decoupling-v1`
- 日期：2026-02-17

## 静态检查

- [x] `rg -n "run_state\\.(enter_map_node|next_floor|set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/app/app.gd`
  - 结果：无匹配（`app.gd` 不再直接承担地图主流程写入）。
- [x] `rg -n "next_route" modules/run_flow scenes/app/app.gd`
  - 结果（节选）：
    - `scenes/app/app.gd:168: func _dispatch_next_route(command_result: Dictionary) -> void`
    - `modules/run_flow/route_dispatcher.gd:27: func make_result(next_route: String, payload: Dictionary = {}) -> Dictionary`
    - `modules/run_flow/map_flow_service.gd:46: return route_dispatcher.make_result(next_route, payload)`
  - 说明：`next_route` 契约已覆盖 app 路由执行与 run_flow 服务返回。

## 自动化检查

- [x] `make workflow-check TASK_ID=phase4-map-orchestration-decoupling-v1`
  - 结果：`[workflow-check] passed.`

## 行为等价验证（可复验步骤）

### 用例 1：地图节点进入 -> 路由分发

1. 在地图选择 BATTLE/REST/SHOP/EVENT/BOSS 任一可达节点。
2. 确认进入对应页面（战斗/营火/商店/事件）。

期望：与改造前分支路径一致。

### 用例 2：SHOP/EVENT 完成 -> B3 bonus -> 返回地图

1. 进入商店或事件节点，执行完成动作（离开/继续）。
2. 检查是否返回地图，并且日志中保留 bonus 文本（如有）。

期望：奖励触发条件与改造前一致。

### 用例 3：战斗胜负分支

1. 进入战斗并分别验证胜利与失败路径。
2. 胜利后进入奖励页并完成；失败后显示 game over。

期望：battle -> reward/map 与 game over 行为与改造前一致。
