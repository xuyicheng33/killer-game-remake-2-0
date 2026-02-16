# Content Pipeline Schema (v0.1.0)

## Scope

This contract defines the minimum content schema for Phase C3 (`feat-content-pipeline-v1`).
It targets four entities: `card`, `enemy`, `relic`, and `event`.
For this task, only `card` is implemented end-to-end (import + validation + runtime usage).

## Card Schema (implemented)

### Required fields

| Field | Type | Constraints |
|---|---|---|
| `id` | `String` | non-empty, unique across the import batch |
| `name` | `String` | non-empty |
| `type` | `String` | enum: `attack`, `skill`, `power`, `status`, `curse` |
| `rarity` | `String` | enum: `common`, `uncommon`, `rare` |
| `cost` | `int` | range `-1..10` |
| `target` | `String` | enum: `self`, `enemy`, `all_enemies`, `none` |
| `text` | `String` | non-empty; used for tooltip |
| `effects` | `Array[Dictionary]` | non-empty |

### Optional fields

| Field | Type | Constraints |
|---|---|---|
| `tags` | `Array[String]` | optional keyword tags |
| `upgrade_to` | `String` | optional target card id |
| `icon` | `String` | resource path, must start with `res://` |
| `sound` | `String` | resource path, must start with `res://` |
| `starter_copies` | `int` | >= 0, used by this task to generate starting deck |

### Effect item schema

Each item in `effects` must be a `Dictionary` with required key `op`.

Supported `op` values in C3 v1:

- `damage`
  - required: `amount: int` (`>= 0`)
- `block`
  - required: `amount: int` (`>= 0`)
- `apply_status`
  - required: `status_id: String` (`strength|dexterity|vulnerable|weak|poison`)
  - required: `stacks: int` (`!= 0`)

### Runtime mapping notes

- `type = status|curse` is accepted by schema and mapped to runtime `Card.Type.SKILL` for current codebase compatibility.
- `target = none` is mapped to runtime `Card.Target.SELF` for current codebase compatibility.
- `cost = -1` enables `keyword_x_cost` on generated card resources.

## Enemy Schema (placeholder for C3)

Required fields:

- `id: String`
- `name: String`
- `max_hp: int`
- `intents: Array[Dictionary]`

Minimum `intents` item:

- `weight: int`
- `op: String`
- `params: Dictionary`

## Relic Schema (placeholder for C3)

Required fields:

- `id: String`
- `name: String`
- `tier: String`
- `hooks: Array[Dictionary]`

Minimum `hooks` item:

- `timing: String`
- `op: String`
- `params: Dictionary`

## Event Schema (placeholder for C3)

Required fields:

- `id: String`
- `title: String`
- `options: Array[Dictionary]`

Minimum `options` item:

- `id: String`
- `text: String`
- `outcome: Dictionary`

## Error Reporting Contract (implemented for card import)

Each validation error includes:

- `source_file`: input file path
- `card_index`: item index in `cards`
- `card_id`: parsed card id if available
- `field`: field path (example: `cards[3].effects[1].amount`)
- `code`: stable error code (example: `missing_field`, `invalid_type`)
- `message`: human-readable reason

Import fails when any error exists. Report is written to:

- `modules/content_pipeline/reports/card_import_report.json`
