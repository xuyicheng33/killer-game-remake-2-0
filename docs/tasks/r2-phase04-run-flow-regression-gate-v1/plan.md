# 任务规划：run_flow 回归门禁扩展

## 任务 ID
`r2-phase04-run-flow-regression-gate-v1`

## 目标
补齐 `rest/shop/event` 分支 payload 契约回归门禁，确保 run_flow 所有主分支均有脚本化契约保护。

## 范围
- **包含**：
  - 新建 `dev/tools/run_flow_regression_check.sh`
  - 覆盖 rest/shop/event 三条非战斗分支的返回键位与路由一致性
  - 校验这些分支通过 `route_dispatcher.make_result` 构造返回（或存在对应的 _result 封装）
  - 接入 `workflow-check`
  - 任务三件套
- **不包含**：
  - 不改变 flow_service 业务逻辑
  - 不改变路由常量或 payload 结构

## 白名单文件
- dev/tools/run_flow_regression_check.sh
- dev/tools/workflow_check.sh
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase04-run-flow-regression-gate-v1/

## 实现步骤
1. 分析现有 rest/shop/event 服务的返回结构
2. 设计门禁检查规则：
   - 检测是否使用 route_dispatcher.make_result 或封装的 _result
   - 检测返回键位是否符合规范
   - 禁止直接返回手写字典
3. 编写门禁脚本
4. 更新 workflow-check 接入
5. 运行验证

## 风险
- 低：仅新增检查脚本，不改业务代码
- 当前实现可能不通过检查，但这是预期行为（暴露问题）

## 验收标准
- [ ] run_flow_regression_check.sh 创建并运行
- [ ] workflow-check 接入新门禁
- [ ] 任务三件套通过门禁检查
