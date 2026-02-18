# 设计提案：feat-effect-stack-v2

**任务ID**: `feat-effect-stack-v2`
**提案日期**: 2026-02-18

---

## 目标效果

在 EffectStackEngine 中实现：
1. 效果优先级排序
2. 触发链机制（最大深度10层）
3. 执行日志记录
4. 效果类型枚举

---

## 非目标

- 不改变现有效果的实现逻辑
- 不修改 UI 层
- 不引入新的效果类型（仅定义枚举）

---

## 方案 A（推荐）

### 数据结构扩展

```gdscript
enum EffectType {
    DAMAGE,
    BLOCK,
    HEAL,
    DRAW,
    APPLY_STATUS,
    REMOVE_STATUS,
    SPECIAL,
}

const MAX_CHAIN_DEPTH := 10

var _chain_depth := 0

# 队列条目结构扩展
{
    "id": int,
    "effect": String,
    "effect_type": EffectType,
    "target": Node,
    "apply": Callable,
    "priority": int,
    "source": Node,
    "value": int,
}
```

### API 变更

```gdscript
func enqueue_effect(
    effect_name: String,
    targets: Array[Node],
    apply_callable: Callable,
    priority: int = 50,
    effect_type: EffectType = EffectType.SPECIAL,
    source: Node = null,
    value: int = 0
) -> void:
```

### 优先级排序

在 `_process_queue()` 开始时，按优先级降序排序：
```gdscript
_queue.sort_custom(func(a, b): return a.priority > b.priority)
```

### 触发链机制

效果执行后，检查返回值是否包含派发事件：
```gdscript
var result = apply_callable.call(target)
if result is Dictionary and result.has("chain_effects"):
    for chain_effect in result.chain_effects:
        enqueue_effect(...)
```

递归深度检查：
```gdscript
_chain_depth += 1
if _chain_depth > MAX_CHAIN_DEPTH:
    push_error("[EffectStack] 链式递归深度超过限制")
    _chain_depth -= 1
    return
```

### ReproLog 集成

```gdscript
ReproLog.append_effect({
    "type": entry.effect_type,
    "source": entry.source,
    "target": entry.target,
    "value": entry.value,
    "turn": _current_turn,
})
```

---

## 方案 B

使用独立的事件总线处理触发链，而非内嵌在 EffectStack 中。

**权衡**:
- 优点：解耦更彻底
- 缺点：需要额外的事件定义，复杂度更高

**不选择原因**: 当前规模下，方案 A 更简洁，且符合 master_plan 的"触发链"描述。

---

## 对现有逻辑的影响

1. **调用点适配**: 现有 `enqueue_effect` 调用点仅使用前3个参数，默认值保证向后兼容
2. **存档**: 无影响
3. **种子一致性**: 无影响

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|
| `test_effect_executes_in_priority_order()` | 高优先级效果先执行 |
| `test_effect_chain_triggers_correctly()` | 效果返回 chain_effects 时自动入队 |
| `test_effect_chain_depth_limit_prevents_infinite_loop()` | 超过10层时中止并报错 |

---

## 请求批准

请确认是否批准此设计方案，以便进入编码阶段。
