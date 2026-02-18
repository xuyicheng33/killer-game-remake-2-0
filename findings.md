# Findings & Decisions

## Requirements
- 审核项目“目前完成情况”。
- 重点评估 `docs/master_plan_v3.md` 规划是否合理。
- 输出应以问题清单为主，按严重级别排序，并提供文件证据。

## Research Findings
- `docs/master_plan_v3.md` 是 2026-02-18 新规划，当前仓库并未按该规划执行完毕（用户确认“V3 还没做”）。
- 当前代码存在与 V3 硬约束冲突项：
  - 仍有战斗域单例：`BuffSystem`、`EffectStackEngine`、`CardZonesModel`。
  - `BuffSystem` 关键钩子仍为空实现。
  - `RelicPotionSystem` 在 `_ready()` 连接信号但无 `_exit_tree()` 断连。
  - `Makefile` 无 `make test`，仓库无 `dev/tests/` 与 GUT addon。
- 当前可运行能力接近“可玩原型”，但内容规模明显低于 V3 目标：
  - 卡牌数据仅 4 张（目标 20）。
  - 敌人仅 2 普通 + 1 Boss（目标 3 普通 + 1 Boss）。
  - 遗物池 4（目标 8），药水池 3（目标 5）。
  - 地图为 6 层（目标 15 层）。
- 当前也有明显完成项：
  - run_flow 生命周期编排与 UI 适配层已建立。
  - 存档版本与 RNG 状态恢复已实现。
  - 事件模板已超过 5 条（满足 V3 最低条数）。
- 已按用户要求将 `docs/master_plan_v3.md` 扩展为“可分工执行版”：
  - 新增“15层真实路线”人话定义。
  - 新增“新设计先复核、先提案、负责人批准后编码”的强制门禁。
  - 为 Phase 0~6 增加“程序员/审核员职责 + 双角色验收门槛”。
  - 新增“Phase 派工最小指令”，可直接下发给不同 AI 角色执行。
- 基于二次审核意见完成 5 项修订：
  - 修复 Phase 5 验收与 Phase 6 主菜单任务的前后依赖冲突（Phase 5 明确不依赖主菜单）。
  - 修复任务 2-6 前置依赖：由 2-5 改为 2-4，并注明 2-5 可并行。
  - 将 1.6 门禁范围收敛到“机制设计”；纯内容填充走简化流程。
  - 给 Phase 3a 的“3敌人”验收补充“当前已达标，仅复验”说明。
  - 明确 P2 消化规则：同一 P2 不得跨两个 Phase。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 审查范围优先覆盖主计划中的“必须项” | 先判断主线可交付性，再看扩展项 |
| 采用“当前状态 vs V3目标”的差异审查 | 用户目标是评估 V3 合理性而非验收 V3 完成 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|

## Resources
-
