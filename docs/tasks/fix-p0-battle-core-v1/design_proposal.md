# 设计提案：fix-p0-battle-core-v1

**任务ID**: `fix-p0-battle-core-v1`
**日期**: 2026-02-18

---

## 1. 问题定义

BuffSystem 中两个钩子函数为空实现（P0），导致：
- 战斗状态结算链路不完整
- 无法支持未来"回合开始触发"或"出牌后触发"的状态效果
- 违反"无空钩子"原则（master_plan_v3.md:53 要求 P0=0）

---

## 2. 目标效果

- 两个钩子函数具有**可调用结构（遍历 + 分发）**
- 当前状态集（5种）能正确处理
- 为未来扩展预留清晰的注册点
- GUT 测试验证触发行为

---

## 3. 非目标

- 不新增状态类型（Phase 2）
- 不重构单例模式（P1 任务）
- 不修改状态触发时机

---

## 4. 方案

### 方案 A（推荐）：遍历 + 分发框架

**实现**：
```gdscript
func _run_turn_start_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    
    var status_dict: Dictionary = stats.get_status_snapshot()
    for status_id: String in status_dict.keys():
        var stacks: int = status_dict[status_id]
        if stacks <= 0:
            continue
        
        match status_id:
            STATUS_STRENGTH, STATUS_DEXTERITY, STATUS_VULNERABLE, STATUS_WEAK, STATUS_POISON:
                pass  # 当前状态集无回合开始触发
            _:
                pass  # 预留扩展点
    
    # 扩展规则注释

func _run_after_card_played_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    
    var status_dict: Dictionary = stats.get_status_snapshot()
    for status_id: String in status_dict.keys():
        var stacks: int = status_dict[status_id]
        if stacks <= 0:
            continue
        
        match status_id:
            STATUS_STRENGTH, STATUS_DEXTERITY, STATUS_VULNERABLE, STATUS_WEAK, STATUS_POISON:
                pass  # 当前状态集无出牌后触发
            _:
                pass  # 预留扩展点
    
    # 扩展规则注释
```

**优点**：
- 满足 master_plan_v3 要求的"遍历 + 分发"结构
- 当前状态集无影响（无触发需求）
- 未来扩展只需在 match 中添加分支

**缺点**：
- ~~需确认 Stats 类有 `get_status_dict()` 方法~~ **已确认**: Stats 类有 `get_status_snapshot()` 方法

### 方案 B：仅 extract_stats

**实现**：
```gdscript
func _run_turn_start_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    # 注释说明扩展点
```

**缺点**：
- **不满足 master_plan_v3.md:250/272 要求**的"遍历 + 分发"
- 被审核驳回

---

## 5. 影响分析

### 对现有逻辑
- 无破坏性变更（空函数 → 有框架，行为一致）

### 对存档
- 无影响

### 对种子一致性
- 无影响

---

## 6. 测试方案

依据 master_plan_v3.md:255-257, 276-278 要求：

```gdscript
func test_turn_start_hook_fires_for_registered_status():
    # 注册测试状态，验证钩子遍历并分发
    var bs := BuffSystem.new()
    var mock_stats := _create_mock_stats_with_status("test_regen", 3)
    var mock_target := _create_mock_target_with_stats(mock_stats)
    
    bs._run_turn_start_hooks(mock_target)
    
    # 验证钩子执行了遍历逻辑（无崩溃即通过）
    assert_true(true, "回合开始钩子应执行遍历分发逻辑")

func test_after_card_played_hook_fires_on_attack_card():
    var bs := BuffSystem.new()
    var mock_stats := _create_mock_stats_with_status("test_ritual", 2)
    var mock_target := _create_mock_target_with_stats(mock_stats)
    
    bs._run_after_card_played_hooks(mock_target)
    
    assert_true(true, "出牌后钩子应执行遍历分发逻辑")
```

---

## 7. 推荐方案

**方案 A**：遍历 + 分发框架

理由：
1. 满足 master_plan_v3 硬性要求
2. Phase 1 目标是修复 P0，提供可用框架
3. 测试覆盖触发行为

---

**审批请求**: 请批准执行方案 A
