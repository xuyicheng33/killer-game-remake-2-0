# 设计复核：feat-map-graph-v2

**任务ID**: `feat-map-graph-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/map_event/map_generator.gd`

**关键函数**:
- `create_act1_seed_graph(seed: int)` → 生成地图图结构
- `_roll_node_type(rng: RandomNumberGenerator, floor_index: int)` → 掷骰节点类型
- `_create_node(...)` → 创建节点

---

## 当前数据结构

```gdscript
const NORMAL_FLOOR_COUNT := 5
const LANE_COUNT := 3

# 节点连接规则
for floor_index in range(NORMAL_FLOOR_COUNT - 1):
    # 当前层连接下一层
    # 随机左右分支
```

---

## 当前限制

1. **层数不足**: 当前仅 6 层（5普通+1Boss），需要扩展为 15 层
2. **节点权重固定**: 无精英层差异化
3. **分支规则简单**: 当前分支规则需要验证是否满足"至少2条完全不同路径"

---

## 复用点

1. `create_act1_seed_graph()` 的图生成算法可复用
2. `_roll_node_type()` 的节点类型掷骰逻辑可复用
3. RunRng 的种子机制可复用

---

## 风险点

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 15层路径过多导致复杂度上升 | 低 | 保持 3 lane 结构 |
| 精英层权重变化影响平衡 | 中 | 按计划调整权重 |
| 存档兼容性 | 中 | 确认存档字段无需变更 |

---

## 结论

MapGenerator 结构清晰，需要：
1. 修改 NORMAL_FLOOR_COUNT 为 14
2. 调整 `_roll_node_type()` 支持精英层权重
3. 补充 GUT 测试验证路径可达性
