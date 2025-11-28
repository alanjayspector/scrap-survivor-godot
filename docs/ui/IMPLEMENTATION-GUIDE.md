# UI Implementation Guide

**Version**: 1.0
**Effective**: 2025-11-28
**Source**: Extracted from CLAUDE_RULES.md

This document outlines the mandatory standards for UI development in the Scrap Survivor project.

## Mobile-Native Development Standards

**Effective**: 2025-11-22 (Week 16 learnings)

### Definition of "Mobile-Native"

**Mobile-native DOES NOT mean:**
- ❌ Gaming UI patterns (two-tap confirmations, button state machines)
- ❌ Hybrid workarounds (desktop + mobile mixed)
- ❌ "Works on mobile" (just responsive to screen size)

**Mobile-native MEANS:**
- ✅ **iOS HIG compliance** - Follow Apple Human Interface Guidelines exactly
- ✅ **Platform patterns** - Use ModalFactory.show_confirmation(), not button states
- ✅ **Native controls** - Use ALERT, SHEET, FULLSCREEN modals
- ✅ **Cite guidelines** - Reference specific HIG sections when claiming compliance

### Before Claiming "iOS HIG Compliant"

**Evidence Checklist:**
```
□ Can cite specific iOS HIG guideline(s)? [URL or section]
□ Uses platform-native patterns? (modals, not button state machines)
□ Tested on actual iOS device? (not just simulator/desktop)
□ Uses ModalFactory or approved mobile components?
```

**If ANY checkbox unchecked → NOT iOS HIG compliant**

### Mobile-First Validation

Before marking mobile work "COMPLETE":
```
□ Follows iOS HIG (not gaming UI patterns)
□ Uses approved mobile components (MobileModal, ModalFactory)
□ Tested on physical iOS device
□ No desktop patterns mixed in
□ Can defend every UI choice with HIG citation
```

---

## Godot 4 Dynamic UI Development (CRITICAL)

**Effective**: 2025-11-22 (After Week 16 iOS SIGKILL crash investigation)

### The Parent-First Protocol

**MANDATORY for ALL dynamic Control node creation in Godot 4.x**

```gdscript
# ✅ CORRECT - Parent-First Protocol (ALWAYS use this)
var node = VBoxContainer.new()
parent_container.add_child(node)  # 1. Parent FIRST
node.layout_mode = 2  # 2. Explicit Mode 2 (Container mode) for iOS safety
node.add_theme_constant_override("separation", 16)  # 3. Configure AFTER

# ❌ WRONG - Configure-Then-Parent (Godot 3.x pattern - DO NOT USE)
var node = VBoxContainer.new()
node.add_theme_constant_override("separation", 16)  # ❌ Configure first
parent_container.add_child(node)  # ❌ Parent last → iOS SIGKILL
```

**Note**: Use `layout_mode = 2` (integer value). The enum constants (LAYOUT_MODE_CONTAINER, etc.) are not exposed in Godot 4.5.1's public GDScript API.

### Why This Matters

**Godot 4 Architecture Change:**
- Control nodes have internal `layout_mode` property (values: 0, 1, 2)
- `.new()` defaults to Mode 1 (Anchors)
- Containers expect Mode 2 (Container-controlled layout)
- **Configure-then-parent creates Mode 1 → Mode 2 conflict**

**iOS Consequence:**
- Container sorts layout → Child rejects (anchors) → Container re-sorts → **Infinite loop**
- Main thread locked → iOS Watchdog timeout (5-10s) → **SIGKILL (0x8badf00d)**
- **No error message** - app just disappears
- Desktop more tolerant (masks the problem)

### The Rules

**NEVER:**
1. ❌ Configure ANY properties before `add_child()`
2. ❌ Set `name`, `text`, `size_flags`, etc. before parenting
3. ❌ Use `set_anchors_preset()` on Container children
4. ❌ Assume desktop behavior = iOS behavior

**ALWAYS:**
1. ✅ Parent immediately after `.new()`
2. ✅ Set `layout_mode = 2` for Container children
3. ✅ Configure ALL properties AFTER parenting
4. ✅ Test on actual iOS device (simulator may not crash)

### Code Review Checklist

Before approving ANY code with dynamic UI:
```
□ All `.new()` calls followed immediately by `add_child()`
□ All Container children have `layout_mode = 2`
□ Zero lines of configuration between `.new()` and `add_child()`
□ No `set_anchors_preset()` calls on Container children
```

### Common Violations

**Labels, Buttons, Controls:**
```gdscript
# ❌ WRONG
var label = Label.new()
label.text = "Hello"  # ❌ Configure first
hbox.add_child(label)

# ✅ CORRECT
var label = Label.new()
hbox.add_child(label)  # Parent FIRST
label.layout_mode = 2
label.text = "Hello"  # Configure AFTER
```

**Containers (VBox, HBox, etc.):**
```gdscript
# ❌ WRONG
var section = VBoxContainer.new()
section.name = "Section"  # ❌ Even innocent properties are wrong
parent.add_child(section)

# ✅ CORRECT
var section = VBoxContainer.new()
parent.add_child(section)  # Parent FIRST
section.layout_mode = 2
section.name = "Section"  # Configure AFTER
```

