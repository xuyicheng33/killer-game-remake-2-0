# AGENTS.md（协作规范 v2.1）

## 1. 项目目标
- 使用 Godot 复刻类杀戮尖塔核心体验，并在稳定复刻基础上做机制创新与新卡设计。
- 开发方式采用“多 AI 串行协作 + 强制交接 + Git 可回滚节点”。
- 优先保证：机制正确性 > 可维护性 > 开发速度。

## 2. 协作角色
- 用户：产品与机制总负责人，做方向决策与最终验收。
- AI：模块执行者，必须按任务边界实施并提供可审计结果。
- 每个 AI 只对“当前任务卡”负责，不扩展无关需求。

## 3. 任务分级与审批
### L0（快车道）
- 定义：纯文档、小修、低风险、单文件。
- 规则：可直接执行，结束后补交接。

### L1（标准）
- 定义：单模块内代码改动，影响面可控。
- 规则：先写任务规划，再执行。

### L2（高风险）
- 定义：跨模块、存档结构变化、战斗结算链路变化。
- 规则：必须先审批（回复“批准”）后执行。

## 4. 串行协作基本原则
1. 一次只做一个任务 ID。
2. 一个任务只允许一个“主模块”。
3. 每次交付必须包含：改动文件、验证结果、风险、下一步。
4. 禁止“顺手重构”跨模块逻辑。
5. 遇到边界不清先停，提 1-2 个可选方案。

## 5. 模块化边界（必须遵守）
详细边界见 `docs/module_architecture.md`。

- `run_meta`：局外流程（开局、角色、种子、进阶、结算）
- `battle_loop`：回合状态机、阶段切换、行动窗口
- `card_system`：卡牌实体、区域流转（抽牌堆/手牌/弃牌堆/消耗堆）
- `effect_engine`：效果执行与结算栈
- `buff_system`：力量/敏捷/易伤/虚弱/脆弱等状态体系
- `enemy_intent`：敌人行为脚本与意图展示
- `map_event`：地图节点、问号事件、路线推进
- `reward_economy`：金币/奖励三选一/商店/移卡
- `relic_potion`：遗物触发与药水使用
- `seed_replay`：存档、随机数、复盘
- `content_pipeline`：数据表与平衡迭代
- `ui_shell`：UI 展示层（不承载核心规则）

## 6. 开发与验证要求
1. 先写后改：先给任务规划，再改代码/文档。
2. 最小改动：仅改任务白名单文件。
3. 可验证：至少提供 1 条可复现验证步骤。
4. 回归意识：说明可能影响的链路。
5. 可读性：命名清晰，避免魔法值，必要时加短注释。

## 7. Git 协作规范
### 前置
- 协作根目录建议初始化为 Git 仓库；若未初始化，先执行：`git init`。
- 当前玩法代码基线目录为：`references/tutorial_baseline/`。

### 分支
- `main`：稳定分支，仅合并通过验收的任务。
- `feat/<module>-<task-id>`：功能任务。
- `fix/<module>-<task-id>`：缺陷任务。
- `chore/<scope>-<task-id>`：文档/工具任务。

### 提交
- 一个任务至少一个可回滚提交。
- 提交信息格式：
  - `feat(module): 变更内容（任务ID）`
  - `fix(module): 修复内容（任务ID）`
  - `docs(scope): 文档更新（任务ID）`

### 禁止
- 不混入无关文件。
- 不把多个模块的大改塞进同一提交。
- 任何破坏性操作前必须确认。

### 自动化守门（新增）
- 提交前必须执行：`make workflow-check`。
- 推荐安装 pre-commit：`make install-hooks`。
- 分支命名必须匹配：`feat|fix|chore/<module>-<task-id>`。

### 常用命令
- `make content-index`：生成参考库索引与重复报告。
- `make workflow-check`：检查分支命名、任务产物、白名单边界。
- `make install-hooks`：安装本地 pre-commit 守门脚本。
- `make new-task TASK_ID=<task-id>`：创建任务目录与三件套模板。

## 8. 文档与交接规范
- 每次任务完成后更新 `docs/work_logs/YYYY-MM.md`。
- 新月份创建当月日志文件，并在 `docs/work_log.md` 维护索引。
- 任务执行前使用 `docs/task_plan_template.md`。
- 任务结束后输出 `docs/handoff_template.md` 对应信息。
- 新概念写入 `docs/glossary.md`。
- 每个任务必须维护目录：`docs/tasks/<task-id>/`。
- 任务目录最小产物：`plan.md`、`handoff.md`、`verification.md`。

## 9. 接口契约与版本
- 跨模块共享结构（如 `BattleState` / `RunState`）必须记录在 `docs/contracts/`。
- 契约变更默认 L2，必须审批。
- 兼容变更升级 MINOR，非兼容变更升级 MAJOR，并在交接中写明影响范围。

## 10. 完成定义（DoD）
- [ ] 功能达到任务目标与边界。
- [ ] 关键机制验证通过（含至少一个异常/边界用例）。
- [ ] 改动文件在白名单内。
- [ ] 已更新日志与交接摘要。
- [ ] 已给出建议 commit message（或已提交）。
- [ ] `make workflow-check` 通过。

## 11. 冲突处理
- 本规范与单次任务卡冲突时，以“任务卡”优先。
- 本规范与用户当次明确指令冲突时，以用户指令优先。

## 12. 当前项目关键前置项
1. 先完成 `content_pipeline`（参考数据清洗）再大规模写玩法逻辑。
2. 战斗主循环与效果引擎优先实现，再接卡牌/敌人内容填充。
3. 首批玩法任务开始前，确保 `make workflow-check` 和 `make content-index` 可稳定执行。

## 13. 仓库布局约定
1. 协作根目录：`/Users/xuyicheng/杀戮游戏复刻2.0`。
2. 教程基线工程：`references/tutorial_baseline/`。
3. 协作文档与流程脚本位于协作根目录：`docs/`、`tools/`、`Makefile`。
4. 参考资料库目录：`references/slay_the_spire_cn/`（由 `make content-index` 生成索引）。
