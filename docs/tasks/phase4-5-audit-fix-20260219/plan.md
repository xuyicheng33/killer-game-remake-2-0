# Phase 6+ 开发规划

**规划日期**: 2026-02-19
**规划范围**: Phase 6 UI 对接及后续内容开发

---

## 一、Phase 6: UI 对接

### 1.1 主菜单场景

**任务**: 创建主菜单场景，包含以下功能：
- 新游戏按钮
- 继续游戏按钮（根据 `SaveService.has_save()` 控制启用状态）
- 角色选择（目前只有 Warrior，Mage 已有占位）

**验收标准**:
- [ ] 主菜单场景可正常加载
- [ ] 新游戏按钮可开始新局
- [ ] 继续游戏按钮在有存档时可用，无存档时禁用
- [ ] 角色选择界面可显示可用角色

### 1.2 角色选择 UI

**任务**: 接入 `CharacterRegistry.get_available_characters()` 接口

**验收标准**:
- [ ] 显示所有可用角色
- [ ] 选择角色后可开始新游戏

### 1.3 ViewModels 验证

**任务**: 验证 `ui_shell/viewmodel/` 下 8 个 ViewModel 与对应 Scene 正确对接

**验收标准**:
- [ ] 所有 ViewModel 正确绑定到对应的 Scene
- [ ] 数据双向绑定正常工作

### 1.4 字体统一

**任务**: 所有 UI 使用系统默认字体

**验收标准**:
- [ ] 所有 Label/Button 节点使用系统默认字体渲染
- [ ] 无字体加载失败的警告
- [ ] 中英文混合显示正常

---

## 二、待清理技术债

### 2.1 P1-6: `_run_after_card_played_hooks` 空实现

**优先级**: 低
**修复时机**: 当需要开发"出牌后触发"机制时

**建议**:
```gdscript
func _run_after_card_played_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return

    # 未来可在此添加出牌后触发的状态效果
    # 例如：连击计数、出牌次数追踪等
```

### 2.2 P2-4: `on_entity_hit` 空壳

**优先级**: 中
**修复时机**: 当需要开发受击触发遗物时

**建议**:
```gdscript
func on_entity_hit(target: Node, source: Node, final_damage: int) -> void:
    if target == null:
        return

    # 触发受击相关效果
    if target.is_in_group("player"):
        Events.player_hit.emit()
        # 可添加遗物触发：如"每次受击获得格挡"
```

### 2.3 P2-5: Integration 测试调用私有方法

**优先级**: 低
**修复时机**: Phase 6 重构测试时

**建议**: 提供公共测试接口或使用 `set_meta` 传递测试数据

### 2.4 P2-6: Elite 敌人无差异化

**优先级**: 中
**修复时机**: 内容开发阶段

**建议**: 在 `act1_enemies.json` 中为 Elite 敌人设置更高的 HP 和特殊能力

---

## 三、Phase 7+: 内容扩展

### 3.1 更多卡牌

- 目标：达到 50+ 卡牌
- 类型分布：攻击 40%、技能 40%、能力 20%

### 3.2 更多敌人

- 目标：达到 15+ 敌人类型
- 包含 Elite 和 Boss 差异化

### 3.3 更多遗物

- 目标：达到 30+ 遗物
- 覆盖更多触发类型

### 3.4 更多药水

- 目标：达到 10+ 药水
- 包含战斗中和战斗外使用的药水

---

## 四、任务分配建议

### 高优先级（立即开始）

| 任务 | 预计工作量 | 负责人 |
|------|-----------|--------|
| 主菜单场景 | 中 | TBD |
| 角色选择 UI | 小 | TBD |
| 字体统一 | 小 | TBD |

### 中优先级（Phase 6 完成后）

| 任务 | 预计工作量 | 负责人 |
|------|-----------|--------|
| Elite 敌人差异化 | 小 | TBD |
| ViewModels 验证 | 中 | TBD |
| on_entity_hit 实现 | 小 | TBD |

### 低优先级（按需）

| 任务 | 预计工作量 | 负责人 |
|------|-----------|--------|
| _run_after_card_played_hooks | 小 | TBD |
| Integration 测试重构 | 中 | TBD |
| 内容扩展（卡牌/敌人/遗物/药水） | 大 | TBD |

---

## 五、里程碑时间线

```
Phase 6 (UI 对接)
├── 主菜单场景         [Week 1]
├── 角色选择 UI        [Week 1]
├── ViewModels 验证    [Week 2]
└── 字体统一           [Week 2]

Phase 7 (技术债清理)
├── Elite 敌人差异化   [Week 3]
├── on_entity_hit      [Week 3]
└── 测试重构           [Week 4]

Phase 8+ (内容扩展)
├── 卡牌扩展           [Ongoing]
├── 敌人扩展           [Ongoing]
├── 遗物扩展           [Ongoing]
└── 药水扩展           [Ongoing]
```

---

## 六、风险评估

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Player/Enemy 子节点依赖导致测试困难 | 中 | 后续重构为组合模式 |
| 遗物重复 ID 状态共享 | 低 | 文档化，添加警告日志 |
| 字体跨平台兼容性 | 低 | 使用系统默认字体 |

---

**规划人**: Claude Code
**规划日期**: 2026-02-19
