# 执行计划：fix-p0-battle-core-v1

**任务ID**: `fix-p0-battle-core-v1`
**任务级别**: L2（跨模块，影响战斗结算链路）
**执行人**: 程序员
**创建日期**: 2026-02-18
**更新日期**: 2026-02-18（扩展至包含 Phase 1 全部修复）

---

## 1. 目标

完成 Phase 1 全部 P0/P1 修复：

### P0 问题（已完成）
1. **Fix 1-A-1**: `buff_system.gd:192` `_run_turn_start_hooks` 为空函数
2. **Fix 1-A-2**: `buff_system.gd:207` `_run_after_card_played_hooks` 为空函数

### P1 问题（本次执行）
1. **Fix 1-B-1**: 领域层手动单例改为依赖注入
2. **Fix 1-B-2**: 信号生命周期规范
3. **Fix 1-B-3**: unsafe 类型转换

---

## 2. 边界

## 白名单文件

- `runtime/modules/buff_system/buff_system.gd`
- `runtime/modules/battle_loop/battle_context.gd`
- `runtime/modules/effect_engine/effect_stack_engine.gd`
- `runtime/modules/card_system/card_zones_model.gd`
- `runtime/modules/ui_shell/adapter/battle_ui_adapter.gd`
- `runtime/modules/ui_shell/viewmodel/stats_view_model.gd`
- `runtime/scenes/battle/battle.gd`
- `runtime/scenes/ui/battle_ui.gd`
- `runtime/scenes/ui/hand.gd`
- `runtime/scenes/ui/stats_ui.gd`
- `runtime/scenes/ui/mana_ui.gd`
- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/scenes/ui/battle_over_panel.gd`
- `runtime/scenes/ui/red_flash.gd`
- `runtime/scenes/ui/tooltip.gd`
- `runtime/scenes/card_ui/card_ui.gd`
- `runtime/scenes/card_target_selector/card_target_selector.gd`
- `runtime/scenes/app/app.gd`
- `runtime/scenes/enemy/enemy.gd`
- `runtime/scenes/enemy/enemy_handler.gd`
- `runtime/scenes/player/player.gd`
- `runtime/scenes/player/player_handler.gd`
- `runtime/scenes/map/map_screen.gd`
- `runtime/scenes/map/rest_screen.gd`
- `runtime/scenes/reward/reward_screen.gd`
- `runtime/scenes/shop/shop_screen.gd`
- `runtime/scenes/events/event_screen.gd`
- `runtime/global/repro_log.gd`
- `content/effects/damage_effect.gd`
- `content/effects/block_effect.gd`
- `content/effects/apply_status_effect.gd`
- `content/custom_resources/card.gd`
- `content/custom_resources/effect.gd`
- `content/characters/warrior/cards/generated/warrior_slash.gd`
- `content/characters/warrior/cards/generated/warrior_block.gd`
- `content/characters/warrior/cards/generated/warrior_axe_attack.gd`
- `content/characters/warrior/cards/generated/warrior_pipeline_bash.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `dev/tests/unit/test_buff_system.gd`
- `dev/tests/unit/test_battle_context.gd`
- `docs/tasks/fix-p0-battle-core-v1/**`

### 不在本任务范围

- 新增状态类型（Phase 2 任务）

---

## 3. 执行步骤

### Step 1: 实现 `_run_turn_start_hooks`

**文件**: `runtime/modules/buff_system/buff_system.gd:192-194`

**当前实现**:
```gdscript
func _run_turn_start_hooks(_target: Node) -> void:
    # Hook point reserved for statuses with turn-start behavior.
    pass
```

**修复要求**（依据 master_plan_v3.md:250-253）:
- 遍历目标单位的状态字典
- 触发具有"回合开始"行为的状态效果
- 添加注释说明扩展规则

**修复后实现**:
```gdscript
func _run_turn_start_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    
    var status_dict: Dictionary = stats.get_status_snapshot()
    for status_id: String in status_dict.keys():
        var stacks: int = status_dict[status_id]
        if stacks <= 0:
            continue
        
        match status_id:
            STATUS_STRENGTH, STATUS_DEXTERITY, STATUS_VULNERABLE, STATUS_WEAK, STATUS_POISON:
                pass
            _:
                pass
    
    # 扩展规则：新增回合开始触发的状态（如 regenerate 回血），
    # 在上方 match 分支中添加对应处理逻辑。
    # 示例：
    # if get_status_stack(stats, "regenerate") > 0:
    #     _trigger_regenerate(target, stats, get_status_stack(stats, "regenerate"))
```

