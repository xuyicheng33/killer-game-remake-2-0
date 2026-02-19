# Handoff: fix-rest-upgrade-consistency-v1

## 交付摘要

此任务已在前期实现。营地升级现在优先使用 `upgrade_to` 字段，与 Exhaust 升级行为一致。

## 实现方案

```gdscript
# run_state.gd:upgrade_card_in_deck_at()
var target_id := base_card.upgrade_to.strip_edges()
if not target_id.is_empty():
    upgraded.id = target_id
    upgraded.upgrade_to = ""
else:
    # 回退到硬编码行为（向后兼容）
    upgraded.id = "%s+" % upgraded.id
```

## 改动文件

（前期已完成）
- `runtime/modules/run_meta/run_state.gd`
- `dev/tests/integration/test_battle_flow.gd`

## 测试覆盖

- `test_rest_screen_upgrade_uses_upgrade_to_field()`
- `test_rest_screen_upgrade_fallback_to_hardcoded()`

## 建议提交信息

（无需单独提交，已在前期实现）
