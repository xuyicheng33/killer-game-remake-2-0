# 验证记录

## 基本信息

- 任务 ID：`feat-seed-deterministic-v1`
- 日期：2026-02-16

## 自动化检查

- [x] `make workflow-check TASK_ID=feat-seed-deterministic-v1`

## Godot 4.6 CLI 自检

- [x] `godot4.6 --version`
  - 输出：`4.6.stable.mono.official.89cea1439`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行，环境挂起）
  - 结果：35 秒内未退出（超时后手动终止）
  - 日志：
    - `Godot Engine v4.6.stable.mono.official.89cea1439`
    - `Connection Invalid error for service com.apple.hiservices-xpcservice.`
    - `Error received in message reply handler: Connection invalid`
  - 说明：该环境下仍为历史一致的 headless 挂起现象；本任务未引入自动 `quit` 逻辑。

## 审核修复回归

- 已修复：
  - 读档恢复 RNG 流状态（避免 `begin_run(seed)` 清零流进度导致 continue 分歧）
  - 敌方 stream key 稳定性增强（改为 node + 敌方 AI 签名 + index）
  - 奖励随机默认 stream 去通用化（商店显式独立 stream）
- 回归命令：
  - `make workflow-check TASK_ID=feat-seed-deterministic-v1`：通过
  - `godot4.6 --version`：`4.6.stable.mono.official.89cea1439`
  - `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`：35 秒超时（环境挂起，日志同上）

## 功能验证（可复验步骤）

### 主路径用例 1：同 seed 地图前 3 层一致

- 前置：通过环境变量固定种子启动（例如 `STS_RUN_SEED=424242 godot4.6 --path /Users/xuyicheng/杀戮游戏复刻2.0`）。
- 步骤：
  1. 用固定 `seed=S` 开局 Run A，记录前 3 层可达节点与选中节点序列。
  2. 用同一 `seed=S` 开局 Run B，执行相同选择策略。
  3. 对比两局前 3 层节点序列是否一致。
- 期望：
  - 前 3 层节点结构与节点选择结果一致。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。

### 主路径用例 2：同 seed 首战敌方行为链路一致

- 前置：同一 `seed=S`，进入首战节点，并观察控制台 `[repro]` 日志。
- 步骤：
  1. Run A 进入首战，记录敌方首轮到若干轮（按当前可观测项）的意图/行为序列。
  2. Run B 使用同一 `seed=S` 重复进入首战并记录同样信息。
  3. 对比两局行为链路是否一致。
- 期望：
  - 首战敌方行为链路一致（在当前项目定义的可观测粒度内）。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。

### 边界用例 1：不同 seed 结果应可区分

- 前置：准备两个不同种子 `S1 != S2`。
- 步骤：
  1. 用 `S1` 与 `S2` 分别开局。
  2. 比较前 1-3 层地图节点或首战行为链路。
- 期望：
  - 至少一个关键可观测项存在差异（节点序列或行为链路）。
- 结果：未运行时实测（当前环境无法完成 headless 运行闭环；已提供 GUI 复验步骤）。
