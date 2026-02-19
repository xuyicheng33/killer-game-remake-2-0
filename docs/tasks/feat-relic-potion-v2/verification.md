# 验证文档：feat-relic-potion-v2

**任务ID**: `feat-relic-potion-v2`
**创建日期**: 2026-02-18

---

## 设计前置检查

- [x] design_review.md 已提交
- [x] design_proposal.md 已提交
- [x] 负责人批准语句已记录：**"批准，开始，把phase2全部做完"**
- [x] 审核员确认可编码

---

## 编码阶段记录

### 2026-02-18 编码完成

**改动文件**:
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `content/custom_resources/relics/relic_data.gd`
- `runtime/global/events.gd`

### 2026-02-19 修复

**改动文件**:
- `runtime/modules/relic_potion/relic_potion_system.gd` - 修复 Card.Type 枚举比较；移除 direct fallback
- `runtime/scenes/enemy/enemy.gd` - 添加 enemy_died 信号发射
- `runtime/scenes/battle/battle.gd` - 注入 effect_stack 到 RelicPotionSystem
- `runtime/scenes/app/app.gd` - 添加 "app" 组
- `runtime/modules/reward_economy/shop_offer_generator.gd` - 修复静态方法调用

### 2026-02-19 复验补强

**改动文件**:
- `runtime/modules/relic_potion/relic_potion_system.gd` - 迁移到 RelicRegistry 回调分发；补 battle-start 就绪延迟保护
- `runtime/modules/relic_potion/relic_catalog.gd` - 改为从 content pipeline JSON 动态加载
- `runtime/modules/relic_potion/relic_base.gd` - 新增遗物回调基类
- `runtime/modules/relic_potion/relic_registry.gd` - 新增遗物注册/实例化入口
- `runtime/modules/relic_potion/data_driven_relic.gd` - 新增数据驱动默认遗物实现
- `dev/tests/unit/test_relic_potion.gd` - 扩充到 12 个行为测试（含 registry 自定义回调）
- `dev/tests/unit/test_content_pipeline_catalogs.gd` - 新增数据源加载测试

**白名单扩展** (已更新 master_plan_v3.md):
- 2-4 白名单扩展为：`runtime/modules/relic_potion/`、`runtime/scenes/app/`、`runtime/scenes/battle/`、`runtime/scenes/enemy/`、`content/custom_resources/relics/`、`runtime/global/`
- 2-6 白名单扩展为：`runtime/modules/reward_economy/`、`runtime/modules/run_flow/`、`runtime/modules/run_meta/`

---

## 测试结果

```
res://dev/tests/unit/test_relic_potion.gd
* test_trigger_type_enum_exists
* test_trigger_types_defined
* test_relic_fires_on_correct_trigger_event
* test_potion_applies_effect_via_effect_stack
* test_turn_start_relic_grants_block
* test_turn_end_relic_heals_player
* test_shop_enter_trigger_is_emitted
* test_block_applied_trigger_is_emitted
* test_boss_killed_trigger_is_emitted
* test_run_start_relic_applies_once
* test_damage_all_enemies_potion_hits_all_targets
* test_custom_relic_callback_invoked_via_registry
12/12 passed.

res://dev/tests/unit/test_content_pipeline_catalogs.gd
* test_event_templates_loaded_from_pipeline_source
* test_relic_pool_loaded_from_pipeline_source
2/2 passed.

make test (2026-02-19)
Totals
------
Scripts              13
Tests                89
Passing Tests        89
Failing Tests         0
```

---

## 最近门禁失败根因（已修复）

- 失败时间：2026-02-19
- 失败用例：`test_custom_relic_callback_invoked_via_registry`
- 根因：GDScript 匿名函数对局部变量按值捕获，测试中 `runtime_relic = ...` 不会回写到外层变量，导致假阴性。
- 修复：测试改为通过 `RuntimeRelicHolder` 引用对象记录创建实例，回调触发与收益断言均通过。

---

## 审核员结论

**通过** - 2026-02-19 复验

1. 遗物架构已对齐为 `RelicBase + RelicRegistry` 回调分发，新增遗物无需改系统主干。
2. 遗物池与事件模板均改为 content pipeline 数据源驱动，改 JSON 可直接影响运行时。
3. `make test` 全量 89/89 通过，文档结论与当前门禁状态一致。
