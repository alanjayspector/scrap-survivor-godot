# Lesson 44: Godot 4 Parent-First UI Protocol (iOS SIGKILL Prevention)

**Date**: 2025-11-22
**Context**: Week 16 Phase 4 - Mobile UI Standards Overhaul
**Severity**: CRITICAL - 7 QA passes to discover, caused iOS app termination
**Impact**: Affects ALL dynamic UI node creation in Godot 4.x

## The Problem

### Symptom
iOS app crashes with SIGKILL (exit code 0x8badf00d - "Ate Bad Food") when opening modals or creating dynamic UI. No error message, just app disappearance.

### What We Did Wrong
```gdscript
# ❌ WRONG - Configure-then-Parent (Godot 3.x pattern)
var content_vbox = VBoxContainer.new()
content_vbox.add_theme_constant_override("separation", 16)  # Configure first
content_vbox.name = "ContentVBox"
modal_container.add_child(content_vbox)  # Parent last
```

### Root Cause
1. **Godot 4 Architecture Change**: Control nodes have internal `layout_mode` property
   - Mode 0: Position (uncontrolled)
   - Mode 1: Anchors (relative positioning)
   - Mode 2: Container (parent controls layout)

2. **Default State**: `Control.new()` defaults to Mode 1 (Anchors)

3. **The Conflict**: When configured BEFORE parenting to a Container:
   - Node establishes anchor-based positioning (Mode 1)
   - Container expects to control layout (Mode 2)
   - Container tries to set position → Child rejects (anchors) → Container re-sorts → Infinite loop

4. **iOS Watchdog**: After 5-10s of main thread hang, iOS kernel sends SIGKILL

### Why It Took 7 QA Passes
- ❌ Fixed scene files (.tscn) - didn't help (bug was in dynamic code)
- ❌ Assumed scene instantiation tests were enough (don't test dynamic content)
- ❌ Desktop doesn't crash (more tolerant of layout conflicts)
- ❌ No error message (iOS just kills the app silently)
- ✅ Finally spawned expert investigation agent (evidence-based debugging)
- ✅ Deep research revealed Parent-First protocol

## The Solution

### The Parent-First Protocol (MANDATORY for Godot 4)

```gdscript
# ✅ CORRECT - Parent-First Protocol
var content_vbox = VBoxContainer.new()
parent_container.add_child(content_vbox)  # 1. Parent FIRST
content_vbox.layout_mode = 2  # 2. Explicit Mode 2
content_vbox.add_theme_constant_override("separation", 16)  # 3. Configure AFTER
content_vbox.name = "ContentVBox"
```

### Why This Works
1. **Immediate Parenting**: Engine sees Container parent, automatically switches to Mode 2
2. **Explicit Mode**: Setting `layout_mode = 2` adds safety (iOS Metal backend)
3. **Post-Configuration**: Properties set AFTER parenting respect Container authority

### Rules
1. **ALWAYS parent immediately after `.new()`** - before ANY configuration
2. **ALWAYS set `layout_mode = 2`** for children of Containers
3. **NEVER configure before parenting** - not even innocent properties like `name`
4. **NEVER set anchors on Container children** - creates the layout conflict

## Affected Code Patterns

### Common Violations

**Labels, Buttons, etc.**
```gdscript
# ❌ WRONG
var label = Label.new()
label.text = "Hello"  # Configure first
label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
hbox.add_child(label)  # Parent last

# ✅ CORRECT
var label = Label.new()
hbox.add_child(label)  # Parent FIRST
label.layout_mode = 2  # Explicit Mode 2
label.text = "Hello"  # Configure AFTER
label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
```

**Containers**
```gdscript
# ❌ WRONG
var section = VBoxContainer.new()
section.add_theme_constant_override("separation", 4)  # Configure first
parent_vbox.add_child(section)  # Parent last

# ✅ CORRECT
var section = VBoxContainer.new()
parent_vbox.add_child(section)  # Parent FIRST
section.layout_mode = 2  # Explicit Mode 2
section.add_theme_constant_override("separation", 4)  # Configure AFTER
```

**Buttons**
```gdscript
# ❌ WRONG
var button = Button.new()
button.text = "Delete"  # Configure first
button.custom_minimum_size = Vector2(0, 44)
button_container.add_child(button)  # Parent last

# ✅ CORRECT
var button = Button.new()
button_container.add_child(button)  # Parent FIRST
button.layout_mode = 2  # Explicit Mode 2
button.text = "Delete"  # Configure AFTER
button.custom_minimum_size = Vector2(0, 44)
```

## Detection Checklist

### Before Code Review
- [ ] All `.new()` calls followed immediately by `add_child()`
- [ ] All Container children have `layout_mode = 2`
- [ ] No configuration between `.new()` and `add_child()`
- [ ] No `set_anchors_preset()` on Container children

### During QA Testing
- [ ] Test on actual iOS device (simulator may not crash)
- [ ] Monitor for app freezes (main thread hang)
- [ ] Check device logs for SIGKILL 0x8badf00d
- [ ] Test all dynamic UI creation (modals, dialogs, popups)

## Research References

- **Godot Issue**: #104598 (scene editor fix in 4.5, but `.new()` still defaults to Mode 1)
- **iOS Watchdog**: 5-10s timeout for main thread responsiveness
- **Metal Backend**: Godot 4.3+ native Metal has tighter coupling, less tolerant of layout conflicts
- **Forensic Analysis**: `docs/godot-ios-sigkill-research.md` (comprehensive technical deep-dive)

## Prevention Strategy

### For Future Development
1. **Always use Parent-First** - make it muscle memory
2. **Code review checklist** - verify all dynamic UI creation
3. **Run scene_instantiation_validator.py** - catches some issues (not all)
4. **Test on iOS device early** - don't rely on desktop/simulator

### Documentation Updates
- ✅ Added to `.system/CLAUDE_RULES.md` (Godot 4 UI Development section)
- ✅ Added to this lessons-learned document
- ✅ Referenced in godot-ios-sigkill-research.md

## Files Fixed (Week 16 Phase 4)
- `scripts/ui/components/mobile_modal.gd`: 6 nodes
- `scripts/ui/character_details_panel.gd`: 6 nodes

## Commit Reference
- Commit: `ffc7666` - fix(ui): apply Parent-First protocol to prevent iOS SIGKILL crashes

## Key Takeaways

1. **Godot 4 is NOT Godot 3** - UI architecture fundamentally changed
2. **iOS is unforgiving** - desktop masks problems that iOS punishes with SIGKILL
3. **Order matters critically** - parent-then-configure, not configure-then-parent
4. **Explicit is better than implicit** - set `layout_mode = 2` for safety
5. **Evidence-based debugging** - spawn expert agents after 1 failure, not 7

## Related Lessons
- Lesson 19: Evidence-based debugging, not tool thrashing
- Lesson 43: Research discovery tiered system
- CLAUDE_RULES.md: QA & Investigation Protocol (spawn expert agent after 1 failure)

---

**Status**: MANDATORY - All Godot 4 dynamic UI code must follow Parent-First protocol
**Next Review**: Never - this is permanent architectural requirement
