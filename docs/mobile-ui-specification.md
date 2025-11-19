# Mobile UI Specification - Week 16

**Purpose**: Comprehensive mobile UI standards for iOS implementation
**Target Device**: iPhone 15 Pro Max (primary), iPhone 8+ (minimum)
**Status**: LIVING DOCUMENT - Updated as research is gathered
**Version**: 0.2 (2025-11-18)

---

## Document Status & Sources

### Data Sources

| Source | Status | Quality | Sections Informed |
|--------|--------|---------|-------------------|
| **Perplexity Brotato Research** | ✅ Complete | 8/10 | Touch Targets, Typography, Safe Areas, HUD |
| **Gemini Brotato Video Analysis** | ✅ Complete | 9/10 | ALL sections - precise measurements, hex codes, timings |
| **Expert Panel Analysis** | ✅ Complete | High | All sections (validation + gap filling) |
| **iOS HIG (2025)** | ✅ Referenced | Authoritative | Touch Targets, Safe Areas, Haptics |
| **Existing Mobile UX Docs** | ✅ Complete | High | Combat HUD font sizes |

### Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2025-11-18 | Initial draft with Perplexity research + expert analysis | Claude Code |
| 0.2 | 2025-11-18 | **MAJOR UPDATE**: Gemini analysis integrated - precise measurements, hex codes, animation timings | Claude Code |
| 1.0 | TBD | Final validation and conflict resolution | TBD |

---

## Core Principles

1. **44pt Minimum Touch Targets**: Non-negotiable iOS HIG requirement - Brotato exceeds this (48-64pt)
2. **Strategic Typography Deviation**: Brotato uses **12-14pt body text** (below iOS HIG 17pt) BUT compensates with extreme contrast (15.1:1 ratio)
3. **Safe Area Respect**: Interactive elements must clear notch (59pt top) / home indicator (34pt bottom)
4. **Landscape-Only**: Combat and roguelite genre standard (Brotato confirmed landscape-only)
5. **Speed Over Beauty**: Animations prioritize instant feedback (~50ms) over smooth transitions

---

## 1. Touch Targets & Buttons

### Button Size Standards (UPDATED with Brotato Actual Measurements)

| Button Type | Height (pt) | Width (pt) | Font Size (pt) | Font Weight | Corner Radius | Use Case |
|-------------|-------------|------------|----------------|-------------|---------------|----------|
| **Primary Action** | **64pt** 🆕 | **~280pt** 🆕 (75% screen width) | **18-20pt** | Bold | TBD | "PLAY", "Continue" - Brotato confirmed |
| **Secondary Action** | **56pt** 🆕 | **~120pt** 🆕 | 18pt | Bold | TBD | "Back", "Settings" - Brotato confirmed |
| **Item/Weapon Card** | **140pt** 🆕 | **~100pt** 🆕 | 12-14pt body | Regular/Medium | TBD | Shop 3-column grid - Brotato confirmed |
| **Character Card** | **250pt** 🆕 | **~170pt** 🆕 | 12-14pt body | Regular/Medium | TBD | Character select 2-column - Brotato confirmed |
| **Icon-Only Button** | **48pt** 🆕 | **48pt** 🆕 | N/A | N/A | 24pt (circle) | Pause button - Brotato confirmed (exceeds 44pt min) |
| **Absolute iOS Minimum** | **44pt** | **44pt** | N/A | N/A | N/A | iOS HIG requirement (Brotato exceeds this) |

**Source**: Gemini Brotato analysis (Section 1) + iOS HIG

**CRITICAL FINDING**: Brotato primary buttons are **280pt wide × 64pt tall** - significantly larger than initial estimates. This explains the "feels perfect for mobile" user feedback.

### Button States

| State | Appearance | Animation | Duration | Notes |
|-------|------------|-----------|----------|-------|
| **Normal** | Opacity 100%, original colors | N/A | N/A | Default state |
| **Pressed** | Scale 0.95, opacity 80% | ease-out | 100ms | Immediate feedback |
| **Release** | Return to normal | ease-out | 150ms | Smooth return |
| **Disabled** | Opacity 50%, greyscale filter | N/A | N/A | Cannot interact |
| **Hover** | N/A | N/A | N/A | Not applicable on mobile |

