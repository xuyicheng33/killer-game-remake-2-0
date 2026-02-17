# 任务交接：save-load-replay 运行时冒烟增强

## 任务 ID
`r2-phase05-save-load-replay-runtime-smoke-v1`

## 完成状态
已完成

## 改动文件

### 修改文件
- `dev/tools/save_load_replay_smoke.sh` - 增强版运行时冒烟验证脚本

### 新增文件
- `docs/tasks/r2-phase05-save-load-replay-runtime-smoke-v1/plan.md`
- `docs/tasks/r2-phase05-save-load-replay-runtime-smoke-v1/handoff.md`
- `docs/tasks/r2-phase05-save-load-replay-runtime-smoke-v1/verification.md`

## 冒烟脚本增强内容

### 保留的检查（4组）
1. **fixed-seed bootstrap check** - 固定种子新局一致性
2. **save/load rng continuity check** - 存档/读档随机流连续性
3. **battle->reward->map route smoke check** - 核心流程路由完整性
4. **deterministic shuffle smoke check** - 确定性洗牌实现

### 新增的检查（5组）
5. **exception path: restore failure fallback** - 异常路径检查
   - restore_run_state 失败后的 begin_run 回退
   - 空状态处理
   - load_run_state 失败处理
   - RunState 恢复失败处理

6. **save version compatibility check** - 存档版本兼容性
   - SAVE_VERSION / MIN_COMPAT_VERSION 常量
   - 版本兼容性校验逻辑
   - 旧版本默认处理（rng_state、save_version 默认值）

7. **environment seed override check** - 环境变量种子覆盖
   - STS_RUN_SEED 环境变量读取
   - 有效性校验
   - 优先逻辑

8. **repro log continuity check** - 复盘日志连续性
   - ReproLog 基础方法存在性
   - 新局时初始化
   - 读档时恢复

9. **runtime main link integrity check** - 运行时主链路完整性
   - 存档文件操作（FileAccess）
   - 数据序列化（JSON）
   - 存档清理功能
   - RunState 初始化

## 是否接入 workflow-check
**否**

原因：
- 此脚本与现有契约门禁（seed_rng_contract_check.sh、persistence_contract_check.sh）有部分重叠
- 冒烟验证更适合在 verification 阶段或发布前手动执行
- 避免 workflow-check 执行时间过长

## 使用说明
```bash
# 手动执行冒烟验证
bash dev/tools/save_load_replay_smoke.sh

# 发布前必做检查清单
- [ ] 运行 save_load_replay_smoke.sh 通过
- [ ] 运行 workflow-check 通过
- [ ] 所有契约门禁通过
```

## 提交信息
```
tools(seed_replay): 增强运行时冒烟验证（r2-phase05-save-load-replay-runtime-smoke-v1）
```
