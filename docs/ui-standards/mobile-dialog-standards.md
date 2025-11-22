# Mobile Dialog & Modal Standards

**Version**: 1.0
**Date**: 2025-11-22
**Phase**: Week 16 Phase 4
**Compliance**: iOS Human Interface Guidelines

---

## Overview

This document defines mobile-native dialog and modal standards for the Scrap Survivor iOS app. All dialogs and modals MUST follow these standards to ensure a consistent, mobile-friendly user experience.

---

## Dialog Types

### 1. Alert Dialog (Small, Centered)

**Use Case**: Simple confirmations, error messages, single-choice prompts

**Specifications**:
- **Width**: 85% of screen width (min 300pt, max 400pt)
- **Height**: Auto (based on content, min 150pt)
- **Padding**: 24pt all sides
- **Border Radius**: 12pt
- **Background**: `Color(0.15, 0.15, 0.15)` (dark gray)
- **Border**: 2pt, accent color

**Button Layout**:
- **Single button**: Centered, full width (minus 24pt margins)
- **Two buttons**: Horizontal row, 16pt gap
- **Button height**: 50pt minimum (iOS HIG: 44pt minimum + 6pt safety)
- **Button font size**: 18pt

**Example Usage**:
- "Character created successfully!"
- "Failed to save character"
- "Delete character?" (with Cancel/Delete buttons)

---

### 2. Sheet Modal (Bottom Sheet, Large)

**Use Case**: Complex information displays (character details, inventory, stats)

**Specifications**:
- **Width**: 100% of screen width
- **Height**: 80-90% of screen height (depending on content)
- **Padding**: 24pt top, 20pt sides, safe area bottom
- **Border Radius**: 16pt top corners only (bottom corners = 0)
- **Background**: `Color(0.12, 0.12, 0.12)` (darker for separation)
- **Drag Handle**: 40×4pt rounded rectangle at top center (optional)

**Presentation**:
- **Entrance**: Slide up from bottom (300ms ease-out)
- **Exit**: Slide down to bottom (250ms ease-in)
- **Backdrop**: Required (dimmed background)

**Gestures**:
- ✅ Swipe down to dismiss
- ✅ Tap outside to dismiss (optional, configurable)

**Example Usage**:
- CharacterDetailsPanel
- Inventory view
- Settings panel

---

### 3. Full-Screen Modal

**Use Case**: Critical flows requiring full attention (onboarding, tutorials, upgrades)

**Specifications**:
- **Width**: 100% of screen width
- **Height**: 100% of screen height
- **Padding**: Safe area insets (respects notch/home indicator)
- **Background**: Opaque (no backdrop needed)

**Presentation**:
- **Entrance**: Fade in (200ms) OR slide up (300ms)
- **Exit**: Fade out (150ms) OR slide down (250ms)

**Gestures**:
- ❌ No tap outside (full-screen takes over)
- ❌ No swipe down (requires explicit dismissal)

**Example Usage**:
- First-time onboarding
- In-app purchase flows
- Tutorial overlays

---

## Backdrop Overlay Specifications

### Visual Appearance
- **Color**: `Color(0, 0, 0, 0.6)` (60% black)
- **Layer**: Behind modal, above main content
- **Full-screen**: Yes (covers entire viewport)

### Animation
- **Fade In**: 200ms ease-out
- **Fade Out**: 150ms ease-in

### Behavior
- **Tap to dismiss**: Configurable (default: true for alerts, false for sheets)
- **Visible**: Always visible when modal is shown

### Implementation
```gdscript
# Backdrop node structure
ColorRect (ModalBackdrop)
  - color: Color(0, 0, 0, 0.6)
  - mouse_filter: STOP (blocks clicks to content below)
  - layout_mode: ANCHORS_PRESET_FULL_RECT
```

---

## Animation Specifications

### Entrance Animations

#### Alert Dialog (Fade + Scale)
```gdscript
# Starting state
modulate.a = 0.0
scale = Vector2(0.9, 0.9)

# Animation (200ms ease-out)
Tween:
  - modulate.a: 0.0 → 1.0 (200ms, EASE_OUT)
  - scale: Vector2(0.9, 0.9) → Vector2(1.0, 1.0) (200ms, EASE_OUT)
```

#### Sheet Modal (Slide Up)
```gdscript
# Starting state
position.y = screen_height  # Off-screen at bottom

# Animation (300ms ease-out)
Tween:
  - position.y: screen_height → final_position (300ms, EASE_OUT)
```

### Exit Animations

