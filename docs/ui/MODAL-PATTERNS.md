# Modal & Dialog Patterns

**Version**: 1.0
**Effective**: 2025-11-28
**Source**: Extracted from CLAUDE_RULES.md

This document outlines the protocols and patterns for implementing modals and dialogs in the Scrap Survivor project.

## Modal & Dialog Layout Protocol (CRITICAL)

**Effective**: 2025-11-23 (After Character Details 21 QA passes)

### The Order-of-Operations Rule

**CRITICAL**: When positioning modals/dialogs dynamically, SIZE MUST be set FIRST, then position calculations.

```gdscript
# ❌ WRONG - Position calculated before size set
modal_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)  # Offsets calculated with size = 0
modal_container.size = Vector2(target_width, 300)  # Size set AFTER → wrong centering

# ✅ CORRECT - Size first, then position
modal_container.size = Vector2(target_width, 300)  # 1. Set size FIRST

# 2. Set anchors manually
modal_container.anchor_left = 0.5
modal_container.anchor_top = 0.5
modal_container.anchor_right = 0.5
modal_container.anchor_bottom = 0.5

# 3. Calculate offsets based on ACTUAL size
var half_width = target_width / 2.0
var half_height = 300.0 / 2.0
modal_container.offset_left = -half_width
modal_container.offset_top = -half_height
modal_container.offset_right = half_width
modal_container.offset_bottom = half_height
```

### Why This Matters

**Problem**: Godot's `set_anchors_and_offsets_preset()` calculates offsets based on the control's CURRENT size.
- If size = 0 when preset is called → offsets = 0
- Control appears with upper-left at anchor point (not centered)
- Changing size later doesn't update offsets automatically

**Solution**: Manual calculation with correct order:
1. **Set size** (gives actual dimensions)
2. **Set anchors** (defines anchor point location in parent)
3. **Calculate offsets** (positions control relative to anchor based on size)

### Godot Control Positioning System

**Anchors** (percentages of parent size):
- `(0.5, 0.5, 0.5, 0.5)` = anchor point at parent's center
- Range: 0.0 (left/top edge) to 1.0 (right/bottom edge)

**Offsets** (pixel distances from anchor points):
- For centered control with size (W, H):
  - `offset_left = -W/2` (left edge W/2 pixels left of anchor)
  - `offset_top = -H/2` (top edge H/2 pixels above anchor)
  - `offset_right = W/2` (right edge W/2 pixels right of anchor)
  - `offset_bottom = H/2` (bottom edge H/2 pixels below anchor)

### When to Use Manual Calculation

**Use `set_anchors_and_offsets_preset()`:**
- Static controls in scene editor
- Size is already set and won't change

**Use Manual Calculation:**
- Dynamic sizing (runtime calculation)
- Size depends on screen dimensions
- Responsive layouts that adapt to viewport

### Red Flags

- 🚩 Calling `set_anchors_and_offsets_preset()` before setting size
- 🚩 Modal appears shifted from intended position
- 🚩 "Centering API doesn't work" (probably order-of-operations issue)
- 🚩 Different positioning on different screen sizes (offsets calculated wrong)

### Lessons Learned Source

From Character Details Polish (QA Passes 19-21):
- QA Pass 19: Used wrong API (`set_anchors_preset` instead of `set_anchors_and_offsets_preset`)
- QA Pass 20: Right API, wrong timing (called before size set) → modal shifted right/down
- QA Pass 21: Manual calculation with correct order → TRUE centering achieved

---

## Mobile Pattern Examples

**✅ CORRECT - iOS HIG Pattern:**
```gdscript
# Destructive confirmation using native modal
ModalFactory.show_destructive_confirmation(
    self,
    "Delete Character?",
    "This cannot be undone.",
    func(): _delete_character()
)
```

**❌ INCORRECT - Gaming UI Hack:**
```gdscript
# Two-tap button state machine (NOT iOS HIG)
if delete_state == 0:
    button.text = "Tap Again to Confirm"
    delete_state = 1
elif delete_state == 1:
    _delete_character()
```
