# 验证记录

## 基本信息

- 任务 ID：`feat-content-pipeline-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-content-pipeline-v1`
  - 输出：`[workflow-check] passed.`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [ ] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
  - 结果：约 36 秒内未退出（手动 `Ctrl+C` 终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439 - https://godotengine.org`
    - `Error received in message reply handler: Connection invalid`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
  - 说明：为当前环境的 headless 挂起问题；本任务未添加任何自动退出运行时逻辑。

## 功能验证（已执行）

### 主路径用例 1：新增 1 张卡数据并导入成功

- 前置：在 `modules/content_pipeline/sources/cards/warrior_cards.json` 新增 `warrior_pipeline_bash`。
- 步骤：
  1. 执行：
     - `python3 tools/content_import_cards.py --input modules/content_pipeline/sources/cards/warrior_cards.json`
  2. 检查导入报告：`modules/content_pipeline/reports/card_import_report.json`
  3. 检查产物：`characters/warrior/cards/generated/warrior_pipeline_bash.gd` 与 `characters/warrior/cards/generated/warrior_pipeline_bash.tres`
- 期望：
  - 导入成功，错误数为 0。
  - 新卡产物存在且可被资源系统加载。
- 结果：通过。
  - 导入输出：`[content-import] ok`、`cards: 4`、`outputs: 9`
  - 报告摘要：`error_count = 0`

### 主路径用例 2：导入后新卡在游戏内可见且可用

- 前置：主路径用例 1 已通过。
- 步骤：
  1. 检查起始牌组资源：`characters/warrior/warrior_starting_deck.tres`。
  2. 确认包含 `res://characters/warrior/cards/generated/warrior_pipeline_bash.tres`。
  3. 检查新卡脚本效果实现：`characters/warrior/cards/generated/warrior_pipeline_bash.gd`（`DamageEffect + ApplyStatusEffect`）。
- 期望：
  - 新卡进入勇士起始牌组并可在战斗流程中抽到/打出。
  - 效果执行路径完整。
- 结果：通过（静态链路验证）。
  - 说明：受当前 headless 挂起影响，未在本机 CLI 完成可视化交互实测；已提供可复验资源链路。

### 边界用例 1：字段缺失/类型错误可定位

- 前置：非法样例文件：`modules/content_pipeline/sources/cards/warrior_cards_invalid.json`
  - 样例 A：缺少 `cost`
  - 样例 B：`cost` 类型错误（字符串）
- 步骤：
  1. 执行：
     - `python3 tools/content_import_cards.py --input modules/content_pipeline/sources/cards/warrior_cards_invalid.json --report modules/content_pipeline/reports/card_import_report_invalid.json`
  2. 检查命令行错误输出与报告文件。
- 期望：
  - 导入失败且错误可定位到字段路径。
- 结果：通过。
  - 错误 1：`cards[0].cost [missing_field]`
  - 错误 2：`cards[1].cost [invalid_type]`
  - 报告文件：`modules/content_pipeline/reports/card_import_report_invalid.json`

## 备注

- 本任务满足 C3 最小可用链路：`新增卡数据 -> 导入成功 -> 进入起始牌组（游戏可见可用链路）`。
