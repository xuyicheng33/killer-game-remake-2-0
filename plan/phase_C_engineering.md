# Phase C：可复现工程化拆分

## 阶段目标

建立“可继续、可复现、可批量扩内容”的工程基础：存档、固定种子、内容管线。

## 阶段入口

- Phase B 完成，一局流程可稳定推进。
- `RunState` 字段结构相对稳定。

## 任务拆分

## C1 `feat-save-load-v1`

- 级别：`L2`
- 主模块：`save_seed_replay`
- 依赖：B 阶段完成
- 关键改动路径：
  - `modules/save_seed_replay/**`
  - `global/save_*.gd`（新建）
  - `scenes/menu/**`（新建或扩展）
  - `docs/contracts/run_state.md`
- 子任务：
  1. `RunState` 序列化/反序列化。
  2. 主菜单新增“继续游戏”。
  3. 增加版本字段与兼容兜底策略。
- 验收：保存后重开恢复同层同状态。

## C2 `feat-seed-deterministic-v1`

- 级别：`L2`
- 主模块：`save_seed_replay`
- 依赖：C1
- 关键改动路径：
  - `modules/save_seed_replay/**`
  - `modules/map_event/**`
  - `scenes/battle/**`
  - `global/rng_*.gd`（新建）
- 子任务：
  1. 统一随机入口，避免模块各自 new RNG。
  2. 地图生成与敌人生成改为同一 seed 体系。
  3. 增加最小复现日志（seed + floor + node + enemy）。
- 验收：同 seed 开两局，前 3 层节点与首战敌人一致。

## C3 `feat-content-pipeline-v1`

- 级别：`L1`（若涉及运行时 schema 迁移则升 `L2`）
- 主模块：`content_pipeline`
- 依赖：C1 + C2
- 关键改动路径：
  - `modules/content_pipeline/**`
  - `tools/content_*`
  - `custom_resources/**`
- 子任务：
  1. 定义卡牌/敌人/遗物/事件数据 schema。
  2. 提供导入、校验、错误报告工具。
  3. 建立最小增量流程：新增 1 张卡 -> 导入 -> 运行可见。
- 验收：新增 1 张卡后通过导入脚本并在游戏内出现。

## 阶段出口

- 用户可中断并继续当前 run。
- 相同 seed 下关键流程可复现。
- 内容扩展不依赖手改多文件，而是走数据管线。
