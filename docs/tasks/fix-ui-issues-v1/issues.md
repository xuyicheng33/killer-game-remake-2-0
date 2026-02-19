# UI Issues List

## Identified Issues

### P1: Battle UI Zone Counts Label Position
**File**: `runtime/scenes/ui/battle_ui.gd:91-94`
**Problem**: Zone counts label uses hardcoded offsets (-520, -20) which don't adapt to screen size
**Solution**: Add responsive positioning based on viewport size

### P2: Rest Screen Info Label Overflow
**File**: `runtime/scenes/map/rest_screen.gd`
**Problem**: info_label has no minimum size or responsive handling
**Solution**: Add autowrap and minimum size

### P3: Tooltip Fixed Anchors
**File**: `runtime/scenes/ui/tooltip.tscn:7-9`
**Problem**: Uses fixed anchors (0.2, 0.8) which may not work on all resolutions
**Solution**: This is by design per plan - not a bug

### P4: Event Screen Description Overflow
**File**: `runtime/scenes/events/event_screen.gd`
**Problem**: desc_label may overflow on long text
**Solution**: Add autowrap_mode

### P5: Button Text Readability on Small Screens
**Files**: Multiple screen files
**Problem**: Some buttons may have text truncated on 720p
**Solution**: Ensure minimum button heights and font sizes

## Fixes Applied

1. Battle UI zone counts label - responsive positioning
2. Rest screen info label - autowrap and minimum size
3. Event screen description - autowrap_mode added
