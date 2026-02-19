# 杀戮游戏复刻 2.0 — 二次复审报告 & 后续开发规划

**复审日期**：2026-02-19
**复审范围**：Phase 0–3（已完成部分）的代码质量、架构符合度、功能正确性
**参考基准**：`docs/master_plan_v3.md`（V3.1）
**复审文件数**：25+ 核心源文件，12 个测试文件，1 个主规划文档

---

## 一、总体评价

Phase 0–3 的工作量大且覆盖面广。架构设计清晰，信号生命周期管理在大部分模块已正确实现，类型安全检查普遍符合要求，GUT 测试覆盖率有实质提升。

**亮点**：
- `EffectStackEngine` 设计优秀，有链式递归深度限制（MAX_CHAIN_DEPTH=10）、优先级排序、完整的类型安全检查
- 场景层与 ViewModel/Adapter 分离清晰，`shop_screen.gd`、`reward_screen.gd`、`rest_screen.gd` 均正确使用 Adapter 模式
- 遗物/药水触发系统已覆盖 12 种触发类型，扩展点设计合理
- 存档系统有版本兼容机制（MIN_COMPAT_VERSION）
- Elite/Boss 遭遇已在 `act1_enemies.json` 中正确定义

但本次复审发现以下**需关注问题**，其中部分属于规划明确要求清零的 P0/P1 级别仍存在残留，需在进入 Phase 4 前确认处置方案。

---

## 二、发现问题清单

### 2.1 P0 级别（严重）

> 经审核专家复核，原 P0-1 实际为技术债而非阻断项（当前无依赖此钩子的机制），降级为 P1-6。
> P0 级别当前无未解决问题。

---

### 2.2 P1 级别（严重，应在进入 Phase 4 前修复）

---

#### P1-1：`card_removal_count` 未序列化，存档后价格重置【阻断项】

**文件**：
- 字段定义：`runtime/modules/run_meta/run_state.gd:18`
- 价格依赖：`runtime/modules/reward_economy/shop_offer_generator.gd:111`
- 序列化缺失：`runtime/modules/persistence/save_service.gd:82`

`_serialize_run_state` 中无 `card_removal_count` 字段。`RunState` 初始化时此值默认为 0。存档再读档后，商店删卡价格从 75 重置，玩家可无限低价删牌。

**附加问题**：
- 门禁脚本未检查此字段：`dev/tools/persistence_contract_check.sh:47`
- `test_save_service.gd` 缺少 RunState roundtrip 测试

**修复要求**：
1. `save_service.gd` 补充序列化/反序列化
2. 门禁脚本增加 `card_removal_count` 检查
3. 新增 GUT 测试 `test_card_removal_count_survives_save_load()`

---

#### P1-2：`BuffSystem._handle_death()` 直接 `queue_free()` 绕过战斗状态机

**文件**：`runtime/modules/buff_system/buff_system.gd:334–346`

```gdscript
func _handle_death(target: Node) -> void:
    if target.is_in_group("player"):
        Events.player_died.emit()
        target.queue_free()   # ← 直接释放场景节点
        return
    if target.is_in_group("enemies"):
        Events.enemy_died.emit(enemy)
        target.queue_free()
```

**问题**：

1. **架构违规**：`BuffSystem` 是 `RefCounted` 域服务，直接调用 `queue_free()` 释放场景节点，违反"场景层只做展示"原则（master_plan_v3.md 架构原则 §1.2）。

2. **竞态条件**：DOT 效果（毒、燃烧）触发死亡后，`_player` 节点被 `queue_free()`，随后 `BattlePhaseStateMachine.check_battle_end()` 检查 `_player.stats.health`，此时 `_player` 为已释放状态，检查将返回 `{"ended": true, "result": "defeat"}` 因 `is_instance_valid` 失败——这个路径确实会触发战斗结束，但触发时机与正常结算时机（`on_resolve_discard_completed` 调用链）不一致。

