# 架构真源索引（Source of Truth）

更新时间：2026-03-04

## 1. 目的

统一回答三个问题：

1. 架构边界到底看哪份文档？
2. 模块职责冲突时以谁为准？
3. 改了代码后哪些文档必须同步？

## 2. 真源优先级（从高到低）

1. `docs/contracts/module_boundaries_v1.md`
   - 模块职责、依赖方向、禁止项、门禁脚本是唯一真源。
2. `docs/module_architecture.md`
   - 对当前代码现状做解释性展开；如与真源冲突，以 1 为准。
3. `runtime/modules/**/README.md`
   - 模块内“快速理解”入口；只做摘要，不重复维护完整契约。
4. 其他文档（roadmap、tasks、work_logs）
   - 记录过程与计划，不作为边界判定依据。

## 3. 变更同步规则（必须）

发生以下变更时，必须先改真源文档再改实现或同时改：

1. 新增跨模块依赖。
2. 调整模块职责归属。
3. 调整 run_flow 路由返回结构。
4. 调整 RunState 字段或持久化结构。

最低同步清单：

1. 更新 `docs/contracts/module_boundaries_v1.md`。
2. 若涉及运行态字段/存档，更新 `docs/contracts/run_state.md`。
3. 在对应任务 `docs/tasks/<task-id>/verification.md` 记录验证命令与结果。

## 4. 快速判定口径

当两份文档描述冲突时，按以下顺序处理：

1. 先看 `docs/contracts/module_boundaries_v1.md`。
2. 再看门禁脚本是否覆盖（`dev/tools/*contract*`、`workflow_check.sh`）。
3. 冲突文档标记为“待同步”，在当前任务内修复。