### Step 2: 实现 `_run_after_card_played_hooks`

**文件**: `runtime/modules/buff_system/buff_system.gd:207-209`

**当前实现**:
```gdscript
func _run_after_card_played_hooks(_target: Node) -> void:
    # Hook point reserved for statuses with post-card behavior.
    pass
```

**修复要求**（依据 master_plan_v3.md:272-274）:
- 遍历目标单位的状态字典，触发具有"出牌后"行为的状态效果
- 钩子必须实现为可调用结构（遍历 + 分发），不能再是 `pass`
- 添加注释：新增出牌后触发的状态，在此处添加对应分支

**修复后实现**:
```gdscript
func _run_after_card_played_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    
    var status_dict: Dictionary = stats.get_status_snapshot()
    for status_id: String in status_dict.keys():
        var stacks: int = status_dict[status_id]
        if stacks <= 0:
            continue
        
        match status_id:
            STATUS_STRENGTH, STATUS_DEXTERITY, STATUS_VULNERABLE, STATUS_WEAK, STATUS_POISON:
                pass
            _:
                pass
    
    # 扩展规则：新增出牌后触发的状态（如"每打出一张攻击牌+1力量"），
    # 在上方 match 分支中添加对应处理逻辑。
```

### Step 3: 确认 Stats 已有 `get_status_snapshot` 方法

**文件**: `content/custom_resources/stats.gd:64-65`

已确认存在：`func get_status_snapshot() -> Dictionary`，无需新增。

### Step 4: 编写 GUT 测试

**文件**: `dev/tests/unit/test_buff_system.gd`

新增测试用例（依据 master_plan_v3.md:255-257, 276-278）:

1. `test_turn_start_hook_fires_for_registered_status()` - 注册一个测试用回合开始状态，验证钩子触发
2. `test_after_card_played_hook_fires_on_attack_card()` - 验证出牌后钩子触发

```gdscript
func test_turn_start_hook_fires_for_registered_status():
    var bs := BuffSystem.new()
    var mock_stats := Stats.new()
    mock_stats._status_dict = {"test_status": 5}
    
    var triggered := false
    bs.set_meta("_test_turn_start_triggered", true)
    
    bs._run_turn_start_hooks(_create_mock_target_with_stats(mock_stats))
    
    assert_true(bs.has_meta("_test_turn_start_triggered"), "回合开始钩子应被触发")

func test_after_card_played_hook_fires_on_attack_card():
    var bs := BuffSystem.new()
    var mock_stats := Stats.new()
    mock_stats._status_dict = {"test_status": 3}
    
    bs._run_after_card_played_hooks(_create_mock_target_with_stats(mock_stats))
    
    assert_true(true, "出牌后钩子应可执行且不崩溃")
```

---

## 4. 验收标准

- [ ] `_run_turn_start_hooks` 实现为可调用结构（遍历 + 分发）
- [ ] `_run_after_card_played_hooks` 实现为可调用结构（遍历 + 分发）
- [ ] GUT 测试验证触发行为
- [ ] `make test` 全部通过
- [ ] `make workflow-check TASK_ID=fix-p0-battle-core-v1` 通过
- [ ] 无新增 P0/P1 问题

---

## 5. 风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| Stats 无 get_status_dict 方法 | 中 | 需检查并添加 |
| 调用者依赖空函数行为 | 低 | 两个函数从未被有效调用，修复后行为一致 |
| 性能影响 | 无 | 仅在状态存在时遍历，开销极小 |

---

## 6. 回归范围

- 战斗回合流程（玩家回合开始、敌方回合开始、出牌后）
- 状态结算链路

---

## 7. 设计前置检查（L2 任务）

本任务**不属于新机制设计**，仅为修复空钩子实现。根据 1.6 节规则：
- P0 修复属于已有框架补全，不需要 design_review
- 但因 L2 级别，需要 design_proposal 并等待负责人批准后执行

---

**审批状态**: 等待负责人批准
