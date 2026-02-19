# 设计提案

## 任务 ID
`feat-card-exhaust-upgrade-on-consume-v1`

## 目标

- 将“消耗后升级”从文案/数据标注变成可执行机制。
- 保持数据驱动：复用 `upgrade_to` 字段，不新增硬编码卡牌分支。

## 非目标

- 不新增全套升级卡资源池。
- 不改战斗主状态机与回合阶段切换。

## 方案 A（采用）

1. 在 `Card` 增加 `upgrade_to` 字段与 `create_exhaust_upgrade_copy()`：
   - 复制当前卡。
   - `id` 替换为 `upgrade_to`。
   - `cost` -1（最低 0）。
   - `upgrade_to` 清空，避免链式升级。
2. 在 `CardZonesModel` 的消耗流程中：
   - 原卡照常进入消耗堆。
   - 若存在升级副本，加入弃牌堆，等待后续抽取。
3. 导入器写入 `.tres` 的 `upgrade_to` 字段。
4. `SaveService` 补 `upgrade_to` 序列化/反序列化。
5. 增加测试：
   - `CardZonesModel` 机制行为。
   - `SaveService` 字段往返。

优点：
- 复用现有链路，改动集中。
- 行为可验证、可回归。

缺点：
- 升级副本数值目前采用“费用-1”的统一规则，不支持每张卡独立升级配置。

## 方案 B

- 仅移除卡面文案与 `upgrade_to` 字段。

缺点：
- 无法满足 Phase 3b“强化（消耗后升级）×1”验收语义。

## 对存档与种子影响

- 存档：新增 `upgrade_to` 卡字段序列化，兼容旧档默认空字符串。
- 种子一致性：不新增随机源，仅改变出牌后牌堆状态。

## 验收建议

- 至少 1 张卡在 `keyword_exhaust + upgrade_to` 下可观察到升级副本入弃牌堆。
- `make test` 全通过，含新测试。
- `make workflow-check TASK_ID=feat-card-exhaust-upgrade-on-consume-v1` 通过。
