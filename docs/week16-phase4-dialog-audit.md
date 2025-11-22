# Week 16 Phase 4: Dialog & Modal Audit Report

**Date**: 2025-11-22
**Phase**: Phase 4 - Dialog & Modal Patterns
**Status**: Audit Complete

---

## Executive Summary

Audited all dialog and modal systems in the codebase. **Key Finding**: All dialogs use desktop-style patterns with small fixed sizes, no mobile-native gestures, and no visual overlays. Significant improvements needed for mobile UX.

---

## Dialog Systems Inventory

### 1. CharacterDetailsPanel ⚠️ **NEEDS SIGNIFICANT MOBILE IMPROVEMENTS**

**Location**:
- Script: [scripts/ui/character_details_panel.gd](scripts/ui/character_details_panel.gd)
- Scene: [scenes/ui/character_details_panel.tscn](scenes/ui/character_details_panel.tscn)

**Current Implementation**:
- Type: `Panel` (not a popup dialog)
- Size: **600×800 pixels** (fixed, centered)
- Presentation: `show()` / `hide()` (instant, no animation)
- Dismissal: Close button only (no tap outside, no swipe)
- Backdrop: **None** (no visual separation from background)

**Mobile UX Issues**:
- ❌ **No backdrop overlay** - Panel floats without dimmed background
- ❌ **No dismiss gestures** - Must tap "Close" button (not mobile-native)
- ❌ **Fixed size** - 600×800 may be cramped on smaller devices
- ❌ **No animations** - Instant show/hide feels abrupt
- ❌ **Desktop-style tabbed interface** - Could be more mobile-friendly

**iOS HIG Violations**:
- Missing backdrop (iOS modals have dimmed backgrounds)
- Missing swipe-to-dismiss gesture
- Missing tap-outside-to-dismiss
- No entrance/exit animations

**Priority**: **HIGH** (explicitly mentioned in Phase 4 objectives)

---

### 2. DeleteConfirmationDialog ⚠️ **TOO SMALL FOR MOBILE**

