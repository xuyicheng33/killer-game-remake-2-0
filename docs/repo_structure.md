# 仓库结构说明（当前结构 + 目标结构 + 迁移原则）

更新时间：2026-02-17

## 1. 当前结构（以代码现状为准）

```text
.
├── scenes/                    # 当前运行入口与页面脚本（app/map/battle/reward/shop/events/ui）
├── modules/                   # 领域模块目录（部分已实现，部分占位）
│   ├── run_meta/              # RunState
│   ├── persistence/           # SaveService（已实现）
│   ├── run_flow/              # 应用编排服务目录（map orchestration + route dispatcher + flow_context + shop/event/rest/battle）
│   ├── ui_shell/              # UI 壳层（viewmodel + adapter）
│   ├── seed_replay/      # 占位目录（无实现）
│   └── ...                    # battle/card/effect/buff/enemy/map/reward/relic/content/ui
├── global/                    # 全局基础能力（events/run_rng/repro_log 等）
├── tools/                     # 工具脚本（workflow/content import/ui_shell + run_flow contract checks）
├── docs/                      # 文档主目录（含 roadmap/session/tasks/contracts）
│   ├── roadmap/               # 阶段路线图与任务池
│   ├── session/               # 协作会话记录（task_plan/findings/progress）
│   ├── tasks/                 # 任务三件套
│   └── contracts/             # 契约文档
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
    ├── roadmap/               # 路线图与阶段计划
    ├── session/               # 协作会话记录（可定期归档）
    ├── contracts/             # 契约真源
    └── tasks/                 # 任务三件套
```

## 3. 命名与目录决策（本次收口）

1. `persistence`：确定为存档主目录与主命名。
2. `seed_replay`：判定为历史占位名，短期冻结，不再新增业务实现。
3. `run_flow`：确定为流程编排目标目录，后续从 `scenes/app/app.gd` 迁入。

## 4. 迁移原则（严格执行）

1. 只做“增量迁移”，不做一次性大搬家。
2. 任何迁移先有契约，再做代码移动（Contract First）。
3. 单次任务最多处理一个主模块 + 少量接线，避免跨域雪崩。
4. 场景层禁止新增核心规则写入点（旧点位按任务逐步清理）。
5. `seed_replay` 与 `persistence` 禁止双轨并行实现，避免真源分裂。

## 5. 后续清单（Phase 4 后）

1. 保持 `run_flow` 路由契约单点维护：新增节点类型时必须同步更新 `route_dispatcher` 与契约检查脚本。
2. 建立 `scenes/*` 直接写 `RunState` 的迁移清单，并按页面拆任务。
3. 明确 `seed/replay` 最终归属：
   - 方案 A：并入 `persistence` 子目录。
   - 方案 B：独立 `seed_replay` 模块，仅承载 RNG/复盘。
4. 继续扩展 `ui_shell` 样板改造范围：将 `battle_ui` 等页面迁移到“viewmodel/adapter + 只读投影 + 命令转发”模式。

## 6. 当前质量门禁入口（Phase 7）

1. `bash tools/ui_shell_contract_check.sh`
   - 拦截 `scenes/ui` 直写 `run_state` 核心入口，校验迁移页面 adapter/viewmodel 接线。
2. `bash tools/run_flow_contract_check.sh`
   - 校验 route 常量单点定义与关键 `next_route + payload` 契约。
3. `make workflow-check TASK_ID=<task-id>`
   - 聚合执行白名单检查 + 两个契约门禁脚本。
