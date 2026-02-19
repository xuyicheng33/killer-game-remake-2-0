# Plan: fix-relic-runtime-cache-v1

## 任务元信息

- 任务ID: fix-relic-runtime-cache-v1
- 等级: L1（单模块：relic_potion）
- 主模块: relic_potion
- 优先级: P1（性能 + 状态追踪问题）

## 目标

修复每次遗物触发都实例化全新遗物对象的问题，改为缓存复用，解决：
1. 无法维护跨触发的遗物状态
2. 频繁 GC 压力

## 状态说明

此任务已在前期实现：
- `relic_potion_system.gd` 使用 `_relic_runtimes: Dictionary` 缓存遗物运行时对象
- `_rebuild_relic_runtime_cache()` 在绑定 RunState 时构建缓存
- `_get_or_create_relic_runtime()` 从缓存获取或创建运行时对象
- GUT 测试已覆盖：`test_relic_runtime_cache_reuses_same_instance()`

## 白名单文件

- runtime/modules/relic_potion/relic_potion_system.gd
- dev/tests/unit/test_relic_potion.gd

## 验证命令

```bash
make test
```

## 状态: COMPLETED
