# R2 基线状态文件

更新时间：2026-02-20
基线 Commit：`f04ef84`（当前分支最新基线）

## 0. 编号口径（2026-02-20 对齐）

- 本文件中的 `Phase` 均指 **R2 工程 Phase**（`r2-phaseXX-*` 任务序列）。
- `docs/后续开发规划v1.0.md` 中的 `Phase` 均指 **产品阶段 Phase**（玩法/内容规划序列）。
- 两套编号并行维护，不做一一映射；跨文档引用时请显式写成 `R2 Phase X` 或 `产品 Phase X`。

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
| UI 壳层契约 | `dev/tools/ui_shell_contract_check.sh` | 场景层必须通过 adapter/viewmodel 访问状态 |
| RunFlow 契约 | `dev/tools/run_flow_contract_check.sh` | 路由常量与返回键位检查 |
| RunFlow Payload 契约 | `dev/tools/run_flow_payload_contract_check.sh` | 关键返回 payload 键位检查 |
| RunFlow 结果结构 | `dev/tools/run_flow_result_shape_check.sh` | 返回字典必须通过 make_result 构造 |
| RunFlow 非战斗回归 | `dev/tools/run_flow_regression_check.sh` | rest/shop/event 分支返回契约检查（阻塞） |
| 生命周期契约 | `dev/tools/run_lifecycle_contract_check.sh` | app.gd 禁止直接调用生命周期模块 |
| 存档契约 | `dev/tools/persistence_contract_check.sh` | 存档版本与状态恢复检查 |
| 种子 RNG 契约 | `dev/tools/seed_rng_contract_check.sh` | 确定性洗牌与 RNG 恢复检查 |
| 场景 RunState 写入 | `dev/tools/scene_runstate_write_check.sh` | 场景层禁止直接写入 RunState |
| 场景嵌套状态写入 | `dev/tools/scene_nested_state_write_check.sh` | 场景层禁止通过嵌套方法写入状态 |
| 白名单检查 | `dev/tools/workflow_check.sh` 内置 | 仅允许白名单文件变更 |
| 分支一致性 | `dev/tools/workflow_check.sh` 内置 | 分支名必须包含 TASK_ID |

### 冒烟验证（发布前手动执行）

```bash
# 存档/读档/复盘冒烟
bash dev/tools/save_load_replay_smoke.sh

# 分支门禁自检
bash dev/tools/workflow_branch_gate_selfcheck.sh
```

## 2. R2 工程 Phase 0-12 任务总览表

| R2 Phase | 任务 ID | 等级 | 主模块 | 目标摘要 | 状态 | 依赖 |
|---|---|---|---|---|---|---|
| 0 | `r2-phase00-baseline-snapshot-v1` | L0 | `run_meta` | 固化 R2 基线、状态面板、执行清单 | **done** | - |
| 1 | `r2-phase01-workflow-gate-hardening-v1` | L1 | `run_meta` | 补齐 workflow-check 自检与跨环境稳定性 | done | Phase 0 |
| 2 | `r2-phase02-audit-pipeline-bootstrap-v1` | L1 | `run_meta` | 建立"发布-实现-审核-提交"标准闭环脚手架 | done | Phase 1 |
| 3 | `r2-phase03-ui-shell-full-decoupling-v1` | L2 | `ui_shell` | 完成 map/rest/shop/event/reward UI 壳层迁移 | done | Phase 2 |
| 4 | `r2-phase04-run-flow-regression-gate-v1` | L1 | `run_flow` | 扩展 run_flow 分支契约回归门禁 | done | Phase 3 |
| 5 | `r2-phase05-save-load-replay-runtime-smoke-v1` | L1 | `seed_replay` | 增强运行时冒烟，补齐主链路可复现检查 | done | Phase 4 |
| 6 | `r2-phase06-content-schema-expansion-v1` | L2 | `content_pipeline` | 设计 enemy/relic/event schema 与校验规则 | done | Phase 5 |
| 7 | `r2-phase07-content-importers-expansion-v1` | L2 | `content_pipeline` | 实装 enemy/relic/event 导入脚本与报告 | done | Phase 6 |
| 8 | `r2-phase08-content-pipeline-gate-integration-v1` | L1 | `content_pipeline` | 接入 workflow 或发布前强制门禁 | done | Phase 7 |
| 9 | `r2-phase09-character2-scaffold-v1` | L2 | `run_meta` | 第二角色骨架与开局接线 | done | Phase 8 |
| 10 | `r2-phase10-enemy-pack-v1` | L2 | `enemy_intent` | 数据驱动遭遇选择 + 普通/精英敌扩容 | done | Phase 9 |
| 11 | `r2-phase11-relic-potion-event-pack-v1` | L2 | `relic_potion` | 扩展遗物/药水/事件内容池与联动 | done | R2 Phase 10 |
| 12 | `r2-phase12-art-asset-replacement-v2` | L1 | `ui_shell` | 最终资源替换轨道（最后执行） | planned | R2 Phase 11 |

### 执行顺序（R2 工程 Phase）

1. R2 Phase 0-2：工具链闭环（L0/L1 快车道）
2. R2 Phase 3-5：UI 壳层完整化 + 契约回归加固
3. R2 Phase 6-8：内容管线扩展
4. R2 Phase 9-11：内容扩容（第二角色、敌人包、遗物药水事件）
5. R2 Phase 12：视觉资源替换（最后执行）

## 2.1 近期主线进展（2026-02-20）

- 已完成并合并：`phase9-strength-axis-cards-v1`（`feat/card-phase9-strength-axis-cards-v1` -> `main`）
- `phase9-strength-axis-cards-v1` 关键结果：
  - 战士卡池扩展到 30 张（新增力量轴核心卡并走内容管线）
  - 新增遗物：战怒之戒、淬炼石
  - 新增效果能力：`strength_multiplier_damage`、`missing_hp_block` 等
  - 修复血誓打击目标、遗物字段持久化、卡牌文案重复显示等审核问题
- 验证口径：`make test` 142/142 通过

## 3. 已知缺口与风险

### 功能缺口

| 缺口 | 影响 | 计划解决 Phase |
|---|---|---|
| R2 Phase 12 视觉资源替换未开始 | 美术/字体/音频仍有占位资源 | R2 Phase 12 |
| 运行时手动回归未全量执行 | 关键链路依赖 Godot 编辑器人工复验 | 持续执行 |

### 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|---|---|---|---|
| 文档与代码进度偏移 | 中 | 状态判断失真、交接困难 | 每次任务收尾同步更新 baseline/work_log/verification |
| 手动场景验证遗漏 | 中 | 运行时行为回归未被发现 | 发布前执行 `save_load_replay_smoke` + Godot 手测清单 |
| 视觉资源替换破坏功能链路 | 低 | R2 Phase 12 返工 | 最后执行，有完整门禁保护 |

### 依赖外部输入

| 依赖 | 来源 | 缺失影响 |
|---|---|---|
| 视觉资源包（图像/音频/字体） | 外部 | R2 Phase 12 无法执行 |
| 资源映射表（旧路径 -> 新路径） | 外部 | R2 Phase 12 无法执行 |

## 4. 历史基线参考

- R2 启动前已完成的 Phase 1-22 架构收口详见 [docs/work_logs/2026-02.md](docs/work_logs/2026-02.md)
- R2 主规划详见 [docs/roadmap/r2_toolchain_first_master_plan_v1.md](docs/roadmap/r2_toolchain_first_master_plan_v1.md)