3. **信号时序**：`Events.player_died` 在 ENEMY Phase 内（由 DOT 触发）提前发射，而正常死亡判定在 RESOLVE Phase 末尾。两套死亡路径并存，行为不统一。

**建议修复阶段**：Phase 5 前（全流程测试会暴露竞态问题）

---

#### P1-3：`BuffSystem` 通过场景树全局查找战斗实体

**文件**：`runtime/modules/buff_system/buff_system.gd:376–410`

```gdscript
func _get_player_node() -> Player:
    var tree := _get_tree()   # Engine.get_main_loop()
    ...
    tree.get_nodes_in_group("player")
```

`BuffSystem` 是 `RefCounted` 域服务，但通过全局场景树查找 Player/Enemy 节点。这违反依赖注入原则（master_plan_v3.md §1.2），且导致：
- GUT 单元测试中 `_get_player_node()` 返回 null，部分测试走了假路径（测试中手动绕过了此问题，非真正隔离）。
- 如果未来有多个战斗实例并存，查询结果不可预测。

**建议修复阶段**：Phase 5 前

---

#### P1-4：`RelicPotionSystem._fire_trigger` 每次都实例化遗物运行时对象

**文件**：`runtime/modules/relic_potion/relic_potion_system.gd:185–194`

```gdscript
for relic in run_state.relics:
    var relic_runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic_data)
    ...
    relic_runtime.call("handle_trigger", ...)
```

每次触发（出牌、受伤、回合开始/结束等）对每个遗物都新建一个运行时对象。一局内出牌次数可达数十次，若遗物数量达到上限 6 个，会产生大量临时对象和 GC 压力。更重要的是：若遗物需要跨触发维护状态（如"本回合已触发X次"），当前方案无法支持，因为每次触发的都是全新实例。

**建议修复阶段**：Phase 5 前（影响性能和状态跟踪）

---

#### P1-5：`_is_battle_start_context_ready` 无限轮询，无退出上限

**文件**：`runtime/modules/relic_potion/relic_potion_system.gd:107–121`

```gdscript
tree.create_timer(0.01, false).timeout.connect(_try_fire_battle_start_trigger, CONNECT_ONE_SHOT)
```

若 `effect_stack` 始终未注入（例如 `battle.gd` 中注入路径有误），此轮询会无限循环直到场景销毁，且不产生任何错误日志。缺乏最大重试次数或超时检测。

**建议修复阶段**：Phase 4（安全补丁，成本低）

---

#### P1-6：`_run_after_card_played_hooks` 结构存在但行为为空

**文件**：`runtime/modules/buff_system/buff_system.gd:230–250`

**现状**：方法体已从 `pass` 改写为迭代结构，但所有 `match` 分支均为 `pass`。

**降级说明**：经审核专家复核，当前并无任何"出牌后触发状态"实际落地（当前触发逻辑在回合开始/结束，见 buff_system.gd:208、216）。此为技术债而非阻断项。

**建议修复阶段**：Phase 5 前（当需要开发"出牌后触发"机制时再实现）

---

#### P1-7：营地升级与 Exhaust 升级逻辑不一致，违反数据驱动原则

**文件**：`runtime/modules/run_meta/run_state.gd:158–184`

**营地升级**（`upgrade_card_in_deck_at`）：
```gdscript
upgraded.id = "%s+" % upgraded.id     # 硬编码 ID 追加 "+"
if upgraded.cost > 0:
    upgraded.cost -= 1                 # 硬编码费用 -1
```

**Exhaust 升级**（`Card.create_exhaust_upgrade_copy`，card.gd:93–110）：
```gdscript
var target_id := upgrade_to.strip_edges()  # 使用 upgrade_to 字段
upgraded.id = target_id                     # 替换为目标 ID
```

两套机制并存：
- Exhaust 升级尊重 `Card.upgrade_to` 字段，可定义任意升级路径
- 营地升级完全忽略 `upgrade_to`，硬编码行为

**修复建议**：营地升级应改为调用 `Card.create_exhaust_upgrade_copy()` 或类似逻辑，统一使用 `upgrade_to` 字段。

