# 任务规划：chore-baseline-alignment-v1

**任务ID**: `chore-baseline-alignment-v1`
**任务级别**: L0
**执行人**: 程序员
**阶段**: Phase 0 (基线对齐)

---

## 目标

确认当前项目可运行状态，记录现状差异清单，为后续 Phase 提供基线参考。

---

## 边界

只做文档操作，不修改代码。

## 白名单文件

- `docs/tasks/chore-baseline-alignment-v1/plan.md`
- `docs/tasks/chore-baseline-alignment-v1/handoff.md`
- `docs/tasks/chore-baseline-alignment-v1/verification.md`
- `docs/tasks/chore-gut-framework-setup-v1/plan.md`
- `docs/tasks/chore-gut-framework-setup-v1/handoff.md`
- `docs/tasks/chore-gut-framework-setup-v1/verification.md`

---

## 步骤

### 步骤 1: 运行冒烟验证脚本
```bash
bash dev/tools/save_load_replay_smoke.sh
```

### 步骤 2: 对照 master_plan_v3.md 第二节"当前项目基线"表格，逐项确认或更正差异

| 维度 | 文档记录 | 实际确认 | 差异说明 |
|---|---|---|---|
| 工具链 | workflow-check 完整 | 待确认 | - |
| 启动流程 | 无主菜单/角色选择 UI | 待确认 | - |
| BuffSystem 钩子 | 两个空钩子 (P0) | 待确认 | - |
| 领域层单例 | 手动 _instance 模式 | 待确认 | - |
| 信号生命周期 | RelicPotionSystem 无 _exit_tree (P1) | 待确认 | - |
| 卡牌数量 | 4张 | 待确认 | - |
| 敌人数量 | 3个 (2普通 + 1Boss) | 待确认 | - |
| 遗物数量 | 4个 | 待确认 | - |
| 药水数量 | 3个 | 待确认 | - |
| 事件数量 | 5个 | 待确认 | - |
| 地图层数 | 6层 | 待确认 | - |
| GUT测试 | 不存在 | 待确认 | - |

### 步骤 3: 记录验证结果到 verification.md

---

## 风险

- 低风险：仅记录现状，不修改代码

---

## 预期产出

- `verification.md`: 冒烟脚本结果 + 差异清单
- `handoff.md`: 改动总结（本任务无代码改动）
