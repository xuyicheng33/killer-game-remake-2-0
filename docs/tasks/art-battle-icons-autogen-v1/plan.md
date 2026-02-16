# 任务计划

## 基本信息

- 任务 ID：`art-battle-icons-autogen-v1`
- 任务级别：`L1`
- 目标阶段：`D2（战斗图标自动生成与替换 v1）`
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L1）与理由

- 任务仅涉及战斗 UI 图标资源生成与引用替换，不触碰战斗规则、数值、存档、流程逻辑。
- 改动集中在 `art/ui/icons`、目标场景资源引用和工具脚本，属于资源层最小替换。
- 因此按 `L1` 执行：先建三件套，再直接实现并回填验证。

## 目标（最小可用）

- 自动生成 5 个新图标（透明底 PNG，至少 `64x64`），不是复用/拷贝旧 tile 图。
- 风格方向：杀戮尖塔风 + 手绘卡牌可读性 + 水墨笔触感。
- 替换并确保以下引用点使用新图标：
  - `enemies/bat/bat_enemy_ai.tscn`
  - `enemies/crab/crab_enemy_ai.tscn`
  - `scenes/ui/intent_ui.tscn`
  - `scenes/ui/stats_ui.tscn`
- 提供可复现自动生成脚本，并在交接文档给出一条可复跑命令。

## 执行约束

- 兼容 Godot 4.6 资源格式。
- 禁止加入 headless 自动退出等运行时副作用逻辑。
- 不自动提交 git commit。

## 改动白名单文件（严格）

- `art/ui/icons/**`
- `tools/**`
- `enemies/bat/bat_enemy_ai.tscn`
- `enemies/crab/crab_enemy_ai.tscn`
- `scenes/ui/intent_ui.tscn`
- `scenes/ui/stats_ui.tscn`
- `docs/tasks/art-battle-icons-autogen-v1/**`

## 明确不做

- 不改人物立绘
- 不改 `characters/**` 与 `scenes/enemy/**` 逻辑
- 不做 D3 音频重构
- 不做 D4 本地化打磨
- 不改 A/B/C 逻辑
- 不做无关重构

## 实施步骤

1. 新建自动生成脚本（`tools/**`）并固定随机种子，生成 5 个 `64x64` 透明底图标。
2. 覆盖输出目标文件：
   - `art/ui/icons/intent_attack.png`
   - `art/ui/icons/intent_block.png`
   - `art/ui/icons/intent_mega_block.png`
   - `art/ui/icons/status_block.png`
   - `art/ui/icons/status_health.png`
3. 校验目标引用点已经接入上述图标资源（必要时最小修改 `.tscn`）。
4. 计算并记录旧/新图标哈希对比，证明不是同图拷贝。
5. 执行验证命令并回填 `verification.md` 和 `handoff.md`。

## 验证方案

1. `make workflow-check TASK_ID=art-battle-icons-autogen-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志与环境问题）
4. 用例验证：
   - 主路径 1：进入战斗后敌人意图图标显示为新图标（非旧 tile）
   - 主路径 2：战斗中玩家/敌人状态栏格挡/生命图标显示正常
   - 边界用例 1：缺图时有可定位报错信息（不崩溃）
   - 额外：新旧图标文件哈希对比

