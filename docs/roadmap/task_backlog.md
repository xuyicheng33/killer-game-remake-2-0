# 任务池与执行顺序（可直接派发）

## 状态说明

- `done`：已完成并已进入当前真实基线
- `in_progress`：已启动，正在继续收口
- `ready`：可立即派发
- `blocked`：依赖未完成

## 全局任务序列

| 顺序 | 任务 ID | 阶段 | 主模块 | 级别 | 状态 | 依赖 |
|---|---|---|---|---|---|---|
| 0 | `feat-bootstrap-v0-20260215` | 基线 | `run_meta/map_event` | `L2` | `done` | - |
| 1 | `feat-battle-loop-state-machine-v1` | A | `battle_loop` | `L2` | `done` | - |
| 2 | `feat-effect-stack-v1` | A | `effect_engine` | `L2` | `done` | A1 |
| 3 | `feat-buff-system-core-v1` | A | `buff_system` | `L2` | `done` | A3 |
| 4 | `feat-card-zones-keywords-v1` | A | `card_system` | `L2` | `done` | A1, A3, A4 |
| 5 | `feat-enemy-intent-rules-v1` | A | `enemy_intent` | `L1/L2` | `done` | A1 |
| 6 | `feat-reward-flow-v1` | B | `reward_economy` | `L1` | `done` | A阶段完成 |
| 7 | `feat-map-graph-progression-v1` | B | `map_event` | `L2` | `done` | B1 |
| 8 | `feat-rest-shop-event-v1` | B | `map_event` | `L2` | `done` | B2 |
| 9 | `feat-relic-potion-core-v1` | B | `relic_potion` | `L2` | `done` | A4, B1 |
| 10 | `feat-save-load-v1` | C | `seed_replay` | `L2` | `done` | B阶段完成 |
| 11 | `feat-seed-deterministic-v1` | C | `seed_replay` | `L2` | `done` | C1 |
| 12 | `feat-content-pipeline-v1` | C | `content_pipeline` | `L1/L2` | `done` | C1, C2 |
| 13 | `art-ui-theme-rebuild-v1` | D | `ui_shell` | `L1` | `in_progress` | C阶段完成 |
| 14 | `art-character-enemy-pack-v1` | D | `ui_shell` | `L1` | `blocked` | D1 |
| 15 | `audio-music-sfx-rebuild-v1` | D | `ui_shell` | `L1` | `blocked` | D1 |
| 16 | `localization-zh-polish-v1` | D | `ui_shell` | `L0/L1` | `blocked` | D1, D2 |

## 当前建议推进

1. `art-ui-theme-rebuild-v1`
2. `art-character-enemy-pack-v1` 的资源准备与引用清点
3. 与路线图并行的工程清理：encounter coverage warning、orphan/resource leak

原因：A/B/C 主链能力已经进入当前真实基线，当前优先级从“补玩法骨架”切换为“体验收口 + 非阻断工程质量清理”。

## 每任务统一交付要求

1. `docs/tasks/<task-id>/plan.md`
2. 代码改动（仅任务白名单）
3. `docs/tasks/<task-id>/verification.md`
4. 1-3 条可直接复验步骤
