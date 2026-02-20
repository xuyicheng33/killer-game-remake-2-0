# Handoff: phase8-relic-expansion-v1

## 交付摘要

Phase 8 完成，实现了遗物系统扩展和代码清理：

1. **8-0 遗物 Tooltip 修复**：简化 BBCode 格式，移除 `[center]` 标签
2. **8-1 BuffSystem 清理**：移除场景树查找 fallback，仅保留依赖注入
3. **8-2 遗物系统扩展**：新增 6 个字段、ON_BATTLE_END 触发器、4 种新效果
4. **8-3 新遗物创建**：6 个数据驱动遗物
5. **8-4 测试覆盖**：新增 3 个 GUT 测试

## 改动文件

### 核心系统
- `runtime/modules/buff_system/buff_system.gd` - 移除 fallback 逻辑
- `runtime/modules/relic_potion/relic_potion_system.gd` - 新增 ON_BATTLE_END 触发器和新效果
- `runtime/modules/relic_potion/relic_base.gd` - 新增 TRIGGER_ON_BATTLE_END 常量
- `runtime/modules/relic_potion/data_driven_relic.gd` - 新增效果处理
- `runtime/modules/relic_potion/relic_catalog.gd` - 支持新字段解析

### 数据模型
- `content/custom_resources/relics/relic_data.gd` - 新增 6 个字段

### 持久化
- `runtime/modules/persistence/save_service.gd` - 序列化/反序列化新字段

### UI
- `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd` - 简化 tooltip 格式

### 新遗物数据
- `content/custom_resources/relics/iron_wall.tres` - 铁壁遗章
- `content/custom_resources/relics/greedy_amulet.tres` - 贪婪护符
- `content/custom_resources/relics/martyr_heart.tres` - 殉道者之心
- `content/custom_resources/relics/energy_crystal.tres` - 能量水晶
- `content/custom_resources/relics/soul_catcher.tres` - 灵魂捕获器
- `content/custom_resources/relics/life_drain.tres` - 生命汲取

### 内容管线
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json` - 新增 6 个遗物定义

### 测试
- `dev/tests/unit/test_relic_potion.gd` - 新增 3 个测试

## 新增字段

| 字段 | 类型 | 说明 |
|------|------|------|
| on_turn_start_energy | int | 回合开始获得能量 |
| on_turn_start_damage | int | 回合开始受到伤害 |
| on_enemy_killed_strength | int | 击杀获得力量 |
| on_enemy_killed_damage | int | 击杀受到伤害 |
| on_enemy_killed_draw | int | 击杀抽牌 |
| on_battle_end_heal_per_kill | int | 战斗结束按击杀数回血 |

## 新增效果类型

| 效果 | 说明 |
|------|------|
| add_energy | 增加玩家能量 |
| take_damage | 玩家受到伤害 |
| add_strength | 增加玩家力量状态 |
| draw_cards | 玩家抽牌（简化实现）|

## 验收结果

- [x] `make test` 142/142 通过
- [x] GUT Orphan Reports = 0
- [x] 内存基线正常

## 建议提交信息

`feat(relic): expand relic system with 6 new relics and new effects（phase8-relic-expansion-v1）`