**建议修复阶段**：Phase 5（影响内容设计一致性）

---

### 2.3 P2 级别（代码质量，可带入但需计划修复）

---

#### P2-1：`draw_cards` 中 `_reshuffle_deck_from_discard` 被调用两次

**文件**：`runtime/modules/battle_loop/battle_context.gd:80–89`

```gdscript
for _index in range(amount):
    _reshuffle_deck_from_discard("card_effect_draw")  # 第一次
    var card: Card = _character.draw_pile.draw_card()
    if card == null:
        break
    _hand.add_card(card)
    drawn += 1
    _reshuffle_deck_from_discard("card_effect_draw")  # 第二次（冗余）
```

第二次调用是冗余的（因为此时刚抽了牌，draw_pile 不为空），但会消耗一次 RNG 流读取（如果 shuffle 被实际调用）。

---

#### P2-2：`map_generator` 中遗留占位符文本

**文件**：`runtime/modules/map_event/map_generator.gd:124`

```gdscript
MapNodeData.NodeType.SHOP:
    return "商店占位节点（B3 再实现交易流程）。"
```

Phase 3b 商店已实现，此描述文字未更新，是过时的占位信息。

---

#### P2-3：`RunState._apply_potion_effect` 战斗外使用损耗药水却无效

**文件**：`runtime/modules/run_meta/run_state.gd:231–233`

```gdscript
PotionData.EffectType.DAMAGE_ALL_ENEMIES:
    return "使用 %s：仅战斗中可生效..." % [potion.title, value]
```

`use_potion_at()` 在执行此分支后仍会消耗药水（`potions.remove_at(index)`）。战斗外使用伤害药水时，药水被白白消耗。

---

#### P2-4：`BuffSystem.on_entity_hit` 是无功能空壳

**文件**：`runtime/modules/buff_system/buff_system.gd:100–103`

```gdscript
func on_entity_hit(target: Node, _source: Node, _final_damage: int) -> void:
    if target == null:
        return
    # 仅此而已
```

方法签名完整但无实际逻辑。若计划在 Phase 4/5 添加受击触发效果（如遗物"每次受击获得格挡"），需先实现此钩子。目前未被任何代码调用。

---

#### P2-5：Integration 测试调用私有方法

**文件**：`dev/tests/integration/test_battle_flow.gd:75`

```gdscript
app.call("_open_battle", "act1_crab_single")
```

通过字符串 `call()` 访问 `GameApp` 的私有方法 `_open_battle`，绕过了公共接口。若方法重命名则测试静默失败。

---

#### P2-6：Elite 遭遇已定义但 Elite 敌人无差异化

**文件**：`runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json:183–195`

Elite 遭遇（`act1_elite_viper_pair`、`act1_elite_viper_bat`）已定义，但敌人配置与普通遭遇完全相同（相同的 HP、相同的 intents）。按照 Slay the Spire 设计，Elite 敌人通常有更高的 HP 和特殊能力。当前 Elite 遭遇仅是敌人数量增加，无实质难度区分。

---

### 2.4 架构/设计层面观察

---

#### A-1：主菜单 UI 缺失

master_plan_v3.md §2 明确计划要求添加"新游戏/继续游戏/角色选择"主菜单。当前 `app.gd` 直接在 `_ready()` 里尝试读档或新局，无主菜单入口。此为 Phase 6 的交付内容，但需提前规划 UI 框架。

---

#### A-2：地图分支结构（经审核确认，无阻断风险）

**文件**：`runtime/modules/map_event/map_generator.gd:153`

经审核专家复核，每个节点都强制连接同 lane 下一层（`map_generator.gd:153`），理论上天然存在多条主干路径。已有测试覆盖多路径验证（`dev/tests/unit/test_map_generator.gd:21`）。

**结论**：原"孤立路径风险"描述偏重，调整为"正常实现，有测试覆盖"。

---

#### A-3：游戏内全部字体应使用系统默认字体

**当前状态**：项目中可能存在硬编码字体路径或自定义字体设置。

