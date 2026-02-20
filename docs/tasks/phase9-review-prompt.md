# Phase 9 代码审核任务

## 角色
你是一名严格的代码审核员，负责审核 Phase 9 的实现是否符合项目规范和任务要求。

## 审核依据文档
1. `AGENTS.md` - 项目协作规范
2. `docs/后续开发规划v1.0.md` - 总体规划
3. `docs/tasks/phase8-relic-expansion-v1/handoff.md` - 前置阶段交接

## Phase 9 任务范围

### 9-0: 修复遗物 Tooltip 描述不显示
- 问题：遗物悬停只显示名称，不显示效果描述
- 预期：显示 `[名称]\n\n[效果描述]`
- 关键文件：
  - `runtime/scenes/ui/tooltip.tscn`
  - `runtime/scenes/ui/tooltip.gd`
  - `runtime/scenes/app/app.tscn`

### 9-1: 卡牌 UI 改造
- 要求：将图标显示改为名称+效果描述文本显示
- 关键文件：
  - `runtime/scenes/card_ui/card_ui.tscn`
  - `runtime/scenes/card_ui/card_ui.gd`

### 9-2: 新增 10 张力量爆发轴卡牌
设计确认的卡牌列表：

| 名称 | 费用 | 类型 | 效果 |
|------|------|------|------|
| 爆发 | 1 | 能力 | 获得 2 层力量 |
| 极限突破 | 2 | 能力 | 获得 1 力量；本回合攻击伤害翻倍；消耗 |
| 战意积蓄 | 1 | 能力 | 获得 2 力量；消耗 |
| 连斩 | 1 | 攻击 | 造成 3 点伤害，连续 3 次 |
| 旋身击 | 1 | 攻击 | 4 伤害；抽 1 张牌 |
| 连环重击 | 2 | 攻击 | 5 伤害×(1+力量层，最多 3 次) |
| 风暴斩 | 0 | 攻击 | 对所有敌人造成 2 点伤害 |
| 背水狂攻 | 1 | 攻击 | 6 伤害；若 HP≤50% 则翻倍 |
| 血誓打击 | 1 | 攻击 | 失去 3 HP，造成 12 伤害 |
| 生存本能 | 1 | 技能 | 获得缺失 HP 20% 的格挡（至少 5 点） |

关键文件：
- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
- `content/characters/warrior/cards/generated/*.gd`
- `content/characters/warrior/cards/generated/*.tres`
- `content/effects/lose_hp_effect.gd`
- `content/effects/conditional_damage_effect.gd`
- `dev/tools/content_import_cards.py`

### 9-3: 新增 2 个配合遗物

| 名称 | 触发 | 效果 |
|------|------|------|
| 战怒之戒 | ON_ATTACK_PLAYED | 每打出攻击牌获得 1 力量（每战最多 5 次） |
| 淬炼石 | ON_RUN_START | 开局获得 2 层永久力量 |

关键文件：
- `content/custom_resources/relics/relic_data.gd`
- `runtime/modules/relic_potion/data_driven_relic.gd`
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `content/custom_resources/relics/rage_ring.tres`
- `content/custom_resources/relics/tempering_stone.tres`
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json`

## 审核检查清单

### 1. 模块边界检查（AGENTS.md 第 5 节）
- [ ] 所有改动是否在任务白名单文件范围内
- [ ] 是否有跨模块的"顺手重构"
- [ ] 新增文件是否放在正确的模块目录

### 2. 代码风格检查
- [ ] 命名是否清晰（无魔法值）
- [ ] 是否有未使用的变量/导入
- [ ] GDScript 类型推断是否正确（避免 `:=` 导致的类型推断失败）

### 3. 功能完整性检查
- [ ] 10 张新卡牌是否全部实现
- [ ] 2 个新遗物是否全部实现
- [ ] 卡牌效果数值是否与设计一致
- [ ] 遗物触发逻辑是否正确（每战上限、跨战斗持久化）

### 4. 测试覆盖检查
- [ ] `make test` 是否全部通过
- [ ] GUT Orphan Reports 是否为 0
- [ ] 是否需要补充新的单元测试

### 5. 技术债检查
- [ ] 是否引入新的硬编码
- [ ] 是否有 TODO/FIXME 未处理
- [ ] 是否有潜在的空指针问题

### 6. 兼容性检查
- [ ] 现有卡牌是否仍正常工作
- [ ] 现有遗物是否仍正常触发
- [ ] 存档系统是否需要更新

## 审核输出格式

```markdown
## Phase 9 审核报告

### 1. 文件变更审查
| 文件 | 状态 | 问题 |
|------|------|------|
| ... | ✅/⚠️/❌ | ... |

### 2. 功能完整性
- 卡牌实现：X/10
- 遗物实现：X/2
- 问题列表：...

### 3. 代码质量
- 类型安全问题：...
- 命名问题：...
- 潜在 Bug：...

### 4. 测试状态
- 通过率：X/142
- 需要补充的测试：...

### 5. 综合评估
- 是否批准合并：是/否/需修改
- 需要修改的问题（P0 必修）：...
- 建议改进（P1 可选）：...

### 6. 建议提交信息
```
feat(card): add 10 strength-axis cards and card UI text display (phase9)

- Phase 9-0: Fix relic tooltip description not showing
- Phase 9-1: Replace card icon with name + effect text display
- Phase 9-2: Add 10 strength burst axis cards
- Phase 9-3: Add Rage Ring and Tempering Stone relics

Tests: 142/142 passed
```
```

## 执行指令
1. 读取所有 Phase 9 相关文件
2. 逐项检查上述清单
3. 输出完整审核报告
4. 给出明确的通过/拒绝/需修改结论
