# Mobile UI Specification - Scrap Survivor

**Version**: 1.0
**Created**: 2025-11-22
**Based On**: iOS Human Interface Guidelines, Week 16 UI Audit
**Target Devices**: iPhone 8 (4.7") minimum → iPhone 15 Pro Max (6.7") maximum

---

## Overview

This specification defines mobile-native UI standards for Scrap Survivor. All UI components must meet these standards to ensure usability on mobile devices.

**Design Philosophy**: "Mobile-first, accessible by default"

**Reference Standards**:
- iOS Human Interface Guidelines (HIG)
- WCAG AA Accessibility (4.5:1 contrast minimum)
- Mobile roguelite genre standards (Brotato, Vampire Survivors)

---

## Typography Scale

Based on iOS Dynamic Type system, adapted for game UI.

| Style | Size (pt) | Weight | Line Height | Usage | Examples |
|-------|-----------|--------|-------------|-------|----------|
| **Hero Title** | 34pt | Bold | 1.2× | App title, major headers | "SCRAP SURVIVOR" |
| **Screen Title** | 28pt | Bold | 1.2× | Scene titles | "The Scrapyard", "Your Survivors" |
| **Section Header** | 22pt | Bold | 1.3× | Group headers | "Character Stats", "Inventory" |
| **Subsection Header** | 20pt | Bold | 1.3× | Subsection dividers | "Base Stats", "Bonuses" |
| **Button Large** | 24pt | Bold | 1.0× | Primary action buttons | "PLAY", "CREATE" |
| **Button Medium** | 20pt | Bold | 1.0× | Secondary action buttons | "Details", "Back" |
| **Button Small** | 18pt | Bold | 1.0× | Tertiary buttons | "Delete", "Cancel" |
| **Body Large** | 18pt | Regular | 1.4× | Primary content | Character descriptions |
| **Body Medium** | 17pt | Regular | 1.4× | Secondary content | Stats, metadata |
| **Label** | 16pt | Regular | 1.3× | Input labels | "Character Name:" |
| **Caption** | 14pt | Regular | 1.3× | Small metadata | "Level 5", "100/200 HP" |
| **Footnote** | 13pt | Regular | 1.3× | Minimum readable | Tap hints, fine print |
| **MINIMUM** | **13pt** | Any | 1.3× | **Absolute minimum** | Below this = unreadable on mobile |

### Typography Rules

