# 验证记录

## 任务 ID
`feat-card-exhaust-upgrade-on-consume-v1`

## 设计前置检查
- [x] design_review.md 已提交
- [x] design_proposal.md 已提交
- [x] 负责人批准语句已记录（原文粘贴）
- [x] 审核员确认可编码

## 负责人批准语句

`以上是审核员的意见，请你先了解这个项目当前状态，并接手 docs/master_plan_v3.md 的 Phase3程序员工作。`

## 执行步骤与结果

1. `Card` 增加 `upgrade_to` 字段与 `create_exhaust_upgrade_copy()`。
2. `CardZonesModel` 在消耗流程中执行“原卡进消耗堆 + 升级副本进弃牌堆”。
3. `content_import_cards.py` 生成 `.tres` 时落地 `upgrade_to`。
4. `SaveService` 增加 `upgrade_to` 序列化/反序列化。
5. 新增测试：
   - `test_exhaust_card_with_upgrade_to_creates_upgraded_copy`
   - `test_exhaust_card_without_upgrade_to_only_moves_to_exhaust`
   - `test_serialize_card_round_trip_preserves_upgrade_to`

## 自动化验证

1. `python3 dev/tools/content_import_cards.py --input runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
   - 结果：通过（`cards: 20`）。
2. `make test`
   - 结果：通过（70/70）。
3. `make workflow-check TASK_ID=feat-card-exhaust-upgrade-on-consume-v1`
   - 执行分支：`feat/card-feat-card-exhaust-upgrade-on-consume-v1`
   - 结果：通过（`[workflow-check] passed.`）。

## 审核员复验结论

- 结论：通过（2026-02-19，阻断项已关闭，可提交）。
