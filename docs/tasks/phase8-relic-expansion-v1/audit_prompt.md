# Phase 8 审核提示词

请作为项目审核员，审核 Phase 8（遗物扩展）的完成情况。以下是审核所需的全部信息。

---

## 一、项目背景

### 1.1 项目简介
- **项目名称**：杀戮游戏复刻 2.0
- **技术栈**：Godot 4.5.1 + GDScript
- **目标**：复刻类杀戮尖塔核心体验
- **当前状态**：Phase 0-7 全部完成，原型可完整游玩

### 1.2 项目规模（Phase 8 前）
- 卡牌：20 张（中文）
- 敌人：4 种
- 遗物：8 个 → **Phase 8 后：14 个**
- 药水：5 种
- 事件：5 个
- 地图：15 层
- 测试：139 个 GUT 测试 → **Phase 8 后：142 个**

### 1.3 协作规范
- 关键文件：`AGENTS.md` - 定义任务分级、模块边界、Git 规范
- 模块边界：`docs/module_architecture.md`

---

## 二、Phase 8 规划目标

### 2.1 原始规划来源
`docs/后续开发规划v1.0.md` 第五节（Phase 8：BuffSystem 重构 + 遗物扩展）

### 2.2 规划任务

| 任务 ID | 任务描述 | 优先级 |
|---------|----------|--------|
| 8-0 | 遗物 Tooltip 修复 | P1 |
| 8-1 | BuffSystem 移除 fallback 逻辑 | P2 |
| 8-2 | 遗物系统扩展（新字段 + 新效果） | P1 |
| 8-3 | 6 个新遗物数据文件 | P2 |
| 8-4 | 测试与验收 | P1 |

### 2.3 6 个新遗物设计（已与用户确认）

| 遗物名 | 稀有度 | 效果 | 实现方式 |
|--------|--------|------|----------|
| 铁壁遗章 | 普通 | 回合开始 +3 格挡 | 数据驱动（简化：非首次格挡） |
| 贪婪护符 | 罕见 | 回合开始 -1HP +1 能量 | 数据驱动 |
| 殉道者之心 | 罕见 | 击杀敌人 -5HP 抽 2 张牌 | 数据驱动 |
| 能量水晶 | 稀有 | 回合开始 +1 能量 | 数据驱动 |
| 灵魂捕获器 | 罕见 | 击杀敌人 +1 力量 | 数据驱动 |
| 生命汲取 | 普通 | 战斗结束按击杀数×2 回血 | 数据驱动 |

---

## 三、实际实现内容

### 3.1 8-0：遗物 Tooltip 修复

**问题**：遗物悬停只显示名称，不显示描述

**实现**：
- 修改 `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`
- 简化 BBCode 格式，移除 `[center]` 标签
- 新格式：`"%s\n\n%s" % [title, description]`

### 3.2 8-1：BuffSystem 移除 fallback

**问题**：BuffSystem 保留场景树查找作为 fallback，违反依赖注入原则

**实现**：
- 修改 `runtime/modules/buff_system/buff_system.gd`
- 删除 `_get_player_node()` 和 `_get_enemy_nodes()` 中的 fallback 逻辑
- 删除 `_get_tree()` 方法
- 现在仅通过 `bind_combatants()` 注入的实体工作

### 3.3 8-2：遗物系统扩展

**新增 RelicData 字段**（`content/custom_resources/relics/relic_data.gd`）：

```gdscript
@export var on_turn_start_energy: int = 0
@export var on_turn_start_damage: int = 0
@export var on_enemy_killed_strength: int = 0
@export var on_enemy_killed_damage: int = 0
@export var on_enemy_killed_draw: int = 0
@export var on_battle_end_heal_per_kill: int = 0
```

**新增触发器**（`runtime/modules/relic_potion/relic_potion_system.gd`）：
- `TriggerType.ON_BATTLE_END`
- 在 `end_battle()` 中触发，context 包含 `kills` 字段

**新增效果类型**（`_apply_relic_effect`）：
| 效果 | 实现 |
|------|------|
| add_energy | `char_stats.mana = mini(mana + value, max_mana)` |
| take_damage | `player_stats.take_damage(value)` |
| add_strength | `player_stats.add_status("strength", value)` |
| draw_cards | 简化实现：从 draw_pile 移动到 discard |

**修改文件清单**：
- `runtime/modules/relic_potion/relic_potion_system.gd` - 触发器 + 效果
- `runtime/modules/relic_potion/relic_base.gd` - 常量 + handle_trigger
- `runtime/modules/relic_potion/data_driven_relic.gd` - 效果处理
- `runtime/modules/relic_potion/relic_catalog.gd` - JSON 解析
- `runtime/modules/persistence/save_service.gd` - 序列化/反序列化

### 3.4 8-3：6 个新遗物

