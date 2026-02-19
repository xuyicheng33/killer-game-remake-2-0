# Task: feat-tooltip-extension-v1

**Task ID**: 7B-3
**Level**: L2
**Status**: COMPLETED
**Approved**: 2026-02-20
**Prerequisite**: 7A-1 (completed)

## Objective

Extend Tooltip support to Shop, Reward, and RelicPotionUI scenes using the event-based system.

## Implementation Plan

### 1. Add New Signals to events.gd

```gdscript
signal relic_tooltip_requested(icon: Texture, text: String)
signal potion_tooltip_requested(icon: Texture, text: String)
```

### 2. Update tooltip.gd

Connect to new signals and reuse `show_tooltip` logic.

### 3. Update Shop Scene

For dynamically created buttons:
- Connect `mouse_entered` to emit tooltip signals
- Connect `mouse_exited` to emit hide signal
- Pass item data through button metadata

### 4. Update Reward Scene

Add mouse_entered/exited handlers to card buttons (already has tooltip_text, but this extends to custom Tooltip).

### 5. Update RelicPotionUI

Add hover handlers for relic list and potion buttons.

## Files to Modify

- `runtime/global/events.gd`
- `runtime/scenes/ui/tooltip.gd`
- `runtime/scenes/shop/shop_screen.gd`
- `runtime/scenes/reward/reward_screen.gd`
- `runtime/scenes/ui/relic_potion_ui.gd`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd`
- `runtime/scenes/app/app.tscn`
- `runtime/scenes/battle/battle.tscn`

## Notes

- Current Tooltip uses fixed anchor layout (no screen clamping)
- Buttons are dynamically created, so we connect signals at creation time

## Acceptance Criteria

- [x] Shop card/relic/potion buttons show tooltip on hover
- [x] Reward card buttons show tooltip on hover
- [x] RelicPotionUI relic/potion buttons show tooltip on hover
- [x] All tests pass
