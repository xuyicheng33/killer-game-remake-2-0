# 任务计划

## 基本信息

- 任务 ID：`art-character-enemy-pack-v1`
- 任务级别：`L1`
- 目标阶段：`D2（角色/敌人资源替换 v1）`
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L1）与理由

- 本任务仅替换角色/敌人战斗立绘与战斗相关图标资源引用，不改战斗规则、数值、存档结构。
- 变更集中在美术资源与场景资源绑定，属于展示层/资源层改动，无跨阶段逻辑重构。
- 因此按 `L1` 执行：先建三件套，再直接实现并回填验证。

## 目标（最小可用）

- 落盘并接入首批角色/敌人立绘资源（玩家：霜北刀；敌人：埋骨钱/离恨烟）。
- 替换战斗链路中的最小意图图标与状态图标引用，清理明显教程残留原图引用。
- 验收口径：进入战斗后玩家/敌人立绘可见；敌人意图与状态图标可见；无缺图导致的崩溃。

## 执行约束

- 严格遵循 Godot 4.6 资源格式与语法，避免 warning-as-error。
- 禁止加入 headless 自动退出等运行时副作用逻辑。
- 不提交 git commit，仅产出变更与建议 commit message。

## 改动白名单文件（严格）

- `art/**`
- `characters/**`
- `enemies/**`
- `scenes/enemy/**`
- `scenes/ui/intent_ui.tscn`
- `scenes/ui/stats_ui.tscn`
- `docs/tasks/art-character-enemy-pack-v1/**`

## 明确不做

- 不做 D3 音频重构
- 不做 D4 本地化打磨
- 不改 A/B/C 逻辑代码（战斗规则、数值、存档）
- 不做与本任务无关重构

## 实施步骤

1. 新建 `art/characters/`，将输入素材按中文名落盘：
   - `art/characters/霜北刀.png`
   - `art/characters/埋骨钱.png`
   - `art/characters/离恨烟.png`
2. 新建 `art/ui/icons/` 并补齐最小图标：
   - `intent_attack.png`
   - `intent_block.png`
   - `intent_mega_block.png`
   - `status_block.png`
   - `status_health.png`
3. 更新立绘映射引用：
   - `characters/warrior/warrior.tres`
   - `enemies/bat/bat_enemy.tres`
   - `enemies/crab/crab_enemy.tres`
4. 更新图标引用：
   - `enemies/bat/bat_enemy_ai.tscn`
   - `enemies/crab/crab_enemy_ai.tscn`
   - `scenes/ui/intent_ui.tscn`
   - `scenes/ui/stats_ui.tscn`
5. 清理战斗链路中的明显教程原图引用（仅白名单内最小可见范围，保持玩法行为不变）。
6. 执行验证命令并回填 `verification.md` 与 `handoff.md`。

## 验证方案

1. `make workflow-check TASK_ID=art-character-enemy-pack-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志并说明环境问题）
4. 用例验证：
   - 主路径 1：进入战斗后玩家/敌人立绘正常显示
   - 主路径 2：敌人意图图标、状态图标显示正常
   - 边界用例 1：资源缺失场景降级/报错信息可定位（不崩溃）