#### Alert Dialog (Fade + Scale)
```gdscript
# Animation (150ms ease-in)
Tween:
  - modulate.a: 1.0 → 0.0 (150ms, EASE_IN)
  - scale: Vector2(1.0, 1.0) → Vector2(0.95, 0.95) (150ms, EASE_IN)
```

#### Sheet Modal (Slide Down)
```gdscript
# Animation (250ms ease-in)
Tween:
  - position.y: final_position → screen_height (250ms, EASE_IN)
```

### Backdrop Animation
```gdscript
# Fade in (200ms)
modulate.a: 0.0 → 1.0 (200ms, EASE_OUT)

# Fade out (150ms)
modulate.a: 1.0 → 0.0 (150ms, EASE_IN)
```

---

## Gesture Specifications

### Tap Outside to Dismiss

**Implementation**:
```gdscript
# Backdrop receives tap events
backdrop.gui_input.connect(_on_backdrop_input)

func _on_backdrop_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        if allow_tap_outside_dismiss:
            dismiss()
```

**Configuration**:
- **Alert Dialogs**: `allow_tap_outside_dismiss = true` (default)
- **Sheet Modals**: `allow_tap_outside_dismiss = true` (configurable)
- **Confirmation Dialogs**: `allow_tap_outside_dismiss = false` (prevent accidental dismissal)

### Swipe Down to Dismiss

**Implementation**:
```gdscript
# Detect swipe gesture on modal
var _swipe_start_position: Vector2
var _is_swiping: bool = false

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _swipe_start_position = event.position
            _is_swiping = true
        else:
            _is_swiping = false

    if event is InputEventScreenDrag and _is_swiping:
        var swipe_distance = event.position.y - _swipe_start_position.y

        # Downward swipe threshold: 100pt
        if swipe_distance > 100:
            dismiss()
```

**Configuration**:
- **Alert Dialogs**: `allow_swipe_dismiss = false` (too small for swipe)
- **Sheet Modals**: `allow_swipe_dismiss = true` (iOS native pattern)

**Visual Feedback**:
- Modal follows finger during drag (elastic effect)
- Snap back if swipe distance < 100pt
- Smooth slide down if swipe distance >= 100pt

---

## Progressive Confirmation Pattern

### Use Case
Destructive actions (delete character, reset data, discard changes)

### Two-Tap Pattern (Recommended)

**State 1: Normal**
- Button text: "Delete"
- Button style: DANGER (red background)
- Button size: 60pt height

**State 2: Warning (after first tap)**
- Button text: "Tap Again to Confirm"
- Button style: DANGER (brighter red, pulsing animation)
- Button size: 60pt height
- Auto-reset: After 3 seconds, return to State 1

**State 3: Executing**
- Button text: "Deleting..."
- Button style: DANGER (dimmed)
- Button disabled: true
- Show loading indicator (spinner)

**Implementation**:
```gdscript
var _delete_confirm_state: int = 0  # 0 = normal, 1 = warning, 2 = executing
var _confirm_timer: Timer = null

func _on_delete_pressed() -> void:
    if _delete_confirm_state == 0:
        # First tap - show warning
        _delete_confirm_state = 1
        delete_button.text = "Tap Again to Confirm"
        HapticManager.warning()

        # Start 3-second timer
        _confirm_timer = Timer.new()
        _confirm_timer.wait_time = 3.0
        _confirm_timer.one_shot = true
        _confirm_timer.timeout.connect(_reset_delete_button)
        add_child(_confirm_timer)
        _confirm_timer.start()

    elif _delete_confirm_state == 1:
        # Second tap - execute deletion
        _delete_confirm_state = 2
        delete_button.text = "Deleting..."
        delete_button.disabled = true
        HapticManager.heavy()

        # Execute deletion
        _execute_deletion()
```

### Alternative: Swipe-to-Delete Pattern

**Visual Design**:
- Swipe left on list item reveals red "Delete" button
- Tap "Delete" button → Show confirmation dialog
- Confirmation dialog uses Alert Dialog pattern (above)

**Use Case**: Character roster list, inventory items

---

## Spacing & Padding Standards

### Modal Padding
- **Alert Dialog**: 24pt all sides
- **Sheet Modal**: 24pt top, 20pt sides, safe area bottom
- **Full-Screen Modal**: Safe area insets (16-44pt depending on device)

### Button Spacing
- **Vertical stack**: 16pt gap between buttons
- **Horizontal row**: 16pt gap between buttons
- **Button margin from edges**: 20pt minimum

### Content Spacing
- **Title to content**: 16pt
- **Content to buttons**: 24pt
- **Section spacing**: 16pt between sections
- **Line spacing**: 6-8pt for multi-line text

---

## Typography Standards (Within Dialogs)

