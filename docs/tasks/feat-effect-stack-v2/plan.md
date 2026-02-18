# 任务规划：feat-effect-stack-v2

**任务ID**: `feat-effect-stack-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

在现有 EffectStackEngine 队列基础上，补充以下功能：
1. 效果优先级（入队时携带 priority，出队按优先级排序）
2. 触发链（效果执行完成后派发新事件，新事件自动入队；最大递归深度10层）
3. 执行日志（每次效果执行后追加到 ReproLog）
4. 效果类型枚举（DAMAGE / BLOCK / HEAL / DRAW / APPLY_STATUS / REMOVE_STATUS / SPECIAL）

---

## 边界

**白名单**:
- `runtime/modules/effect_engine/effect_stack_engine.gd`
- `dev/tests/unit/test_effect_stack.gd`
- `runtime/global/repro_log.gd`

**不涉及**:
- UI 层改动
- 存档结构变化
- 其他模块的 API 变化

---

## 步骤

### Step 1: 添加效果类型枚举和优先级支持
- 新增 `EffectType` 枚举
- 修改 `enqueue_effect` 签名，增加 `priority: int = 50` 参数
- 入队时存储优先级，出队时按优先级排序（高优先级先执行）

### Step 2: 实现触发链机制
- 效果执行完成后，检查是否派发新事件
- 新事件自动入队
- 新增 `_chain_depth: int` 跟踪递归深度
- 超过最大深度（10层）时 `push_error` 并中止

### Step 3: 集成 ReproLog
- 每次效果执行后，追加日志记录
- 格式：`{type, source, target, value, turn}`

### Step 4: 补充 GUT 测试
- `test_effect_executes_in_priority_order()`
- `test_effect_chain_triggers_correctly()`
- `test_effect_chain_depth_limit_prevents_infinite_loop()`

---

## 风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 触发链可能导致性能问题 | 中 | 限制最大递归深度，添加日志监控 |
| 现有调用点需要适配 | 低 | priority 默认值 50，保持向后兼容 |

---

## 验收标准

- [ ] `make test` 通过，新增 3 个测试用例全部通过
- [ ] 手动验证：效果按优先级执行
- [ ] 手动验证：触发链正确入队，深度限制生效
- [ ] `make workflow-check TASK_ID=feat-effect-stack-v2` 通过

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
