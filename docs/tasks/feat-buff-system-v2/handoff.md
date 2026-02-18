# 交接文档：feat-buff-system-v2

**任务ID**: `feat-buff-system-v2`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/buff_system/buff_system.gd` | 修改 | 扩展为10种状态 |
| `dev/tests/unit/test_buff_system.gd` | 修改 | 新增 13 个测试用例 |

---

## 新增状态

| 状态 | 触发时机 | 层数消耗规则 |
|---|---|---|
| 燃烧（Burn） | 回合结束扣2血，然后消除 | 回合结束消除 |
| 束缚（Constricted） | 回合结束扣血=层数 | 永久 |
| 金属化（Metallicize） | 回合结束获得格挡=层数 | 永久 |
| 愤怒（Ritual） | 回合结束+力量=层数 | 永久 |
| 再生（Regenerate） | 回合结束回血=层数 | 回合结束-1 |

---

## 已知问题

无

---

## 建议 commit message

```
feat(buff_system): expand to 10 status types (feat-buff-system-v2)

- Add Burn, Constricted, Metallicize, Ritual, Regenerate
- Implement turn start/end triggers for new statuses
- Add status labels for UI
```