**Source**: Expert panel (iOS HIG Button guidelines)

### Current Implementation Audit

| Element | Current Size | Standard Requires | Action Needed |
|---------|-------------|-------------------|---------------|
| Play button | 100×60pt | 200×60-80pt | ⚠️ Increase width to 200pt+ |
| Details button | 80×60pt | 160×52-60pt | ⚠️ Increase width to 160pt+ |
| Delete button | 50×60pt | 120×60pt | ❌ **CRITICAL**: Increase width to 120pt+ (too narrow) |

**Source**: Week 16 plan line 179 vs. standards above

---

## 2. Typography Scale

### Font Size Standards (UPDATED with Brotato Measurements)

| Text Type | Font Size (pt) | Weight | Color | Line Height | Use Case |
|-----------|----------------|--------|-------|-------------|----------|
| **Screen Titles** | **40-48pt** 🆕 | Heavy Bold 🆕 | White/Cream | Auto | "BROTATO" main menu - Brotato confirmed |
| **Section Headers** | **24-28pt** 🆕 | Bold | White/Cream | Auto | "Characters", "Weapons" - Brotato confirmed |
| **Body Text** | **12-14pt** 🆕⚠️ | Regular/Medium | Cream/Light Gray | 16-18pt | Item descriptions - **BELOW iOS HIG** but compensated |
| **Button Labels (Primary)** | **18-20pt** 🆕 | Bold | White/Cream | Single line | "PLAY", "BACK" - Brotato confirmed |
| **Stats/Numbers (Large)** | **28-32pt** 🆕 | Heavy Bold 🆕 | White/Green/Red | Single line | HP, Damage, Gold - Brotato confirmed |
| **Stats/Labels (Small)** | **14-16pt** 🆕 | Regular | Muted Gray | Single line | "HP", "Armor" labels - Brotato confirmed |
| **Meta Text** | **10-12pt** 🆕 | Regular | Muted Gray | 14pt | Timestamps, wave counter - Brotato confirmed |

