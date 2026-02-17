# 任务规划：第二角色骨架

## 任务 ID
`r2-phase09-character2-scaffold-v1`

## 等级
L2（需审批）

## 目标
第二角色可运行骨架（无美术依赖），支持开局选择、独立牌组、存档兼容。

## 现状分析

### 当前角色系统
- 角色定义：`content/characters/warrior/warrior.tres`
- 起始牌组：`content/characters/warrior/warrior_starting_deck.tres`
- 角色选择：**无**，`app.gd` 硬编码 `HERO_TEMPLATE = preload("warrior.tres")`
- 存档系统：**不保存 character_id**，读档时需要传入 base_stats 参数

### 存档版本
当前 SAVE_VERSION = 2，MIN_COMPAT_VERSION = 1

## 技术方案

### 1. 新角色资源（mage/法师）
- `content/characters/mage/mage.tres` - 复用战士美术占位
- `content/characters/mage/mage_starting_deck.tres` - 复用战士起始牌组
- 属性差异：max_health=30, max_mana=4, cards_per_turn=5

### 2. 角色注册表
- 新增 `runtime/modules/run_meta/character_registry.gd`
- 通过 character_id 查找角色模板
- 支持 fallback 到 warrior

### 3. character_id 存档支持
- RunState 新增 `character_id: String` 字段
- save_service 序列化/反序列化 character_id
- 升级 SAVE_VERSION 到 3
- 旧存档默认 character_id = "warrior"

### 4. 环境变量角色选择
- 通过 `SELECTED_CHARACTER_ID` 环境变量或配置选择角色
- 默认为 "warrior"
- 适合开发期快速切换

## 白名单文件
- content/characters/mage/
- runtime/modules/run_meta/character_registry.gd
- runtime/modules/run_meta/run_state.gd
- runtime/modules/persistence/save_service.gd
- runtime/modules/run_flow/run_lifecycle_service.gd
- runtime/scenes/app/app.gd
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase09-character2-scaffold-v1/
- docs/contracts/run_state.md

## 验证步骤
1. 环境变量设置 `SELECTED_CHARACTER_ID=mage` 后启动游戏
2. 新游戏 -> 战斗 -> 奖励 -> 地图（手动验证）
3. 存档退出 -> 继续游戏（验证角色恢复正确）
4. `make workflow-check TASK_ID=r2-phase09-character2-scaffold-v1`

## 提交信息格式
```
feat(run_meta): 第二角色骨架（r2-phase09-character2-scaffold-v1）
```

---

**请回复"批准"以继续执行此 L2 任务。**
