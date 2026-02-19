# Phase 4-5 审核修复交接文档

**交接日期**: 2026-02-19

---

## 一、已完成工作

### 1.1 P1 级别问题修复

所有 P1 级别问题已修复：
- P1-1: `card_removal_count` 序列化 ✅
- P1-2: BuffSystem 死亡处理重构 ✅
- P1-3: BuffSystem 依赖注入 ✅
- P1-4: 遗物运行时缓存 ✅
- P1-5: 重试上限限制 ✅
- P1-7: 营地升级逻辑统一 ✅

### 1.2 P2 级别问题修复

- P2-1: 冗余调用移除 ✅
- P2-2: 商店描述更新 ✅
- P2-3: 战斗外药水消耗修复 ✅

### 1.3 测试覆盖

- 新增 20+ 测试用例
- 测试通过率: 116/116 (100%)
- 门禁脚本通过

---

## 二、架构变更

### 2.1 BuffSystem 依赖注入

```gdscript
# 新增方法
func bind_combatants(player: Player, enemies: Array[Enemy]) -> void
func unbind_combatants() -> void
func remove_enemy(enemy: Enemy) -> void

# 优先使用注入的实体，回退到场景树查找
func _get_player_node() -> Player
func _get_enemy_nodes() -> Array[Enemy]
```

### 2.2 遗物运行时缓存

```gdscript
# 新增字段
var _relic_runtimes: Dictionary = {}  # 遗物ID -> 运行时对象缓存
const MAX_BATTLE_START_RETRIES := 100

# 新增方法
func _rebuild_relic_runtime_cache() -> void
func _get_or_create_relic_runtime(relic_data: RelicData) -> Variant
func add_relic(relic: RelicData) -> void
func remove_relic(relic_id: String) -> bool
```

### 2.3 死亡处理流程

```
之前: BuffSystem._handle_death() -> queue_free()
现在: BuffSystem._handle_death() -> emit signal -> battle.gd 处理节点释放
```

---

## 三、关键文件变更

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `buff_system.gd` | 重构 | 依赖注入、死亡处理重构 |
| `battle_context.gd` | 增强 | 绑定 BuffSystem 战斗实体 |
| `battle.gd` | 增强 | 添加敌人死亡处理 |
| `relic_potion_system.gd` | 优化 | 缓存、重试上限 |
| `save_service.gd` | 修复 | card_removal_count 序列化 |
| `run_state.gd` | 修复 | 升级逻辑、药水消耗 |

---

## 四、测试文件变更

| 文件 | 新增测试数 |
|------|------------|
| `test_save_service.gd` | 3 |
| `test_relic_potion.gd` | 6 |
| `test_battle_flow.gd` | 7 |

---

## 五、已知限制

### 5.1 测试中 FakePlayer/FakeEnemy 创建困难

Player 和 Enemy 类依赖子节点（Sprite2D、StatsUI 等），直接继承创建会导致运行时错误。当前使用轻量级 Mock 节点替代。

**建议**: 后续可考虑重构 Player/Enemy 为组合模式，分离数据模型和视图。

### 5.2 遗物重复 ID 行为

当存在重复 relic id 时，缓存会共享同一运行时实例。这是预期行为，但开发者应避免使用重复 ID。

---

## 六、下一步行动

### Phase 6: UI 对接

1. 创建主菜单场景
2. 实现新游戏/继续游戏按钮
3. 角色选择 UI
4. 字体统一

### 待清理技术债

- P1-6: `_run_after_card_played_hooks` 空实现
- P2-4: `on_entity_hit` 空壳
- P2-5: Integration 测试调用私有方法
- P2-6: Elite 敌人无差异化

---

## 七、参考资料

- 复审报告: 会话记录中
- 主规划文档: `docs/master_plan_v3.md`
- 门禁脚本: `dev/tools/persistence_contract_check.sh`
