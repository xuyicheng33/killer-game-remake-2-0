# 任务计划

## 基本信息

- 任务 ID：`art-portrait-scale-fit-v1`
- 任务级别：`L1`
- 目标阶段：`D2（立绘战斗内尺寸适配 v1）`
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L1）与理由

- 本任务仅修复战斗场景中立绘显示尺寸与对齐问题，属于视觉层适配。
- 不涉及战斗规则、数值、存档、随机种子或流程状态机。
- 改动范围限制在 `scenes/player/**`、`scenes/enemy/**`（必要时最小调整场景），符合 `L1`。

## 目标（最小可用）

1. 玩家与敌人立绘在战斗中可读、不过屏、不遮 UI。
2. 适配当前高分辨率立绘：
   - `art/characters/霜北刀.png`
   - `art/characters/离恨烟.png`
   - `art/characters/埋骨钱.png`
3. 实现分辨率无关缩放逻辑，兼容旧低分辨率贴图。
4. 保持战斗行为不变，仅调整显示层。

## 执行约束

- 兼容 Godot 4.6 语法与资源格式。
- 禁止加入 headless 自动退出等运行时副作用逻辑。
- 不自动提交 git commit。

## 改动白名单文件（严格）

- `scenes/player/**`
- `scenes/enemy/**`
- `scenes/battle/battle.tscn`
- `docs/tasks/art-portrait-scale-fit-v1/**`

## 明确不做

- 不改 `characters/**`、`enemies/**` 数值与 AI
- 不改 `modules/**` 逻辑
- 不做 D3 音频重构
- 不做 D4 本地化
- 不做无关重构

## 实施步骤

1. 在 `scenes/player/player.gd` 增加立绘自动适配逻辑：
   - 根据 `texture.get_size().y` 计算统一缩放。
   - 高分辨率立绘按目标显示高度缩放。
   - 低分辨率旧图保持原有默认缩放，避免异常放大。
2. 在 `scenes/enemy/enemy.gd` 增加同类自动适配逻辑，并保持箭头位置计算正确。
3. 仅在必要时最小调整 `player.tscn` / `enemy.tscn` / `battle.tscn` 的显示参数。
4. 执行命令验证并回填三件套。

## 验证方案

1. `make workflow-check TASK_ID=art-portrait-scale-fit-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志并说明环境问题）
4. 功能验证：
   - 主路径 1：玩家立绘完整可见，不遮手牌区
   - 主路径 2：敌人立绘完整可见，意图与状态 UI 正常
   - 边界用例 1：低分辨率旧图切回后缩放不异常且不崩溃
5. 记录关键数值（纹理尺寸、最终 scale）用于改前/改后对比。

