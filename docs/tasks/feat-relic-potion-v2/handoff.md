# 交接文档：feat-relic-potion-v2

**任务ID**: `feat-relic-potion-v2`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/relic_potion/relic_potion_system.gd` | 修改 | 触发时机枚举 + 信号扩展 |
| `content/custom_resources/relics/relic_data.gd` | 修改 | 新增触发字段 |
| `runtime/global/events.gd` | 修改 | 新增 `enemy_died` 信号 |

---

## 关键改动

### 触发时机枚举

```gdscript
enum TriggerType {
    ON_BATTLE_START, ON_TURN_START, ON_TURN_END,
    ON_CARD_PLAYED, ON_ATTACK_PLAYED, ON_SKILL_PLAYED,
    ON_DAMAGE_TAKEN, ON_BLOCK_APPLIED, ON_ENEMY_KILLED,
    ON_RUN_START, ON_SHOP_ENTER, ON_BOSS_KILLED,
}
```

### RelicData 新增字段

- `on_enemy_killed_gold`
- `on_turn_start_block`
- `on_turn_end_heal`
- `shop_discount_percent`

---

## 已知问题

无

---

## 建议 commit message

```
feat(relic_potion): implement trigger system (feat-relic-potion-v2)

- Add TriggerType enum
- Expand RelicData fields
- Add enemy_died signal
```
