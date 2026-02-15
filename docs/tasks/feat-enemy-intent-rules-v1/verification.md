# 验证记录

## 基本信息

- 任务 ID：`feat-enemy-intent-rules-v1`
- 日期：2026-02-15

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-enemy-intent-rules-v1`

## 主路径验证（至少 2 条）

### 用例 1：条件动作优先于权重动作

- 前置：运行 `scenes/battle/battle.tscn`（默认包含 CrabEnemy）
- 步骤：
  1. 进入战斗后，观察 `CrabEnemy` 的意图（默认是攻击/格挡之一）。
  2. 在玩家回合通过打牌将 `CrabEnemy` 血量压到 `<= 6`（触发 `crab_mega_block_action.gd` 的条件）。
  3. 不结束回合也可观察意图 UI 是否立即更新为 Mega Block 的图标。
  4. 结束回合，进入敌方阶段，确认 `CrabEnemy` 实际执行 Mega Block（获得大量格挡）。
- 期望：
  - 当条件满足时，敌人选择条件池动作（即使权重池存在更高权重动作）。
  - 意图 UI 展示与实际执行动作一致。

### 用例 2：不可连续动作生效

- 前置：运行 `scenes/battle/battle.tscn`（默认包含 BatEnemy/BatEnemy2，且其 AI 含 2 个权重动作）
- 步骤：
  1. 第 1 回合直接点击“结束回合”，观察两个 Bat 在敌方阶段分别执行的动作类型（Attack 或 Block）。
  2. 进入第 2 回合玩家阶段时，观察两个 Bat 的意图：应当不与它们“上一回合实际执行”的动作重复。
  3. 重复 1-2 步至少 2 次，确认在存在替代动作时，不会出现连续两回合相同动作。
- 期望：
  - 在存在其他可选动作时，敌人不会连续两回合选择同一动作。
  - 意图 UI 与实际执行一致。

## 边界验证（至少 1 条）

### 用例 3：仅剩一个动作可选时的兜底

- 前置：需要在 Godot 编辑器里临时构造“仅一个动作”的 AI（不提交该变更）。
- 步骤：
  1. 打开 `enemies/bat/bat_enemy_ai.tscn`，临时删除 `BatBlockAction`（或将其 `chance_weight` 设为 0 并确保另一个动作权重 > 0）。
  2. 运行 `scenes/battle/battle.tscn`，进入战斗并连续结束回合 2-3 次。
- 期望：
  - 规则层不会因“不可连续动作”导致无动作可选而崩溃。
  - 若只有一个动作可选，允许重复（或按实现的兜底策略），且 UI 展示一致。

## 运行环境说明

- Godot 运行时实测：未运行时实测（本机未检测到 `godot`/`godot4` 可执行文件）。
- 本机可复验步骤：
  1. 安装 Godot 4.x。
  2. 用 Godot 打开工程目录 `杀戮游戏复刻2.0/`。
  3. 直接运行 `scenes/battle/battle.tscn` 并按上述用例验证。
