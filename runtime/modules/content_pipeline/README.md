# content_pipeline

## Directory Layout

Schema 定义位于 `runtime/modules/content_pipeline/schemas/`，而导入脚本位于 `dev/tools/`。
这是刻意的分离设计：Schema 属于运行时契约定义，而导入脚本属于开发工具（不参与运行时加载），
遵循仓库 `runtime/` vs `dev/` 的分层原则。

Status:
- C3 minimum usable path is implemented for cards.
- Schema definitions ready for enemies/relics/events (R2 Phase 6).
- Importers implemented for all content types (R2 Phase 7).
- Gate integration ready (R2 Phase 8).

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

Added in `r2-phase07-content-importers-expansion-v1`:
- Enemy importer: `dev/tools/content_import_enemies.py`
- Relic importer: `dev/tools/content_import_relics.py`
- Event importer: `dev/tools/content_import_events.py`

Added in `r2-phase08-content-pipeline-gate-integration-v1`:
- Aggregate gate script: `dev/tools/content_pipeline_check.sh`
- Dual-layer gate strategy documented.

Not implemented in this task:
- Full editor UI.
- Enemy/relic/event import execution (Phase 7).

## Gate Strategy

### Dual-Layer Execution

| Layer | Command | When | Duration |
|-------|---------|------|----------|
| Daily | `make workflow-check` | Every commit | ~2s |
| Release | `bash dev/tools/content_pipeline_check.sh` | Before release | ~1.4s |

### Content Pipeline Check
```bash
bash dev/tools/content_pipeline_check.sh
```

Runs all five importers plus one negative contract:
1. cards
2. enemies
3. relics
4. potions
5. events
6. invalid potion contract

Reports output to `runtime/modules/content_pipeline/reports/`.

## Schema Documentation

See `schemas/README.md` for:
- Schema version strategy
- Error code conventions
- Import contract for Phase 7

## Content Types

| Type | Schema | Examples | Import Status |
|------|--------|----------|---------------|
| Cards | `card_schema.json` | `sources/cards/` | ✅ Implemented |
| Enemies | `enemy_schema.json` | `sources/enemies/examples/` | ✅ Implemented |
| Relics | `relic_schema.json` | `sources/relics/examples/` | ✅ Implemented |
| Potions | `potion_schema.json` | `sources/potions/examples/` | ✅ Implemented |
| Events | `event_schema.json` | `sources/events/examples/` | ✅ Implemented |

## Runtime Source Of Truth

- Events runtime catalog reads JSON source directly.
- Encounter runtime registry reads JSON source directly.
- Potion runtime catalog now reads JSON source directly.
- Existing `content/custom_resources/potions/*.tres` are legacy resources, no longer the runtime source of truth.

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

### Enemy Import
```bash
python3 dev/tools/content_import_enemies.py \
  --input runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json
```

### Relic Import
```bash
python3 dev/tools/content_import_relics.py \
  --input runtime/modules/content_pipeline/sources/relics/examples/common_relics.json
```

### Event Import
```bash
python3 dev/tools/content_import_events.py \
  --input runtime/modules/content_pipeline/sources/events/examples/baseline_events.json
```

### Potion Import
```bash
python3 dev/tools/content_import_potions.py \
  --input runtime/modules/content_pipeline/sources/potions/examples/base_potions.json
```

### All Content (Aggregate)
```bash
bash dev/tools/content_pipeline_check.sh
```

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