**目标**：所有 UI 文本使用系统默认字体，确保：
- 无需加载额外字体文件，减少资源占用
- 跨平台兼容性更好
- 中文显示正常（系统字体通常已包含中日韩字符）

**实现建议**：
1. 检查 `main_theme.tres` 中的字体设置，移除自定义字体引用
2. 检查所有 UI 场景中的 `add_theme_font_size_override` 调用，确保无硬编码字体路径
3. 如需统一字体大小，仅在 theme 中设置默认值，不指定具体字体

**验收标准**：
- 所有 Label/Button 节点使用系统默认字体渲染
- 无字体加载失败的警告
- 中英文混合显示正常

---

## 三、后续阶段开发规划建议

### 3.1 Phase 3 收尾（进入 Phase 4 前的唯一阻断项）

**唯一阻断项**：P1-1（card_removal_count 序列化）

| 问题 | 预计工作量 | 说明 |
|------|-----------|------|
| P1-1：序列化 `card_removal_count` | 极小（2行代码） | 直接阻断存档往返验收 |
| 门禁脚本补检查 | 极小（1行） | `dev/tools/persistence_contract_check.sh:47` |
| GUT roundtrip 测试 | 小 | 新增 `test_card_removal_count_survives_save_load()` |

---

### 3.2 Phase 4：存档验证 + 种子一致性

**必须序列化且验证的字段**（当前存档版本 v3 应补全）：
- `card_removal_count`（P1-1，当前缺失）
- `run_start_relics_applied`（已有）
- 玩家状态 statuses（已有）
- RNG stream states（已有）

**Phase 4 GUT 测试建议**（补充 `test_save_service.gd`）：
```
test_card_removal_count_survives_save_load()
test_relic_count_survives_save_load()
test_map_position_survives_save_load()
test_same_seed_generates_same_map()
test_rng_state_restore_reproduces_next_draw()
```

**Phase 4 可并行处理的技术债**（非阻断）：
- P1-5：无限轮询加退出限制（成本低）
- P1-3：BuffSystem 场景树查找 → 依赖注入

---

### 3.3 Phase 5：完整流程打通

**Phase 5 前应清理的技术债**（P1 级别）：

| 问题 | 说明 |
|------|------|
| P1-2：`_handle_death()` 死亡时序 | 全流程测试一定会触发 DOT 死亡路径，竞态会导致测试不稳定 |
| P1-3：BuffSystem 场景树查找 | 如果增加更复杂的场景管理，全局查找可能返回错误实例 |
| P1-4：RelicPotionSystem 每次触发实例化 | 性能+状态追踪问题 |
| P1-6：`_run_after_card_played_hooks` 空实现 | 当需要开发"出牌后触发"机制时再实现 |
| P1-7：营地升级逻辑不一致 | 影响内容设计一致性 |
| P2-4：`on_entity_hit` 空壳 | 若有受击触发遗物则必须实现 |

Phase 5 新增验收清单建议：
```
□ 从开局到 Boss 通关，不中途崩溃
□ 所有 6 种节点类型均能正常进入和退出
□ DOT 效果杀死玩家/敌人后战斗正确结束
□ 遗物 ON_BATTLE_START 在第一次回合前触发（已有集成测试）
□ 药水在战斗中/外行为正确
□ Boss 通关后存档清除，重启进入新局
□ 战败后存档清除，重启进入新局
```

---

### 3.4 Phase 6：UI 对接

Phase 6 验收项（参考 master_plan_v3.md:872、936）：
1. **主菜单场景**：新游戏按钮 + 继续游戏按钮（SaveService.has_save() 控制启用）+ 角色选择（目前只有 Warrior，Mage 已有占位）
2. **角色选择 UI**：`CharacterRegistry.get_available_characters()` 接口已有，UI 层接入即可
3. **ViewModels 验证**：`ui_shell/viewmodel/` 下 8 个 ViewModel 是否都已与对应 Scene 正确对接
4. **字体统一**：所有 UI 使用系统默认字体（见 A-3），移除自定义字体引用

