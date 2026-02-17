# 验证记录

## 基本信息

- 任务 ID：`r2-phase00-baseline-snapshot-v1`
- 日期：2026-02-17

## 验证命令与结果

### 1. 检查基线 commit

```bash
$ git log -1 --oneline
```

**输出**：
```
2b1ab22 docs(roadmap): add R2 toolchain-first plan and reviewer prompt kit（r2-phase00-baseline-snapshot-v1）
```

### 2. 检查 workflow 通过

```bash
$ make workflow-check TASK_ID=r2-phase00-baseline-snapshot-v1
```

**输出**：
```
[workflow-check] running quality gates...
[repo-structure-check] passed.
[ui_shell_contract] checking forbidden direct RunState writes under runtime/scenes/ui...
[PASS] no forbidden run_state direct writes in runtime/scenes/ui
[ui_shell_contract] checking migrated pages are wired through adapter + viewmodel...
[PASS] stats_ui uses stats adapter
[PASS] stats adapter uses stats viewmodel
[PASS] stats_ui does not directly query BuffSystem
[PASS] relic_potion_ui uses relic_potion adapter
[PASS] relic_potion adapter uses relic_potion viewmodel
[PASS] relic_potion_ui does not directly call relic_potion_system.use_potion
[PASS] battle_ui uses battle_ui adapter
[PASS] battle_ui adapter uses battle_ui viewmodel
[PASS] battle_ui does not directly import card_system/card_zones_model
[ui_shell_contract] all checks passed.
[run_flow_contract] checking route constants single-point definition...
[run_flow_contract] search backend: grep fallback (rg not found)
[PASS] ROUTE_MAP single-point definition
[PASS] ROUTE_BATTLE single-point definition
[PASS] ROUTE_REWARD single-point definition
[PASS] ROUTE_REST single-point definition
[PASS] ROUTE_SHOP single-point definition
[PASS] ROUTE_EVENT single-point definition
[PASS] ROUTE_GAME_OVER single-point definition
[PASS] route dispatcher output contains next_route key
[run_flow_contract] checking map node type -> next_route mapping...
[PASS] battle/elite/boss route group
[PASS] battle route return
[PASS] rest route branch
[PASS] rest route return
[PASS] shop route branch
[PASS] shop route return
[PASS] event route branch
[PASS] event route return
[run_flow_contract] checking map_flow payload contract...
[PASS] map_flow defines payload dictionary
[PASS] map_flow enter payload accepted
[PASS] map_flow enter payload node_id
[PASS] map_flow enter payload node_type
[PASS] map_flow enter payload reward_gold
[PASS] map_flow placeholder branch payload advanced_floor
[PASS] non-battle completion payload node_type
[PASS] non-battle completion bonus_log payload
[PASS] non-battle completion next_route map
[run_flow_contract] checking battle_flow win/lose routes...
[PASS] battle win next_route reward
[PASS] battle win payload reward_gold
[PASS] battle lose next_route game_over
[PASS] battle lose payload game_over_text
[PASS] battle reward apply payload reward_log
[PASS] battle reward apply next_route map
[run_flow_contract] all checks passed.
[run_flow_payload_contract] checking run_flow payload contracts...
[run_flow_payload_contract] 1. 检查 make_result 函数签名与返回结构...
[PASS] make_result 函数签名正确
[PASS] make_result 返回包含 next_route
[PASS] make_result 遍历 payload 字段
[PASS] make_result 合并 payload 字段
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
[PASS] battle_flow._result 函数签名正确
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
[run_lifecycle_contract] checking forbidden direct dependencies in app.gd...
[PASS] app.gd must not directly preload save_service.gd
[PASS] app.gd must not directly preload save_service.tscn
[PASS] app.gd must not directly preload run_rng.gd
[PASS] app.gd must not directly preload repro_log.gd
[PASS] app.gd must not directly instantiate SaveService
[PASS] app.gd must not directly instantiate RunRng
[PASS] app.gd must not directly instantiate ReproLog
[run_lifecycle_contract] checking lifecycle service calls through run_flow_service...
[PASS] app.gd must call start_new_run through run_flow_service.lifecycle_service
[PASS] app.gd must call try_load_saved_run through run_flow_service.lifecycle_service
[PASS] app.gd must call save_checkpoint through run_flow_service.lifecycle_service
[run_lifecycle_contract] all checks passed.
[persistence_contract] checking save version constants...
[PASS] SAVE_VERSION constant exists
[PASS] MIN_COMPAT_VERSION constant exists
[persistence_contract] checking player stats serialization...
[PASS] _serialize_player_stats includes statuses field from get_status_snapshot
[persistence_contract] checking player stats deserialization...
[PASS] _apply_player_stats calls set_status for status restoration
[PASS] _apply_player_stats has default empty dict for v1 compatibility
[persistence_contract] all checks passed.
[seed_rng_contract] checking card_pile.gd shuffle_with_rng implementation...
[PASS] card_pile.gd must have shuffle_with_rng(stream_key: String) method
[PASS] shuffle_with_rng must use RunRng.randi_range with stream_key
[seed_rng_contract] checking player_handler.gd battle shuffle calls...
[PASS] player_handler.start_battle must use shuffle_with_rng("battle_start_shuffle")
[PASS] player_handler.reshuffle_deck_from_discard must use shuffle_with_rng("reshuffle_discard")
[seed_rng_contract] checking run_lifecycle_service.gd RNG restore logic...
[PASS] run_lifecycle_service.try_load_saved_run must call restore_run_state
[PASS] run_lifecycle_service must have begin_run fallback when restore fails
[seed_rng_contract] all checks passed.
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
[scene_nested_state_write] checking forbidden nested state write patterns in runtime/scenes...
[scene_nested_state_write] 1. 检查 player_stats 写入方法调用...
[PASS] 无 run_state.player_stats 禁止的方法调用
[scene_nested_state_write] 2. 检查 map_graph 写入方法调用...
[PASS] 无 run_state.map_graph 禁止的方法调用
[scene_nested_state_write] 3. 检查 relics/potions 集合操作...
[PASS] 无 run_state.relics/potions 禁止的集合操作
[scene_nested_state_write] 4. 检查 player_stats.deck/discard 集合操作...
[PASS] 无 run_state.player_stats.deck/discard 禁止的集合操作

[scene_nested_state_write] all checks passed.
[scene_nested_state_write] 场景层未发现直接写入嵌套状态的操作。
[workflow-check] passed.
```

