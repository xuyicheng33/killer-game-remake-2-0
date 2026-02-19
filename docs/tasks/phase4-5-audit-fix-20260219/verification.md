# Phase 4-5 审核修复验证文档

**修复日期**: 2026-02-19
**修复范围**: Phase 0–3 遗留问题 + Phase 4-5 新增测试
**参考基准**: `docs/master_plan_v3.md` (V3.1)

---

## 一、修复问题清单

### P1 级别（严重）

| 问题ID | 描述 | 修复状态 | 验证方式 |
|--------|------|----------|----------|
| **P1-1** | `card_removal_count` 未序列化 | ✅ 已修复 | GUT 测试 + 门禁脚本 |
| **P1-2** | `_handle_death()` 直接 `queue_free()` | ✅ 已修复 | 集成测试 |
| **P1-3** | BuffSystem 通过场景树全局查找 | ✅ 已修复 | 单元测试 |
| **P1-4** | 遗物每次触发实例化 | ✅ 已修复 | 单元测试 |
| **P1-5** | 无限轮询无退出上限 | ✅ 已修复 | 单元测试 |
| **P1-7** | 营地升级逻辑不一致 | ✅ 已修复 | 集成测试 |

### P2 级别（代码质量）

| 问题ID | 描述 | 修复状态 | 验证方式 |
|--------|------|----------|----------|
| **P2-1** | 冗余调用 `_reshuffle_deck_from_discard` | ✅ 已修复 | 代码审查 |
| **P2-2** | 商店占位符文本 | ✅ 已修复 | 代码审查 |
| **P2-3** | 战斗外使用伤害药水被消耗 | ✅ 已修复 | 集成测试 |

---

## 二、测试结果

### 测试统计

```
Scripts:     14
Tests:       117
Passing:     117
Asserts:     594
Time:        2.441s
```

### 门禁脚本

```
[persistence_contract] all checks passed.
```

---

## 三、新增测试清单

### Phase 4: RunState 序列化测试

- `test_run_state_full_roundtrip` - RunState 全字段往返测试
- `test_map_graph_roundtrip` - 地图图序列化测试
- `test_player_stats_with_statuses_roundtrip` - 带状态的玩家状态测试

### Phase 4: 重试机制测试

- `test_max_battle_start_retries_constant_exists` - 重试上限常量测试
- `test_battle_start_retry_count_increments_on_context_not_ready` - 重试计数测试
- `test_battle_start_gives_up_after_max_retries` - 重试放弃测试
- `test_battle_start_triggers_when_context_ready` - 正常触发测试

### Phase 5: 信号机制基础测试

- `test_events_signal_mechanism` - Events 信号机制基础验证

### Phase 5: DOT 死亡集成测试

- `test_dot_death_triggers_battle_end_correctly` - DOT 死亡信号测试（已补充 battle end 断言）
- `test_dot_damage_and_death_logic_via_trigger_poison` - DOT 伤害逻辑测试
- `test_battle_phase_machine_empty_enemies_victory` - 空敌人列表胜利测试
- `test_battle_phase_machine_with_dead_enemy` - 死亡敌人判定测试
- `test_handle_death_signal_for_enemies_group` - 敌人组信号测试

### Phase 5: 升级逻辑测试

- `test_rest_screen_upgrade_uses_upgrade_to_field` - 营地升级使用 upgrade_to 字段
- `test_rest_screen_upgrade_fallback_to_hardcoded` - 营地升级回退到硬编码

### Phase 5: 药水使用测试

- `test_damage_potion_not_consumed_outside_battle` - 战斗外伤害药水不消耗

### 遗物缓存测试

- `test_relic_runtime_cache_reuses_same_instance` - 遗物运行时缓存复用
- `test_relic_runtime_cache_duplicate_id_shares_state` - 重复 ID 状态共享
- `test_relic_runtime_cache_clears_on_rebind` - 重绑定时缓存清除

---

## 四、技术发现：GDScript 闭包捕获问题

在修复 DOT 死亡集成测试过程中，发现 GDScript 的一个重要行为：

**问题描述**: 在 lambda 中修改捕获的外部变量时，外部变量的值不会更新。

