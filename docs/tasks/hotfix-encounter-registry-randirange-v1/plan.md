# 任务规划：encounter_registry randi_range 参数顺序修复

## 任务 ID
`hotfix-encounter-registry-randirange-v1`

## 问题
`encounter_registry.gd:106` 中 `randi_range` 参数顺序错误，导致游戏无法启动。

## 修复
`randi_range(1, total_weight, rng_stream_key)` 改为 `randi_range(rng_stream_key, 1, total_weight)`

## 白名单文件
- runtime/modules/enemy_intent/encounter_registry.gd
