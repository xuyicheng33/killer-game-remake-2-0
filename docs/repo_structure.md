# 仓库结构说明（模块化）

## 顶层目录

- `scenes/`：运行时场景入口与UI展示
- `modules/`：按领域拆分的模块目录（架构主线）
- `characters/` `enemies/` `effects/` `custom_resources/`：过渡期legacy内容目录
- `global/`：全局事件与公共节点
- `tools/`：流程与内容工具脚本
- `docs/`：规范、任务、路线图、分析文档
- `references/`：只读参考资料（教程基线 + 原版资料）

## references 说明

- `references/tutorial_baseline/`：教程工程只读基线（已 `.gdignore`）
- `references/slay_the_spire_cn/`：原版资料参考库

## 迁移原则

1. 新功能优先写入 `modules/<module>/`。
2. 旧目录的代码按任务逐步迁移，不一次性大挪动。
3. 场景层(`scenes`)只做展示与编排，不承载复杂规则。
