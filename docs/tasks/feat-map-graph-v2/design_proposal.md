# 设计提案：feat-map-graph-v2

**任务ID**: `feat-map-graph-v2`
**提案日期**: 2026-02-18

---

## 目标效果

将 MapGenerator 扩展为 15 层真实分支地图：
1. 修改 NORMAL_FLOOR_COUNT 为 14（14普通+1Boss=15层）
2. 调整节点类型权重，支持精英层差异化
3. 验证至少存在 2 条完全不同的路径

---

## 非目标（不做什么）

- 不修改节点类型定义
- 不修改地图 UI 显示逻辑
- 不修改存档结构
- 不引入新的节点类型

---

## 方案 A（推荐）

### 常量修改

```gdscript
const NORMAL_FLOOR_COUNT := 14  # 14层普通 + 1层Boss = 15层
```

### 权重调整

```gdscript
static func _roll_node_type(rng: RandomNumberGenerator, floor_index: int) -> MapNodeData.NodeType:
    var roll := rng.randf()
    var is_elite_floor := floor_index >= 7  # 第8层起为精英层
    
    if is_elite_floor:
        if roll < 0.35: return MapNodeData.NodeType.BATTLE      # 35%
        if roll < 0.55: return MapNodeData.NodeType.ELITE       # 20%
        if roll < 0.67: return MapNodeData.NodeType.REST        # 12%
        if roll < 0.72: return MapNodeData.NodeType.SHOP        # 5%
        return MapNodeData.NodeType.EVENT                       # 28%
    else:
        if roll < 0.45: return MapNodeData.NodeType.BATTLE      # 45%
        if roll < 0.53: return MapNodeData.NodeType.ELITE       # 8%
        if roll < 0.68: return MapNodeData.NodeType.REST        # 15%
        if roll < 0.73: return MapNodeData.NodeType.SHOP        # 5%
        return MapNodeData.NodeType.EVENT                       # 27%
```

---

## 方案 B（备选）

保持当前权重不变，仅增加层数。

**权衡**:
- 方案 A 优点：精英层体验更丰富，符合 master_plan 要求
- 方案 B 优点：改动最小

**选择方案 A 原因**: 符合 master_plan_v3.md 第 597-607 行的权重要求。

---

## 对现有逻辑的影响

| 影响项 | 说明 |
|---|---|---|
| 地图生成 | 层数增加，路径数增加 |
| 存档 | 无影响（floor_index 已支持任意值） |
| UI 显示 | 需要验证滚动/缩放是否正常 |

---

## 对存档的影响

无影响。存档仅记录 `map_current_node_id`，不存储完整地图结构（地图由种子重新生成）。

---

## 对种子一致性的影响

**有影响**。相同种子将生成 15 层而非 6 层地图。但这是预期行为，种子一致性在扩展后仍然保持（相同种子→相同15层地图）。

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|---|
| `test_map_has_15_layers()` | 地图包含 15 层 |
| `test_map_has_multiple_paths_to_boss()` | 至少 2 条不同路径 |
| `test_same_seed_produces_same_map()` | 相同种子地图一致 |
| `test_elite_floor_has_more_elites()` | 精英层精英节点比例更高 |

---

## 请求批准

请确认是否批准此设计方案，以便进入编码阶段。
