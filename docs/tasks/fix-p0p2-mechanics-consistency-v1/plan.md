# 任务计划：fix-p0p2-mechanics-consistency-v1

## 基本信息

- 任务 ID：`fix-p0p2-mechanics-consistency-v1`
- 任务级别：`L2`
- 主模块：`run_meta`
- 负责人：`Codex`
- 日期：`2026-02-21`

## 目标

修复当前 P0/P2 机制一致性问题：继续游戏角色模板一致性、伤害药水战斗外消耗一致性、遗物重复 ID 串态风险、遗物 `draw_cards` 语义与实现不一致。

## 范围边界

- 包含：
  - 存档读档角色模板恢复逻辑修复
  - 伤害药水在无敌人场景下不消耗
  - 遗物重复 ID 添加约束与读档去重
  - `draw_cards` 改为战斗上下文下真实抽到手牌
  - 对应单元测试补充与回归测试调整
  - 任务文档与工作日志更新
- 不包含：
  - 新增玩法内容（新卡/新敌人/新遗物）
  - UI 视觉改版
  - 存档版本升级

## 改动白名单文件

- `runtime/modules/persistence/save_service.gd`
- `runtime/modules/run_flow/run_lifecycle_service.gd`
- `runtime/scenes/app/app.gd`
- `runtime/modules/run_meta/run_state.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `dev/tests/unit/test_save_service.gd`
- `dev/tests/unit/test_relic_potion.gd`
- `docs/tasks/fix-p0p2-mechanics-consistency-v1/plan.md`
- `docs/tasks/fix-p0p2-mechanics-consistency-v1/handoff.md`
- `docs/tasks/fix-p0p2-mechanics-consistency-v1/verification.md`
- `docs/work_logs/2026-02.md`

## 实施步骤

1. 调整读档入口与 SaveService 模板解析策略，优先按存档 `character_id` 选择模板，避免“选中角色”和“存档角色”错配。
2. 调整 RelicPotionSystem 的伤害药水消耗策略与 `draw_cards` 落点语义。
3. 在 RunState 与 SaveService 增加遗物重复 ID 防护（新增拒绝 + 读档去重）。
4. 补充/更新测试，覆盖上述 4 类问题；执行 `make test` 与 `make workflow-check TASK_ID=fix-p0p2-mechanics-consistency-v1`。
5. 更新任务交接、验证记录和工作日志。

## 验证方案

1. `make test`
2. `make workflow-check TASK_ID=fix-p0p2-mechanics-consistency-v1`
3. `bash dev/tools/save_load_replay_smoke.sh`

## 风险与回滚

- 风险：
  - `draw_cards` 语义修复涉及战斗上下文定位，若定位失败可能导致效果不触发。
  - 遗物 ID 去重会改变“历史重复ID存档”的恢复结果（从共享/重复触发变为去重）。
- 回滚方式：
  - 按提交执行 `git revert <commit>`。
