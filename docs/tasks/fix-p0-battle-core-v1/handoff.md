# 交接文档：fix-p0-battle-core-v1

**任务ID**: `fix-p0-battle-core-v1`
**日期**: 2026-02-18

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/buff_system/buff_system.gd` | 修改 | 实现两个空钩子为遍历+分发结构 |
| `dev/tests/unit/test_buff_system.gd` | 修改 | 新增 8 个测试用例验证钩子触发与遍历分发 |

---

## 改动详情

### buff_system.gd

1. `_run_turn_start_hooks` (第192-214行)
   - 空函数 → 遍历 + 分发结构
   - 使用 `stats.get_status_snapshot()` 获取状态字典
   - 遍历所有状态并按 match 分发
   - 添加扩展规则注释

2. `_run_after_card_played_hooks` (第220-240行)
   - 同上

### test_buff_system.gd

新增 8 个测试用例：
- `test_turn_start_hooks_dispatches_for_player`
- `test_turn_start_hooks_dispatches_for_enemy`
- `test_after_card_played_hooks_dispatches_for_player`
- `test_after_card_played_hooks_dispatches_for_enemy`
- `test_turn_start_hooks_handles_null_target`
- `test_after_card_played_hooks_handles_null_target`
- `test_turn_start_hooks_handles_no_stats`
- `test_hooks_iterate_all_status_types`

测试实现说明：
- 使用 `partial_double(Player/Enemy)` 构造可调用钩子的目标对象。
- 通过 stub `update_stats` 避免场景子节点依赖，聚焦钩子行为验证。

---

## 已知问题

无

---

## 下一步

- Fix 1-B-1: 领域层手动单例改为依赖注入 (`refactor-battle-context-injection-v1`)
- Fix 1-B-2: 信号生命周期规范 (`fix-signal-lifecycle-v1`)
- Fix 1-B-3: unsafe 类型转换 (`fix-type-safety-v1`)

---

**程序员签名**: 已完成
**日期**: 2026-02-18