---

### 3.5 技术债跟踪建议

| 问题 | 建议修复阶段 | 说明 |
|------|------------|------|
| P1-1：card_removal_count 序列化 | **Phase 4 阻断** | 唯一阻断项 |
| P1-5：无限轮询加退出限制 | Phase 4 | 成本低，安全补丁 |
| P1-3：BuffSystem 场景树查找 | Phase 4/5 | 依赖注入重构 |
| P1-2：`_handle_death()` | Phase 5 前 | 竞态问题 |
| P1-4：遗物每次触发实例化 | Phase 5 前 | 性能+状态追踪 |
| P1-6：出牌后钩子 | Phase 5 | 按需实现 |
| P1-7：营地升级逻辑 | Phase 5 | 统一到 upgrade_to |
| P2-4：on_entity_hit | Phase 5 | 按需实现 |

---

## 四、测试覆盖补全建议

当前测试套件对核心域覆盖较好（`make test` 结果：96/96 全通过），但以下场景需要补充测试：

```
□ save/load card_removal_count 往返（P1-1 对应测试）—— 必须
□ RunState 全字段 roundtrip 测试
□ 毒/燃烧等 DOT 杀死单位后 check_battle_end 正确返回 defeat
□ 同 seed 生成地图结果完全一致（确定性）
□ upgrade_card_in_deck_at 后 card.id 和 cost 正确变化
□ 战斗外使用伤害药水不消耗（或行为明确文档化）
□ RelicPotionSystem: ON_SHOP_ENTER 触发
□ 营地升级与 Exhaust 升级行为一致性（P1-7 对应测试）
□ Elite 遭遇能正确触发并生成更强的敌人配置
□ Boss 战结束后存档清除、路由到 run_complete
```

**门禁脚本需补充检查**：
- `dev/tools/persistence_contract_check.sh:47` 增加 `card_removal_count` 字段检查

**现有测试质量评估**：

| 测试文件 | 覆盖面 | 评价 |
|---------|--------|------|
| `test_buff_system.gd` | 10 种状态效果 | 覆盖完整，毒/燃烧/再生/仪式等 |
| `test_effect_stack.gd` | 优先级、链式深度 | 覆盖完整，包含递归保护测试 |
| `test_map_generator.gd` | 15 层生成、多路径验证 | 覆盖核心逻辑 |
| `test_relic_potion.gd` | 触发系统、药水效果 | 覆盖主要触发类型 |
| `test_save_service.gd` | 序列化/反序列化 | 缺少 card_removal_count 测试 |
| `test_battle_flow.gd`（集成） | Boss/普通胜利路由 | 使用私有方法调用（P2-5） |

---

## 五、Phase 0–3 交付物完成度核验

对照 `master_plan_v3.md` 各阶段交付物：

| Phase | 交付物 | 状态 | 备注 |
|-------|--------|------|------|
| **Phase 0** | GUT 框架可运行 | ✅ 完成 | `make test` 可用，96/96 通过 |
| **Phase 0** | 现状差异清单 | ✅ 完成 | 已在 baseline-alignment 任务中记录 |
| **Phase 1** | P0=0 | ✅ 完成 | 经审核确认，无 P0 阻断项 |
| **Phase 1** | P1=0 | ⚠️ 有残留 | P1-1 未修复（唯一阻断项） |
| **Phase 1** | BattleContext 可测试 | ✅ 完成 | 已有依赖注入机制 |
| **Phase 2** | 战斗/Buff/效果后端有 GUT | ✅ 完成 | 测试文件存在且可运行 |
| **Phase 3a** | 8卡/3敌/6遗物/4药水 | ✅ 超额 | 实际：20卡/4敌/10遗物/5药水 |
| **Phase 3b** | 20卡/4敌/8遗物/5药水 | ✅ 完成 | 已达标 |
| **Phase 3b** | 商店买遗物/药水 | ✅ 完成 | 有代码实现 |

---

## 六、进入 Phase 4 前的阻断项清单

