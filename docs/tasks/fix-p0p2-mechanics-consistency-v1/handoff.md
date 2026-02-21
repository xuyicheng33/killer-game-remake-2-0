# Handoff：fix-p0p2-mechanics-consistency-v1

## 基本信息

- 任务 ID：`fix-p0p2-mechanics-consistency-v1`
- 主模块：`run_meta`
- 提交人：`Codex`
- 日期：`2026-02-21`

## 改动摘要

1. 修复继续游戏读档模板错配：读档时优先按存档 `character_id` 解析角色模板，不再依赖当前选中角色。
2. 修复伤害药水战斗外误消耗：无敌人目标时给出提示并保留药水。
3. 修复遗物重复 ID 风险：运行态新增重复 ID 拒绝、读档阶段新增重复 ID 去重。
4. 修复遗物 `draw_cards` 语义：改为通过 `BattleContext.draw_cards()` 抽到手牌，不再写入弃牌堆。
5. 补充并调整单元测试，覆盖上述机制回归点。

## 变更文件

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

## 验证结果

- [x] 用例 1：`make test`（147/147）
- [x] 用例 2：`make workflow-check TASK_ID=fix-p0p2-mechanics-consistency-v1`
- [x] 用例 3：`bash dev/tools/save_load_replay_smoke.sh`（9 组检查全部通过）

## 风险与影响范围

- 影响范围：
  - 继续游戏路径（`app -> run_lifecycle -> save_service`）
  - 遗物/药水结算路径（`relic_potion_system`）
  - 遗物获取/读档恢复路径（`run_state` + `save_service`）
- 已知风险：
  - `draw_cards` 现在依赖战斗上下文；若上下文缺失，会跳过效果并输出 warning（不再 silently 写入弃牌堆）。

## 建议提交信息

- `fix(run_meta): 修复P0/P2机制一致性问题（fix-p0p2-mechanics-consistency-v1）`
