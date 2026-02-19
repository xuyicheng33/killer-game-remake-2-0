# Task: content-cards-chinese-v1

## Verification Summary

**Date**: 2026-02-19
**Status**: COMPLETED

## Changes Made

Translated all 20 cards in `warrior_cards.json` from English to Chinese:

| ID | Chinese Name | Chinese Text |
|----|--------------|--------------|
| warrior_axe_attack | 斧击 | 造成 6 点伤害。 |
| warrior_block | 防御 | 获得 5 点格挡。 |
| warrior_slash | 回旋斩 | 对所有敌人造成 4 点伤害。 |
| warrior_pipeline_bash | 管道猛击 | 造成 5 点伤害。施加 1 层易伤。 |
| warrior_guard_stance | 防御姿态 | 获得 8 点格挡。 |
| warrior_berserker_form | 狂战士形态 | 获得 1 点力量。 |
| warrior_last_stand | 背水一战 | 造成 10 点伤害。消耗。 |
| warrior_whirlwind_x | 旋风斩 | X费。对所有敌人造成 2 点伤害。 |
| warrior_quick_cut | 快斩 | 造成 4 点伤害。 |
| warrior_heavy_chop | 重劈 | 造成 8 点伤害。 |
| warrior_twin_strike | 双击 | 造成 3 点伤害两次。 |
| warrior_condition_rend | 撕裂斩 | 若目标有虚弱，造成额外伤害。施加 1 层易伤。 |
| warrior_finisher_attack | 处决劈砍 | 若目标有易伤，造成额外伤害。消耗。消耗时，将一张升级版加入弃牌堆。 |
| warrior_shield_wall | 盾墙 | 获得 12 点格挡。 |
| warrior_tactical_breath | 战术呼吸 | 抽 1 张牌。 |
| warrior_battle_focus | 战斗专注 | 获得 1 点能量。 |
| warrior_intimidate | 威吓 | 施加 2 层虚弱。 |
| warrior_crush_armor | 破甲 | 施加 2 层易伤。 |
| warrior_iron_will | 钢铁意志 | 获得 2 点敏捷。 |
| warrior_blood_oath | 鲜血誓言 | 特殊：获得 2 点力量和 1 点敏捷。 |

## Verification

- `python3 dev/tools/content_import_cards.py` succeeded
- 20 cards imported, 41 output files generated
- All 131 GUT tests pass

## Acceptance Criteria

- [x] All 20 cards have Chinese `name`
- [x] All 20 cards have Chinese `text`
- [x] Content import runs successfully