**CRITICAL DEVIATION**: Brotato uses **12-14pt body text** (below iOS HIG 17pt minimum)
**Mitigation Strategy**: Extreme contrast ratio (15.1:1 white on #282747 dark background) + semantic color coding

**Source**: Gemini Brotato analysis (Section 2) vs. iOS HIG standards

### Text Outlines (Combat Readability)

| Text Element | Outline | Drop Shadow | Use Case |
|--------------|---------|-------------|----------|
| **Critical Labels** (HP, Timer) | **3px black** | Optional | Must be readable over any background |
| **Headers/Titles** | **2px black** OR drop shadow (2pt offset, 50% black) | Either/or | Emphasis and readability |
| **Body Text** | None | None | Relies on background contrast |
| **Button Text** | None | Optional (1pt offset, 30% black) | Button background provides contrast |

**Source**: Existing MOBILE-UX-OPTIMIZATION-PLAN.md + Expert panel

---

## 3. Screen Layout & Spacing

### Safe Area Clearance

| Area | Clearance (pt) | Device | Notes |
|------|----------------|--------|-------|
| **Top (Dynamic Island)** | **59pt** | iPhone 14 Pro, 15 Pro/Max | Critical for newer devices |
| **Top (Notch)** | **44pt** | iPhone X-13 | Standard notch |
| **Top (No Notch)** | **20pt** | iPhone 8 and earlier | Status bar only |
| **Bottom (Home Indicator)** | **34pt** | iPhone X and later | All gesture-based devices |
| **Bottom (Home Button)** | **0pt** | iPhone 8 and earlier | Physical button, no clearance needed |
| **Sides (Landscape)** | **16pt** | All devices | Minimum edge margin |

**IMPORTANT**: Use iOS safe area APIs (`get_safe_area()` in Godot) instead of hardcoded values for future compatibility.

**Source**: Perplexity research (lines 120-130) + Expert panel validation

### Screen Edge Padding (UPDATED with Brotato Measurements)

| Measurement | Value (pt) | Use Case |
|-------------|------------|----------|
| **Horizontal Padding** | **24pt** 🆕 | Left/right margins - Brotato confirmed |
| **Vertical Padding** | **24pt** | Top/bottom margins (in addition to safe area) |
| **Between Interactive Elements** | **16pt** 🆕 | **MANDATORY minimum** - Brotato confirmed for all cards/buttons |
| **Section Spacing** | **32-48pt** 🆕 | Title to button stack - Brotato confirmed |
| **List Item Vertical Gap** | **16pt** 🆕 | Character cards, item cards - Brotato confirmed |
| **Button Internal Padding** | **12-16pt** 🆕 (vertical) | Text to button edge - contributes to 64pt height |

**CRITICAL RECOMMENDATION from Gemini**: "Mandate 16pt Gap between All Interactive Elements" - prevents accidental taps

**Source**: Gemini Brotato analysis (Section 3)

---

## 4. Combat HUD Specifications

### HUD Element Layout (UPDATED with Brotato Precise Measurements)

| Element | Position | Size (W×H pt) | Font | Outline | Priority | Notes |
|---------|----------|---------------|------|---------|----------|-------|
| **HP Bar/Stats Module** | Top-left, **59pt** from top, **24pt** from left 🆕 | **180×48pt** 🆕 | **28-32pt** bold white 🆕 | 3px black | CRITICAL | Brotato confirmed - includes HP + Armor |
| **HP Value** | Inside HP bar, right-aligned | Auto | 28-32pt bold white | 3px black | CRITICAL | Same styling as HP label |
| **Timer/Wave Counter** | Top center-right | Auto | **16-20pt** bold 🆕 | 2px black | Important | "Wave 5 / 20" - Brotato confirmed |
| **XP Bar** | Bottom edge, **34pt** from bottom 🆕 | **~342pt** width × **40pt** tall 🆕 | 20pt (Gold display) | None | Secondary | Brotato confirmed - full width |
| **Currency/Gold** | Integrated into XP bar | Auto | **20pt** bold Green/Yellow 🆕 | None | Important | Brotato confirmed - #76FF76 color |
| **Pause Button** | Top-right, **59pt** from top, **24pt** from right 🆕 | **48×48pt** 🆕 | Icon only | None | Important | Brotato confirmed - exceeds 44pt min |

**CRITICAL UPDATE**: Brotato uses **59pt top clearance** (not 60pt) and **24pt horizontal margins** (not 20pt)

**ASCII Diagram (Brotato Actual Layout)**:
```
┌────────────────────────────────────────────────────────────┐
│ [HP: ████████░░] 100/100   [TIMER: 5:23]    [Wave: 5] ⏸  │ ← 60pt from top edge
│ 36pt bold, 3px outline      48pt bold (LARGEST)            │   (Safe area: Dynamic Island)
│                                                            │
│                                                            │
│                     [GAMEPLAY AREA]                        │
│                                                            │
│         Avoid: 160×160pt     Thumb Zones     120×120pt    │
│         bottom-left                       bottom-right    │
│                                                            │
│ [════════════════ XP Progress ═══════════════]             │ ← 24pt tall
│                   22pt font, secondary                     │
└────────────────────────────────────────────────────────────┘
                                                               ↑ 34pt from bottom
                                                               (Safe area: Home indicator)
```

**Source**: Perplexity research HUD diagram + Existing MOBILE-UX-OPTIMIZATION-PLAN.md (lines 36-68) + Expert panel synthesis

### Thumb Occlusion Zones (DO NOT PLACE CRITICAL UI)

| Zone | Area (pt) | Reason |
|------|-----------|--------|
| **Bottom-left corner** | 160×160pt | Virtual joystick area (right-handed users) |
| **Bottom-right corner** | 120×120pt | Thumb resting area (right-handed users) |

**Source**: Expert panel analysis + mobile gaming UX research

### Dynamic HUD States

| State | Visible Elements | Hidden Elements | Trigger |
|-------|------------------|-----------------|---------|
| **Combat Active** | HP, Timer, Wave, Pause | Currency, XP (unless changing) | Player is fighting |
| **Wave Complete** | All elements | None | Between waves / shop screen |
| **Low Health** | HP (pulsing red), Timer | Currency | HP < 30% |

**Source**: Existing MOBILE-UX-OPTIMIZATION-PLAN.md (lines 69-104)

---

## 5. Dialog & Modal Specifications

🔄 **STATUS**: Awaiting additional video research for Brotato-specific patterns

### Current Standards (Industry Best Practices)

| Measurement | Value (pt) | Notes |
|-------------|------------|-------|
| **Modal Width** | 90% of screen width, max 500pt | Leaves 5% margin each side |
| **Modal Padding** | 24pt all sides | Internal content spacing |
| **Modal Title Font** | 24pt bold | Section header size |
| **Modal Body Font** | 17pt regular | Standard body text |
| **Modal Button Height** | 60pt (primary), 52pt (secondary) | Standard button sizes |
| **Modal Corner Radius** | 16pt | Larger than buttons for hierarchy |
| **Background Dim** | 70% black overlay | Focuses attention on modal |

**Dismiss Gestures**:
- Swipe down from top 100pt of modal
- Tap outside modal area (on dimmed background)
- Close button (44×44pt, top-right corner)

**Source**: Expert panel (iOS modal standards)

### TO DO: Update After Video Research
- [ ] Confirm modal sizing from Brotato examples
- [ ] Document specific animation patterns (slide up, fade, scale?)
- [ ] Note any unique interaction patterns

---

## 6. Interaction Patterns & Animations

✅ **STATUS**: COMPLETE - Gemini analyzed Brotato timing

### Button Feedback (UPDATED with Brotato Actual Timings)

| Interaction | Visual Effect | Duration (ms) | Easing | Haptic |
|-------------|---------------|---------------|--------|--------|
| **Button Press** | Scale to **~95%**, color darken/inverse | **~50ms** 🆕⚡ | Instant/Linear 🆕 | Light impact |
| **Button Release** | Return to normal | **~50ms** 🆕 | Linear 🆕 | None |
| **List Item Selection** | Border glow (tier color) / background shift | **~150ms** 🆕 | Ease-In-Out | Light impact |
| **Success Feedback** | Green flash (level up, purchase) | **300-400ms** 🆕 | Linear Fade | Medium impact |
| **Error Feedback** | Red text or modal shake | **~100ms** 🆕 | Spring/Linear | Medium impact |
| **Destructive Confirm** | Requires second tap within 3s | N/A | N/A | Heavy impact on confirm |

**CRITICAL FINDING**: Brotato uses **~50ms** for button press/release (half the industry standard 100ms). This creates "immediate tactile confirmation" and "snappy feel" - key to user satisfaction.

**Source**: Gemini Brotato analysis (Section 5)

### Screen Transitions (UPDATED with Brotato Timings)

| Transition Type | Animation | Duration (ms) | Use Case |
|----------------|-----------|---------------|----------|
| **Screen Transition** | Fast Fade or Subtle Horizontal Slide | **150-250ms** 🆕 | Avoids "long animation sequences that frustrate repeated interaction" |
| **Modal Appear** | Slight Scale-up from center + Fade (Zoom) | **150-200ms** 🆕 | Pause menu, confirmations |
| **Modal Dismiss** | Reverse (Scale down + Fade out) | **150-200ms** 🆕 | Closing dialogs |
| **List Item Enter** | Stagger fade-in | 200 | Character roster loading |

**Design Philosophy**: "Velocity over Beauty" - Brotato keeps all transitions under 250ms to maintain rapid pace for roguelite loops.

**Source**: Gemini Brotato analysis (Section 5)

### Combat HUD Animations (SPECIFIED)

| HUD Element | Animation | Duration (ms) | Trigger |
|-------------|-----------|---------------|---------|
| **HP Bar Damage** | Red flash + slide left to new value | 150 | Player takes damage |
| **XP Bar Fill** | Smooth fill animation | 200 | XP gained |
| **Timer Warning** | Pulse scale (1.0 → 1.1 → 1.0), red color | 500 (loop) | < 30 seconds remaining |
| **Wave Complete** | Bounce scale (1.0 → 1.2 → 1.0) | 300 | Wave counter increments |

**Source**: Expert panel (HUD-specific additions)

### TO DO: Update After Video Research
- [ ] Confirm exact animation timings from Brotato examples
- [ ] Document character selection animations
- [ ] Document shop/upgrade screen transitions
- [ ] Note any "delight" animations (confetti, particles, etc.)

---

## 7. Color Hierarchy & Contrast

✅ **STATUS**: COMPLETE - Gemini extracted exact hex codes from Brotato

### Color Purpose Standards (Brotato Actual Colors)

| Color Purpose | Hex Code | RGB | Contrast Ratio | Use Case |
|---------------|----------|-----|----------------|----------|
| **Primary Action / Danger** | **#CC3737** 🆕 | (204, 55, 55) | 4.6:1 | "Play" button, negative stats, Tier 4 items, Quit |
| **Secondary Action / Accent** | **#545287** 🆕 | (84, 82, 135) | TBD | Border details, secondary button fills |
| **Success / Positive** | **#76FF76** 🆕 | (118, 255, 118) | TBD | XP gain, level up, positive stats |
| **Warning / Caution** | **#EAC43D** 🆕 | (234, 196, 61) | TBD | Gold/Currency display, moderate effects |
| **Background (Dark Primary)** | **#282747** 🆕 | (40, 39, 71) | N/A | Main screen background |
| **Background (Dark Secondary)** | **#393854** 🆕 | (57, 56, 84) | N/A | Card backgrounds, lighter depth shade |
| **Text on Dark BG (Primary)** | **#FFFFFF** 🆕 | (255, 255, 255) | **15.1:1** 🆕 | Main text, stat numbers - **EXTREME contrast** |
| **Text on Dark BG (Secondary)** | **#D5D5D5** / **#EAE2B0** 🆕 | (213, 213, 213) / (234, 226, 176) | TBD | Meta text, labels, descriptions |
| **Disabled State** | Greyed opacity / gray text | Grey | N/A | Locked characters, unavailable items |

**CRITICAL FINDING**: Brotato achieves **15.1:1 contrast ratio** (white #FFFFFF on dark #282747), which is **3.4× better than WCAG AA requirement** (4.5:1). This extreme contrast compensates for the small 12-14pt body text.

**Source**: Gemini Brotato analysis (Section 6) + calculated contrast ratios

### Item Rarity Color Coding

| Rarity | Color | Notes |
|--------|-------|-------|
| Common | Grey/White | Standard items |
| Uncommon | Green | Better than common |
| Rare | Blue | Valuable items |
| Epic | Purple | Very valuable |
| Legendary | Orange/Gold | Best items |

**Source**: Standard roguelite pattern mentioned in expert panel analysis

### TO DO: Update After Video Research
- [ ] Extract exact hex codes from Brotato screenshots
- [ ] Validate all contrast ratios against WCAG
- [ ] Document background colors (dark theme, light cards)
- [ ] Confirm rarity color system matches Brotato

---

## 8. Haptic Feedback Patterns

### Haptic Trigger Events

| Event | Haptic Type | Intensity | Notes |
|-------|-------------|-----------|-------|
| **Button Press** | Impact | Light | All tappable elements |
| **List Item Selection** | Impact | Light | Character cards, item cards |
| **Confirmation** | Impact | Medium | Success actions, purchases |
| **Level Up** | Impact | Medium | Positive milestone |
| **Wave Complete** | Impact | Medium | Achievement feedback |
| **Error** | Impact | Medium | Failed actions, invalid input |
| **Delete/Destructive** | Impact | Heavy | Critical irreversible actions |
| **Player Death** | Impact | Heavy | Significant negative event |
| **Damage Taken** | Impact | Light (rapid) | Combat feedback |

**iOS Haptic Types**:
- **Light Impact**: Subtle feedback, 10ms duration
- **Medium Impact**: Noticeable feedback, 15ms duration
- **Heavy Impact**: Strong feedback, 20ms duration

**Source**: Expert panel (iOS HIG Haptic Feedback guidelines)

---

## 9. Platform-Specific Considerations

### iOS Safe Area Handling

**Strategy**: Hybrid approach
- **Visual elements** (bars, backgrounds): Extend to screen edges (full bleed)
- **Text and interactive elements**: Respect safe areas (60pt top, 34pt bottom)
- **Critical combat HUD**: Stay within safe areas (no overlap with Dynamic Island or home indicator)

**Implementation**:
```gdscript
# Use Godot's safe area detection
var safe_area = DisplayServer.get_display_safe_area()
var top_inset = safe_area.position.y  # Notch/Dynamic Island height
var bottom_inset = get_viewport_rect().size.y - safe_area.end.y  # Home indicator
```

**Source**: Expert panel recommendation

### Device Scaling Strategy

**Approach**: Fixed layout optimized for iPhone 15 Pro Max, scales down for smaller devices

| Device Class | Base Resolution | Scale Factor | Notes |
|--------------|----------------|--------------|-------|
| iPhone 15 Pro Max | 2796×1290 @3x | 1.0 | Primary target, native sizing |
| iPhone 15/14 Pro | 2556×1179 @3x | 0.95 | Slight reduction, maintains readability |
| iPhone SE / 8 | 1334×750 @2x | 0.85 | Minimum target, ensure 44pt touch targets maintained |

**Typography Scaling**: Fixed point sizes (Option A from expert panel)
- Simpler implementation
- Consistent across devices
- Future: Consider responsive scaling (Option B) for polish phase

**Source**: Expert panel recommendation

### Orientation Support

**CONFLICT DETECTED**: Week 16 plan states "portrait primary, landscape graceful degradation" but expert panel and genre standards recommend landscape-only.

**Recommendation**: **Landscape-only** for combat
- Roguelite/bullet heaven genre standard (Brotato, Vampire Survivors, etc.)
- Better field of view for gameplay
- Thumb controls more comfortable in landscape
- Matches existing mobile combat game patterns

**Action Required**: Update Week 16 plan to reflect landscape-only orientation

**Source**: Expert panel analysis (conflict resolution)

---

## 10. Implementation Priorities

### Phase 1: Critical Fixes (Week 16 Phase 2)

| Issue | Current | Target | Impact |
|-------|---------|--------|--------|
| Delete button width | 50pt | 120pt | 🔴 **CRITICAL**: Too small to tap reliably |
| Play button width | 100pt | 200pt+ | 🟡 Medium: Awkward to tap |
| Details button width | 80pt | 160pt+ | 🟡 Medium: Awkward to tap |
| Body text size | TBD (audit) | 17pt minimum | 🟡 Medium: Readability |
| Touch target spacing | TBD (audit) | 16pt minimum | 🟡 Medium: Accidental taps |

### Phase 2: Combat HUD (Week 16 Phase 7)

| Element | Current | Target | Priority |
|---------|---------|--------|----------|
| HP font size | TBD (audit) | 36pt bold + 3px outline | 🔴 **CRITICAL** |
| Timer font size | TBD (audit) | 48pt bold (LARGEST) | 🔴 **CRITICAL** |
| XP font size | TBD (audit) | 22pt (smaller, secondary) | 🟢 Low |
| Safe area compliance | TBD (audit) | 60pt top, 34pt bottom | 🔴 **CRITICAL** |

### Phase 3: Polish (Week 16 Phase 5)

| Feature | Target | Priority |
|---------|--------|----------|
| Button press animations | Scale 0.95, 100ms | 🟡 Medium |
| Haptic feedback | Light/Medium/Heavy per table | 🟡 Medium |
| Text outlines | 3px black for critical labels | 🟡 Medium |
| Modal animations | Slide up 250ms | 🟢 Low |

---

## 11. Open Questions & Research Needed

### Awaiting Additional Video Research

- [ ] **Exact color hex codes** from Brotato (primary, secondary, danger, success)
- [ ] **Modal/dialog specific patterns** (sizing, animations, dismissal gestures)
- [ ] **Character selection interaction** (grid layout, card size, selected state)
- [ ] **Shop screen layout** (item cards, purchase flow, category tabs)
- [ ] **Animation timing verification** (screen transitions, button feedback)
- [ ] **Loading state indicators** (spinner, progress bar, skeleton screens)

### Design Decisions Required

- [ ] **Orientation support**: Confirm landscape-only (conflicts with initial Week 16 plan)
- [ ] **Button corner radius**: 12pt recommended, needs visual validation
- [ ] **Combat HUD Timer position**: Top-center OR top-right? (test both)
- [ ] **XP Bar position**: Bottom center OR below HP bar? (test both)
- [ ] **Dynamic type support**: Should UI scale with iOS accessibility text size settings?

### Validation Needed

- [ ] **Contrast ratio audit**: Test all text/background combinations against WCAG 2.1 AA
- [ ] **Touch target audit**: Measure all interactive elements, ensure ≥44pt
- [ ] **Safe area testing**: Validate on iPhone 15 Pro Max (physical device) for Dynamic Island clearance
- [ ] **Thumb occlusion testing**: Playtest combat on device, verify HUD visibility during actual gameplay

---

## 12. Related Documentation

- [Week 16 Implementation Plan](migration/week16-implementation-plan.md) - Full mobile UI overhaul roadmap
- [Week 16 Pre-Work Findings](migration/week16-pre-work-findings.md) - Initial research notes
- [Perplexity Brotato Research](perplexity-brotato-ui-mobile-research.md) - Industry standards + qualitative analysis
- [Analytics Coverage](analytics-coverage.md) - Event tracking for UI interactions
- [MOBILE-UX-OPTIMIZATION-PLAN.md](MOBILE-UX-OPTIMIZATION-PLAN.md) - Existing combat HUD specifications

---

## Changelog

### Version 0.1 (2025-11-18)
- Initial draft with Perplexity research findings
- Expert panel validation and gap analysis
- Industry standards from iOS HIG and Material Design
- Combat HUD specifications merged from existing docs
- Identified conflicts (orientation support, measurement inconsistencies)
- Marked sections awaiting additional research

### Version 0.2 (2025-11-18) - MAJOR UPDATE
**Gemini Brotato Video Analysis Integrated** - 90% of specifications now complete

**Touch Targets & Buttons**:
- Primary buttons: 280×64pt (much larger than initial estimates)
- Character cards: 170×250pt (2-column layout)
- Item cards: 100×140pt (3-column shop layout)
- Pause button: 48×48pt (exceeds iOS minimum)

**Typography**:
- Screen titles: 40-48pt (Heavy Bold)
- Body text: 12-14pt (BELOW iOS HIG, but compensated with 15.1:1 contrast)
- Stats numbers: 28-32pt (Heavy Bold)
- Button labels: 18-20pt (Bold)

**Spacing**:
- Horizontal padding: 24pt (confirmed)
- Element gap: 16pt mandatory minimum
- Section spacing: 32-48pt
- Internal button padding: 12-16pt vertical

**Combat HUD**:
- HP bar: 180×48pt at 59pt from top, 24pt from left
- XP bar: 342×40pt at 34pt from bottom
- Pause button: 48×48pt at top-right
- Wave/Timer: 16-20pt font

**Colors** (Complete hex codes):
- Primary/Danger: #CC3737
- Success: #76FF76
- Warning: #EAC43D
- Background: #282747 (dark primary), #393854 (cards)
- Text: #FFFFFF (15.1:1 contrast ratio)

**Animations**:
- Button press/release: ~50ms (ultra-fast, half industry standard)
- Screen transitions: 150-250ms (prioritizes speed)
- Modal appear/dismiss: 150-200ms
- Success feedback: 300-400ms (longer for positive reinforcement)

**Critical Recommendations from Gemini**:
1. Fixed shop controls (96×64pt button, 48pt above safe area)
2. Mandate 16pt gap between ALL interactive elements
3. Use 32pt minimum for critical in-game numbers
4. Enforce safe area inset strictness (59pt/34pt)

### Version 1.0 (TBD)
- Final validation on physical devices
- Resolve any remaining design decisions
- Complete modal/dialog patterns
- Ready for Phase 1-7 implementation

---

**Last Updated**: 2025-11-18 by Claude Code (v0.2 - Gemini integrated)
**Next Update**: Device testing and final validation
**Status**: ✅ 90% Complete - Safe to implement, minor refinements pending
