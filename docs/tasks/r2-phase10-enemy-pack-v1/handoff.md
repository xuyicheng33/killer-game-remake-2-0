# 任务交接：敌人包扩容

## 任务 ID
`r2-phase10-enemy-pack-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `runtime/modules/enemy_intent/enemy_registry.gd` - 敌人资源注册表
- `runtime/modules/enemy_intent/encounter_registry.gd` - 遭遇数据加载与选择
- `docs/tasks/r2-phase10-enemy-pack-v1/plan.md`
- `docs/tasks/r2-phase10-enemy-pack-v1/handoff.md`
- `docs/tasks/r2-phase10-enemy-pack-v1/verification.md`

### 修改文件
- `runtime/scenes/battle/battle.tscn` - 移除硬编码敌人，EnemyHandler 初始为空
- `runtime/scenes/battle/battle.gd` - 新增 `_spawn_enemies()` 动态生成敌人
- `runtime/modules/run_flow/map_flow_service.gd` - 集成遭遇选择，传递 encounter_id
- `runtime/scenes/app/app.gd` - `_open_battle()` 接收并传递 encounter_id
- `runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json` - 扩容遭遇数据

## 系统设计

### 遭遇选择流程
```
[map_flow_service.enter_map_node()]
    |
    +--> EncounterRegistry.pick_encounter(floor, tags)
    |     根据楼层范围和标签筛选，加权随机选择
    |
    v
[route_dispatcher.make_result()]
    payload.encounter_id 传入
    |
    v
[app.gd _open_battle(encounter_id)]
    |
    v
[battle.gd _spawn_enemies()]
    根据 encounter_id 获取 enemy_ids
    动态实例化敌人场景
```

### 遭遇数据结构
```json
{
  "id": "act1_mixed",
  "enemies": ["crab", "bat"],
  "weight": 3,
  "tags": ["common"],
  "floor_range": {"min": 2, "max": 8}
}
```

### 扩容内容
新增遭遇：
- act1_bat_single - 单蝙蝠
- act1_crab_pair - 双小蟹
- act1_triple_bat - 三蝙蝠
- act1_crab_bat_crab - 小蟹-蝙蝠-小蟹

## 验证结果
- 自动验证：已完成（遭遇接线、战斗动态生成、battle.tscn 去硬编码检查通过）
- 手动验证：待在 Godot 编辑器中执行楼层分布与战斗流程实测

## 提交信息
```
feat(enemy_intent): 敌人包扩容与数据驱动遭遇（r2-phase10-enemy-pack-v1）
```
