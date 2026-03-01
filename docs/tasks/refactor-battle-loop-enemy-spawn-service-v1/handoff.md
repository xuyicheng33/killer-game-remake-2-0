# Handoff

## 变更摘要
- 新增 `EnemySpawnService`，集中处理遭遇解析、敌人实例化、位置布局与集合返回。
- `battle.gd` 改为调用服务完成敌人生成，保留场景层接线与生命周期职责。

## 风险
- 生成服务仍依赖 `EnemyHandler/Enemy` 场景类，后续可进一步抽象为契约接口。
