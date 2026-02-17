# 验证报告：第二角色骨架

## 任务 ID
`r2-phase09-character2-scaffold-v1`

## 验证步骤

### 1. 门禁验证

**命令**：
```bash
make workflow-check TASK_ID=r2-phase09-character2-scaffold-v1
```

**状态**：待执行

### 2. 手动验证（需在 Godot 编辑器中执行）

#### 测试场景 1：默认角色（warrior）
1. 启动游戏
2. 新游戏 -> 战斗 -> 奖励 -> 地图
3. 验证角色属性：max_health=35, max_mana=3, cards_per_turn=4

#### 测试场景 2：切换角色（mage）
1. 设置环境变量 `SELECTED_CHARACTER_ID=mage`
2. 启动游戏
3. 新游戏 -> 验证角色属性：max_health=30, max_mana=4, cards_per_turn=5

#### 测试场景 3：存档兼容
1. 使用 mage 角色进行游戏
2. 进入战斗后退出
3. 重新启动游戏（不设置环境变量）
4. 继续游戏 -> 验证角色恢复为 mage（character_id 正确保存）

### 3. 存档文件检查

验证存档 JSON 包含 `character_id` 字段：
```json
{
  "save_version": 3,
  "character_id": "mage",
  "seed": ...,
  ...
}
```

## 验证结论
待执行验证后填写。
