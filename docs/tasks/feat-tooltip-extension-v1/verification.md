# Task: feat-tooltip-extension-v1

## Verification Summary

**Date**: 2026-02-20
**Status**: COMPLETED

## Changes Made

### 1. New Signals in events.gd

```gdscript
signal relic_tooltip_requested(icon: Texture, text: String)
signal potion_tooltip_requested(icon: Texture, text: String)
```

### 2. tooltip.gd Updated

Connected to new signals:
```gdscript
Events.relic_tooltip_requested.connect(show_tooltip)
Events.potion_tooltip_requested.connect(show_tooltip)
```

### 3. Reward Screen (reward_screen.gd)

- Replaced built-in `tooltip_text` with custom tooltip signals
- Added `_on_card_button_mouse_entered` and `_on_card_button_mouse_exited` handlers

### 4. Shop Screen (shop_screen.gd)

- Updated ViewModel to include `tooltip_icon` and `tooltip_text` in button data
- Added `_on_offer_button_mouse_entered` and `_on_offer_button_mouse_exited` handlers

### 5. RelicPotionUI (relic_potion_ui.gd)

- Updated ViewModel to include tooltip data for potions
- Added `_on_potion_button_mouse_entered` and `_on_potion_button_mouse_exited` handlers

### 6. ViewModels Updated

**shop_ui_view_model.gd**:
- Added `_tooltip_icon_for_offer()` and `_tooltip_text_for_offer()` helper functions
- Projection now includes `tooltip_icon` and `tooltip_text` for each offer

**relic_potion_view_model.gd**:
- Added `_potion_desc()` and `_potion_icon()` helper functions
- Projection now includes tooltip data for each potion button

## Verification

- All 131 GUT tests pass
- Tooltip signals properly connected in all scenes

## Acceptance Criteria

- [x] Shop card/relic/potion buttons show tooltip on hover
- [x] Reward card buttons show tooltip on hover
- [x] RelicPotionUI potion buttons show tooltip on hover
- [x] All tests pass

## Notes

- Relics in RelicPotionUI are displayed as a text list (not individual buttons), so tooltip support is only for potions
- Tooltip positioning is fixed (no screen clamping per original design)