### 3. 检查三件套存在

```bash
$ ls -la docs/tasks/r2-phase00-baseline-snapshot-v1/
```

**输出**：
```
total 24
drwxr-xr-x   5 xuyicheng  staff   160 Feb 17 19:54 .
drwxr-xr-x  47 xuyicheng  staff  1504 Feb 17 19:42 ..
-rw-r--r--@   1 xuyicheng  staff  1662 Feb 17 19:54 handoff.md
-rw-r--r--@   1 xuyicheng  staff  2035 Feb 17 19:54 plan.md
-rw-r--r--@   1 xuyicheng  staff   707 Feb 17 19:54 verification.md
```

### 4. 检查基线状态文件

```bash
$ cat docs/r2_baseline_status.md | head -30
```

**输出**：
```
# R2 基线状态文件

更新时间：2026-02-17
基线 Commit：`2b1ab22`

## 1. 可复现命令集

### 日常开发

```bash
# 安装 Git Hooks
make install-hooks

# 生成内容索引
make content-index

# 创建新任务
make new-task TASK_ID=<task-id>

# 门禁检查（提交前必执行）
make workflow-check TASK_ID=<task-id>
```

### 门禁检查明细

`make workflow-check` 串行执行以下检查：

| 检查项 | 脚本路径 | 说明 |
|---|---|---|
| 仓库结构检查 | `dev/tools/repo_structure_check.sh` | 校验目录结构与 repo_structure.md 一致 |
```

## 结论

- 状态：**通过**
- 结论：所有验证命令执行成功，workflow-check 全部门禁通过，三件套与基线状态文件已创建。
