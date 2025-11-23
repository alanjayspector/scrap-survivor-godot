# Godot 4 UI Development Best Practices

**Quick Reference Guide for Dynamic UI Creation**

---

## ⚠️ CRITICAL: The Parent-First Protocol

**STATUS**: MANDATORY for ALL Godot 4.x dynamic UI code

### The Pattern (Use This ALWAYS)

```gdscript
# Step 1: Instantiate
var node = Control.new()  # or Label, Button, VBoxContainer, etc.

# Step 2: Parent IMMEDIATELY
parent_container.add_child(node)

# Step 3: Set layout mode (for Container children)
node.layout_mode = 2  # Mode 2

# Step 4: Configure (ONLY AFTER parenting)
node.text = "Hello"
node.custom_minimum_size = Vector2(100, 44)
node.add_theme_font_size_override("font_size", 18)
```

### Why Order Matters

| Step | What Happens | Why It Matters |
|------|--------------|----------------|
| 1. `.new()` | Node created with `layout_mode = 1` (Anchors) | Default Godot 4 behavior |
| 2. `add_child()` | Engine sees Container parent, should switch to Mode 2 | Critical state transition |
| 3. Set `layout_mode = 2` | Explicit Mode 2 (safety) | iOS Metal backend requirement |
| 4. Configure properties | Properties respect Container authority | No layout conflict |

**If you configure BEFORE step 2**: Node stays in Mode 1 → Container conflict → **iOS SIGKILL crash**

---

## Common Patterns

### Labels

```gdscript
# Creating a label for HBoxContainer
var label = Label.new()
hbox.add_child(label)  # Parent FIRST
label.layout_mode = 2
label.text = "Score: 100"
label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
label.add_theme_font_size_override("font_size", 16)
```

### Buttons

```gdscript
# Creating a button for VBoxContainer
var button = Button.new()
vbox.add_child(button)  # Parent FIRST
button.layout_mode = 2
button.text = "Continue"
button.custom_minimum_size = Vector2(0, 44)  # iOS HIG: 44pt minimum
button.pressed.connect(_on_continue_pressed)
```

### Containers (VBox, HBox, etc.)

```gdscript
# Creating nested containers
var section = VBoxContainer.new()
parent_vbox.add_child(section)  # Parent FIRST
section.layout_mode = 2
section.add_theme_constant_override("separation", 8)
section.name = "ScoreSection"

# Now add children to this section
var title = Label.new()
section.add_child(title)  # Parent FIRST (to section)
title.layout_mode = 2
title.text = "High Scores"
```

### ColorRect (Backgrounds, Overlays)

```gdscript
# Creating a backdrop
var backdrop = ColorRect.new()
self.add_child(backdrop)  # Parent FIRST
backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)  # OK: Not a Container child
backdrop.color = Color(0, 0, 0, 0.6)
backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
```

**Note**: If parent is NOT a Container, anchors are OK. But still parent first!

---

## Anti-Patterns (DO NOT USE)

### ❌ Configure-Then-Parent (Godot 3.x style)

```gdscript
# ❌ WRONG - This WILL crash on iOS
var label = Label.new()
label.text = "Hello"  # ❌ Configure before parenting
label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
container.add_child(label)  # ❌ Too late
```

### ❌ Batch Configuration Before Parenting

```gdscript
# ❌ WRONG - Looks clean but crashes on iOS
var button = Button.new()
button.text = "Delete"
button.custom_minimum_size = Vector2(0, 44)
button.add_theme_font_size_override("font_size", 18)
button_container.add_child(button)  # ❌ All config before parenting
```

### ❌ Setting Anchors on Container Children

```gdscript
# ❌ WRONG - Creates layout mode conflict
var panel = Panel.new()
container.add_child(panel)
panel.set_anchors_preset(Control.PRESET_CENTER)  # ❌ Anchor conflict
```

---

## Checklist for Code Review

Before merging any PR with dynamic UI:

- [ ] Every `.new()` is followed by `add_child()` within 1-2 lines
- [ ] `layout_mode = 2` set for all Container children
- [ ] Zero configuration lines between `.new()` and `add_child()`
- [ ] No `set_anchors_preset()` on Container children
- [ ] Tested on actual iOS device (not just desktop/simulator)

---

## Debugging iOS SIGKILL Crashes

### Symptoms
- App disappears instantly (no error message)
- Happens when opening modals/dialogs
- Desktop works fine, iOS fails
- Device logs show `0x8badf00d` (Watchdog timeout)

### Diagnosis
1. Check recent dynamic UI code
2. Look for configure-then-parent pattern
3. Verify `layout_mode = 2` is set

### Fix
1. Convert ALL dynamic node creation to Parent-First
2. Add explicit `layout_mode = 2`
3. Test on iOS device

### Prevention
- Use Parent-First from day one
- Code review every dynamic UI change
- Run validators before committing
- Test iOS early and often

---

## iOS-Specific Considerations

### Watchdog Timer
- **Launch**: ~20 seconds tolerance
- **Runtime**: 5-10 seconds tolerance
- **Main thread hang** → SIGKILL (no mercy)

### Metal Backend (Godot 4.3+)
- Tighter coupling than MoltenVK
- Less tolerant of layout conflicts
- Explicit `layout_mode = 2` is critical

### Safe Area
- Use `DisplayServer.get_display_safe_area()`
- Wrap UI in MarginContainer
- Don't anchor directly to full screen

---

## Examples from Codebase

### ✅ Good: mobile_modal.gd

```gdscript
func _build_content() -> void:
    content_vbox = VBoxContainer.new()
    content_vbox.name = "ContentVBox"
    modal_container.add_child(content_vbox)  # Parent FIRST
    content_vbox.layout_mode = 2  # Explicit Mode 2
    content_vbox.add_theme_constant_override("separation", 16)  # Configure AFTER
```

### ✅ Good: character_details_panel.gd

```gdscript
func _create_stat_row(stat_name: String, stat_value: String) -> HBoxContainer:
    var hbox = HBoxContainer.new()
    hbox.custom_minimum_size = Vector2(0, 28)

    var name_label = Label.new()
    hbox.add_child(name_label)  # Parent FIRST
    name_label.layout_mode = 2  # Explicit Mode 2
    name_label.text = stat_name  # Configure AFTER
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    return hbox
```

---

## Related Documentation

- **Deep Dive**: `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md`
- **Research**: `docs/godot-ios-sigkill-research.md` (forensic analysis)
- **Rules**: `.system/CLAUDE_RULES.md` (Godot 4 Dynamic UI Development section)
- **Godot Issue**: #104598 (scene editor fix, `.new()` still defaults to Mode 1)

---

## Quick Reference Card

```
PARENT-FIRST PROTOCOL (Godot 4.x)
==================================

✅ DO THIS:
  1. var node = Control.new()
  2. parent.add_child(node)
  3. node.layout_mode = 2
  4. node.property = value

❌ NOT THIS:
  1. var node = Control.new()
  2. node.property = value  ← WRONG ORDER
  3. parent.add_child(node)

WHY: iOS SIGKILL (0x8badf00d)
     Infinite layout loop → Watchdog timeout → Crash

TEST: Always test on actual iOS device
```

---

**Last Updated**: 2025-11-22
**Status**: MANDATORY for all Godot 4.x projects