### If This Is Violated

**Symptoms:**
- iOS app crashes with SIGKILL (no error)
- App freezes when opening modals/dialogs
- Desktop works fine, iOS fails
- Device logs show 0x8badf00d

**Response:**
1. Read `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md`
2. Read `docs/godot-ios-sigkill-research.md`
3. Fix ALL dynamic node creation (not just the crash site)
4. Test on iOS device before claiming fix

### Documentation

**Primary Reference:**
- `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md` (examples, detection, prevention)

**Research:**
- `docs/godot-ios-sigkill-research.md` (forensic analysis, Watchdog mechanism, infinite loop details)

**Related:**
- Godot Issue #104598 (scene editor fix in 4.5, but `.new()` still defaults to Mode 1)

---

## Destructive Operation UI Standards

**Effective**: 2025-11-23 (After Character Details modal sizing lessons)

### Prominence Principle

**Rule**: Destructive operations MUST have visually prominent UI that conveys seriousness and reduces accidental taps.

### Size Requirements for Destructive Confirmations

**Minimum Standards** (iOS mobile):
- **Modal height**: 300px minimum (not 220px)
- **Modal width**: 90% of screen width, max 500px
- **Title font**: 28pt (not 24pt)
- **Message font**: 20pt (not 18pt)
- **Button size**: 140×64px minimum (not 120×56px)
- **Button font**: 20pt (not 18-19pt)
- **Padding**: 36px (not 28px)
- **Content spacing**: 24px between elements (not 20px)

### Why Size Matters

**Psychology**: Larger, more prominent UI signals importance
- Small modal (220px) = "This is a minor decision"
- Large modal (300px) = "This is a serious decision"
- Users PAY ATTENTION to prominent UI
- Reduces accidental taps (fat finger protection)

**Comparison**:
- 220px modal felt "not serious enough" for character deletion
- 300px modal (+36% larger) felt appropriately serious
- User feedback: "success current modal is sufficient for this polish pass"

### Destructive Operation Checklist

Before implementing delete/destructive confirmation:
```
□ Modal height ≥300px (prominence)
□ Modal width 90% screen (up to 500px max)
□ Title font ≥28pt (impact)
□ Message font ≥20pt (readability)
□ Buttons ≥140×64px (easy to tap, hard to mis-tap)
□ Button font ≥20pt (clarity)
□ Generous padding/spacing (visual breathing room)
□ Properly centered (manual calculation if dynamic sizing)
□ Tested on device (not just simulator)
```

### Additional Protections (Optional but Recommended)

**Progressive Confirmation**:
- First tap: Show "Are you sure?" modal
- Second tap (within 3 seconds): Actually delete
- Prevents single-tap accidents

**Undo Toast**:
- After deletion, show "Undo Delete" toast for 5 seconds
- Industry standard pattern
- Reduces user rage from accidents

**Visual Signals**:
- Red color for destructive actions
- Warning icons (skull, trash, danger symbol)
- Clear button labels ("Delete Character" not just "Delete")
- Include consequences in message ("This cannot be undone")

### Red Flags

- 🚩 Delete confirmation modal < 300px tall (too small)
- 🚩 Delete confirmation buttons < 140×64px (mis-tap risk)
- 🚩 No visual distinction between "Cancel" and "Delete" buttons
- 🚩 Can accidentally tap "Delete" when aiming for "Cancel" (too close)
- 🚩 Modal feels "generic" not "serious"

### Lessons Learned Source

From Character Details Polish (QA Pass 20-21):
- Initial modal: 220px tall, felt too small for serious action
- Revised modal: 300px tall (+36%), buttons 140×64px (+17%), larger fonts
- User feedback: "make the modal larger and more prominent" → we did → success

---

## 2D Texture Import Settings (Godot Standard)

**Effective**: 2025-11-27 (Asset import compliance)

### Required Setting for 2D UI Textures

All 2D textures (sprites, UI backgrounds, icons) MUST have:

```
detect_3d/compress_to=0
```

### Why This Matters

- `detect_3d/compress_to=1` (VRAM Compressed) = **BAD** for 2D
  - Causes auto-recompression if texture detected in 3D context
  - Wastes processing, can cause visual artifacts
  - Not appropriate for UI/2D assets

- `detect_3d/compress_to=0` (Disabled) = **GOOD** for 2D
  - Prevents unnecessary recompression
  - Correct setting for all 2D UI textures
  - Matches Godot best practices

### When Importing New Assets

After copying a new image to `assets/`:

1. Open Godot editor (generates .import file)
2. Check the .import file for `detect_3d/compress_to`
3. If value is `1`, change to `0`
4. Validator will catch this if missed

### Verification

The `check-imports.sh` validator enforces this rule:
- Checks all .import files in assets/
- Flags any 2D textures with `detect_3d/compress_to=1`
- **BLOCKING** - commit will fail until fixed

### Files That Need This Setting

- `assets/ui/backgrounds/*.png`, `*.jpg`
- `assets/ui/portraits/*.png`
- `assets/ui/icons/*.png`
- Any 2D sprite or UI texture
