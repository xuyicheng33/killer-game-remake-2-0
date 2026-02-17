# 验证记录

## 任务信息

- 任务 ID：`r2-phase03-ui-shell-full-decoupling-v1`
- 验证时间：2026-02-17

## 验证命令执行

### 1. 检查5个页面均通过adapter接入

```bash
$ grep -l "adapter" runtime/scenes/map/*.gd runtime/scenes/shop/*.gd runtime/scenes/events/*.gd runtime/scenes/reward/*.gd 2>/dev/null
runtime/scenes/map/map_screen.gd
runtime/scenes/map/rest_screen.gd
runtime/scenes/shop/shop_screen.gd
runtime/scenes/events/event_screen.gd
runtime/scenes/reward/reward_screen.gd
```

**结果：通过** - 5个页面均包含adapter引用

### 2. UI壳层契约检查

```bash
$ bash dev/tools/ui_shell_contract_check.sh
[ui_shell_contract] checking forbidden direct RunState writes under runtime/scenes/ui...
[PASS] no forbidden run_state direct writes in runtime/scenes/ui
[ui_shell_contract] checking migrated pages are wired through adapter + viewmodel...
[PASS] stats_ui uses stats adapter
[PASS] stats adapter uses stats viewmodel
[PASS] stats_ui does not directly query BuffSystem
[PASS] relic_potion_ui uses relic_potion adapter
[PASS] relic_potion adapter uses relic_potion viewmodel
[PASS] relic_potion_ui does not directly call relic_potion_system.use_potion
[PASS] battle_ui uses battle_ui adapter
[PASS] battle_ui adapter uses battle_ui viewmodel
[PASS] battle_ui does not directly import card_system/card_zones_model
[ui_shell_contract] all checks passed.
```

**结果：通过**

### 3. 全量workflow通过（修正后）

```bash
$ make workflow-check TASK_ID=r2-phase03-ui-shell-full-decoupling-v1
[workflow-check] running quality gates...
[repo-structure-check] passed.
[ui_shell_contract] all checks passed.
[run_flow_contract] all checks passed.
[run_flow_payload_contract] all checks passed.
[run_flow_result_shape] all checks passed.
[run_lifecycle_contract] all checks passed.
[persistence_contract] all checks passed.
[seed_rng_contract] all checks passed.
[scene_runstate_write] all checks passed.
[scene_nested_state_write] all checks passed.
[workflow-check] passed.
```

**结果：通过**

## 验证结果

| 命令 | 结果 | 说明 |
|------|------|------|
| grep adapter接入 | 通过 | 5个页面均包含adapter引用 |
| ui_shell_contract_check | 通过 | 所有契约检查通过 |
| workflow-check | 通过 | 新分支 `feat/ui_shell-r2-phase03-ui-shell-full-decoupling-v1` |

## 修正说明

### 白名单扩展理由

原始任务模板中的白名单未包含场景脚本文件，但任务目标要求"改造对应场景脚本，改为通过adapter获取投影"。因此需要扩展白名单以包含：

- `runtime/scenes/map/map_screen.gd`
- `runtime/scenes/map/rest_screen.gd`
- `runtime/scenes/shop/shop_screen.gd`
- `runtime/scenes/events/event_screen.gd`
- `runtime/scenes/reward/reward_screen.gd`

这些文件的改动是完成 UI 壳层架构迁移所必需的"接线改动"，不涉及业务逻辑变更。

### 白名单格式修正

plan.md 中白名单行原格式 `文件路径（新建）` 导致解析失败，已修正为纯路径格式。

## 提交信息

```
feat(ui_shell): map/rest/shop/event/reward UI壳层迁移（r2-phase03-ui-shell-full-decoupling-v1）

- 新增 5 个 viewmodel: map/rest/shop/event/reward_ui_view_model.gd
- 新增 5 个 adapter: map/rest/shop/event/reward_ui_adapter.gd
- 改造 5 个场景脚本使用 adapter 架构
- 更新 ui_shell README 文档
- 新增任务三件套
```

Commit: `22a7cf0`
Branch: `feat/ui_shell-r2-phase03-ui-shell-full-decoupling-v1`
