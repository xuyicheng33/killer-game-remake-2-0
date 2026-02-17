# 任务计划

## 基本信息

- 任务 ID：`art-portrait-canvas-normalize-v1`
- 任务级别：`L1`
- 目标阶段：`D2（立绘画布规范化与横向适配 v1）`
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L1）与理由

- 本任务仅修复立绘显示层问题（横向重叠、箭头偏移），不改战斗规则、数值、存档或流程逻辑。
- 变更集中于美术资源处理脚本、立绘资源引用、显示缩放逻辑，属于 `L1` 范围。

## 目标（最小可用）

1. 对三张立绘执行自动去透明边 + 安全边距 + 统一导出尺寸，输出到 `art/characters/processed/`。
2. 更新角色/敌人资源引用到 processed 版本。
3. 保留现有高度适配逻辑，并增加最大显示宽度约束（玩家/敌人可配置）。
4. 敌人箭头偏移按约束后的显示宽度计算，避免与人物轮廓脱离。

## 执行约束

- 兼容 Godot 4.6。
- 禁止加入 headless 自动退出等运行时副作用逻辑。
- 不自动提交 git commit。

## 改动白名单文件（严格）

- `art/characters/**`
- `dev/tools/**`
- `characters/warrior/warrior.tres`
- `enemies/bat/bat_enemy.tres`
- `enemies/crab/crab_enemy.tres`
- `scenes/player/player.gd`
- `scenes/enemy/enemy.gd`
- `docs/tasks/art-portrait-canvas-normalize-v1/**`

## 明确不做

- 不改 `scenes/battle/battle.tscn` 布局
- 不改 icons / 音频 / 本地化
- 不做 A/B/C 逻辑改动

## 建议参数

- 导出画布：`2048x2048`（RGBA）
- 安全边距：`10%`
- 最大显示宽度：
  - 玩家：`<= 320 px`
  - 敌人：`<= 240 px`

## 实施步骤

1. 新增工具脚本生成 processed 立绘（不覆盖原图）：
   - `art/characters/processed/霜北刀.png`
   - `art/characters/processed/离恨烟.png`
   - `art/characters/processed/埋骨钱.png`
2. 更新以下资源引用到 processed 路径：
   - `characters/warrior/warrior.tres`
   - `enemies/bat/bat_enemy.tres`
   - `enemies/crab/crab_enemy.tres`
3. 在 `scenes/player/player.gd`、`scenes/enemy/enemy.gd` 增加宽度约束，保持低分辨率旧图兼容。
4. 敌人箭头偏移改为基于约束后显示宽度。
5. 执行命令验证并回填文档。

## 验证方案

1. `make workflow-check TASK_ID=art-portrait-canvas-normalize-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（挂起则记录日志）
4. 用例验证：
   - 主路径 1：三敌同场时立绘不明显重叠，轮廓可分辨
   - 主路径 2：敌人箭头贴近人物，不漂移
   - 边界 1：切回旧 `16x16` 时缩放逻辑不崩
5. 记录改前/改后关键数值：纹理尺寸、最终 scale、最终显示宽高。

