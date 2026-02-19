# Task: fix-tooltip-event-signature-v1

**Task ID**: 7A-1
**Level**: L1
**Status**: COMPLETED

## Problem Analysis

Current signature mismatch:

| Location | Type | Signature |
|----------|------|-----------|
| `events.gd:9` | Signal definition | `card_tooltip_requested(card: Card)` |
| `card_base_state.gd:31` | Emit call | `.emit(card_ui.card.icon, card_ui.card.tooltip_text)` |
| `tooltip.gd:37` | Handler | `show_tooltip(icon: Texture, text: String)` |

The signal is defined to take a `Card` object, but the actual emission passes `(Texture, String)`.

## Fix Strategy (Minimal Change)

**Chosen approach**: Update signal definition to match actual usage.

This is the smallest change because:
1. The emission code already works correctly
2. The handler already expects `(Texture, String)`
3. Only the signal definition needs to change

## Implementation

### Change to events.gd

```gdscript
# Before:
signal card_tooltip_requested(card: Card)

# After:
signal card_tooltip_requested(icon: Texture, text: String)
```

## 改动白名单文件

- `runtime/global/events.gd`

## Files to Modify

- `runtime/global/events.gd` (line 9)

## Acceptance Criteria

- [x] Signal definition matches emit/handler signatures
- [x] No GDScript type warnings
- [x] Existing tests pass
