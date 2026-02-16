# 任务计划

## 基本信息

- 任务 ID：`feat-rest-shop-event-v1`
- 任务级别：`L2`
- 主模块：`map_event`（协同 `reward_economy`）
- 负责人：Codex
- 日期：2026-02-16

## 目标

实现 Phase B / B3 最小可用流程：营火二选一、商店买卡/删卡、事件节点可触发并回写状态，且完成后可继续 B2 地图推进。

## 审批门槛（必须）

- 本任务为 `L2`，先完成文档后停在审批点。
- 在你回复“批准”前，不进行任何代码实现。

## 范围边界

- 包含：
  - 营火：休息 / 升级（二选一）
  - 商店：买卡 / 删卡（最小可用）
  - 事件：统一事件框架 + 至少 10 条可触发基础事件数据
  - 节点完成后回写 `RunState` 并继续地图推进
- 不包含：
  - B4 遗物药水
  - C/D 阶段内容
  - 视觉重构

## 改动白名单文件

- `docs/tasks/feat-rest-shop-event-v1/**`
- `modules/map_event/**`
- `modules/reward_economy/**`
- `scenes/map/**`
- `scenes/events/**`
- `scenes/shop/**`
- `scenes/app/**`
- `modules/run_meta/**`
- `docs/contracts/run_state.md`

## 实施步骤（审批后执行）

1. 梳理当前 B2 节点流转（REST/SHOP/EVENT 的占位逻辑）并确定最小插入点。
2. 设计并实现事件框架与 10 条基础事件模板数据。
3. 实现营火页面（休息/升级）并写回 `RunState`。
4. 实现商店页面（买卡/删卡）并写回金币与牌组。
5. 将 REST/SHOP/EVENT 从占位改为对应页面流程，确保完成后返回地图且可达性正确推进。
6. 更新契约文档（如需）与三件套验证/交接结果。

## 验证方案（审批后执行）

1. `make workflow-check TASK_ID=feat-rest-shop-event-v1`
2. Godot 4.6 CLI：
   - `godot4.6 --version`
   - `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`
3. 功能验证：至少 2 条主路径 + 1 条边界用例。

## 风险与回滚

- 风险：
  - B3 节点流程与 B2 可达性推进耦合，可能导致“完成节点后无法继续推进”。
  - 商店买卡/删卡操作牌组时，若卡资源处理不当可能引入重复引用或删除异常。
  - 事件模板数量增加后，若随机选择与回写耦合不清，可能出现状态不一致。
- 回滚方式：
  - 回滚本任务提交，恢复到 B2 的 REST/SHOP/EVENT 占位推进逻辑。

