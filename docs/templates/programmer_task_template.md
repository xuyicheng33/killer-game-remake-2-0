# 程序员任务卡模板

适用对象：AI 编程员（主职责：按卡实现、验证、交付）

---

## 任务元信息

| 字段 | 值 |
|---|---|
| 任务 ID | `<task-id>` |
| 任务等级 | `<L0/L1/L2>` |
| 主模块 | `<module>` |

---

## 目标

`<一句话描述本阶段核心目标>`

---

## 本任务边界

1. 只做 `<scope>`，不改 `<out_of_scope>`。
2. 不得跨模块扩改，不得改玩法语义（除非任务明确要求）。

---

## 必做项

1. `<must_do_1>`
2. `<must_do_2>`
3. `<must_do_3>`

---

## 白名单文件

仅允许修改以下文件：

- `<path_1>`
- `<path_2>`
- `<path_3>`

---

## 任务三件套（必须维护）

| 文件 | 职责 |
|---|---|
| `docs/tasks/<task-id>/plan.md` | 实现计划与设计决策 |
| `docs/tasks/<task-id>/handoff.md` | 交接说明与注意事项 |
| `docs/tasks/<task-id>/verification.md` | 验证命令与结果截图 |

---

## 验证命令

必须贴真实输出摘要：

```bash
# 1. 验证命令 1
<cmd_1>

# 2. 验证命令 2
<cmd_2>

# 3. workflow 门禁
make workflow-check TASK_ID=<task-id>
```

---

## 禁止项

- [ ] 不做跨模块顺手重构
- [ ] 不改白名单外文件
- [ ] 不省略三件套
- [ ] 不写"理论通过"，必须贴真实命令输出

---

## 交付要求

1. `verification.md` 必须可复现，不写"理论通过"。
2. `handoff.md` 的 workflow-check 状态必须与实际一致。
3. 给出建议 commit message（符合仓库规范）。

---

## 建议 Commit Message 格式

```
<type>(<scope>): <short description>（<task-id>）

- <detail_1>
- <detail_2>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

类型（type）选择：
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档变更
- `refactor`: 重构（不改变功能）
- `test`: 测试相关
- `chore`: 构建/工具/脚手架
