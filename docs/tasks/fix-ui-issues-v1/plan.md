# Task: fix-ui-issues-v1

**Task ID**: 7C-1
**Level**: L2
**Status**: COMPLETED

## Objective

Identify and fix UI layout issues across all game screens.

## Issues Identified

### P1: Battle UI Zone Counts Label Position
**File**: `runtime/scenes/ui/battle_ui.gd`
**Problem**: Zone counts label used hardcoded offsets (-520, -20) which don't adapt to screen size
**Solution**: Added responsive positioning with `_apply_zone_counts_responsive_layout()`

### P2: Rest Screen Info Label Overflow
**File**: `runtime/scenes/map/rest_screen.gd`
**Problem**: info_label could overflow with long text
**Solution**: Added `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`

### P3: Event Screen Description Overflow
**File**: `runtime/scenes/events/event_screen.gd`
**Problem**: desc_label and result_label could overflow with long text
**Solution**: Added `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`

## Changes Made

### battle_ui.gd
- Added viewport resize handler for zone counts label
- Created `_apply_zone_counts_responsive_layout()` function
- Label width now scales with viewport: 35% width, clamped 280-520px
- Margins scale with viewport size

### rest_screen.gd
- Added autowrap_mode to info_label

### event_screen.gd
- Added autowrap_mode to desc_label and result_label

## Verification

- All 131 tests pass
- Responsive layout tested at 720p and 1080p thresholds

## Acceptance Criteria

- [x] Issues list collected in issues.md
- [x] Zone counts label is now responsive
- [x] Text labels have autowrap for overflow
- [x] All tests pass
