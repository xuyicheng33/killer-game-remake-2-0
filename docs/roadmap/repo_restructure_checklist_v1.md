# 仓库重构建议清单（v1）

更新时间：2026-02-17

## P0（已完成）

- [x] 清理缓存与空壳目录：`.DS_Store`、`.godot/`、`legacy/`
- [x] 路线图目录归位：`plan/ -> docs/roadmap/`
- [x] 会话文档归位：`task_plan/findings/progress -> docs/session/`
- [x] 增加根目录 `README.md`
- [x] 增加仓库规范：`docs/repo_conventions.md`
- [x] 增加结构门禁：`tools/repo_structure_check.sh` 并接入 `workflow-check`
- [x] 增加大迁移脚本草案：`tools/restructure_migration_draft.sh`

## P1（下一批，低风险）

- [x] 明确卡牌真源目录：`characters/warrior/cards/generated/` 作为唯一真源
- [ ] 给 `references/` 增加外置方案说明（分仓或子模块）
- [ ] 把 `docs/archive/` 建立归档规则（按月份或阶段）
- [ ] 在 `tools/workflow_check.sh` 增加“新目录命名约束”检查（蛇形/小写/模块前缀）

## P2（中风险，需任务化）

- [ ] 命名收口：`modules/save_seed_replay` 并入 `modules/persistence` 或正式改名 `seed_replay`
- [ ] `scenes/ui` 持续迁移到 `modules/ui_shell`（先 battle_ui，再 hand/tooltip 等）
- [ ] 统一内容管线输入/输出目录（sources/reports/generated）

## P3（高风险，建议独立分支）

- [ ] 执行 runtime/content/dev 三层目录重构（按 `tools/restructure_migration_draft.sh` 分批）
- [ ] 全量更新 `res://` 路径并跑主流程回归（app->map->battle->reward）
- [ ] 迁移完成后升级结构门禁，禁止回退到旧路径
