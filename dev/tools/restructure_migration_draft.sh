#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
[migration-draft] 说明：本仓库已完成 runtime/content/dev 三层目录迁移。
[migration-draft] 当前脚本保留历史草案，供后续新仓库参考；不会执行任何移动。

建议执行前置：
1) 新建任务分支（不要在 main 直接做）
2) 确保工作区干净：git status
3) 先跑一轮：make workflow-check TASK_ID=<task-id>

-----------------------------------
历史草案命令（仅作参考）：
-----------------------------------

# 1) 建目录
mkdir -p runtime content dev

# 2) 运行时代码归位
git mv scenes runtime/scenes
git mv modules runtime/modules
git mv global runtime/global

# 3) 内容资源归位
git mv art content/art
git mv characters content/characters
git mv enemies content/enemies
git mv effects content/effects
git mv custom_resources content/custom_resources

# 4) 工具归位
git mv tools dev/tools

# 5) 批量替换路径引用（示例，执行前先评审）
rg -n "res://(scenes|modules|global|art|characters|enemies|effects|custom_resources|tools)/" runtime content docs project.godot

# 6) 路径替换后验证
make workflow-check TASK_ID=<task-id>

# 7) 运行验证（Godot 打开项目，验证 app->map->battle->reward 主流程）

------------------------------
注意事项：
------------------------------

- `project.godot` 的主场景路径和 autoload 路径必须同步更新。
- 所有 `*.tscn` / `*.tres` 的 ext_resource 路径都会受影响。
- 建议分两批迁移：先 runtime，再 content/dev，降低回滚成本。
- 该草案不包含自动替换逻辑，避免误改；请在任务内分步执行并验证。
EOF
