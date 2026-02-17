# 任务规划：遗物/药水/事件内容池扩容

## 任务 ID
`r2-phase11-relic-potion-event-pack-v1`

## 等级
L2（需审批）

## 目标
扩充遗物/药水/事件内容池并保持可回归，接入随机选择机制。

## 现状分析

### 遗物系统
- **数据定义**: `relic_data.gd` - id, title, description, 4种效果
- **资源文件**: 仅 `ember_ring.tres` 一个
- **奖励来源**: `reward_generator.gd` 硬编码 `SAMPLE_RELIC`
- **JSON 数据**: `common_relics.json` 有 5 个遗物定义，但未集成

### 药水系统
- **数据定义**: `potion_data.gd` - HEAL/GOLD/BLOCK 三种效果
- **资源文件**: `healing_potion.tres`, `iron_skin_potion.tres`
- **奖励来源**: `reward_generator.gd` 硬编码 `SAMPLE_POTION`, `SAMPLE_POTION_ALT`
- **JSON 数据**: 无 schema 和数据文件

### 事件系统
- **数据定义**: `event_catalog.gd` 中硬编码 10 个事件
- **JSON 数据**: `baseline_events.json` 有 5 个事件，但未集成
- **选择机制**: `event_service.pick_event_template()` 随机选择

## 技术方案

### 1. 遗物池注册表
新增 `runtime/modules/relic_potion/relic_catalog.gd`:
- 从 .tres 资源加载遗物池
- 支持按稀有度筛选
- 随机选择接口

### 2. 药水池注册表
新增 `runtime/modules/relic_potion/potion_catalog.gd`:
- 从 .tres 资源加载药水池
- 随机选择接口

### 3. 扩充资源文件
新增遗物 .tres 文件（对应 JSON 中的定义）:
- `burning_blood.tres` - 战士初始遗物
- `golden_idol.tres` - 打牌获得金币
- `thorns_potion.tres` - 反伤格挡

新增药水 .tres 文件:
- `fire_potion.tres` - 造成伤害

### 4. 奖励系统集成
修改 `reward_generator.gd`:
- 使用 Catalog 替代硬编码常量
- 随机选择遗物/药水

### 5. 事件池扩容
扩容 `event_catalog.gd`:
- 新增更多事件模板
- 支持 JSON 数据加载（可选）

### 6. 日志与回归
为关键触发链补充日志:
- 遗物获得日志
- 药水使用日志
- 事件效果日志

## 白名单文件
- runtime/modules/relic_potion/relic_catalog.gd
- runtime/modules/relic_potion/potion_catalog.gd
- runtime/modules/reward_economy/reward_generator.gd
- runtime/modules/run_flow/map_flow_service.gd
- runtime/modules/map_event/event_catalog.gd
- content/custom_resources/relics/
- content/custom_resources/potions/
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase11-relic-potion-event-pack-v1/

## 验证步骤
1. 战斗奖励 -> 遗物/药水多样化（手动验证）
2. 事件节点 -> 不同事件（手动验证）
3. `make workflow-check TASK_ID=r2-phase11-relic-potion-event-pack-v1`

## 提交信息格式
```
feat(relic_potion): 遗物/药水/事件内容池扩容（r2-phase11-relic-potion-event-pack-v1）
```

---

**请回复"批准"以继续执行此 L2 任务。**
