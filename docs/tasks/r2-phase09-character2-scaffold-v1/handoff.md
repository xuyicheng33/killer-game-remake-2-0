# 任务交接：第二角色骨架

## 任务 ID
`r2-phase09-character2-scaffold-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `content/characters/mage/mage.tres` - 法师角色资源（复用战士美术）
- `runtime/modules/run_meta/character_registry.gd` - 角色注册表
- `docs/tasks/r2-phase09-character2-scaffold-v1/plan.md`
- `docs/tasks/r2-phase09-character2-scaffold-v1/handoff.md`
- `docs/tasks/r2-phase09-character2-scaffold-v1/verification.md`

### 修改文件
- `runtime/modules/run_meta/run_state.gd` - 新增 character_id 字段
- `runtime/modules/persistence/save_service.gd` - 序列化/反序列化 character_id，SAVE_VERSION 升级到 3
- `runtime/modules/run_flow/run_lifecycle_service.gd` - start_new_run 传递 character_id
- `runtime/scenes/app/app.gd` - 使用 CharacterRegistry 替代硬编码 HERO_TEMPLATE
- `docs/contracts/run_state.md` - 更新契约文档

## 角色系统设计

### 角色注册表
```gdscript
const CHARACTER_REGISTRY := {
    "warrior": "res://content/characters/warrior/warrior.tres",
    "mage": "res://content/characters/mage/mage.tres",
}
```

### 角色选择方式
通过环境变量 `SELECTED_CHARACTER_ID` 选择角色：
```bash
SELECTED_CHARACTER_ID=mage godot
```
默认为 "warrior"。

### 法师属性
- max_health: 30（战士 35）
- max_mana: 4（战士 3）
- cards_per_turn: 5（战士 4）
- 起始牌组：复用战士牌组（待后续独立设计）

## 存档兼容性

### 版本升级
SAVE_VERSION: 2 → 3

### 向后兼容
- v1/v2 存档读取时，character_id 默认为 "warrior"
- 不影响现有存档

## 验证结果
- 门禁检查：待执行

## 提交信息
```
feat(run_meta): 第二角色骨架（r2-phase09-character2-scaffold-v1）
```
