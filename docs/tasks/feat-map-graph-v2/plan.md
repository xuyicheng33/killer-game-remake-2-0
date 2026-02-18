# 任务规划：feat-map-graph-v2

**任务ID**: `feat-map-graph-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

将 MapGenerator 扩展为 15 层真实分支地图。

---

## 边界

**白名单**:
- `runtime/modules/map_event/map_generator.gd`
- `dev/tests/unit/test_map_generator.gd`

**不涉及**:
- UI 层改动
- 存档结构变化
- 节点类型定义

---

## 修改内容

```gdscript
# 当前
const NORMAL_FLOOR_COUNT := 5

# 修改为
const NORMAL_FLOOR_COUNT := 14  # 14层普通 + 1层Boss = 15层
```

---

## 分支规则

- 每个节点连接下一层的 1-2 个节点
- 保证从起点到 Boss 存在至少 2 条完全不同路径
- 保持有向无环图（当前实现已有）

---

## 节点类型权重

| 节点类型 | 普通层权重 | 精英层（第8层以后）权重 |
|---|---|---|
| 普通战斗 | 45% | 35% |
| 精英战斗 | 8% | 20% |
| 休息点 | 15% | 12% |
| 商店 | 5% | 5% |
| 事件 | 27% | 28% |

---

## 步骤

### Step 1: 修改 NORMAL_FLOOR_COUNT

### Step 2: 调整 `_roll_node_type` 权重，支持精英层差异化

### Step 3: 补充 GUT 测试
- `test_map_has_15_layers()`
- `test_map_has_multiple_paths_to_boss()`
- `test_same_seed_produces_same_map()`

---

## 风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 层数增加导致 UI 滚动问题 | 低 | 验证 UI 适配 |
| 种子一致性变化 | 低 | 相同种子仍产生相同地图 |

---

## 验收标准

- [ ] 地图包含 15 层
- [ ] 至少 2 条不同路径可达 Boss
- [ ] 相同种子产生相同地图
- [ ] `make test` 通过
- [ ] `make workflow-check TASK_ID=feat-map-graph-v2` 通过

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
