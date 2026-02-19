# Task: fix-ui-issues-v1

## Verification Summary

**Date**: 2026-02-20
**Status**: COMPLETED

## Changes Made

### 1. Battle UI Zone Counts Label (`runtime/scenes/ui/battle_ui.gd`)

Added responsive positioning:
- Added viewport resize handler for zone counts label
- Created `_apply_zone_counts_responsive_layout()` function
- Label width now scales with viewport: 35% width, clamped 280-520px
- Margins scale with viewport size

### 2. Rest Screen Info Label (`runtime/scenes/map/rest_screen.gd`)

Added text overflow handling:
```gdscript
info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
```

### 3. Event Screen Description (`runtime/scenes/events/event_screen.gd`)

Added text overflow handling:
```gdscript
desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
```

## Verification

- All 131 GUT tests pass
- Responsive layout tested at 720p and 1080p thresholds
- No text overflow on long descriptions

## Acceptance Criteria

- [x] Issues list collected in issues.md
- [x] Zone counts label is now responsive
- [x] Text labels have autowrap for overflow
- [x] All tests pass
