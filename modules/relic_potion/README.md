# relic_potion

状态：
- Phase B / B4 `feat-relic-potion-core-v1`：已接入最小遗物/药水系统。

职责：
- 遗物触发链管理（战斗开始 / 出牌后 / 受击后）。
- 药水使用入口与触发日志透出。

当前最小实现：
- `relic_potion_system.gd`：绑定 `RunState`，监听全局事件并应用遗物触发效果。
