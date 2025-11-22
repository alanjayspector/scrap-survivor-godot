# Character Roster Visual Overhaul (Future Work)

**Priority**: Medium-High
**Estimated Effort**: 2-3 hours
**Suggested Approach**: Expert panel consultation (Sr. PM + Sr. Mobile Game Designer)

---

## User Feedback (2025-11-22)

**Context**: During Week 16 Phase 3.5 validation on iPhone 15 Pro Max

**Quote**:
> "The character roster scene still needs work in terms of being visually appealing. The row background color we chose looks very flat, not very mobile game looking. It should look dynamic and really pop. This is a screen that will have a lot of impact as it showcases all the work the player has done - the fruits of their labor."

**Current State**: Functional but "basic" - not visually compelling for a trophy/achievement screen

---

## Problem Statement

The **Character Roster** screen ([scenes/ui/character_roster.tscn](../scenes/ui/character_roster.tscn)) currently:
- ✅ Functions correctly (displays unlocked characters)
- ✅ Has readable typography
- ❌ Looks "flat" and "basic" (not premium mobile game aesthetic)
- ❌ Doesn't create excitement/pride for player achievements
- ❌ Background colors lack dynamism

**Expected**: This screen should feel like a "trophy case" - celebrating player progress with visual flair

---

## Proposed Solution (TBD - Needs Expert Panel)

### Potential Approaches

1. **Card Elevation & Depth**
   - Add shadows/glows to character cards
   - Subtle 3D layering effects
   - Depth perception (card stacking)

2. **Dynamic Backgrounds**
   - Gradient overlays instead of flat colors
   - Animated backgrounds (particles, subtle motion)
   - Character-themed color schemes (per-character auras)

3. **Visual Feedback & Animation**
   - Entrance animations (cards slide in, fade in)
   - Hover/press states with scale/glow
   - Unlock celebrations (particle effects, screen shake)

4. **Premium Polish Elements**
   - Border treatments (glows, gradients)
   - Rarity indicators (common/rare/legendary tiers?)
   - Achievement badges/icons
   - Progress indicators (character mastery/usage stats)

5. **Mobile Game Reference Examples**
   - Brotato: Bold colors, high contrast, chunky borders
   - Hearthstone: Card glows, rarity gems, premium borders
   - Slay the Spire: Elegant frames, subtle animations
   - Marvel Snap: Dynamic card reveals, energy effects

---

## Scope Considerations

**In Scope**:
- Visual design overhaul (colors, effects, animations)
- Premium mobile game aesthetic
- Celebration of player achievements
- Character card presentation

**Out of Scope** (Separate efforts):
- Functional changes to roster system
- Character unlock mechanics
- Stat tracking beyond what exists

---

## Recommended Approach

### Phase 1: Expert Consultation (0.5h)
- Present character roster to Sr. PM + Sr. Mobile Game Designer
- Show current implementation (screenshots)
- Reference industry examples (Brotato, Hearthstone, etc.)
- Get specific visual design recommendations

### Phase 2: Design Mockup (1h)
- Create visual mockup based on expert feedback
- Define color palette, effects, animations
- Document technical implementation plan

### Phase 3: Implementation (1-2h)
- Implement visual improvements
- Add animations/effects
- Polish and iterate

### Phase 4: Validation (0.5h)
- Device testing (iPhone 15 Pro Max, iPhone 8)
- Expert panel review
- User satisfaction check

---

## Technical Considerations

**Existing Systems to Leverage**:
- Theme system ([themes/game_theme.tres](../themes/game_theme.tres))
- ButtonAnimation component ([scripts/ui/components/button_animation.gd](../scripts/ui/components/button_animation.gd))
- HapticManager for tactile feedback
- UI Icons library (Kenney icons)

**New Elements Needed**:
- Card background treatment component
- Particle effects for unlocks/reveals
- Gradient/glow shaders (if needed)
- Animation sequences

---

## Success Criteria

**Visual Impact**:
- ✅ Screen feels "premium" and "mobile-native"
- ✅ Character cards "pop" and feel dynamic
- ✅ Celebrates player achievements visually
- ✅ Comparable polish to commercial mobile roguelites

**User Experience**:
- ✅ User feels proud viewing their roster
- ✅ Screen has "wow factor" for first unlock
- ✅ Clear visual hierarchy (unlocked vs locked)
- ✅ Smooth, delightful interactions

---

## References

**Related Screens**:
- Character Selection: Successfully improved in Week 16 Phase 2 ✅
- Character Creation: Functional, may need similar treatment
- Character Details Panel: Modal that could benefit from polish

**Related Work**:
- Week 16: Mobile UI Standards Overhaul (typography, touch targets, etc.)
- Theme System Phase 1 & 2: Standardized button styles
- ButtonAnimation Component: Press feedback (can be reused)

---

## Priority Rationale

**Why Medium-High Priority:**
- First screen players see after unlocking characters
- High emotional impact (achievement celebration)
- Reflects on overall game quality/polish
- Relatively quick win (2-3 hours with expert guidance)

**Why Not Critical:**
- Functional system works correctly
- Week 16 focus is broader mobile UI standards
- Can be tackled in dedicated visual polish phase

---

## Suggested Timeline

**Option 1: Week 17 Phase** (if Week 16 finishes early)
- Tackle as bonus polish phase
- Leverage existing expert panel momentum

**Option 2: Standalone "Visual Polish Week"**
- Dedicated session for all "trophy case" screens
- Character Roster, Combat Victory screen, etc.
- Comprehensive visual overhaul

**Option 3: Post-Week 16 Quick Win**
- 2-3 hour focused session
- Expert panel consultation + rapid implementation

---

**Created**: 2025-11-22
**Source**: User feedback during Week 16 Phase 3.5 validation
**Status**: Noted for future work (not blocking Week 16 progress)
**Next Step**: Schedule expert panel consultation when ready