**示例**:
```gdscript
# 错误写法 - signal_received 不会被更新
var signal_received := false
Events.enemy_died.connect(func(_e: Enemy):
    signal_received = true  # 这里修改的是闭包内的副本
, CONNECT_ONE_SHOT)
Events.enemy_died.emit(enemy)
assert_true(signal_received)  # 失败！signal_received 仍然是 false

# 正确写法 - 使用字典作为可变引用类型
var state := {"received": false}
Events.enemy_died.connect(func(_e: Enemy):
    state["received"] = true  # 修改字典内容
, CONNECT_ONE_SHOT)
Events.enemy_died.emit(enemy)
assert_true(state["received"])  # 通过！
```

**影响**: 所有使用 lambda 捕获变量的信号监听测试都需要使用此模式。

---

## 五、关键代码修改

### 5.1 BuffSystem 死亡处理重构

**修改文件**: `runtime/modules/buff_system/buff_system.gd`

**修改内容**:
- 移除 `_handle_death()` 中的 `queue_free()` 调用
- 添加 `bind_combatants()` 和 `unbind_combatants()` 方法支持依赖注入
- 添加 `remove_enemy()` 方法同步敌人列表

**影响范围**: 战斗死亡处理、DOT 效果杀死单位

### 5.2 RelicPotionSystem 性能优化

**修改文件**: `runtime/modules/relic_potion/relic_potion_system.gd`

**修改内容**:
- 添加 `_relic_runtimes` 缓存字典
- 添加 `MAX_BATTLE_START_RETRIES = 100` 重试上限
- 添加 `_rebuild_relic_runtime_cache()` 和 `_get_or_create_relic_runtime()` 方法

**影响范围**: 遗物触发系统、战斗开始流程

### 5.3 存档序列化补全

**修改文件**: `runtime/modules/persistence/save_service.gd`

**修改内容**:
- 序列化添加 `card_removal_count` 字段
- 反序列化添加 `card_removal_count` 恢复

**影响范围**: 存档/读档功能

### 5.4 战斗外药水使用修复

**修改文件**: `runtime/modules/run_meta/run_state.gd`

**修改内容**:
- `use_potion_at()` 中对 DAMAGE_ALL_ENEMIES 类型不消耗药水
- `upgrade_card_in_deck_at()` 优先使用 `upgrade_to` 字段

**影响范围**: 药水系统、营地升级

### 5.5 运行时死亡链路统一入口（二次审核修复）

**修改文件**: `runtime/scenes/battle/battle.gd`

**修改内容**:
- `_on_enemy_died()` 改为调用 `_battle_context.remove_enemy(enemy)`
- 确保同步 BuffSystem 的敌人列表，避免引用不同步

**影响范围**: 敌人死亡处理、BuffSystem 敌人队列

### 5.6 测试断言完善（二次审核修复）

**修改文件**: `dev/tests/integration/test_battle_flow.gd`

**修改内容**:
- `test_dot_death_triggers_battle_end_correctly` 补充 `check_battle_end()` 断言
- 统一清理策略：`queue_free()` + `await get_tree().process_frame`
- 消除 Orphan 警告

**影响范围**: DOT 死亡测试覆盖

---

## 六、后续阶段规划

### Phase 6: UI 对接

1. **主菜单场景**: 新游戏按钮 + 继续游戏按钮 + 角色选择
2. **角色选择 UI**: `CharacterRegistry.get_available_characters()` 接入
3. **ViewModels 验证**: `ui_shell/viewmodel/` 下 8 个 ViewModel 对接验证
4. **字体统一**: 所有 UI 使用系统默认字体

### 待清理技术债

| 问题 | 说明 | 建议修复阶段 |
|------|------|-------------|
| P1-6 | `_run_after_card_played_hooks` 空实现 | Phase 5（按需） |
| P2-4 | `on_entity_hit` 空壳 | Phase 5（按需） |
| P2-5 | Integration 测试调用私有方法 | Phase 6 |
| P2-6 | Elite 敌人无差异化 | Phase 6 |

---

## 七、验证人签字

**验证人**: Claude Code
**验证日期**: 2026-02-19
**验证状态**: ✅ 全部通过