**Location**:
- Scene: [scenes/ui/character_roster.tscn:100-105](scenes/ui/character_roster.tscn#L100)
- Usage: [scripts/ui/character_roster.gd:28,198](scripts/ui/character_roster.gd#L28)

**Current Implementation**:
- Type: `ConfirmationDialog` (Godot built-in)
- Size: **400×150 pixels** (very small!)
- Presentation: `popup_centered()` (default Godot style)
- Behavior: Single-tap "Delete" button → immediate deletion
- Styling: Danger button styling applied (red button) ✅

**Mobile UX Issues**:
- ❌ **TOO SMALL** - 400×150 is cramped for mobile
- ❌ **No progressive confirmation** - Single tap deletes (accidental deletions!)
- ❌ **Desktop-style dialog** - Small, centered popup (not mobile-native)
- ❌ **No dismiss gestures** - Requires tapping Cancel button
- ❌ **No animations** - Instant popup

**iOS HIG Violations**:
- Dialog too small for comfortable mobile tapping
- Missing progressive confirmation (iOS often uses swipe-to-delete + confirm)
- Missing tap-outside-to-dismiss
- No entrance/exit animations

**Priority**: **HIGH** (explicit Phase 4 objective: "Progressive delete confirmation")

---

### 3. AcceptDialog Instances (character_creation.gd) ⚠️ **DESKTOP-STYLE**

**Location**: [scripts/ui/character_creation.gd](scripts/ui/character_creation.gd)

**Usage**:
- Slot limit errors (`_show_slot_limit_error` - line 398)
- Creation errors (`_show_creation_error_dialog` - line 588)
- Save errors (`_show_save_error_dialog` - line 608)
- Locked character dialogs (`_show_locked_character_dialog` - line 629)

**Current Implementation**:
- Type: `AcceptDialog` (Godot built-in)
- Size: Default `popup_centered()` (likely small)
- Presentation: Instant popup, no animation
- Dismissal: "OK" button only

**Mobile UX Issues**:
- ❌ **Desktop-style dialogs** - Small, centered popups
- ❌ **No mobile-native styling** - Default Godot appearance
- ❌ **No animations** - Instant popup
- ❌ **No dismiss gestures**

**Priority**: **MEDIUM** (improve after CharacterDetailsPanel and DeleteConfirmation)

---

### 4. Debug Menu Dialogs (Non-Critical)

**Location**: [scripts/debug/debug_menu.gd](scripts/debug/debug_menu.gd)

**Current Implementation**:
- Debug tool only (not player-facing in production)
- Uses ConfirmationDialog and AcceptDialog for notifications

**Priority**: **LOW** (debug tool, not player-facing)

---

## Mobile UX Best Practices (iOS HIG Reference)

### What Mobile-Native Dialogs Should Have:

1. **Backdrop/Overlay** ✅
   - Semi-transparent dark background (0.5 alpha black)
   - Dims content behind modal
   - Visual separation from main UI

2. **Larger Sizes** ✅
   - Minimum 80% screen width for important dialogs
   - Generous padding (24-32pt margins)
   - Touch-friendly button spacing (16pt minimum)

3. **Dismiss Gestures** ✅
   - Tap outside to dismiss (for non-critical dialogs)
   - Swipe down to dismiss (iOS native pattern)
   - Close button (always available)

4. **Animations** ✅
   - Entrance: Fade + slide up (200-300ms)
   - Exit: Fade + slide down (150-250ms)
   - Backdrop: Fade in/out (150-200ms)

5. **Progressive Confirmation** ✅ (for destructive actions)
   - First tap: Warning state (highlight, color change)
   - Second tap: Execute action
   - OR: Swipe-to-delete pattern (iOS standard)

---

## Recommendations & Action Plan

### Phase 4 Implementation Order:

#### 1. Create Reusable Modal Overlay System (HIGH PRIORITY)
- **Component**: `MobileModal.gd` / `mobile_modal.tscn`
- **Features**:
  - Semi-transparent backdrop (tap-to-dismiss option)
  - Full-screen or large size (80-90% screen width)
  - Entrance/exit animations (slide up + fade)
  - Swipe-down-to-dismiss gesture
  - Configurable: `allow_tap_outside`, `allow_swipe_dismiss`

#### 2. Improve CharacterDetailsPanel (HIGH PRIORITY)
- **Changes**:
  - Add backdrop overlay (dimmed background)
  - Add tap-outside-to-dismiss gesture
  - Add swipe-down-to-dismiss gesture
  - Add entrance/exit animations (slide up from bottom)
  - Increase padding for mobile (24-32pt)
  - Make responsive to screen size (80-90% width on mobile)

#### 3. Implement Progressive Delete Confirmation (HIGH PRIORITY)
- **Option A: Two-Tap Pattern**
  - First tap: Button turns red with "Tap again to confirm"
  - Second tap: Execute deletion
  - Timer: Reset to normal after 3 seconds

- **Option B: Larger Dialog with Clear Warning**
  - Replace 400×150 dialog with larger mobile-native modal
  - Prominent warning text
  - Large, clearly labeled buttons ("Cancel" / "Delete Forever")
  - Red danger styling for delete button

- **Recommended**: Option A (more mobile-native, prevents accidental taps)

#### 4. Standardize All AcceptDialog/ConfirmationDialog Instances (MEDIUM PRIORITY)
- Replace Godot built-in dialogs with custom `MobileModal` component
- Apply consistent sizing, styling, animations
- Add dismiss gestures

---

## Success Criteria (Phase 4)

- [x] All dialogs audited and documented ✅
- [ ] MobileModal reusable component created
- [ ] CharacterDetailsPanel uses backdrop + gestures + animations
- [ ] Delete confirmation prevents accidental deletions
- [ ] All dialogs feel "mobile-native" (not cramped desktop popups)
- [ ] Tap-outside-to-dismiss works reliably
- [ ] Modal animations feel smooth (200-300ms entrance, 150-250ms exit)

---

## Technical Notes

### Current Dialog Types in Codebase:
- `Panel` - CharacterDetailsPanel (custom implementation)
- `ConfirmationDialog` - Delete confirmation (Godot built-in)
- `AcceptDialog` - Error/info dialogs (Godot built-in)

### Proposed Architecture:
```
MobileModal (base class)
├── MobileDialogModal (alerts, confirmations)
├── MobileSheetModal (bottom sheet for CharacterDetailsPanel)
└── MobileOverlay (backdrop component)
```

### Key Files to Modify:
- [scripts/ui/character_details_panel.gd](scripts/ui/character_details_panel.gd) - Add backdrop + gestures
- [scenes/ui/character_details_panel.tscn](scenes/ui/character_details_panel.tscn) - Increase size
- [scripts/ui/character_roster.gd](scripts/ui/character_roster.gd) - Progressive delete confirmation
- [scenes/ui/character_roster.tscn](scenes/ui/character_roster.tscn) - Replace ConfirmationDialog

### New Files to Create:
- `scripts/ui/components/mobile_modal.gd` - Base modal class
- `scenes/ui/components/mobile_modal.tscn` - Modal scene
- `scripts/ui/components/modal_backdrop.gd` - Backdrop overlay
- `scenes/ui/components/modal_backdrop.tscn` - Backdrop scene

---

## Next Steps

1. ✅ **COMPLETE**: Audit dialogs and modals
2. **NEXT**: Define mobile dialog standards (sizes, spacing, animations)
3. **THEN**: Implement MobileModal reusable component
4. **THEN**: Improve CharacterDetailsPanel
5. **THEN**: Implement progressive delete confirmation
6. **FINALLY**: Test on iPhone 15 Pro Max

---

**Audit Completed**: 2025-11-22
**Auditor**: Claude Code (Week 16 Phase 4)
