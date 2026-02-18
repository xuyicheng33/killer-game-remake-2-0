# 交接文档：feat-effect-stack-v2

**任务ID**: `feat-effect-stack-v2`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/effect_engine/effect_stack_engine.gd` | 修改 | 新增优先级、触发链、日志、类型枚举 |
| `runtime/global/repro_log.gd` | 修改 | 新增 `log_effect()` 方法 |
| `dev/tests/unit/test_effect_stack.gd` | 修改 | 新增 9 个测试用例 |

---

## 关键改动

### 新增效果类型枚举

```gdscript
enum EffectType {
    DAMAGE, BLOCK, HEAL, DRAW,
    APPLY_STATUS, REMOVE_STATUS, SPECIAL,
}
```

### 新增触发链机制

- 最大递归深度：10层
- 超限时 `push_error` 中止

### 效果优先级

- 入队时携带 `priority` 参数（默认 50）
- 出队时按优先级降序排序

---

## 已知问题

无

---

## 下一步

进入 Phase 2 任务 2-2（BuffSystem）

---

## 建议 commit message

```
feat(effect_engine): implement priority, chain, and logging (feat-effect-stack-v2)

- Add EffectType enum
- Add priority-based queue sorting
- Add chain effect triggering with depth limit
- Add ReproLog integration
```
