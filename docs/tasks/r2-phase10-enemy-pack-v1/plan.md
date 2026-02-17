# 任务规划：敌人包扩容

## 任务 ID
`r2-phase10-enemy-pack-v1`

## 等级
L2（需审批）

## 目标
敌人包扩容并移除 battle 固定敌人硬编码，实现数据驱动遭遇选择。

## 现状分析

### 当前问题
- `battle.tscn` 中硬编码了 3 个敌人（BatEnemy, CrabEnemy, BatEnemy2）
- 没有遭遇选择逻辑
- 所有战斗都是相同敌人配置

### 现有资产
- 敌人资源：`content/enemies/crab/crab_enemy.tres`, `content/enemies/bat/bat_enemy.tres`
- 敌人场景模板：`runtime/scenes/enemy/enemy.tscn`
- 遭遇数据：`runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json`

## 技术方案

### 1. 遭遇注册表
新增 `runtime/modules/enemy_intent/encounter_registry.gd`：
- 加载遭遇配置 JSON
- 根据 floor_range 和 tags 筛选遭遇
- 加权随机选择

### 2. 敌人注册表
新增 `runtime/modules/enemy_intent/enemy_registry.gd`：
- 加载敌人配置
- 根据 enemy_id 查找 EnemyStats 资源路径

### 3. 战斗场景改造
修改 `battle.tscn` 和 `battle.gd`：
- EnemyHandler 初始为空
- 新增 `encounter_id` 导出变量
- `start_battle` 时根据 encounter_id 动态生成敌人

### 4. 流程集成
修改 `map_flow_service.gd`：
- `enter_map_node` 时选择遭遇
- 将 `encounter_id` 传入路由 payload

### 5. 扩展敌人数据
扩容 `act1_enemies.json`：
- 新增精英遭遇
- 增加更多普通遭遇组合

## 白名单文件
- runtime/modules/enemy_intent/encounter_registry.gd
- runtime/modules/enemy_intent/enemy_registry.gd
- runtime/modules/run_flow/map_flow_service.gd
- runtime/scenes/battle/battle.tscn
- runtime/scenes/battle/battle.gd
- runtime/scenes/app/app.gd
- runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase10-enemy-pack-v1/

## 验证步骤
1. 地图普通节点 -> 不同敌组（手动验证）
2. 战斗流程正常（手动验证）
3. `make workflow-check TASK_ID=r2-phase10-enemy-pack-v1`

## 提交信息格式
```
feat(enemy_intent): 敌人包扩容与数据驱动遭遇（r2-phase10-enemy-pack-v1）
```

---

**请回复"批准"以继续执行此 L2 任务。**
