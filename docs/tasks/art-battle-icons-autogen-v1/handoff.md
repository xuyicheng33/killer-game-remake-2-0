# 任务交接

## 基本信息

- 任务 ID：`art-battle-icons-autogen-v1`
- 目标阶段：`D2（战斗图标自动生成与替换 v1）`
- 任务级别：`L1`
- 提交人：Codex
- 日期：2026-02-16

## 当前状态

- 阶段：`实现完成`
- 状态：`已实现 + 已回填验证（含环境限制说明）`

## 实现范围

- 自动生成并替换 5 个战斗图标：
  - `art/ui/icons/intent_attack.png`
  - `art/ui/icons/intent_block.png`
  - `art/ui/icons/intent_mega_block.png`
  - `art/ui/icons/status_block.png`
  - `art/ui/icons/status_health.png`
- 接入引用点：
  - `enemies/bat/bat_enemy_ai.tscn`
  - `enemies/crab/crab_enemy_ai.tscn`
  - `scenes/ui/intent_ui.tscn`
  - `scenes/ui/stats_ui.tscn`
- 新增自动生成脚本（`tools/**`），并提供可复跑命令。

## 可复跑命令

- `python3 tools/generate_battle_icons.py --output-dir art/ui/icons --size 64 --seed 20260216`

## 变更文件

- `docs/tasks/art-battle-icons-autogen-v1/plan.md`
- `docs/tasks/art-battle-icons-autogen-v1/handoff.md`
- `docs/tasks/art-battle-icons-autogen-v1/verification.md`
- `tools/generate_battle_icons.py`
- `art/ui/icons/intent_attack.png`
- `art/ui/icons/intent_block.png`
- `art/ui/icons/intent_mega_block.png`
- `art/ui/icons/status_block.png`
- `art/ui/icons/status_health.png`

## 验证结果

- [ ] `make workflow-check TASK_ID=art-battle-icons-autogen-v1`
  - 失败：本任务外既有改动 `characters/warrior/warrior.tres` 不在当前白名单内
- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
  - 约 40 秒未退出，手动中断；日志见 `verification.md`
- [x] 主路径 1（静态链路）：敌人意图图标引用为新图标路径
- [x] 主路径 2（静态链路）：状态栏格挡/生命图标引用为新图标路径
- [x] 边界用例 1（静态定位）：缺图时报错路径可定位
- [x] 哈希对比：新图标与旧图标/旧 tile/heart 哈希均不同

## 风险与说明

- 若 `godot4.6 --headless ... --quit` 挂起，仅记录环境日志，不加入自动退出逻辑。

## 建议提交信息

- `feat(art): autogenerate battle intent/status icons with deterministic ink style (art-battle-icons-autogen-v1)`
