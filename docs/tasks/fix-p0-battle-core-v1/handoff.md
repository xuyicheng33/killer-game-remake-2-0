# 交接文档：fix-p0-battle-core-v1

**任务ID**: `fix-p0-battle-core-v1`
**日期**: 2026-02-18
**更新日期**: 2026-02-18（完成 Phase 1 全部修复 + 审核反馈修复）

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/buff_system/buff_system.gd` | 修改 | 空钩子实现 + 移除单例 + 信号生命周期 |
| `runtime/modules/battle_loop/battle_context.gd` | 新增 | 战斗核心服务容器 |
| `runtime/modules/effect_engine/effect_stack_engine.gd` | 修改 | 移除单例 + print→push_warning |
| `runtime/modules/card_system/card_zones_model.gd` | 修改 | 移除单例 + 信号生命周期 + unbind_context |
| `runtime/modules/ui_shell/adapter/battle_ui_adapter.gd` | 修改 | 通过 bind_battle_context 接收 CardZonesModel |
| `runtime/modules/ui_shell/viewmodel/stats_view_model.gd` | 修改 | 增加 buff_system 参数 |
| `runtime/scenes/battle/battle.gd` | 修改 | 创建 BattleContext + 信号生命周期 + 视觉随机注释 + _exit_tree 销毁 |
| `runtime/scenes/ui/battle_ui.gd` | 修改 | 接收 BattleContext + 信号生命周期 |
| `runtime/scenes/ui/hand.gd` | 修改 | 传递 BattleContext |
| `runtime/scenes/card_ui/card_ui.gd` | 修改 | 接收 BattleContext + 信号生命周期 |
| `runtime/scenes/app/app.gd` | 修改 | print→push_warning |
| `runtime/modules/relic_potion/relic_potion_system.gd` | 修改 | 信号生命周期 + 类型安全 |
| `runtime/global/repro_log.gd` | 修改 | print→push_warning |
| `content/effects/damage_effect.gd` | 修改 | 通过 BattleContext 获取服务 |
| `content/effects/block_effect.gd` | 修改 | 同上 |
| `content/effects/apply_status_effect.gd` | 修改 | 同上 |
| `content/custom_resources/card.gd` | 修改 | play/can_play/apply_effects 增加 battle_context 参数透传 |
| `content/custom_resources/effect.gd` | 修改 | execute 增加 battle_context 参数 |
| `content/characters/warrior/cards/generated/*.gd` | 修改 | apply_effects 透传 battle_context |
| `dev/tests/unit/test_buff_system.gd` | 修改 | 新增 8 个测试用例 |
| `dev/tests/unit/test_battle_context.gd` | 新增 | BattleContext 独立实例化测试 |

---

## 关键改动详情

### BattleContext 生命周期

```gdscript
# battle.gd
func _exit_tree() -> void:
    _disconnect_signals()
    if _battle_context != null:
        _battle_context.unbind_battle_context()
        _battle_context = null
```

### Card 参数透传（无强引用）

```gdscript
# card.gd - 移除 _battle_context 成员变量
func apply_effects(_targets: Array[Node], _battle_context: RefCounted = null) -> void:
    pass  # 子类重写，参数透传到效果
```

### 信号生命周期闭环模式

```gdscript
func _ready() -> void:
    _connect_signals()

func _exit_tree() -> void:
    _disconnect_signals()

func _connect_signals() -> void:
    if not Events.xxx.is_connected(_handler):
        Events.xxx.connect(_handler)

func _disconnect_signals() -> void:
    if Events.xxx.is_connected(_handler):
        Events.xxx.disconnect(_handler)
```

---

## 已知问题

无

---

## 下一步

Phase 1 已完成，可进入 Phase 2：核心系统后端完整实现

---

**程序员签名**: 已完成 Phase 1 全部修复
**日期**: 2026-02-18

---

## 审核员结论

**审核人**: Codex（审核员）  
**复验日期**: 2026-02-18  
**结论**: ✅ 通过并已提交
