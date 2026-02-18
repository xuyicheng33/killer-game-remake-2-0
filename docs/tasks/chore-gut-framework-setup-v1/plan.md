# 任务规划：chore-gut-framework-setup-v1

**任务ID**: `chore-gut-framework-setup-v1`
**任务级别**: L1
**执行人**: 程序员
**阶段**: Phase 0 (GUT 框架接入)

---

## 目标

将 GUT (Godot Unit Testing) 框架接入项目，建立测试基础设施，为后续 Phase 的核心模块测试提供支持。

---

## 边界

新增 GUT 测试框架及测试目录结构。

## 白名单文件

- `addons/gut/`
- `dev/tests/`
- `Makefile`
- `dev/tools/run_gut_tests.sh`
- `project.godot`
- `docs/tasks/chore-gut-framework-setup-v1/`
- `docs/tasks/chore-baseline-alignment-v1/`
- `docs/master_plan_v3.md`
- `task_plan.md`
- `findings.md`
- `progress.md`

---

## 步骤

### 步骤 1: 下载并添加 GUT 插件

从 GitHub 下载 GUT 最新稳定版本：
- 仓库: https://github.com/bitwes/Gut
- 目标目录: `addons/gut/`

### 步骤 2: 建立测试目录结构

```
dev/tests/
├── unit/
│   ├── test_buff_system.gd     (冒烟占位)
│   ├── test_effect_stack.gd    (冒烟占位)
│   ├── test_card_zones.gd      (冒烟占位)
│   └── test_map_generator.gd   (冒烟占位)
└── integration/
    └── test_battle_flow.gd     (冒烟占位)
```

### 步骤 3: 编写冒烟测试

创建 `test_gut_smoke.gd`:
```gdscript
extends GutTest

func test_gut_framework_available():
    assert_true(true, "GUT 框架可用")
```

### 步骤 4: 在 Makefile 添加 `make test` 目标

```makefile
test:
    @godot --headless --script addons/gut/gut_cmdln.gd -d -gdir=res://dev/tests -gexit
```

---

## 验收标准

- [ ] `addons/gut/` 目录存在且包含 GUT 插件
- [ ] `dev/tests/` 目录结构完整
- [ ] `make test` 运行成功
- [ ] 冒烟测试通过

---

## 风险

- GUT 插件版本兼容性: 需确认与项目 Godot 版本兼容
- 命令行模式执行: 需确认 godot 命令在 PATH 中

---

## 前置检查

- [ ] 确认项目 Godot 版本
- [ ] 确认 godot 命令可用

---

## 预期产出

- GUT 插件完整接入
- 测试目录结构建立
- `make test` 可执行
- 冒烟测试通过
