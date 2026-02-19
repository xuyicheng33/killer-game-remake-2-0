# Task: content-cards-chinese-v1

**Task ID**: 7B-2a
**Level**: L1
**Status**: COMPLETED

## Objective

Translate card data in `warrior_cards.json` from English to Chinese for `name` and `text` fields.

## Field Requirements

Per `content_import_cards.py:34`:
- `name`: Card name (Chinese)
- `text`: Effect description (Chinese)

## Implementation

Translate all 20 cards in `warrior_cards.json`:

| ID | English Name | Chinese Name | English Text | Chinese Text |
|----|--------------|--------------|--------------|--------------|

## Files to Modify

- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json`
- `content/characters/warrior/cards/generated/*.tres`
- `runtime/modules/content_pipeline/reports/card_import_report.json`

## Acceptance Criteria

- [x] All 20 cards have Chinese `name`
- [x] All 20 cards have Chinese `text`
- [x] `python dev/tools/content_import_cards.py` runs successfully