1. **Never go below 13pt** - Anything smaller is unreadable on mobile devices
2. **Body text should be 17pt+** - For primary content (descriptions, paragraphs)
3. **Use bold for emphasis** - Not color alone (accessibility)
4. **Test on smallest device** - iPhone 8 (4.7") should be readable without squinting
5. **Allow text wrapping** - Don't truncate unless necessary

### Current Violations (From Audit)

- **character_selection.tscn**: 15 labels at 12pt (stat labels) - **MUST FIX**
- Various scenes: 16 labels under 17pt (mostly acceptable for captions/metadata)

---

## Touch Target Sizes

Based on iOS HIG and mobile gaming best practices.

| Element Type | Minimum Size | Recommended Size | Current Status |
|--------------|--------------|------------------|----------------|
| **Primary Button** | 44pt height | 60-80pt height | ✅ 60-132pt |
| **Secondary Button** | 44pt height | 52-60pt height | ✅ 60-99pt |
| **Small Button (Icon)** | 44×44pt | 50×50pt | ✅ 60pt+ |
| **Toggle/Checkbox** | 44×44pt | 48×48pt | N/A |
| **List Row** | Full width × 44pt | Full width × 60-80pt | ✅ 99pt+ |
| **Text Input** | Full width × 44pt | Full width × 52pt | - |

### Touch Target Rules

1. **44pt is MINIMUM, not target** - Aim for 60-80pt for frequently-used buttons
2. **Thumb zones matter** - Bottom 1/3 of screen = easiest to reach one-handed
3. **Spacing prevents mis-taps** - 16-24pt between adjacent buttons
4. **Visual weight = importance** - Play button should be larger than Delete button
5. **Hit boxes = visual size** - No invisible tap areas

### Current Status

✅ **ALL buttons meet 44pt minimum** (0 violations)
✅ **Most buttons are 60-200pt** (excellent)

**Button Size Distribution**:
- 60-80pt: Primary/secondary buttons (most common) ✅
- 99-132pt: Large action buttons (Play, Create, Back) ✅
- 200pt: Character type selection buttons ✅

---

## Spacing Scale

Consistent spacing creates visual rhythm and improves scannability.

| Name | Value (pt) | Usage | Examples |
|------|------------|-------|----------|
| **Tiny** | 4pt | Tight inline spacing | Icon + label gap |
| **Small** | 8pt | Related elements | Stat label + value |
| **Medium** | 12pt | Element separation | List item spacing |
| **Large** | 16pt | Group spacing | Button spacing (prevents mis-taps) |
| **XLarge** | 24pt | Section breaks | Major UI sections |
| **XXLarge** | 32pt | Screen margins | Edge padding |
| **Huge** | 48pt | Hero spacing | Title area padding |

### Spacing Rules

1. **16-24pt between interactive elements** - Prevents accidental taps
2. **32pt screen margins** - Comfortable edge padding (larger screens)
3. **16pt screen margins** - Minimum for small screens (iPhone 8)
4. **12pt minimum for list items** - Comfortable scanning
5. **Group related elements** - Use consistent spacing to show relationships

### Safe Area Handling

**Critical for notched devices (iPhone X+):**

- **Top safe area**: Notch/Dynamic Island (44-59pt on iPhone 15 Pro Max)
- **Bottom safe area**: Home indicator (34pt on modern iPhones)
- **Side safe areas**: Rounded corners (minimal, ~4-8pt)

**ScreenContainer Component** (Phase 6):
- Automatically adds safe area margins
- Use for all full-screen layouts
- Respects `get_viewport().get_safe_area()`

---

## Color Palette & Contrast

Based on existing theme + WCAG AA compliance.

| Color Name | Hex | Usage | Contrast Ratio |
|------------|-----|-------|----------------|
| **Primary Text** | #FFFFFF | Main content | 21:1 on dark BG ✅ |
| **Secondary Text** | #E0E0E0 | Metadata, labels | 12:1 on dark BG ✅ |
| **Disabled Text** | #888888 | Inactive elements | 4.6:1 on dark BG ✅ |
| **Primary Purple** | #9D4EDD | Primary buttons, accents | - |
| **Success Green** | #10B981 | Positive actions, success | - |
| **Danger Red** | #EF4444 | Destructive actions, errors | - |
| **Warning Yellow** | #F59E0B | Warnings, cautions | - |
| **Background Dark** | #0F0F0F | Main background | - |
| **Background Panel** | #1A1A1A | Card/panel backgrounds | - |
| **Border Gray** | #333333 | Subtle borders | - |

### Contrast Rules

1. **Text on background: 4.5:1 minimum** (WCAG AA)
2. **Large text (18pt+): 3:1 minimum** (WCAG AA Large Text)
3. **Interactive elements: 3:1 minimum** (borders, icons)
4. **Don't rely on color alone** - Use icons, text, or patterns for meaning
5. **Test on actual device** - Simulator colors differ from real screens

---

## Button Styles

### Primary Button (Play, Start, Confirm)

**Visual Design**:
- Height: **60-80pt** (mobile-optimized)
- Min Width: **200pt**
- Font: **24pt Bold**
- Corner Radius: **8pt**
- Background: **Primary Purple (#9D4EDD)** or **Success Green (#10B981)**
- Text Color: **White (#FFFFFF)**

**States**:
- **Normal**: Full color, no effects
- **Pressed**: Scale to **0.90× (10% reduction)**, darken 10%
- **Disabled**: 50% opacity, grey background
- **Hover** (desktop): Lighten 10%

**Animation**: 50ms scale-down on press, 100ms bounce-back on release

**Current Usage**: PlayButton, CreateButton, NextWaveButton

---

### Secondary Button (Details, Settings, Back)

**Visual Design**:
- Height: **52-60pt**
- Min Width: **120pt**
- Font: **20pt Bold**
- Corner Radius: **6pt**
- Background: **Outlined** (transparent with 2pt border)
- Border Color: **Secondary Purple (#7B2CBF)**
- Text Color: **Secondary Purple (#7B2CBF)**

**States**:
- **Normal**: Outlined, no fill
- **Pressed**: Scale to 0.90×, fill with border color, text becomes white
- **Disabled**: 50% opacity
- **Hover**: Border brightens 20%

**Current Usage**: DetailsButton, BackButton, SettingsButton

---

### Danger Button (Delete, Quit)

**Visual Design**:
- Height: **50-60pt**
- Min Width: **100pt**
- Font: **18pt Bold**
- Corner Radius: **6pt**
- Background: **Outlined** (transparent with 2pt border)
- Border Color: **Danger Red (#EF4444)**
- Text Color: **Danger Red (#EF4444)**

**States**:
- **Normal**: Red outlined
- **Pressed**: Scale to 0.90×, fill with red, text becomes white
- **Disabled**: 50% opacity
- **Hover**: Border brightens

**Special**: May require **progressive confirmation** (two-step delete) - see Phase 4

**Current Usage**: DeleteButton, QuitButton

---

### Ghost Button (Tertiary, Subtle)

**Visual Design**:
- Height: **44-50pt**
- Font: **16-18pt Bold**
- Background: **Transparent**
- Text Color: **Secondary Text (#E0E0E0)**

**States**:
- **Normal**: Text only, no background
- **Pressed**: Scale to 0.95×, text brightens
- **Disabled**: 50% opacity

**Current Usage**: Collapsible headers, tertiary actions

---

## Layout Guidelines

### Screen Margins

**Responsive to device size**:

| Device | Screen Edges | Top/Bottom | Safe Area Extra |
|--------|--------------|------------|-----------------|
| iPhone 8 (4.7") | 16pt | 24pt | N/A (no notch) |
| iPhone 15 Pro Max (6.7") | 24pt | 32pt | +44pt top (Dynamic Island), +34pt bottom (home indicator) |

**Use ScreenContainer component** (Phase 6) for automatic safe area handling.

---

### Section Spacing

- **Between major sections**: 24-32pt
- **Between related elements**: 12-16pt
- **Between list items**: 8-12pt
- **Between buttons**: 16-24pt (prevents mis-taps)

---

### Text Spacing

- **Line height**: 1.4× font size (body text)
- **Line height**: 1.2× font size (headers)
- **Paragraph spacing**: 12pt
- **Label + value gap**: 8pt

---

## Visual Feedback Standards

### Haptic Feedback

**Intensity Levels** (from HapticManager):
- **Light** (10ms, 30%): Button taps, UI feedback
- **Medium** (25ms, 50%): Selections, confirmations
- **Heavy** (50ms, 80%): Impacts, errors, warnings

**When to Use**:
- ✅ Button presses (all interactive elements)
- ✅ Selections (character selection, item pickup)
- ✅ Confirmations (create character, start wave)
- ✅ Errors (validation failure, delete confirmation)
- ✅ Impacts (damage taken, enemy killed)
- ❌ Continuous events (movement, XP gain) - too spammy

**Platform Support**: iOS 13+, Android 8+, No-op on desktop

---

### Button Press Animation

**Standard Animation** (from ButtonAnimation component):
- **Press**: Scale down to **0.90×** (10% reduction) over **50ms**, ease out
- **Release**: Scale back to **1.0×** over **100ms** with slight bounce (TRANS_BACK)
- **Touch Exit**: Reset to 1.0× if touch moves outside button

**Accessibility**: Respects `UIConstants.animations_enabled` setting

---

### Audio Feedback

**Sound Effects**:
- Button tap: `ui_button_press.ogg` (short, subtle)
- Success: `ui_success.ogg` (positive tone)
- Error: `ui_error.ogg` (warning tone)
- Confirmation: `ui_confirm.ogg` (satisfying click)

**Volume**: -12dB to -18dB (not overpowering)

---

### Loading Indicators

**When to Show**:
- Scene transitions > 100ms
- Async operations (character creation, save/load)
- Network requests (future: leaderboards, cloud save)

**Style**: Spinner or progress bar, depending on operation type

---

## Accessibility Features

### Dynamic Type Support (Phase 2)

**Text scaling**: 0.9× to 1.3× multiplier
**User preference**: Stored in settings (future)
**Test at extremes**: Ensure layout doesn't break at 0.9× or 1.3×

---

### Reduce Motion Support (Phase 5)

**iOS Setting**: Accessibility → Motion → Reduce Motion
**Behavior**: Disable all animations (button scales, transitions)
**Fallback**: Instant state changes (still show pressed state, just no animation)

---

### Haptic Preference (Phase 5)

**User Setting**: Enable/Disable haptics
**Platform Check**: Automatically disabled on desktop/web
**Graceful Degradation**: Game fully playable without haptics

---

## Validation Checklist

Use this checklist for all new UI screens:

### Typography ✅
- [ ] All text ≥ 13pt (absolute minimum)
- [ ] Body text ≥ 17pt (recommended)
- [ ] Headers use hierarchy (34pt → 28pt → 22pt)
- [ ] Text is readable on iPhone 8 without squinting

### Touch Targets ✅
- [ ] All buttons ≥ 44pt height (iOS HIG minimum)
- [ ] Primary buttons ≥ 60pt height (recommended)
- [ ] Adjacent buttons have 16-24pt spacing
- [ ] Buttons tested with "fat finger" (one-handed thumb use)

### Spacing ✅
- [ ] Screen margins: 16-32pt (responsive to device size)
- [ ] Safe areas respected (no overlap with notch/home indicator)
- [ ] Sections have breathing room (24-32pt between major groups)
- [ ] No cramped areas (12pt minimum between elements)

### Color Contrast ✅
- [ ] Text on background ≥ 4.5:1 (WCAG AA)
- [ ] Large text ≥ 3:1 (WCAG AA Large)
- [ ] Tested on actual device (not just simulator)

### Visual Feedback ✅
- [ ] All buttons have haptic feedback
- [ ] All buttons have press animation (scale 0.90×)
- [ ] All buttons have audio feedback (optional but recommended)
- [ ] Loading states for async operations

### Accessibility ✅
- [ ] Dynamic Type support (text scales with user preference)
- [ ] Reduce Motion support (animations can be disabled)
- [ ] Haptics can be disabled
- [ ] No reliance on color alone for meaning

---

## Implementation Notes

### Current Status (Week 16 Phase 1 Audit)

**Completed**:
- ✅ All buttons meet 44pt minimum (0 violations)
- ✅ Most buttons are 60-200pt (excellent)
- ✅ Theme system with Primary/Secondary/Danger/Ghost styles
- ✅ HapticManager with light/medium/heavy support
- ✅ ButtonAnimation component (0.90 scale, 50ms)

**Remaining Work**:
- 🔨 **Phase 2**: Fix character_selection.tscn (15 labels at 12pt → 13pt minimum)
- 🔨 **Phase 2**: Optionally improve 16pt labels to 17pt (body text standard)
- 🔨 **Phase 6**: Implement ScreenContainer for safe areas
- 🔨 **Phase 5**: Add Reduce Motion support
- 🔨 **Phase 7**: Optimize Combat HUD for mobile

---

## Reference Materials

- **iOS HIG**: https://developer.apple.com/design/human-interface-guidelines/
- **WCAG AA**: https://www.w3.org/WAI/WCAG21/quickref/
- **Brotato Reference**: `docs/brotato-reference.md`
- **Week 16 Plan**: `docs/migration/week16-implementation-plan.md`
- **UI Audit Report**: `docs/ui-audit-report.md` (2025-11-22)

---

**Last Updated**: 2025-11-22
**Next Review**: After Phase 2-3 implementation (typography + touch targets)
