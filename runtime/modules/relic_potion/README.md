# relic_potion

状态：
- Phase B / B4 `feat-relic-potion-core-v1`：已接入最小遗物/药水系统。
- 2026-02-23：完成首轮解耦重构（缓存/执行/药水使用服务拆分）。

职责：
- 遗物触发链管理（战斗开始 / 出牌后 / 受击后）。
- 药水使用入口与触发日志透出。

当前最小实现：
- `relic_potion_system.gd`：Facade，负责生命周期、事件订阅与跨服务编排。
- `relic_runtime_cache.gd`：遗物运行时对象缓存，避免重复实例化。
- `relic_effect_executor.gd`：遗物效果派发与状态写回。
- `potion_use_service.gd`：药水使用规则、目标解析与消耗策略。
