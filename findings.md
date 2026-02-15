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
- 当前最大功能缺口仍在 `effect_engine/buff_system/relic_potion/reward_economy/save_seed_replay`。
- 已新增模块骨架目录，后续任务可按模块独立派发与验收。
