# Task: feat-card-display-name-v1

## Verification Summary

**Date**: 2026-02-19
**Status**: COMPLETED

## Changes Made

### 1. Card Class (`content/custom_resources/card.gd`)

Added:
```gdscript
@export var display_name: String = ""

func get_display_name() -> String:
    return display_name if not display_name.is_empty() else id
```

### 2. Content Import Script (`dev/tools/content_import_cards.py`)

Updated `_generate_card_tres()` to map JSON `name` to `display_name`:
```python
lines.append(f"display_name = {_json_string(card.get('name', ''))}")
```

### 3. ViewModels Updated

**shop_ui_view_model.gd:92**:
```gdscript
return card.get_display_name()  # was: return card.id
```

**reward_ui_view_model.gd:61**:
```gdscript
return "%s  [费:%s]" % [card.get_display_name(), card.get_cost_label()]
```

### 4. Persistence (`save_service.gd`)

**_serialize_card()**: Added `data["display_name"] = card.display_name`
**_deserialize_card()**: Added `card.display_name = str(data.get("display_name", ""))`

## Verification

- All 131 GUT tests pass
- Generated card files contain `display_name` field with Chinese names
- Example: `warrior_axe_attack.tres` has `display_name = "斧击"`

## Acceptance Criteria

- [x] Card class has `display_name` field
- [x] ContentPipeline maps `name` → `display_name`
- [x] Shop/Reward display Chinese names
- [x] Save/Load preserves `display_name`
- [x] All tests pass
