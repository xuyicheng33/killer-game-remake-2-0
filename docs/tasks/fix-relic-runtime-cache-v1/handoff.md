# Handoff: fix-relic-runtime-cache-v1

## 交付摘要

此任务已在前期实现。遗物运行时对象现在被缓存复用，支持跨触发状态维护。

## 实现方案

1. `RelicPotionSystem` 初始化时创建 `_relic_runtimes: Dictionary` 字典
2. `bind_run_state()` 调用 `_rebuild_relic_runtime_cache()` 构建缓存
3. `_fire_trigger()` 使用 `_get_or_create_relic_runtime()` 获取缓存对象

## 改动文件

（前期已完成）
- `runtime/modules/relic_potion/relic_potion_system.gd`
- `dev/tests/unit/test_relic_potion.gd`

## 测试覆盖

- `test_relic_runtime_cache_reuses_same_instance()`
- `test_relic_runtime_cache_duplicate_id_shares_state()`
- `test_relic_runtime_cache_clears_on_rebind()`

## 建议提交信息

（无需单独提交，已在前期实现）
