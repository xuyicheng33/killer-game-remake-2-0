# Plan: R2 Phase 2 - Audit Pipeline Bootstrap

## 任务元信息

| 字段 | 值 |
|---|---|
| 任务 ID | `r2-phase02-audit-pipeline-bootstrap-v1` |
| 任务等级 | L1 |
| 主模块 | `run_meta` |

## 目标

把"发布者 + 审核员"流程固化成可复用模板，统一任务派发、审核、提交流程。

## 设计决策

### 1. 模板文件位置

- 审核员输出模板：`docs/templates/auditor_output_template.md`
- 程序员任务卡模板：`docs/templates/programmer_task_template.md`

### 2. 模板结构设计

#### 审核员输出模板

包含以下固定节：
1. 审核结论（通过/不通过）
2. Findings（按严重度分级）
3. 验证结果（命令与结论表格）
4. 提交信息（commit hash + message）
5. 风险与未覆盖验证点
6. 下一任务提示词

#### 程序员任务卡模板

包含以下固定节：
1. 任务元信息（ID/等级/主模块）
2. 目标
3. 边界定义
4. 必做项
5. 白名单文件
6. 任务三件套说明
7. 验证命令
8. 禁止项
9. 交付要求

### 3. 自动推进规则增强

在 `r2_task_publisher_reviewer_prompts_v1.md`（后续已删除）中新增：
- 查找下一任务规则
- 自动填充字段规则
- 禁止项附加规则
- 模板引用规则
- 自动推进流程图
- 示例输出格式

## 白名单文件

- `docs/templates/auditor_output_template.md`
- `docs/templates/programmer_task_template.md`
- `r2_task_publisher_reviewer_prompts_v1.md`（后续在 `chore-prompts-cleanup-v1` 删除）
- `docs/work_logs/2026-02.md`
- `docs/tasks/r2-phase02-audit-pipeline-bootstrap-v1/plan.md`
- `docs/tasks/r2-phase02-audit-pipeline-bootstrap-v1/handoff.md`
- `docs/tasks/r2-phase02-audit-pipeline-bootstrap-v1/verification.md`

## 实现步骤

1. 创建 `docs/templates/` 目录
2. 创建 `auditor_output_template.md`
3. 创建 `programmer_task_template.md`
4. 更新 `r2_task_publisher_reviewer_prompts_v1.md`（后续已删除）
5. 更新 `docs/work_logs/2026-02.md`
6. 创建任务三件套

## 风险评估

| 风险 | 等级 | 缓解措施 |
|---|---|---|
| 模板格式不统一 | Low | 参考现有文档风格 |
| 自动推进规则遗漏场景 | Medium | 添加详细规则与示例 |

## 依赖

- R2 Phase 1：workflow-gate-hardening（已完成）
