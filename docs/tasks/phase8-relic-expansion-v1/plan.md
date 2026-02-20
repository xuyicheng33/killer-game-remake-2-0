# Plan: phase8-relic-expansion-v1

## 基本信息

- 任务 ID：`phase8-relic-expansion-v1`
- 任务级别：`L1`
- 主模块：`relic_potion`
- 负责人：AI 协作代理
- 日期：2026-02-20

## 目标

完成 Phase 8 遗物扩展：修复 Tooltip、清理 BuffSystem fallback、补齐新遗物字段与触发链路，并交付可回归验证结果。

## 范围边界

- 包含：遗物触发/效果扩展、遗物数据字段与持久化、6 个新遗物定义、Phase 8 测试补充。
- 不包含：跨战斗遗物持久化机制（延后到 Phase 11）、战斗主循环重构、非遗物模块重构。

## 改动白名单文件

- `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`
- `runtime/modules/buff_system/buff_system.gd`
- `content/custom_resources/relics/relic_data.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `runtime/modules/relic_potion/relic_base.gd`
- `runtime/modules/relic_potion/data_driven_relic.gd`
- `runtime/modules/relic_potion/relic_catalog.gd`
- `runtime/modules/persistence/save_service.gd`
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json`
- `content/custom_resources/relics/iron_wall.tres`
- `content/custom_resources/relics/greedy_amulet.tres`
- `content/custom_resources/relics/martyr_heart.tres`
- `content/custom_resources/relics/energy_crystal.tres`
- `content/custom_resources/relics/soul_catcher.tres`
- `content/custom_resources/relics/life_drain.tres`
- `dev/tests/unit/test_relic_potion.gd`
- `docs/tasks/phase8-relic-expansion-v1/plan.md`
- `docs/tasks/phase8-relic-expansion-v1/handoff.md`
- `docs/tasks/phase8-relic-expansion-v1/verification.md`
- `docs/tasks/phase8-relic-expansion-v1/audit_prompt.md`

## 实施步骤

1. 修复遗物/药水 Tooltip 文本格式并验证 UI 投影结构。
2. 清理 BuffSystem 回退路径，仅保留注入式战斗实体访问。
3. 扩展遗物字段、触发器与效果分发，实现 6 个新遗物数据并接入内容管线。
4. 更新存档序列化/反序列化与单元测试，执行全量测试和内存基线。

## 验证方案

1. `make test`（预期 142/142）。
2. `bash dev/tools/memory_baseline.sh`（预期 `GUT Orphan Reports = 0`）。
3. 手动核查 `common_relics.json` 中 6 个新遗物的字段与设计一致性。

## 风险与回滚

- 风险：`draw_cards` 目前是“抽到弃牌堆”的简化实现，后续可能需要改为手牌流转并补回归。
- 回滚方式：按提交粒度执行 `git revert <commit>`。
