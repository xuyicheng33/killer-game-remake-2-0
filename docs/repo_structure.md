# 仓库结构说明（当前结构 + 目标结构 + 迁移原则）

更新时间：2026-02-16

## 1. 当前结构（以代码现状为准）

```text
.
├── scenes/                    # 当前运行入口与页面脚本（app/map/battle/reward/shop/events/ui）
├── modules/                   # 领域模块目录（部分已实现，部分占位）
│   ├── run_meta/              # RunState
│   ├── persistence/           # SaveService（已实现）
│   ├── run_flow/              # 应用编排服务目录（shop/event/rest 第一批已落地）
│   ├── save_seed_replay/      # 占位目录（无实现）
│   └── ...                    # battle/card/effect/buff/enemy/map/reward/relic/content/ui
├── global/                    # 全局基础能力（events/run_rng/repro_log 等）
├── tools/                     # 工具脚本（workflow/content import）
├── docs/                      # 文档、任务三件套、契约
├── characters/ effects/ enemies/ custom_resources/
│                               # 运行时资源与遗留目录
└── references/                # 只读参考资料
```

## 2. 目标结构（Phase 2+ 方向，不在本任务执行迁移）

```text
.
├── scenes/
│   ├── app/                   # 仅页面装配与路由壳层
│   ├── battle/ map/ reward/ shop/ events/ ui/
│   └── ...                    # 仅展示 + 输入
├── modules/
│   ├── run_flow/              # 应用服务编排（流程状态推进、场景切换决策）
│   ├── run_meta/              # RunState 与跨场景真状态
│   ├── persistence/           # 存档/读档/版本迁移
│   ├── seed_replay/           # （可选）随机流与复盘服务；若不拆分则并入 persistence/global
│   └── 其他领域模块           # battle/card/effect/buff/enemy/map/reward/relic/content
├── global/
│   └── 仅保留真正全局基础设施（事件总线、可复用工具）
└── docs/
    ├── contracts/             # 契约真源
    └── tasks/                 # 任务三件套
```

## 3. 命名与目录决策（本次收口）

1. `persistence`：确定为存档主目录与主命名。
2. `save_seed_replay`：判定为历史占位名，短期冻结，不再新增业务实现。
3. `run_flow`：确定为流程编排目标目录，后续从 `scenes/app/app.gd` 迁入。

## 4. 迁移原则（严格执行）

1. 只做“增量迁移”，不做一次性大搬家。
2. 任何迁移先有契约，再做代码移动（Contract First）。
3. 单次任务最多处理一个主模块 + 少量接线，避免跨域雪崩。
4. 场景层禁止新增核心规则写入点（旧点位按任务逐步清理）。
5. `save_seed_replay` 与 `persistence` 禁止双轨并行实现，避免真源分裂。

## 5. Phase 2 前置清单

1. 在 `modules/run_flow/` 补接口草案（`contract.md` 或同等文档，不改玩法）。
2. 建立 `scenes/*` 直接写 `RunState` 的迁移清单，并按页面拆任务。
3. 明确 `seed/replay` 最终归属：
   - 方案 A：并入 `persistence` 子目录。
   - 方案 B：独立 `seed_replay` 模块，仅承载 RNG/复盘。
4. 为 `ui_shell` 增加目录内文档，说明 `scenes/ui` -> `modules/ui_shell` 的映射。
