# Plan: phase17-scene-nested-state-write-gate-v1

## 任务概述

- 任务ID：phase17-scene-nested-state-write-gate-v1
- 等级：L1
- 主模块：run_meta
- 目标：在 phase16 基础上补"嵌套状态写入门禁"，防止通过 `run_state.player_stats.*`、`run_state.map_graph.*`、`run_state.relics/potions.*` 的方法调用绕过门禁

## 背景

Phase 16 新增了 `scene_runstate_write_check.sh` 门禁，禁止场景层直接写入 `run_state` 字段。但该门禁存在漏洞：
- 可以通过 `run_state.player_stats.heal()`、`run_state.player_stats.take_damage()` 等方法绕过
- 可以通过 `run_state.relics.append()`、`run_state.potions.erase()` 等集合操作绕过
- 可以通过 `run_state.map_graph.*` 方法绕过

本任务补齐这些漏洞，确保所有状态写入必须通过模块层公开接口。

## 设计决策

### 门禁脚本设计

`scene_nested_state_write_check.sh` 检查以下禁止模式：

1. **player_stats 方法调用**
   - `run_state.player_stats.(set_|add_|remove_|clear_|apply_|heal|take_damage|gain_block|set_status)\w*\(`

2. **map_graph 方法调用**
   - `run_state.map_graph.(set_|add_|remove_|clear_|advance_)\w*\(`

3. **relics/potions 集合操作**
   - `run_state.(relics|potions|deck|discard|exhausted|consumables).(append|erase|clear|push_|pop_|insert|remove)\(`

4. **player_stats.deck/discard 集合操作**
   - `run_state.player_stats.(deck|discard|draw_pile|exhausted|consumables).(append|erase|clear|push_|pop_|insert|remove)\(`

### 允许的操作

- 只读访问（如 `run_state.player_stats.health` 读取）
- 只读方法调用（如 `run_state.player_stats.get_status()`）

### 集成决策

**默认接入 workflow-check**，因为：
1. 这是 Phase 16 门禁的补充，防止绕过
2. 与现有门禁互补，不重叠
3. 违反此约束会导致架构退化

## 白名单文件

- `dev/tools/scene_nested_state_write_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase17-scene-nested-state-write-gate-v1/`

## 风险评估

- 低风险：仅新增验证脚本，不改玩法逻辑
- 回滚：删除新增脚本和文档修改即可

## 验收标准

1. 门禁脚本执行成功，输出 `[scene_nested_state_write] all checks passed.`
2. workflow-check 包含新门禁并通过
3. 文档更新完整
4. 任务三件套齐全
