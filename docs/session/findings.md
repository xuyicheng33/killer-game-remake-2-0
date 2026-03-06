# Findings

## 2026-02-15 参考库分析

- 参考库体量：卡牌 446、遗物 184、能力 139、事件 57、敌人 51、药水 47、角色 4。
- 内容密度最高在“卡牌 + 状态 + 遗物联动”，应先保证 effect/buff 结算正确性。
- 参考条目普遍包含中英文名、ID、类型、稀有度、耗能/效果、更新历史，可直接映射为内容管线字段。
- 敌人资料有“动作规律与约束”（如不可连续动作、进阶数值差异），说明敌人模块需要规则约束层，不应只靠随机权重。

## 2026-02-15 工程与流程

- 根目录已导入教程的战斗 UI/交互层资源与脚本。
- 新增模块骨架：`run_meta`、`map_event`，并通过 `scenes/app` 串联流程。
- 战斗结束逻辑已改为信号回传流程，不再直接退出程序。
- 已初始化 Git 仓库，分支为 `main`。
- `workflow-check` 已升级为：强制 TASK_ID、强制任务三件套、校验任务白名单。

## 2026-02-15 风险提醒

- 当前 battle 规则内核仍是 legacy 版本；后续应逐步替换为可测试的纯规则层。
- 首次提交规模会较大，建议后续模块开发按任务分支细粒度拆提交。

## 2026-02-15 运行报错定位

- `RunState` 作为 `Resource` 不应自定义 `signal changed`，应使用内建 `changed` + `emit_changed()`。
- 项目内保留教程全量目录会造成重复 `class_name` 注册风险；已在教程目录添加 `.gdignore` 作为只读参考。

## 2026-02-15 结构重构补充

- 目录已重构为 `references/tutorial_baseline` 与 `references/slay_the_spire_cn`，参考资料与运行代码分离更清晰。
- 当前最大功能缺口仍在 `effect_engine/buff_system/relic_potion/reward_economy/seed_replay`。
- 已新增模块骨架目录，后续任务可按模块独立派发与验收。

## 2026-02-17 Phase6 UI Shell 化调研

- `scenes/ui/stats_ui.gd` 当前直接依赖 `BuffSystem.get_status_badges`，UI 脚本同时承担了“状态投影计算 + 组件渲染”两层职责。
- `scenes/ui/relic_potion_ui.gd` 当前直接读取 `RunState` 拼接文案、计算可见性、创建按钮，并直接调用 `relic_potion_system.use_potion(index)`。
- 现有流程中药水使用业务已封装在 `RelicPotionSystem` / `RunState.use_potion_at`，可通过 adapter 转发命令实现“UI 不直接写规则”。
- `modules/ui_shell` 目前只有 README，无 viewmodel/adapter 实现，可作为本次首批样板落点。

## 2026-02-17 Phase6 UI Shell 化结果

- `stats_ui` 与 `relic_potion_ui` 已完成首批迁移：UI 改为“读 adapter 投影 + 发 adapter 命令”。
- 静态检索 `run_state\\.(set_|add_|remove_|clear_|advance_|mark_|apply_)` 在 `scenes/ui` 无命中。
- `workflow-check` 对 `TASK_ID=phase6-ui-shell-viewmodel-decoupling-v1` 已通过。

## 2026-02-17 Phase7 质量门禁调研与结论

- `dev/tools/run_flow_contract_check.sh` 原有检查覆盖了核心路由分支与部分 payload 键，但未显式约束 `ROUTE_*` 单点定义。
- `workflow_check.sh` 原流程只做脚手架/分支/白名单校验，尚未串行执行模块契约门禁脚本。
- `stats_ui` 与 `relic_potion_ui` 的 adapter/viewmodel 链路已具备，可直接固化为脚本约束，防止回退到场景脚本直连业务。

## 2026-02-17 Phase7 质量门禁结果

- 新增 `dev/tools/ui_shell_contract_check.sh`，已覆盖：
  - `scenes/ui` 禁止 `run_state.set_/add_/remove_/clear_/advance_/mark_/apply_` 直写。
  - `stats/relic_potion` 页面必须走 adapter -> viewmodel 接入。
- 扩展 `dev/tools/run_flow_contract_check.sh`，已覆盖：
  - `ROUTE_*` 常量单点定义锁定到 `route_dispatcher.gd`。
  - map/battle 关键 `next_route + payload` 键位回归检查。
- `dev/tools/workflow_check.sh` 已串行执行两个门禁脚本，形成提交前可一键执行的质量门禁入口。

## 2026-03-06 稳定性收口后的文档口径

- 当前项目口径应统一为“2026-03-06 真实基线”：A/B/C 主链能力已落地，D1 已启动且在继续收口。
- `task_backlog` 不应再把 `battle_loop / effect_engine / buff_system / reward_flow / save_load / seed / content_pipeline` 标成 ready 或 blocked；这些能力已进入当前运行基线。
- README、路线图、进度与任务档案的推荐优先级应统一为：`art-ui-theme-rebuild-v1` + 非阻断工程清理（encounter coverage warning、orphan/resource leak）。
- 当前测试/CI 口径应统一为：本地 `make ci-check`、`make test` 均通过；测试脚本支持自动 Godot import 预热；远端 CI 也运行真实 Godot 校验。
- 当前保留问题也应统一描述为“warning / 已知保留项”，而不是“主流程未实现”或“模块仍处于骨架阶段”。
