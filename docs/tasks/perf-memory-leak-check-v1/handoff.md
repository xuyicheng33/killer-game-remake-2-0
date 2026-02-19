# 任务交接

## 基本信息

- 任务 ID：`perf-memory-leak-check-v1`
- 主模块：`dev/tools`, `dev/tests/perf`
- 提交人：Codex
- 日期：2026-02-20

## 当前状态

- 状态：`已完成`

## 改动摘要

- 创建 Soak 测试脚本 `dev/tools/soak_test.sh`
- 新增内存测试套件 `dev/tests/perf/test_scene_switch_memory.gd`
- 测试数量从 126 增加到 131

## 变更文件

- `dev/tools/soak_test.sh` (新增)
- `dev/tests/perf/test_scene_switch_memory.gd` (新增)

## 风险与影响范围

- Soak 测试默认运行 10 个周期，可通过参数调整
- 内存测试使用 Godot Performance Monitor API

## 使用方式

```bash
bash dev/tools/soak_test.sh [cycles]
```

## 建议提交信息

- `test(perf): add soak test and memory leak detection tests`

## 审核员结论

- 结论：通过，内存泄漏检测功能已就位。
