# content_pipeline

Status:
- C3 minimum usable path is implemented for cards.
- Schema definitions ready for enemies/relics/events (R2 Phase 6).

Implemented in `feat-content-pipeline-v1`:
- Card schema validation (required fields, enums, type checks, duplicate ID checks).
- Card import command that generates runtime card scripts/resources.
- Error report output with source file + field path + reason.
- Starting deck generation for warrior from imported card data (`starter_copies`).

Added in `r2-phase06-content-schema-expansion-v1`:
- Enemy schema: `schemas/enemy_schema.json`
- Relic schema: `schemas/relic_schema.json`
- Event schema: `schemas/event_schema.json`
- Example data for all three content types (valid + invalid cases).
- Unified error report format specification.

Not implemented in this task:
- Full editor UI.
- Enemy/relic/event import execution (Phase 7).

## Schema Documentation

See `schemas/README.md` for:
- Schema version strategy
- Error code conventions
- Import contract for Phase 7

## Content Types

| Type | Schema | Examples | Import Status |
|------|--------|----------|---------------|
| Cards | `card_schema.json` | `sources/cards/` | ✅ Implemented |
| Enemies | `enemy_schema.json` | `sources/enemies/examples/` | ⏳ Phase 7 |
| Relics | `relic_schema.json` | `sources/relics/examples/` | ⏳ Phase 7 |
| Events | `event_schema.json` | `sources/events/examples/` | ⏳ Phase 7 |

## Commands

### Card Import
```bash
python3 dev/tools/content_import_cards.py \
  --input runtime/modules/content_pipeline/sources/cards/warrior_cards.json
```

Default outputs:
- `content/characters/warrior/cards/generated/*.gd`
- `content/characters/warrior/cards/generated/*.tres`
- `content/characters/warrior/warrior_starting_deck.tres`
- `runtime/modules/content_pipeline/reports/card_import_report.json`

## Error Report Format

All import reports follow unified error model:

```json
{
  "source": "enemies/act1_enemies.json",
  "field": "enemies[0].max_health",
  "code": "INVALID_TYPE",
  "message": "Expected integer, got string"
}
```

See `schemas/README.md` for full error code reference.
