# 仓库结构说明（当前结构 + 迁移原则）

更新时间：2026-03-06

## 1. 当前结构（以代码现状为准）

```text
.
├── addons/                    # Godot 插件（当前主要为 GUT）
├── project.godot              # Godot 工程入口
├── icon.svg / icon.svg.import # 工程图标资源
├── main_theme.tres            # 全局 UI 主题
├── default_bus_layout.tres    # 音频总线配置
├── runtime/                   # 运行时代码层
│   ├── scenes/                # 运行入口与页面脚本（app/map/battle/reward/shop/events/ui）
│   ├── modules/               # 领域模块目录
│   │   ├── run_meta/          # RunState
│   │   ├── persistence/       # SaveService（已实现）
│   │   ├── run_flow/          # 应用编排服务目录
│   │   ├── ui_shell/          # UI 壳层（viewmodel + adapter）
│   │   ├── # seed_replay 已删除
│   │   └── ...                # battle/card/effect/buff/enemy/map/reward/relic/content/ui
│   └── global/                # 全局基础能力（events/run_rng/repro_log 等）
├── content/                   # 资源与内容层
│   ├── art/
│   ├── characters/
│   ├── enemies/
│   ├── effects/
│   └── custom_resources/
├── dev/
│   └── tools/                 # 工具脚本（workflow/content import/ui_shell + run_flow contract checks）
├── docs/                      # 文档主目录（含 roadmap/session/tasks/contracts）
│   ├── roadmap/               # 阶段路线图与任务池
│   ├── session/               # 协作会话记录（task_plan/findings/progress）
│   ├── tasks/                 # 任务三件套
│   ├── archive/               # 归档后的方案、评审与历史说明
│   └── contracts/             # 契约文档
└── references/                # 只读参考资料
    ├── slay_the_spire_cn/     # 参考资料索引输入源
    └── tutorial_baseline/     # 只读人工对照工程
```

## 2. 命名与目录决策（当前）

1. `runtime/modules/persistence`：存档主目录与主命名。
2. `runtime/modules/seed_replay`：已删除（历史占位名）。
3. `runtime/modules/run_flow`：流程编排目标目录。

## 3. 迁移原则（严格执行）

1. 只做“增量迁移”，不做一次性大搬家。
2. 任何迁移先有契约，再做代码移动（Contract First）。
3. 单次任务最多处理一个主模块 + 少量接线，避免跨域雪崩。
4. 场景层禁止新增核心规则写入点（旧点位按任务逐步清理）。
5. `runtime/modules/persistence` 为唯一存档实现目录。

## 4. 后续清单

1. 保持 `run_flow` 路由契约单点维护：新增节点类型时必须同步更新 `route_dispatcher` 与契约检查脚本。
2. 建立 `runtime/scenes/*` 直接写 `RunState` 的迁移清单，并按页面拆任务。
3. 明确 `seed/replay` 最终归属：
   - 方案 A：并入 `persistence` 子目录。
   - 方案 B：独立 `seed_replay` 模块，仅承载 RNG/复盘。
4. 继续扩展 `ui_shell` 样板改造范围：将 `battle_ui` 等页面迁移到“viewmodel/adapter + 只读投影 + 命令转发”模式。

## 5. 结构补充约束（2026-03 收口）

1. 根目录只保留工程入口、Godot 根资产与一级主目录；新的零散文件由结构门禁拦截。
2. `docs/tasks/` 保留完整历史，不迁移旧任务；归档类文档统一进入 `docs/archive/`。
3. `references/` 顶层只保留声明过的只读参考子目录与说明文档；不混入新的工具输出或运行时代码。
4. 本地状态目录（如 `.godot/`、`.cursor/`、`.claude/`、`.ruff_cache/`）不计入仓库结构，不得追踪进 git。

## 6. 当前质量门禁入口

1. `bash dev/tools/ui_shell_contract_check.sh`
   - 拦截 `runtime/scenes/ui` 直写 `run_state` 核心入口，校验迁移页面 adapter/viewmodel 接线。
2. `bash dev/tools/run_flow_contract_check.sh`
   - 校验 route 常量单点定义与关键 `next_route + payload` 契约。
3. `make workflow-check TASK_ID=<task-id>`
   - 聚合执行白名单检查 + 两个契约门禁脚本。
