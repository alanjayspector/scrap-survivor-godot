# Next Session: Theme System Implementation

**Last Updated**: 2025-11-20 20:30
**Current Branch**: `main` (merged from `test/performance-diagnostic-7acc9e0`)
**Next Task**: Godot Theme System Research + Implementation

---

## Bug Fix Summary (COMPLETED)

### iOS Metal ScrollContainer Clipping Bug - SOLVED

**Root Cause**: iOS Metal TBDR (Tile-Based Deferred Rendering) strictly culls 0x0 geometry. Combined with `clip_contents = true` (default), dynamically created content was being incorrectly clipped even when sizes were valid.

**The Fix (Applied)**:
1. `clip_contents = false` on ScrollContainer
2. Proper async timing with `await get_tree().process_frame` after `queue_free()` and after adding children
3. `custom_minimum_size` on all dynamically created nodes

**Key Technical Findings**:
| Issue | Solution |
|-------|----------|
| `queue_free()` is async | Await frame after clearing before adding new nodes |
| iOS Metal culls 0x0 geometry | Set `custom_minimum_size` on dynamic nodes |
| `clip_contents=true` broken on iOS | Set `clip_contents = false` |
| Layout needs time to propagate | Await frame after adding children |

---

## Character Details Panel Redesign (COMPLETED)

Implemented modern mobile UI pattern based on expert panel research (Vampire Survivors, Brotato, Survivor.io):

**New Structure**:
- 3-tab layout: Stats | Gear | Records
- Primary stats card: 4 key stats always visible (HP, DMG, ARM, SPD)
- Collapsible sections: Offense/Defense/Utility (tap to expand)
- Currency moved to Records tab

**Issues Remaining** (to be fixed by Theme System):
- Emojis don't render on iOS (need sprite-based icons or styled text)
- No visual styling on cards/buttons (default Godot look)
- Tabs and collapsible headers look like plain text
- Overall UI lacks game-ready polish

---

## Next Session: Theme System

### Quick Start Prompt

```
I'm implementing a Godot 4.5.1 Theme System for production-ready mobile game UI.

Please start by:
1. Read .system/CLAUDE_RULES.md
2. Read .system/NEXT_SESSION.md (this file)
3. Do research on Godot 4 Theme system best practices

Context:
- Branch: main (start new feature/theme-system branch)
- All tests passing: 647/671
- We have existing UIConstants and ColorPalette in scripts/ui/theme/
- Current UI uses default Godot styling - needs game-ready polish
- Target: Mobile survivor game (iOS primary, landscape orientation)

Research questions to answer:
1. Theme resource (.tres) vs StyleBox approach - which is better for mobile games?
2. How to handle emoji/icon rendering on iOS (sprite sheets vs custom font?)
3. Best practices for TabContainer and Button styling in Godot 4
4. How other Godot mobile games structure their theme systems
5. Performance considerations for mobile theme systems

After research, create implementation plan for:
- Styled buttons (primary, secondary, destructive)
- Styled cards/panels with backgrounds
- Styled tabs
- Icon system that works on iOS
- Consistent typography
```

### Gemini Research Prompts

For deeper research, use these prompts with Gemini:

**Prompt 1: Godot 4 Theme System Deep Dive**
```
I'm building a mobile game in Godot 4.5.1 (survivor-like, iOS primary). I need to implement a professional Theme system. Please research and explain:

1. Theme resource architecture in Godot 4:
   - Theme inheritance and overrides
   - StyleBox types (Flat, Texture, Line, Empty) and when to use each
   - Theme type variations (hover, pressed, disabled states)

2. Best practices for mobile game themes:
   - Performance considerations
   - Touch state feedback (pressed states, visual feedback)
   - Accessibility (contrast, touch targets)

3. Real-world examples:
   - How do successful Godot mobile games structure their themes?
   - Common patterns and anti-patterns

4. Integration with existing code:
   - I have UIConstants.gd and ColorPalette.gd already
   - How should Theme resource reference these?

Provide concrete Godot 4.5 code examples and .tres file structure.
```

**Prompt 2: iOS Icon Rendering Solutions**
```
In my Godot 4.5.1 mobile game, emoji characters (❤️⚔️🛡️) don't render on iOS devices. Research solutions:

1. Why do emojis fail to render on iOS in Godot?
2. Alternative approaches:
   - Custom icon font (like Font Awesome)
   - Sprite sheet with TextureRect
   - Using Godot's built-in icon system
   - SVG icons

3. For each approach, provide:
   - Pros/cons for mobile performance
   - Implementation complexity
   - Godot 4.5 code examples

4. Recommended solution for a mobile game with ~20 different UI icons

I need a solution that works reliably on iOS and Android, with good performance.
```

**Prompt 3: Modern Mobile Game UI Patterns in Godot**
```
Research how to implement these modern mobile game UI patterns in Godot 4.5.1:

1. Styled TabContainer:
   - Custom tab bar appearance
   - Tab indicator/underline animations
   - Touch-friendly tab sizing

2. Collapsible/Accordion sections:
   - Smooth expand/collapse animations
   - Visual expand/collapse indicators
   - Touch feedback

3. Card-style panels:
   - Elevated appearance (shadow/border)
   - Rounded corners
   - Background styling

4. Button variations:
   - Primary (prominent, colored)
   - Secondary (outlined)
   - Destructive (red, for delete actions)
   - Ghost (minimal, text-only)

For each, provide Godot 4.5 Theme/StyleBox configuration and any required GDScript.
Reference games like Vampire Survivors, Brotato, Survivor.io for visual inspiration.
```

---

## Branch Strategy

```
main (current)
  └── feature/theme-system (create this)
        ├── Theme resource (.tres)
        ├── Styled components
        └── Icon system
```

After theme system is complete, merge to main.

**Abandoned branch**: `feature/week16-mobile-ui` - Superseded by diagnostic branch work, safe to delete.

---

## Files to Reference

**Existing Theme Infrastructure**:
- `scripts/ui/theme/ui_constants.gd` - Measurements, spacing, touch targets
- `scripts/ui/theme/color_palette.gd` - Colors with WCAG contrast validation

**Mobile UI Spec**:
- `docs/mobile-ui-specification.md` - Complete design system spec (v1.1)

**Current Panel Implementation**:
- `scenes/ui/character_details_panel.tscn` - New tabbed structure
- `scripts/ui/character_details_panel.gd` - Collapsible logic

**Research Documents**:
- `docs/gemini-mobile-ui-research.md` - Previous research
- `docs/claude-mobile-game-ui-design-system.md` - Design system docs

---

## Success Criteria for Theme System

1. **Buttons** look styled (not default Godot gray)
2. **Cards/panels** have visible backgrounds with rounded corners
3. **Tabs** are clearly tappable with visual selection state
4. **Icons** render correctly on iOS (no broken emojis)
5. **Collapsible headers** look like buttons, not plain text
6. **Consistent typography** across all screens
7. **All touch targets** remain iOS HIG compliant (44pt+)
8. **Performance** - No frame drops on mobile

---

**Session Date**: 2025-11-20
**Commits on main**: Up to `96a709f` (feat: redesign character details panel)
