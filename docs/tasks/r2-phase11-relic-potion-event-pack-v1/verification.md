# 验证报告：遗物/药水/事件内容池扩容

## 任务 ID
`r2-phase11-relic-potion-event-pack-v1`

## 验证步骤

### 1. 门禁验证

**命令**：
```bash
make workflow-check TASK_ID=r2-phase11-relic-potion-event-pack-v1
```

**状态**：待执行

### 2. 手动验证（需在 Godot 编辑器中执行）

#### 测试场景 1：遗物多样性
1. 启动游戏
2. 新游戏 -> 完成战斗（奇数层奖励遗物）
3. 观察遗物是否多样化（余烬指环、燃烧之血、黄金神像、荆棘护符）

#### 测试场景 2：药水多样性
1. 完成战斗（偶数层奖励药水）
2. 观察药水是否多样化（治疗药水、铁皮药水、火焰药水）

#### 测试场景 3：事件多样性
1. 进入事件节点
2. 观察事件是否多样化（现在有15个事件）

#### 测试场景 4：Shop/Event节点奖励
1. 进入 Shop 节点 -> 获得随机遗物
2. 进入 Event 节点完成 -> 获得随机药水

### 3. 资源文件验证

验证新资源文件存在：
```bash
ls content/custom_resources/relics/*.tres
ls content/custom_resources/potions/*.tres
```

## 验证结论
待执行验证后填写。
