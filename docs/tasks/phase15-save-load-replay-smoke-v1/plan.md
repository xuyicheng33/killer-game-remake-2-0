# Plan: phase15-save-load-replay-smoke-v1

## 任务概述

- 任务ID：phase15-save-load-replay-smoke-v1
- 等级：L1
- 主模块：seed_replay
- 目标：新增可重复执行的最小冒烟验证脚本，覆盖"固定 seed 新局一致性、存档/读档随机流连续性、核心流程不崩"

## 背景

Phase 9 引入了确定性洗牌，Phase 13/14 引入了契约门禁。本任务补充冒烟验证脚本，作为发布前快速验证手段，与契约门禁互补。

## 设计决策

### 脚本设计

冒烟验证脚本 `save_load_replay_smoke.sh` 包含四个检查块：

1. **fixed-seed bootstrap check**
   - RunRng.begin_run(seed) 方法存在
   - RunRng.get_run_seed() 方法存在
   - RunRng.DEFAULT_SEED 常量存在
   - RunLifecycleService.start_new_run_with_seed(seed) 方法存在
   - RunState.seed 字段存在

2. **save/load rng continuity check**
   - RunRng.export_run_state() 方法存在
   - RunRng.restore_run_state(state) 方法存在
   - SaveService._serialize_run_state 调用 export_run_state()
   - SaveService.load_run_state 返回 rng_state 字段
   - RunLifecycleService.try_load_saved_run 调用 restore_run_state()

3. **battle->reward->map route smoke check**
   - ROUTE_MAP/BATTLE/REWARD/GAME_OVER 常量存在
   - BattleFlowService.resolve_battle_completion 方法存在
   - MapFlowService.enter_map_node 方法存在
   - RunRouteDispatcher.make_result 方法存在

4. **deterministic shuffle smoke check**
   - CardPile.shuffle_with_rng(stream_key) 方法存在
   - shuffle_with_rng 使用 RunRng.randi_range
   - PlayerHandler 战斗洗牌调用正确

### workflow-check 集成决策

**不默认接入 workflow-check**，原因：

1. 与 seed_rng_contract_check.sh、persistence_contract_check.sh 有部分重叠
2. 冒烟验证更适合在 verification 阶段或发布前手动执行
3. workflow_check.sh 应只包含"提交前必过"的契约门禁

## 白名单文件

- `dev/tools/save_load_replay_smoke.sh`
- `runtime/modules/seed_replay/README.md`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase15-save-load-replay-smoke-v1/`

## 风险评估

- 低风险：仅新增验证脚本，不改玩法逻辑
- 回滚：删除新增脚本和文档修改即可

## 验收标准

1. 冒烟脚本执行成功，输出 `[smoke] all checks passed.`
2. 文档更新完整
3. 任务三件套齐全
