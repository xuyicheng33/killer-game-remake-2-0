# 任务计划

## 基本信息

- 任务 ID：`feat-content-pipeline-v1`
- 任务级别：`L2`
- 目标阶段：`C3（内容管线最小可用）`
- 主模块：`content_pipeline`（协同 `custom_resources` / `characters`）
- 负责人：Codex
- 日期：2026-02-16

## 级别判定（L2）与理由

- 本任务要打通“外部内容数据 -> 导入产物 -> 运行时可用”的链路，涉及 `tools`、`modules`、`custom_resources`、`characters`，属于跨模块改动。
- 需要定义并落地内容 schema 与校验规则，实质是新增数据契约与错误处理接口，不是单模块内部逻辑调整。
- 验收要求“新增 1 张卡数据后游戏内可见可用”，会影响内容加载路径与运行时行为，按 `L2` 处理并走审批。

## 目标

- 定义卡牌/敌人/遗物/事件的最小 schema（先从“卡牌”落地）。
- 提供最小导入与校验流程（命令行脚本或工具函数）。
- 验收口径：新增 1 张卡数据 -> 导入成功 -> 游戏内可见可用。
- 输出清晰错误报告（字段缺失/类型错误时可定位）。

## 审批门槛（必须）

- 本任务为 `L2`，先完成三件套文档后停在审批点。
- 在你回复“批准”前，不进行任何业务代码实现。
- 实现阶段必须遵循 Godot 4.6 语法约束，避免 warning-as-error 触发。
- 禁止加入 headless 自动退出等运行时副作用逻辑。

## 范围边界

- 包含：
  - 内容 schema 最小集合定义：`card/enemy/relic/event`
  - 优先落地 `card` 的导入、校验、错误报告与最小运行时接入
  - 最小 CLI 或工具函数入口，支持一次导入与失败定位
- 不包含：
  - 完整编辑器 UI
  - 全量资产重建
  - C4/D 阶段内容
  - 大规模平衡性调整
  - 与本任务无关的重构

## 改动白名单文件（严格限制）

- `modules/content_pipeline/**`
- `dev/tools/content_*`
- `custom_resources/**`
- `characters/**`
- `docs/contracts/**`
- `docs/tasks/feat-content-pipeline-v1/**`

## 最小 Schema 草案（审批后固化到 docs/contracts/**）

### 1) Card（首批落地）

| 字段 | 类型 | 必填 | 约束/说明 |
|---|---|---|---|
| `id` | `String` | 是 | 全局唯一，建议 `snake_case` |
| `name` | `String` | 是 | 展示名 |
| `type` | `String` | 是 | `attack/skill/power/status/curse` |
| `rarity` | `String` | 是 | `common/uncommon/rare` |
| `cost` | `int` | 是 | `-1..10`（`-1` 表示 X 或特殊） |
| `target` | `String` | 是 | `self/enemy/all_enemies/none` |
| `text` | `String` | 是 | 规则文本 |
| `effects` | `Array[Dictionary]` | 是 | 至少 1 条 effect；每条含 `op` 与参数 |
| `tags` | `Array[String]` | 否 | 关键词标签 |
| `upgrade_to` | `String` | 否 | 指向升级后卡 ID |

### 2) Enemy（最小定义）

- 必填：`id/name/max_hp/intents`
- `intents` 最小元素：`weight`、`op`、`params`

### 3) Relic（最小定义）

- 必填：`id/name/tier/hooks`
- `hooks` 最小元素：`timing`、`op`、`params`

### 4) Event（最小定义）

- 必填：`id/title/options`
- `options` 最小元素：`id/text/outcome`

## 实施步骤（审批后执行）

1. 在 `docs/contracts/**` 固化四类 schema 文档，明确必填/枚举/默认值/错误码。
2. 在 `modules/content_pipeline/**` 实现 `card` 解析与结构化校验（先单文件或单目录导入）。
3. 在 `dev/tools/content_*` 提供最小导入命令入口（输入源数据，输出导入结果与错误清单）。
4. 将导入产物落到 `custom_resources/**`，并在 `characters/**` 完成最小引用接入，保证新增卡可在游戏流程出现并可使用。
5. 补齐错误报告：至少覆盖“字段缺失/类型错误/非法枚举/重复 ID”四类，并包含字段路径与源文件定位。
6. 按 `verification.md` 执行验证并回填结果，再更新 `handoff.md`。

## 验收口径（审批后执行）

- 新增 1 张合法卡牌数据可导入成功。
- 游戏内可见该卡（如奖励池/牌库/起始牌组之一）且可打出，行为与配置一致。
- 非法数据会被拒绝并输出可定位错误（文件 + 字段路径 + 原因）。

## 风险与回滚

- 风险：
  - schema 约束过严或过松会导致导入可用性与稳定性失衡。
  - 导入产物与运行时资源格式不一致可能造成“导入成功但不可用”。
  - 错误报告若缺少路径定位，会显著提高排障成本。
- 回滚方式：
  - 回滚本任务提交，恢复为手工维护内容的旧流程。
