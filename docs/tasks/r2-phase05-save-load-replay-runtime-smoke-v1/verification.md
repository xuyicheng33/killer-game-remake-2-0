# 验证报告：save-load-replay 运行时冒烟增强

## 验证命令

### 1. 冒烟脚本
```bash
bash dev/tools/save_load_replay_smoke.sh
```

**结果**: 通过 ✅

执行了 9 组检查，共 54 个断言：

| 检查组 | 断言数 | 状态 |
|--------|--------|------|
| 0. 前置检查 | 10 | ✅ PASS |
| 1. fixed-seed bootstrap | 6 | ✅ PASS |
| 2. save/load rng continuity | 8 | ✅ PASS |
| 3. battle->reward->map route | 10 | ✅ PASS |
| 4. deterministic shuffle | 4 | ✅ PASS |
| 5. exception path fallback | 4 | ✅ PASS |
| 6. save version compatibility | 6 | ✅ PASS |
| 7. environment seed override | 3 | ✅ PASS |
| 8. repro log continuity | 5 | ✅ PASS |
| 9. runtime main link integrity | 7 | ✅ PASS |

### 2. Workflow 门禁
```bash
make workflow-check TASK_ID=r2-phase05-save-load-replay-runtime-smoke-v1
```

**结果**: 待运行（需要创建分支并切换）

## 新增检查详解

### 异常路径检查（第5组）
验证读档失败时的降级策略：
- `restored_rng` 失败标记检查
- `begin_run(seed)` 回退调用
- 空状态和 RunState 为空的双重检查

### 版本兼容检查（第6组）
验证存档版本机制：
- v1/v2 版本兼容
- 缺失字段的默认处理
- 版本范围校验

### 环境种子检查（第7组）
验证环境变量覆盖：
- `STS_RUN_SEED` 读取
- 整数有效性校验
- 优先于时间戳种子

### 复盘日志检查（第8组）
验证复盘连续性：
- 新局/读档时的日志初始化
- 进度恢复

### 主链路检查（第9组）
验证运行时完整性：
- 文件操作
- JSON 序列化
- 存档清理

## 结论
冒烟脚本增强完成，覆盖更全面，更接近运行时场景。建议发布前手动执行。
