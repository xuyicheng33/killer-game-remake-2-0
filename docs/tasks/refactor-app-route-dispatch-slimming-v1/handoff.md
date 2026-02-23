# Handoff

## 变更摘要
- `app.gd` 路由处理从硬编码 `match` 改为字典化 handler，路由新增时改动点更集中。
- rest/shop/event 页面打开路径统一走 `_open_run_state_screen`，减少重复样板。
- 启动/继续流程复位逻辑统一走 `_reset_app_overlay_state`。

## 风险
- 路由处理改为 callable map 后，若 route key 拼写错误会回落到 map。