**唯一阻断项**（必须修复）：

| 问题ID | 问题描述 | 影响范围 | 修复复杂度 |
|--------|---------|---------|-----------|
| **P1-1** | `card_removal_count` 未序列化 | Phase 4 存档往返验收失败 | 极低（2行代码） |

**附加要求**：
- 门禁脚本 `dev/tools/persistence_contract_check.sh` 补充检查
- GUT 测试 `test_card_removal_count_survives_save_load()` 新增

**Phase 5 前应清理的技术债**（非 Phase 4 阻断）：

| 问题ID | 问题描述 | 影响范围 |
|--------|---------|---------|
| P1-2 | `_handle_death()` 直接 free | 存在竞态 |
| P1-3 | 遗物每次触发实例化 | 性能+状态追踪 |
| P1-5 | 无限轮询无上限 | 安全隐患 |
| P1-6 | 出牌后钩子空实现 | 技术债 |
| P1-7 | 营地升级逻辑不一致 | 内容设计一致性 |

---

## 七、关键文件路径索引

| 模块 | 关键文件 |
|------|---------|
| Buff 系统 | `runtime/modules/buff_system/buff_system.gd` |
| 存档 | `runtime/modules/persistence/save_service.gd` |
| 运行状态 | `runtime/modules/run_meta/run_state.gd` |
| 遗物/药水 | `runtime/modules/relic_potion/relic_potion_system.gd` |
| 战斗循环 | `runtime/modules/battle_loop/battle_context.gd` |
| 战斗阶段机 | `runtime/modules/battle_loop/battle_phase_state_machine.gd` |
| 效果栈引擎 | `runtime/modules/effect_engine/effect_stack_engine.gd` |
| 地图生成 | `runtime/modules/map_event/map_generator.gd` |
| 遭遇注册 | `runtime/modules/enemy_intent/encounter_registry.gd` |
| 卡牌基类 | `content/custom_resources/card.gd` |
| 应用入口 | `runtime/scenes/app/app.gd` |
| 商店界面 | `runtime/scenes/shop/shop_screen.gd` |
| 奖励界面 | `runtime/scenes/reward/reward_screen.gd` |
| 营火界面 | `runtime/scenes/map/rest_screen.gd` |
| 遭遇数据 | `runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json` |
| Buff 测试 | `dev/tests/unit/test_buff_system.gd` |
| 流程测试 | `dev/tests/integration/test_battle_flow.gd` |
| 存档测试 | `dev/tests/unit/test_save_service.gd` |

---

## 八、复审结论

### 总体评分：8/10（良好，有一处阻断项）

**已做得好的方面**：
- 架构分层清晰，Adapter/ViewModel 模式正确使用
- 信号生命周期管理（connect/disconnect 配对）普遍正确
- 效果栈引擎设计健壮，有完整的递归保护和类型安全
- 内容数据驱动架构已建立，支持 JSON 导入
- 测试覆盖面广，96/96 全通过
- 内容规模已到位：20卡/4敌/10遗物/5药水/13遭遇

**需改进的方面**：
- P1-1（card_removal_count 序列化）未在 Phase 1 结束时修复（唯一阻断项）
- 营地升级逻辑与 Exhaust 升级不一致，违反数据驱动原则
- `BuffSystem` 仍通过场景树查找，未完全转为依赖注入
- 部分空壳方法（`on_entity_hit`、`_run_after_card_played_hooks`）未实现

### 建议的下一步行动

1. **立即修复 P1-1**（card_removal_count 序列化）—— 这是 Phase 4 的唯一阻断项
2. **补充门禁检查** —— `dev/tools/persistence_contract_check.sh` 增加 `card_removal_count`
3. **新增 GUT 测试** —— `test_card_removal_count_survives_save_load()`
4. **Phase 4 后清理技术债** —— 按优先级处理 P1-2 至 P1-7

---

**复审人**：Claude Code（基于代码静态分析）
**审核专家复核**：2026-02-19
**复审完成时间**：2026-02-19
