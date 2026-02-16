# ui_shell

状态：
- 部分实现（代码当前在 `scenes/ui/*.gd`）

职责：
- 承载 UI 展示与交互壳层。
- 读取模块输出并刷新界面，不拥有核心业务状态。

现状映射：
- `scenes/ui/battle_ui.gd`：展示回合 UI + 牌区计数。
- `scenes/ui/stats_ui.gd`：展示属性与状态徽章。
- `scenes/ui/relic_potion_ui.gd`：展示遗物/药水与触发日志。

边界约束：
- 禁止在 UI 脚本中新增效果结算、敌方决策、存档读写逻辑。
