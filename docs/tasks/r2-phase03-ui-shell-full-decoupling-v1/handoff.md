# 交接文档

## 任务信息

- 任务 ID：`r2-phase03-ui-shell-full-decoupling-v1`
- 完成时间：2026-02-17
- 实现者：Claude

## 交付物清单

| 文件路径 | 状态 | 说明 |
|---------|------|------|
| `runtime/modules/ui_shell/viewmodel/map_ui_view_model.gd` | 新建 | 地图界面投影计算 |
| `runtime/modules/ui_shell/viewmodel/rest_ui_view_model.gd` | 新建 | 休息界面投影计算 |
| `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd` | 新建 | 商店界面投影计算 |
| `runtime/modules/ui_shell/viewmodel/event_ui_view_model.gd` | 新建 | 事件界面投影计算 |
| `runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd` | 新建 | 奖励界面投影计算 |
| `runtime/modules/ui_shell/adapter/map_ui_adapter.gd` | 新建 | 地图界面适配器 |
| `runtime/modules/ui_shell/adapter/rest_ui_adapter.gd` | 新建 | 休息界面适配器 |
| `runtime/modules/ui_shell/adapter/shop_ui_adapter.gd` | 新建 | 商店界面适配器 |
| `runtime/modules/ui_shell/adapter/event_ui_adapter.gd` | 新建 | 事件界面适配器 |
| `runtime/modules/ui_shell/adapter/reward_ui_adapter.gd` | 新建 | 奖励界面适配器 |
| `runtime/modules/ui_shell/README.md` | 修改 | 更新架构映射文档 |
| `runtime/scenes/map/map_screen.gd` | 修改 | 改为使用 MapUIAdapter |
| `runtime/scenes/map/rest_screen.gd` | 修改 | 改为使用 RestUIAdapter |
| `runtime/scenes/shop/shop_screen.gd` | 修改 | 改为使用 ShopUIAdapter |
| `runtime/scenes/events/event_screen.gd` | 修改 | 改为使用 EventUIAdapter |
| `runtime/scenes/reward/reward_screen.gd` | 修改 | 改为使用 RewardUIAdapter |
| `docs/work_logs/2026-02.md` | 修改 | 追加 R2 Phase 3 工作日志 |

## 架构变更说明

### 壳层架构模式

每个 UI 页面现在遵循统一的 `scene -> adapter -> viewmodel` 架构：

1. **ViewModel**：纯数据投影层，接收原始数据，返回格式化的 Dictionary 投影。不持有状态，只做数据转换。

2. **Adapter**：作为桥梁，持有 ViewModel 实例，监听数据源变化，调用 ViewModel 生成投影，通过 signal 通知 UI 层。转发用户命令到 flow_service。

3. **Scene**：纯展示层，读取 adapter 投影渲染 UI，将用户交互转发给 adapter。

### 新增文件职责

| 文件 | 职责 |
|-----|------|
| `map_ui_view_model.gd` | 将 RunState/MapGraphData 投影为地图节点展示数据 |
| `rest_ui_view_model.gd` | 将 RunState 投影为休息界面展示数据 |
| `shop_ui_view_model.gd` | 将 RunState/商店商品投影为商店界面展示数据 |
| `event_ui_view_model.gd` | 将事件模板投影为事件界面展示数据 |
| `reward_ui_view_model.gd` | 将 RewardBundle 投影为奖励界面展示数据 |
| `map_ui_adapter.gd` | 监听 RunState.changed，推送地图投影，转发节点选择/重启命令 |
| `rest_ui_adapter.gd` | 监听 RunState.changed，推送休息界面投影，转发休息/升级命令 |
| `shop_ui_adapter.gd` | 监听 RunState.changed，推送商店投影，转发购买/移除/离开命令 |
| `event_ui_adapter.gd` | 推送事件投影，转发选项选择/继续命令 |
| `reward_ui_adapter.gd` | 推送奖励投影，转发卡牌选择/跳过命令 |

## 后续任务建议

1. R2 Phase 4：扩展 run_flow 分支契约回归门禁
2. 考虑为新增 adapter 添加契约检查规则

## 已知风险

- 验证命令 `grep -l "adapter" runtime/scenes/rest/*.gd` 可能因路径不存在而失败（rest_screen.gd 在 map 目录下）
