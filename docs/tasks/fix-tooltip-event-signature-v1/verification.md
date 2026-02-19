# Task: fix-tooltip-event-signature-v1

## Verification Summary

**Date**: 2026-02-19
**Status**: COMPLETED

## Changes Made

### events.gd (line 9)

```gdscript
# Before:
signal card_tooltip_requested(card: Card)

# After:
signal card_tooltip_requested(icon: Texture, text: String)
```

## Verification

- All 131 GUT tests pass
- Signal definition now matches actual usage in `card_base_state.gd:31`
- Handler in `tooltip.gd:37` already expects correct signature

## Signature Alignment

| Location | Before | After |
|----------|--------|-------|
| events.gd:9 | `card_tooltip_requested(card: Card)` | `card_tooltip_requested(icon: Texture, text: String)` |
| card_base_state.gd:31 | `.emit(icon, text)` | (unchanged - already correct) |
| tooltip.gd:37 | `show_tooltip(icon: Texture, text: String)` | (unchanged - already correct) |

## Acceptance Criteria

- [x] Signal definition matches emit/handler signatures
- [x] No GDScript type warnings
- [x] All 131 tests pass
