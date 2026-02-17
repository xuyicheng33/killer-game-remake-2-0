# 任务交接：run_flow 回归门禁扩展

## 任务 ID
`r2-phase04-run-flow-regression-gate-v1`

## 完成状态
已完成

## 改动文件

### 新增文件
- `dev/tools/run_flow_regression_check.sh` - run_flow 非战斗分支回归门禁脚本

### 修改文件
- `dev/tools/workflow_check.sh` - 接入新门禁到 workflow-check 链路

## 门禁功能说明

### 覆盖范围
1. **rest_flow_service** - 休息分支
   - 检查 _result 封装函数存在性
   - 检查是否调用 route_dispatcher.make_result
   - 检查返回键位（completed, info_text）

2. **shop_flow_service** - 商店分支
   - 检查 _result 封装函数存在性
   - 检查是否调用 route_dispatcher.make_result
   - 检查返回键位（handled, status_text）

3. **event_flow_service** - 事件分支
   - 检查 _result 封装函数存在性
   - 检查返回类型（当前与路由契约不符）

### 检测策略
- 使用 WARN 级别暴露契约偏差（不阻塞，仅报告）
- 保留后续改造空间，业务代码零改动

## 当前发现的问题
1. rest_flow_service._result 返回手写字典，未使用 route_dispatcher.make_result
2. shop_flow_service._result 返回手写字典，未使用 route_dispatcher.make_result
3. event_flow_service 缺少 _result 封装，execute_option 返回 String 而非 Dictionary

## 后续建议
- 后续任务可针对这些问题进行契约对齐改造
- 改造完成后可将相关 WARN 升级为 FAIL 实现强制门禁

## 提交信息
```
tools(run_flow): 扩展回归门禁覆盖 rest/shop/event 分支（r2-phase04-run-flow-regression-gate-v1）
```
