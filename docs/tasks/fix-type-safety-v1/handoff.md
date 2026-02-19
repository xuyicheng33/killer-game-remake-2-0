# handoff: fix-type-safety-v1

## 已完成
- 对高风险场景统一改为“先判型，后转换”：
  - `Dictionary.get(...)`
  - `load(...)`
  - `get_child(...)`
- 补充了 UI/ViewModel 和事件模块中的遗漏点。
- 新增 `dev/tools/type_safety_check.sh` 门禁脚本。
- 将类型安全门禁接入 `workflow_check.sh` 与 `Makefile`。

## 门禁策略
- 仅拦截高风险模式，不拦截 `.new/.instantiate/.duplicate` 等安全模式，避免误报。
