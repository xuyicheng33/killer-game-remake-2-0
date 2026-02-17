# 验证记录

## 基本信息

- 任务 ID：`phase6-ui-shell-viewmodel-decoupling-v1`
- 日期：2026-02-17

## 静态检查

- [x] `rg -n "run_state\\.(set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/ui`
  - 结果：无命中（`scenes/ui` 未发现直接 `run_state.*` 规则写入调用）。
- [x] `rg -n "ViewModel|view_model|adapter" scenes/ui modules`
  - 结果：`stats_ui.gd`、`relic_potion_ui.gd` 已接入 `adapter`，`modules/ui_shell/viewmodel/*` 与 `modules/ui_shell/adapter/*` 命中符合预期。

## 自动化守门

- [x] `make workflow-check TASK_ID=phase6-ui-shell-viewmodel-decoupling-v1`
  - 结果：`[workflow-check] passed.`

## 行为等价核对（Phase 5 对齐）

### 用例 1：Stats UI 展示一致

1. 玩家或敌人状态变更（生命、格挡、状态层数）。
2. 检查 `stats_ui` 文本与可见性。

期望：与改造前一致，仅数据来源改为 viewmodel/adapter。

### 用例 2：Relic/Potion UI 展示与命令一致

1. 进入 run 后查看遗物/药水计数与列表文案。
2. 点击药水按钮，检查药水减少、日志更新、UI 刷新。

期望：与改造前一致，药水命令由 adapter 转发。
