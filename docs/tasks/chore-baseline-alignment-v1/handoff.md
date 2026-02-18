# 交接文档：chore-baseline-alignment-v1

**任务ID**: `chore-baseline-alignment-v1`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

**无代码改动**

**新增文档**:
- `docs/tasks/chore-baseline-alignment-v1/plan.md`
- `docs/tasks/chore-baseline-alignment-v1/verification.md`
- `docs/tasks/chore-baseline-alignment-v1/handoff.md`

**删除过时文件**:
- `task_plan.md` (根目录)
- `findings.md` (根目录)
- `progress.md` (根目录)

---

## 验证结果

### 冒烟脚本
- `bash dev/tools/save_load_replay_smoke.sh`: **全部通过** (9组检查)

### 手动主流程验证
- 启动 → 选角色 → 走地图 → 进入战斗 → 出牌 → 结束回合: **全部通过**

### Workflow Check
- `make workflow-check TASK_ID=chore-gut-framework-setup-v1`: **通过**

### 基线差异确认

| 问题 | 级别 | 位置 | 说明 |
|---|---|---|---|
| BuffSystem 空钩子 | P0 | `buff_system.gd:192-209` | `_run_turn_start_hooks` 和 `_run_after_card_played_hooks` 为 `pass` |
| RelicPotionSystem 缺 _exit_tree | P1 | `relic_potion_system.gd:11-15` | 信号连接无对应断开 |
| 视觉层直接随机 | P2 | `battle.gd:96`, `shaker.gd:14` | 使用 `randf_range()` 做视觉抖动，不影响游戏逻辑 |

### 基线信息更正

| 维度 | 文档记录 | 实际状态 |
|---|---|---|
| 敌人数量 | 3个 (2普通+1Boss) | 2个普通敌人，Boss 未找到独立定义 |
| 事件数量 | 5个 | 15个事件模板 |

---

## 已知问题

1. **P0 问题** (Phase 1 必修):
   - BuffSystem 两个空钩子导致回合开始/出牌后状态效果无法触发

2. **P1 问题** (Phase 1 必修):
   - RelicPotionSystem 信号泄漏
   - 领域层手动单例模式 (`buff_system.gd:18`, `effect_stack_engine.gd:6`, `card_zones_model.gd:6`)

3. **P2 问题** (Phase 1 开始消化):
   - 视觉层直接随机调用

---

## 下一步

Phase 1 任务:
1. 修复 BuffSystem 空钩子 (P0)
2. 重构领域层单例为依赖注入 (P1)
3. 修复信号生命周期 (P1)
4. 统一 RunRng 入口 (P2)

---

## 建议 commit message

```
docs(baseline): complete Phase 0 baseline alignment (chore-baseline-alignment-v1)

- Run smoke tests (all passed)
- Document baseline differences
- Complete manual main flow verification
- Remove deprecated root files
```
