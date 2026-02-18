# 设计复核：feat-effect-stack-v2

**任务ID**: `feat-effect-stack-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/effect_engine/effect_stack_engine.gd`

**关键函数**:
- `enqueue_effect(effect_name: String, targets: Array[Node], apply_callable: Callable) -> void`（第12-35行）
- `_process_queue() -> void`（第50-84行）

---

## 当前数据结构

```gdscript
var _queue: Array[Dictionary] = []
var _is_processing := false
var _current_item := "idle"
var _next_entry_id := 1

# 队列条目结构
{
    "id": int,
    "effect": String,
    "target": Node,
    "apply": Callable,
}
```

---

## 当前限制

1. **无优先级**: 效果按入队顺序执行，无法控制执行顺序
2. **无触发链**: 效果执行后不会自动派发新事件
3. **无日志记录**: 未集成 ReproLog
4. **无类型枚举**: 效果名称为字符串，无类型安全

---

## 复用点

1. `_queue` 数组结构可扩展，添加 `priority` 和 `effect_type` 字段
2. `_process_queue()` 的主循环可扩展，添加日志和触发链逻辑
3. 现有的 `debug_state_changed` 信号可复用

---

## 风险点

1. **性能**: 优先级排序可能影响大量效果时的性能（预期单次效果数 < 20，可接受）
2. **向后兼容**: 现有调用点使用旧的 `enqueue_effect` 签名

---

## 相关文件

- `runtime/global/repro_log.gd` - 需要集成
- `content/effects/*.gd` - 效果定义，可能需要适配新签名

---

## 结论

当前 EffectStackEngine 结构清晰，可在此基础上扩展。主要改动：
1. 扩展队列条目结构
2. 修改入队/出队逻辑
3. 集成 ReproLog
4. 保持向后兼容（默认参数）
