# content_pipeline

Status:
- C3 minimum usable path is implemented for cards.

Implemented in `feat-content-pipeline-v1`:
- Card schema validation (required fields, enums, type checks, duplicate ID checks).
- Card import command that generates runtime card scripts/resources.
- Error report output with source file + field path + reason.
- Starting deck generation for warrior from imported card data (`starter_copies`).

Not implemented in this task:
- Full editor UI.
- Enemy/relic/event import execution (schema placeholders only).

## Command

```bash
python3 tools/content_import_cards.py \
  --input modules/content_pipeline/sources/cards/warrior_cards.json
```

Default outputs:
- `characters/warrior/cards/generated/*.gd`
- `characters/warrior/cards/generated/*.tres`
- `characters/warrior/warrior_starting_deck.tres`
- `modules/content_pipeline/reports/card_import_report.json`
