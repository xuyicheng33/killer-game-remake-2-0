# 交接文档：feat-map-graph-v2

**任务ID**: `feat-map-graph-v2`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/map_event/map_generator.gd` | 修改 | 15层 + 精英层权重 |
| `dev/tests/unit/test_map_generator.gd` | 修改 | 新增 9 个测试用例 |

---

## 关键改动

### 层数扩展

```gdscript
const NORMAL_FLOOR_COUNT := 14  # 14层普通 + 1层Boss = 15层
const ELITE_FLOOR_START := 7    # 第8层起为精英层
```

### 精英层权重

| 节点类型 | 普通层 | 精英层 |
|---|---|---|
| 普通战斗 | 45% | 35% |
| 精英战斗 | 5% | 20% |
| 休息点 | 15% | 12% |
| 商店 | 8% | 5% |
| 事件 | 27% | 28% |

---

## 已知问题

无

---

## 建议 commit message

```
feat(map_generator): expand to 15 floors with elite weights (feat-map-graph-v2)

- Increase NORMAL_FLOOR_COUNT to 14
- Add ELITE_FLOOR_START constant
- Adjust node type weights for elite floors
```
