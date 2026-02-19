# Task: feat-card-display-name-v1

**Task ID**: 7B-1
**Level**: L2
**Status**: COMPLETED
**Approved**: 2026-02-19

## Objective

Add `display_name` field to Card class for Chinese card names, with ContentPipeline mapping, ViewModel updates, and persistence support.

## Implementation Plan

### 1. Card Class Extension (`content/custom_resources/card.gd`)

Add:
```gdscript
@export var display_name: String = ""

func get_display_name() -> String:
    return display_name if not display_name.is_empty() else id
```

### 2. ContentPipeline Update (`dev/tools/content_import_cards.py`)

- Map JSON `name` field to `display_name` in the generated .tres files
- Keep `id` as the English identifier

### 3. ViewModel Updates

- `shop_ui_view_model.gd:92`: `return card.id` → `return card.get_display_name()`
- `reward_ui_view_model.gd:61`: `card.id` → `card.get_display_name()`

### 4. Persistence Support (`save_service.gd`)

- `_serialize_card()`: Add `data["display_name"] = card.display_name`
- `_deserialize_card()`: Add `card.display_name = str(data.get("display_name", ""))`

## Files to Modify

- `content/custom_resources/card.gd`
- `dev/tools/content_import_cards.py`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd`
- `runtime/modules/persistence/save_service.gd`

## Acceptance Criteria

- [x] Card class has `display_name` field
- [x] ContentPipeline maps `name` → `display_name`
- [x] Shop/Reward display Chinese names
- [x] Save/Load preserves `display_name`
- [x] All tests pass
