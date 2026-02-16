# 任务计划

## 基本信息

- 任务 ID：`art-ui-theme-rebuild-v1`
- 任务级别：`L1`
- 目标阶段：`D1（UI 主题重构 v1）`
- 主模块：`ui_shell`
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L1）与理由

- 本任务仅涉及 UI 主题与展示层资源（字体、色板、控件样式、布局可读性）。
- 不修改战斗规则、数值结算、存档结构或跨模块契约。
- 改动范围限定在场景样式与主题资源，属于展示层内聚调整，按 `L1` 执行。

## 目标

- 统一字体、色板、控件样式（按钮/面板/标签/卡片容器等）。
- 地图页、战斗页、奖励页视觉风格统一（同一主题语言）。
- 完成 1080p 与 16:9 下可读性与布局适配（不遮挡、不重叠、文字可读）。
- 资源放到 `art/ui/**`，主题集中在 `main_theme.tres`。

## 执行约束

- 严格遵循 Godot 4.6 语法与资源格式，避免 warning-as-error。
- 仅做 UI/主题相关改动，不改战斗规则、数值逻辑、存档逻辑。
- 禁止加入 headless 自动退出等运行时副作用逻辑。

## 范围边界

- 包含：
  - `main_theme.tres` 统一主题基线
  - `scenes/map`、`scenes/battle`、`scenes/reward`、`scenes/ui`、`scenes/app` 的视觉统一与布局可读性修正
  - `art/ui/**` 主题资源（背景纹理/说明）
- 不包含：
  - D2 角色/敌人资源替换
  - D3 音频重构
  - D4 文案本地化打磨
  - A/B/C 逻辑代码改动
  - 与本任务无关重构

## 改动白名单文件（严格）

- `scenes/ui/**`
- `scenes/map/**`
- `scenes/battle/**`
- `scenes/reward/**`
- `scenes/app/**`
- `main_theme.tres`
- `art/ui/**`
- `docs/tasks/art-ui-theme-rebuild-v1/**`

## 实施步骤

1. 建立统一视觉方向（字体 fallback、深色底 + 暖色强调、统一 Panel/Button/Label 样式）。
2. 重写 `main_theme.tres` 基线样式，覆盖常用控件外观与文本可读性。
3. 在地图页、奖励页、战斗页接入同主题容器与背景纹理，清理分散的冲突样式。
4. 调整关键布局参数，确保 1080p 与 16:9 下不遮挡/不重叠。
5. 验证长文本和小窗口可读性（自动换行、容器不溢出）。
6. 执行命令验证并回填 `verification.md` 与 `handoff.md`。

## 验证方案

1. `make workflow-check TASK_ID=art-ui-theme-rebuild-v1`
2. `godot4.6 --version`
3. `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（若挂起，记录日志并注明环境问题）
4. 功能验证：
   - 主路径 1：地图 -> 战斗 -> 奖励 UI 主题一致性
   - 主路径 2：1080p/16:9 适配
   - 边界用例 1：长文本/小窗口不溢出

## 风险与回滚

- 风险：
  - 主题集中后，局部 hardcode 样式可能与全局主题叠加产生对比度问题。
  - 控件最小尺寸与字体调整可能导致极端窗口尺寸下的内容拥挤。
- 回滚方式：
  - 回滚本任务提交，恢复旧主题与场景样式。
