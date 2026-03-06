# references 说明

`references/` 是只读参考资料区，不参与运行时加载。

- `slay_the_spire_cn/`：当前参考资料索引输入源，供 `make content-index` 使用。
- `tutorial_baseline/`：只读人工对照工程，用于查阅教程基线实现，不接入日常运行时、测试和结构门禁之外的业务路径。

约束：

- 不在本目录写入运行时代码、导入产物、测试输出或临时草稿。
- 若未来需要外置/分仓处理，必须同步更新 `dev/tools/content_index.sh` 与相关文档口径。
