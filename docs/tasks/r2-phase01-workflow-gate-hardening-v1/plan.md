# 任务计划

## 基本信息

- 任务 ID：`r2-phase01-workflow-gate-hardening-v1`
- 任务级别：`L1`
- 主模块：`run_meta`
- 负责人：-
- 日期：2026-02-17

## 目标

增强 workflow-check 的"稳定性 + 自检能力"，降低环境差异误报。

## 任务边界

1. 只做 dev/tools/ 脚本增强，不改业务逻辑
2. 降级策略：rg -> grep 兼容性处理
3. 新增自检脚本验证门禁逻辑

## 必做项

1. 检查 dev/tools/*workflow*.sh 中 rg 依赖，统一添加 grep 降级
2. 新建 dev/tools/workflow_gate_selfcheck.sh，覆盖：
   - 分支名格式检查
   - TASK_ID 对齐检查
   - 白名单阻断场景
3. 更新 docs/work_logs/2026-02.md 记录改动

## 白名单文件

- `dev/tools/workflow_check.sh`
- `dev/tools/ui_shell_contract_check.sh`
- `dev/tools/run_flow_contract_check.sh`
- `dev/tools/workflow_gate_selfcheck.sh`（新建）
- `docs/work_logs/2026-02.md`
- `docs/tasks/r2-phase01-workflow-gate-hardening-v1/plan.md`
- `docs/tasks/r2-phase01-workflow-gate-hardening-v1/handoff.md`
- `docs/tasks/r2-phase01-workflow-gate-hardening-v1/verification.md`

## 验证命令

```bash
# 1. 检查 rg/grep 降级可用
bash dev/tools/workflow_gate_selfcheck.sh

# 2. 全量 workflow 通过
make workflow-check TASK_ID=r2-phase01-workflow-gate-hardening-v1

# 3. 在纯净环境（无 rg）测试降级
which rg || echo "rg not found, using grep fallback"
```

## 禁止项

- 不改动业务代码
- 不删除现有 rg 调用，只添加降级分支

## 风险与回滚

- 风险：脚本误报导致提交流程中断
- 回滚方式：回滚本任务白名单文件
