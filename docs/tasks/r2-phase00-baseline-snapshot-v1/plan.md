# 任务计划

## 基本信息

- 任务 ID：`r2-phase00-baseline-snapshot-v1`
- 任务级别：`L0`（快车道）
- 主模块：`run_meta`
- 负责人：-
- 日期：2026-02-17

## 目标

建立 R2 的统一基线快照与进度看板，固化当前可审计状态，产出 R2 任务执行清单。

## 任务边界

1. 只做文档与状态面板，不改代码逻辑
2. 不改动已有模块实现
3. 仅维护任务三件套

## 必做项

1. 在 docs/work_logs/2026-02.md 末尾新增「R2 基线启动」章节，记录：
   - 当前代码基线 commit hash
   - 已完成的 phase1-22 架构收口摘要
   - R2 任务总表（状态、依赖、负责人列留空）
2. 创建 docs/tasks/r2-phase00-baseline-snapshot-v1/ 目录与三件套：
   - plan.md：本任务计划（复制上述内容）
   - handoff.md：执行摘要、风险、下一步
   - verification.md：验证命令与结果
3. 产出 docs/r2_baseline_status.md 基线状态文件，包含：
   - 当前可复现命令集（make workflow-check 等）
   - R2 Phase 0-12 任务总览表
   - 已知缺口与风险

## 白名单文件

- `docs/work_logs/2026-02.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/plan.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/handoff.md`
- `docs/tasks/r2-phase00-baseline-snapshot-v1/verification.md`
- `docs/r2_baseline_status.md`

## 验证命令

```bash
# 1. 检查基线 commit
git log -1 --oneline

# 2. 检查 workflow 通过
make workflow-check TASK_ID=r2-phase00-baseline-snapshot-v1

# 3. 检查三件套存在
ls -la docs/tasks/r2-phase00-baseline-snapshot-v1/

# 4. 检查基线状态文件
cat docs/r2_baseline_status.md | head -30
```

## 交付要求

1. verification.md 必须包含上述 4 条命令的真实输出
2. handoff.md 的 workflow-check 状态与实际一致
3. 建议 commit message：`docs(run_meta): R2 Phase 0 基线快照与任务总表（r2-phase00-baseline-snapshot-v1）`

## 风险与回滚

- 风险：无（仅文档任务）
- 回滚方式：回滚本任务白名单文件
