# Phase 7 审核提示词

请作为项目审核员，审核 Phase 7 的完成情况。以下是审核所需的全部信息。

---

## 一、项目背景

### 项目简介
- 项目名称：杀戮游戏复刻 2.0
- 技术栈：Godot 4.5.1 + GDScript
- 目标：复刻类杀戮尖塔核心体验
- 当前状态：Phase 0-6 + R2 Phase 0-11 全部完成，原型可完整游玩

### 项目规模
- 卡牌：20 张（中文）
- 敌人：4 种
- 遗物：9 个
- 药水：5 种
- 事件：5 个
- 地图：15 层
- 测试：134 个 GUT 测试

### 协作规范
关键文件：`AGENTS.md` - 定义了任务分级、模块边界、Git 规范

---

## 二、Phase 7 规划目标

### 原始规划（来自 `docs/后续开发规划v1.0.md`）

用户报告的 4 个 Bug：
1. 选卡奖励界面出现英文序号（应为中文）
2. 遗物悬停无 Tooltip 显示
3. 拖动出牌后卡牌卡在屏幕中央
4. 击杀所有敌人后不立即判定胜利

技术债修复（P1 级）：
- P1-2：死亡竞态问题
- P1-4：遗物实例化性能问题
- P1-7：营火升级逻辑不一致

性能基线：
- FPS >= 45
- GUT Orphan Reports = 0
- 内存占用 < 150MB

---

## 三、任务完成情况

### 批次 1：P1 阻断项（串行执行）

| 任务 | 描述 | 状态 | 说明 |
|------|------|------|------|
| 7-4 | 击杀敌人立即判定胜利 | ✅ | **新增代码** |
| 7-5 | 遗物触发对象缓存 | ✅ | 已在前期实现 |
| 7-6 | 营火升级逻辑统一 | ✅ | 已在前期实现 |

### 批次 2：P2 体验修复（并行执行）

| 任务 | 描述 | 状态 | 说明 |
|------|------|------|------|
| 7-1 | 奖励界面英文序号 | ✅ | 已在前期修复 |
| 7-2 | 遗物 Tooltip 不显示 | ✅ | **新增代码** |
| 7-3 | 出牌后卡牌卡屏 | ✅ | **新增代码** |

### 批次 3：性能验证

| 任务 | 描述 | 状态 | 说明 |
|------|------|------|------|
| 7-7 | 性能基线验证 | ✅ | 134/134, Orphan=0 |

---

## 四、本次新增的代码改动

### 4.1 `runtime/scenes/battle/battle.gd`

**改动目的**：修复击杀敌人后不立即判定胜利的问题

**改动内容**：
```gdscript
# _on_enemy_died() 新增：
if _battle_phase_machine != null:
    var battle_result := _battle_phase_machine.check_battle_end()
    if battle_result.ended:
        _on_battle_ended(battle_result.result)

# _on_player_died() 简化：
# 移除了等待 RESOLVE 阶段的逻辑，直接调用 _on_battle_ended("defeat")
```

### 4.2 `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`

**改动目的**：支持遗物 Tooltip 显示

**改动内容**：
- 将 `relic_list_text: String` 改为 `relic_items: Array[Dictionary]`
- 每个 item 包含 `title`, `tooltip_text`, `tooltip_icon`

### 4.3 `runtime/scenes/ui/relic_potion_ui.gd`

**改动目的**：渲染遗物按钮并连接 Tooltip 信号

**改动内容**：
- 新增 `_render_relics()` 方法
- 新增 `_on_relic_button_mouse_entered/exited()` 方法
- `relic_list_label` 类型从 `Label` 改为 `VBoxContainer`

### 4.4 `runtime/scenes/ui/relic_potion_ui.tscn`

**改动目的**：支持遗物按钮列表

**改动内容**：
- `RelicListLabel` 节点类型从 `Label` 改为 `VBoxContainer`

### 4.5 `runtime/scenes/card_ui/card_ui.gd`

**改动目的**：修复卡牌播放后卡在屏幕的问题

**改动内容**：
- `play()` 方法在所有提前返回路径上添加 `queue_free()`

### 4.6 `dev/tests/unit/test_battle_context.gd`

**改动目的**：验证战斗结束判定修复

**新增测试**：
- `test_killing_all_enemies_triggers_immediate_victory()`
- `test_player_death_triggers_immediate_defeat()`
- `test_battle_continues_when_enemies_alive()`

---

## 五、文档更新

### 5.1 `docs/后续开发规划v1.0.md` (V1.0 → V1.1)

变更内容：
- Phase 7 增加任务 7-6、7-7 和执行批次说明
- Phase 8 拆分为 8-1（BuffSystem 重构）和 8-2（遗物扩展）
- P1-3 从 Phase 12 提前至 Phase 8-1
- P1-7 从 Phase 12 提前至 Phase 7-6
- 里程碑描述更新

### 5.2 `docs/work_logs/2026-02.md`

新增 Phase 7 工作记录

---

## 六、验证结果

### GUT 测试
```
Scripts              16
Tests               134
Passing Tests       134
Asserts             806
Time              3.212s
---- All tests passed! ----
```

### 性能基线
```
- Tests Passed: 134/134
- GUT Orphan Reports: 0
- Exit Code: 0
```

---

## 七、审核清单

请按以下清单进行审核：

### 7.1 代码质量
- [ ] 改动文件是否在白名单内
- [ ] 代码是否符合项目命名规范
- [ ] 是否有未使用的代码或注释
- [ ] 信号连接/断开是否成对

### 7.2 功能正确性
- [ ] 敌人死亡后是否立即检查战斗结束
- [ ] 玩家死亡后是否立即失败
- [ ] 遗物悬停是否显示 Tooltip
- [ ] 卡牌播放失败是否正确移除 UI

### 7.3 测试覆盖
- [ ] 新增测试是否通过
- [ ] 是否有回归测试失败
- [ ] 测试命名是否清晰

### 7.4 文档完整性
- [ ] 任务三件套是否完整
- [ ] 工作日志是否更新
- [ ] 规划文档版本是否更新

### 7.5 架构符合度
- [ ] 是否违反模块边界（见 `docs/module_architecture.md`）
- [ ] 是否违反依赖方向
- [ ] 是否引入新的技术债

---

## 八、关键文件路径

| 类别 | 路径 |
|------|------|
| 协作规范 | `AGENTS.md` |
| 规划文档 | `docs/后续开发规划v1.0.md` |
| 模块架构 | `docs/module_architecture.md` |
| 工作日志 | `docs/work_logs/2026-02.md` |
| 任务目录 | `docs/tasks/fix-*-v1/` |
| 测试入口 | `dev/tests/` |

---

## 九、审核输出格式

请按以下格式输出审核结果：

```
## 审核结论：通过 / 不通过

### 发现问题
| 级别 | 文件 | 行号 | 问题描述 |
|------|------|------|----------|
| Critical/High/Medium/Low | ... | ... | ... |

### 验证结果
- [ ] make test 通过
- [ ] 代码质量检查通过
- [ ] 功能验证通过

### 建议提交信息
```
<commit message>
```

### 下一步建议
- ...
```

---

**审核员请开始审核！**
