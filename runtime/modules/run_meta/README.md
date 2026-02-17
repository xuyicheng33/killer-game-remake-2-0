# run_meta

状态：
- 已接入核心运行态（`runtime/modules/run_meta/run_state.gd`）

职责：
- 定义并维护 `RunState`（seed/act/floor/gold/map/deck/relic/potion）。
- 提供地图推进与牌组变更等跨场景状态写入口。
- 作为局内持久状态真源，向 UI 与流程层提供只读投影基础。

当前边界：
- 允许被 `app/map/reward/shop/event/relic_potion/persistence` 读取或调用公开接口。
- 不负责流程编排（该职责目标归属 `run_flow`）。