**创建的文件**：
```
content/custom_resources/relics/iron_wall.tres
content/custom_resources/relics/greedy_amulet.tres
content/custom_resources/relics/martyr_heart.tres
content/custom_resources/relics/energy_crystal.tres
content/custom_resources/relics/soul_catcher.tres
content/custom_resources/relics/life_drain.tres
```

**更新的内容管线**：
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json`

### 3.5 8-4：测试

**新增 GUT 测试**（`dev/tests/unit/test_relic_potion.gd`）：
- `test_new_relic_fields_exist()` - 验证新字段可读写
- `test_save_service_serializes_new_relic_fields()` - 验证序列化
- `test_save_service_deserializes_new_relic_fields()` - 验证反序列化

---

## 四、审核要点

### 4.1 代码质量审核

请检查以下文件：

1. **BuffSystem 清理**
   - 文件：`runtime/modules/buff_system/buff_system.gd`
   - 确认无 `get_tree().get_nodes_in_group()` 调用
   - 确认 `_get_player_node()` 仅检查 `_player` 成员

2. **遗物系统扩展**
   - 文件：`runtime/modules/relic_potion/relic_potion_system.gd`
   - 检查 `end_battle()` 正确触发 `ON_BATTLE_END`
   - 检查 `_apply_relic_effect()` 新增效果实现正确

3. **数据模型**
   - 文件：`content/custom_resources/relics/relic_data.gd`
   - 确认 6 个新字段已添加

4. **持久化**
   - 文件：`runtime/modules/persistence/save_service.gd`
   - 检查 `_serialize_relics()` 和 `_deserialize_relics()` 包含新字段

### 4.2 功能验收

运行以下命令：

```bash
# 运行全部测试
make test

# 预期：142/142 通过

# 内存基线
bash dev/tools/memory_baseline.sh

# 预期：GUT Orphan Reports = 0
```

### 4.3 新遗物数据审核

检查以下遗物的 JSON 定义是否正确：

```bash
# 查看新遗物定义
grep -A 20 '"id": "iron_wall"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
grep -A 20 '"id": "greedy_amulet"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
grep -A 20 '"id": "martyr_heart"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
grep -A 20 '"id": "energy_crystal"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
grep -A 20 '"id": "soul_catcher"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
grep -A 20 '"id": "life_drain"' runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
```

### 4.4 边界条件检查

1. **draw_cards 效果**
   - 当前是简化实现（移动到 discard 而非 hand）
   - 这是已知的技术债，可接受

2. **空列表保护**
   - `_get_enemy_nodes()` 返回空数组时应安全
   - `on_battle_end` 在 `kills=0` 时不应触发回血

---

## 五、验收清单

### 5.1 自动化验收

- [ ] `make test` 142/142 通过
- [ ] GUT Orphan Reports = 0
- [ ] 无新增 Godot 警告

### 5.2 代码审核

- [ ] BuffSystem 无场景树查找
- [ ] 遗物系统新字段已添加到所有相关文件
- [ ] 持久化正确处理新字段
- [ ] 新遗物 JSON 数据格式正确

### 5.3 设计一致性

- [ ] 6 个新遗物与用户确认的设计一致
- [ ] 铁壁遗章简化为"回合开始+3格挡"（非首次格挡）
- [ ] 无跨战斗持久化遗物（已延后到 Phase 11）

---

## 六、关键文件路径

| 类别 | 文件路径 |
|------|----------|
| 遗物数据模型 | `content/custom_resources/relics/relic_data.gd` |
| 遗物系统 | `runtime/modules/relic_potion/relic_potion_system.gd` |
| 遗物基类 | `runtime/modules/relic_potion/relic_base.gd` |
| 数据驱动遗物 | `runtime/modules/relic_potion/data_driven_relic.gd` |
| 遗物目录 | `runtime/modules/relic_potion/relic_catalog.gd` |
| BuffSystem | `runtime/modules/buff_system/buff_system.gd` |
| 存档服务 | `runtime/modules/persistence/save_service.gd` |
| 新遗物 JSON | `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json` |
| 遗物测试 | `dev/tests/unit/test_relic_potion.gd` |

---

## 七、任务三件套

已创建：
- `docs/tasks/phase8-relic-expansion-v1/plan.md`
- `docs/tasks/phase8-relic-expansion-v1/handoff.md`
- `docs/tasks/phase8-relic-expansion-v1/verification.md`

---

## 八、审核结论格式

请按以下格式输出审核结论：

```
## Phase 8 审核结论

### 自动化测试
- 测试结果：X/X
- Orphan Reports：X

### 代码质量
- BuffSystem 清理：✅/❌ + 说明
- 遗物系统扩展：✅/❌ + 说明
- 持久化：✅/❌ + 说明

### 功能完整性
- 6 个新遗物：✅/❌
- 效果触发：✅/❌

### 风险项
- 列出发现的问题或技术债

### 总体评估
- ✅ 通过 / ❌ 需修复

### 建议的后续行动
- 列出建议
```

---

**文档版本**：v1.0
**创建日期**：2026-02-20
**任务 ID**：phase8-relic-expansion-v1
