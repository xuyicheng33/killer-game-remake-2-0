# 验证记录

## 基本信息

- 任务 ID：`content-relics-set2-v1`
- 日期：2026-02-19

## 内容填充前置检查（简化）
- [x] design_proposal.md 已提交
- [x] 审核员确认：仅内容填充，未引入新机制

## 执行步骤与结果

1. 新增遗物资源：
   - `content/custom_resources/relics/trailblazer_emblem.tres`
   - `content/custom_resources/relics/merchant_seal.tres`
2. 数量核验：
   - `ls content/custom_resources/relics/*.tres | wc -l`
   - 结果：`8`。
3. 门禁校验：
   - `make workflow-check TASK_ID=content-relics-set2-v1`
   - 结果：通过。
4. 回归验证：
   - `make test`
   - 结果：通过（68/68）。

## 人工复验记录（Phase 3a/3b）

- [x] 战斗抽样复验（遗物触发链）
- [x] 商店抽样复验（`ON_SHOP_ENTER` 折扣）
- [x] 事件抽样复验
- [x] 完整一局到 Boss 复验
- [x] 出现概率抽样（遗物出现分布）
- [x] 审核员记录抽样日志并确认

- 人工复验日志（2026-02-19，负责人）：`trailblazer_emblem` 开局加金币/最大生命生效且读档不重复；`merchant_seal` 商店折扣生效；战斗/事件抽样链路正常；整局至 Boss 完成；遗物出现分布抽样符合预期。

## 备注

- 白名单执行依据：`docs/master_plan_v3.md` 的“Phase 3 联动执行补充（白名单例外）”。
- `ON_SHOP_ENTER`：已由 `merchant_seal.shop_discount_percent` 覆盖。
- `ON_RUN_START`：已落地 `on_run_start_gold` + `on_run_start_max_health` 字段与一次性触发保护。
- 已完成：`RelicCatalog` 已纳入新增遗物，新增内容可进入随机池。
- 机制实现任务：`docs/tasks/feat-relic-on-run-start-trigger-v1/`。

## 审核结论

- 结论：通过（人工复验完成，满足 Phase 3b 遗物扩容验收项）。

## 审核员补充复验（2026-02-19）

- 分支门禁复验分支：`feat/audit-content-relics-set2-v1`
- 命令：`make workflow-check TASK_ID=content-relics-set2-v1`
- 结果：通过（`[workflow-check] passed.`）。
