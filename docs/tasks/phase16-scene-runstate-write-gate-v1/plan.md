# Plan: phase16-scene-runstate-write-gate-v1

## 任务概述

- 任务ID：phase16-scene-runstate-write-gate-v1
- 等级：L1
- 主模块：run_meta
- 目标：新增"场景层禁止直接写 RunState"总门禁，防止后续回归把状态写入散落回 scenes

## 背景

经过 Phase 2-4 的架构收口，场景层已不再直接写入 RunState，而是通过模块层服务进行状态修改。本任务新增门禁脚本，防止后续开发过程中回归到直接写入模式。

## 设计决策

### 门禁脚本设计

`scene_runstate_write_check.sh` 检查以下禁止模式：

1. **直接赋值操作**
   - `run_state.<field> =` （不匹配 `==` 和 `!=`）

2. **复合赋值操作**
   - `run_state.<field> +=/-=/*=/\=/%=`

3. **集合修改操作**
   - `run_state.<field>.append/erase/clear/push_*/pop_*`

4. **禁止方法调用**
   - `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_`

5. **嵌套写入**
   - `run_state.player_stats.<field> =` 或复合赋值

### 允许的操作

- 只读访问（如 `run_state.gold`、`run_state.player_stats.health` 读取）
- 比较操作（如 `run_state.gold == 100`）

### 集成决策

**默认接入 workflow-check**，因为：
1. 这是"提交前必过"的架构约束
2. 与现有门禁互补，不重叠
3. 违反此约束会导致架构退化

## 白名单文件

- `dev/tools/scene_runstate_write_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase16-scene-runstate-write-gate-v1/`

## 风险评估

- 低风险：仅新增验证脚本，不改玩法逻辑
- 回滚：删除新增脚本和文档修改即可

## 验收标准

1. 门禁脚本执行成功，输出 `[scene_runstate_write] all checks passed.`
2. workflow-check 包含新门禁并通过
3. 文档更新完整
4. 任务三件套齐全