### Alert Dialogs
- **Title**: 22pt, bold, `Color.WHITE`
- **Message**: 16pt, regular, `Color(0.9, 0.9, 0.9)`
- **Buttons**: 18pt, medium, `Color.WHITE`

### Sheet Modals
- **Header title**: 28pt, bold, `Color.WHITE`
- **Subtitle**: 18pt, regular, `Color(0.7, 0.7, 0.7)`
- **Body text**: 18pt, regular, `Color(0.9, 0.9, 0.9)`
- **Section headers**: 20pt, bold, `Color(0.9, 0.7, 0.3)` (accent)
- **Buttons**: 20pt, medium, `Color.WHITE`

---

## Accessibility Considerations

### Dynamic Type Support
- All font sizes should scale with accessibility settings
- Test at 1.3× scale (largest common setting)
- Minimum touch target: 44pt × 44pt (iOS HIG)

### Haptic Feedback
- **Dialog appearance**: `HapticManager.light()`
- **Button tap**: `HapticManager.light()`
- **Destructive action warning**: `HapticManager.warning()`
- **Destructive action execution**: `HapticManager.heavy()`

### VoiceOver Support
- All buttons must have descriptive labels
- Modal title announced when shown
- Focus automatically moves to modal when opened
- Escape key / swipe gestures properly labeled

---

## Component Architecture

### MobileModal Base Class

```gdscript
class_name MobileModal
extends Control

## Signals
signal shown()
signal dismissed()

## Configuration
@export var modal_type: ModalType = ModalType.ALERT
@export var allow_tap_outside_dismiss: bool = true
@export var allow_swipe_dismiss: bool = false
@export var backdrop_color: Color = Color(0, 0, 0, 0.6)

enum ModalType {
    ALERT,      # Small centered dialog
    SHEET,      # Bottom sheet
    FULLSCREEN  # Full-screen takeover
}

## Child nodes (set in _ready)
var backdrop: ColorRect
var modal_container: PanelContainer
var content_container: VBoxContainer

func show_modal() -> void:
    """Show modal with animation"""
    # Implementation...

func dismiss() -> void:
    """Dismiss modal with animation"""
    # Implementation...

func _animate_entrance() -> void:
    """Play entrance animation based on modal_type"""
    # Implementation...

func _animate_exit() -> void:
    """Play exit animation based on modal_type"""
    # Implementation...
```

---

## Testing Checklist

Before shipping any dialog/modal:

- [ ] Animations smooth at 60 FPS
- [ ] Tap outside dismisses (if configured)
- [ ] Swipe down dismisses (if configured)
- [ ] Backdrop visible and properly dimmed
- [ ] Buttons meet 44pt × 44pt minimum
- [ ] Text readable at 1.3× scale
- [ ] Haptic feedback on all interactions
- [ ] VoiceOver announces modal title
- [ ] Works on iPhone 12 mini (5.4" - smallest supported)
- [ ] Works on iPhone 15 Pro Max (6.7" - largest common)
- [ ] Safe area insets respected (notch, home indicator)
- [ ] Progressive confirmation prevents accidental taps (destructive actions)

---

## Examples

### Example 1: Simple Alert

```gdscript
var alert = MobileModal.new()
alert.modal_type = MobileModal.ModalType.ALERT
alert.allow_tap_outside_dismiss = true
alert.title = "Character Created!"
alert.message = "Your character 'Rusty' is ready to fight."
alert.add_button("Start Playing", _on_start_playing)
alert.show_modal()
```

### Example 2: Confirmation Dialog

```gdscript
var confirm = MobileModal.new()
confirm.modal_type = MobileModal.ModalType.ALERT
confirm.allow_tap_outside_dismiss = false  # Force explicit choice
confirm.title = "Delete Character?"
confirm.message = "This action cannot be undone."
confirm.add_button("Cancel", _on_cancel, ButtonStyle.SECONDARY)
confirm.add_button("Delete", _on_delete, ButtonStyle.DANGER)
confirm.show_modal()
```

### Example 3: Bottom Sheet

```gdscript
var sheet = MobileModal.new()
sheet.modal_type = MobileModal.ModalType.SHEET
sheet.allow_swipe_dismiss = true
sheet.title = "Character Details"
# Add custom content to sheet.content_container
var details_panel = CHARACTER_DETAILS_PANEL.instantiate()
sheet.content_container.add_child(details_panel)
sheet.show_modal()
```

---

## References

- [iOS Human Interface Guidelines - Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
- [iOS Human Interface Guidelines - Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [iOS Human Interface Guidelines - Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [Material Design - Dialogs](https://m3.material.io/components/dialogs/overview) (reference only)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-22
**Next Review**: After Phase 4 implementation
