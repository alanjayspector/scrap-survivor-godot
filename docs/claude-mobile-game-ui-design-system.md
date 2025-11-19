# Mobile Game UI Design System for Godot 4.5.1
## Industry Best Practices & Implementation Guide

**Document Version**: 1.0  
**Last Updated**: November 18, 2025  
**Target Platform**: iOS 15+ (primary), Android 8+ (secondary)  
**Game Engine**: Godot 4.5.1  
**Minimum iOS**: iOS 15.0 (98% market coverage, mature Safe Area APIs)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Touch Target Standards](#1-touch-target-standards)
3. [Typography Scale](#2-typography-scale)
4. [Spacing System](#3-spacing-system)
5. [Combat HUD Layout](#4-combat-hud-layout)
6. [Interaction Patterns & Animations](#5-interaction-patterns--animations)
7. [Color Hierarchy & Accessibility](#6-color-hierarchy--accessibility)
8. [Screen-Specific Patterns](#7-screen-specific-patterns)
9. [Polish & Feedback Details](#8-polish--feedback-details)
10. [Godot 4.5.1 Implementation Guide](#godot-451-implementation-guide)
11. [Priority Matrix](#priority-matrix)
12. [Testing Framework](#testing-framework)

---

## Executive Summary

This document provides a comprehensive mobile game UI design system based on iOS Human Interface Guidelines (HIG), Material Design principles, and battle-tested patterns from successful mobile games. Rather than copying a single game's measurements, this system teaches you the **principles** behind good mobile UI design so you can make informed decisions for your specific game.

### Key Philosophy: Form Follows Function

Mobile game UI design balances three competing priorities:

1. **Usability** - Players must be able to interact without errors
2. **Readability** - Information must be scannable during action
3. **Minimal Occlusion** - UI should not block gameplay

**Software Engineering Principle: Design by Contract**  
Every UI element has implicit contracts:
- Buttons promise they can be pressed accurately
- Text promises it can be read at a glance
- Layout promises it won't interfere with gameplay

This document defines those contracts with specific measurements.

### Why These Numbers Matter

Mobile UI is constrained by **human physiology**:
- **Average adult thumb width**: 11-14mm (≈40-50pt on screen)
- **Minimum comfortable target**: 9mm (≈32pt)
- **iOS minimum recommendation**: 44pt (12.5mm on standard density)
- **Android minimum recommendation**: 48dp (≈9mm)

**We use the iOS 44pt standard** as our baseline because:
1. It's well-tested across billions of interactions
2. It works for 95th percentile hands (small to large)
3. It provides sufficient error margin during fast gameplay

---

## 1. Touch Target Standards

### Core Principle: Fitts's Law

**Definition**: The time to acquire a target is a function of distance and size.

**Practical Application**: Make important, frequently-pressed buttons larger and closer to natural thumb positions.

### Standard Touch Target Measurements

| Element Type | Width (pt) | Height (pt) | iOS HIG | Android | Notes |
|--------------|------------|-------------|---------|---------|-------|
| **Primary Action Button** | 280-320 | 56-64 | ✅ | ✅ | "Play", "Continue" - use full content width minus margins |
| **Secondary Action Button** | 140-160 | 52-56 | ✅ | ✅ | "Back", "Settings" - can be smaller than primary |
| **Icon-Only Button** | 52-60 | 52-60 | ✅ | ✅ | Close, settings, info - add 8pt padding beyond icon |
| **Combat Button** | 64-80 | 64-80 | ✅ | ✅ | Pause, abilities - needs to be tappable during action |
| **Character/Item Card** | 120-140 | 160-180 | ✅ | ✅ | Selection grids - optimize for 2-3 columns |
| **List Item Row** | Full width | 60-72 | ✅ | ✅ | Tappable lists - needs vertical breathing room |
| **Virtual Joystick Area** | 120-160 | 120-160 | ✅ | ✅ | Movement controls - large touch area, visual can be smaller |

### Software Engineering Concept: **Magic Numbers Anti-Pattern**

Don't hardcode these values throughout your code. Instead:

```gdscript
# res://ui/ui_constants.gd
class_name UIConstants
extends RefCounted

# Touch target sizes (iOS points)
const TOUCH_TARGET_MIN: int = 44
const TOUCH_TARGET_STANDARD: int = 56
const TOUCH_TARGET_LARGE: int = 64
const TOUCH_TARGET_COMBAT: int = 72

# Minimum spacing between interactive elements
const TOUCH_SPACING_MIN: int = 8

# Helper function to ensure minimum size
static func ensure_minimum_touch_target(size: Vector2) -> Vector2:
    return Vector2(
        max(size.x, TOUCH_TARGET_MIN),
        max(size.y, TOUCH_TARGET_MIN)
    )
```

### Thumb Zone Analysis

**Critical Concept**: Natural thumb reach zones vary by hand position.

```
┌─────────────────────────────────────┐
│ ❌ Hard to Reach (top corners)      │
│                                      │
│      🟡 Moderate (top center)       │
│                                      │
│                                      │
│   ✅ Easy (center, lower third)     │
│                                      │
│ 👍 Natural Thumb Rest               │
│    (bottom third, centered)         │
└─────────────────────────────────────┘
```

**Design Principle**: Place **primary actions** in the ✅ Easy zone, **secondary actions** in 🟡 Moderate, **destructive actions** in ❌ Hard.

**Why?** This creates natural **progressive disclosure** - important actions are fast, dangerous actions require deliberate movement.

### Godot Implementation Pattern

```gdscript
# res://ui/components/adaptive_button.gd
@tool
class_name AdaptiveButton
extends Button

@export var button_type: ButtonType = ButtonType.STANDARD

enum ButtonType {
    STANDARD,      # 56pt
    COMBAT,        # 72pt for in-game
    ICON_ONLY,     # 52pt square
    PRIMARY        # 56-64pt height, full width
}

func _ready():
    _apply_size_constraints()

func _apply_size_constraints():
    match button_type:
        ButtonType.STANDARD:
            custom_minimum_size = Vector2(UIConstants.TOUCH_TARGET_STANDARD, 
                                         UIConstants.TOUCH_TARGET_STANDARD)
        ButtonType.COMBAT:
            custom_minimum_size = Vector2(UIConstants.TOUCH_TARGET_COMBAT, 
                                         UIConstants.TOUCH_TARGET_COMBAT)
        ButtonType.ICON_ONLY:
            custom_minimum_size = Vector2(52, 52)
        ButtonType.PRIMARY:
            custom_minimum_size = Vector2(0, 56)  # Width handled by container
```

**Software Engineering Principle: Single Responsibility Principle (SRP)**  
This button component has ONE job: ensure minimum touch target compliance. Layout and styling are separate concerns.

---

## 2. Typography Scale

### Core Principle: Readability Hierarchy

**Definition**: Text must be scannable at three cognitive levels:
1. **Glanceable** (0.5s) - Critical game state (HP, ammo)
2. **Scannable** (2-3s) - Menus, options
3. **Readable** (5s+) - Descriptions, tutorials

### Standard Typography Scale (iOS Points)

| Style | Size (pt) | Weight | Line Height | Use Case | Min iOS | WCAG Level |
|-------|-----------|--------|-------------|----------|---------|------------|
| **Display Large** | 48-56 | Bold/Black | 1.1 | Splash screens, game over | ✅ | AAA |
| **Display Medium** | 36-42 | Bold | 1.15 | Screen titles, wave numbers | ✅ | AAA |
| **Title Large** | 28-32 | SemiBold | 1.2 | Section headers | ✅ | AAA |
| **Title Medium** | 22-24 | Medium | 1.25 | Card titles, character names | ✅ | AA |
| **Body Large** | 18-20 | Regular | 1.4 | Item descriptions, tutorials | ✅ | AA |
| **Body Standard** | 16-17 | Regular | 1.45 | Button labels, default text | ✅ | AA |
| **Body Small** | 14-15 | Regular | 1.4 | Meta info, timestamps | ✅ | AA |
| **Caption** | 12-13 | Regular/Medium | 1.3 | Stat labels, subscript | ⚠️ | A |
| **Stat Numbers (Combat)** | 24-28 | Bold | 1.0 | HP, damage numbers | ✅ | AAA |
| **Currency/Score** | 20-24 | SemiBold | 1.15 | Gold, XP display | ✅ | AA |

### Critical Design Principles

**1. Minimum 17pt for Body Text**  
iOS HIG recommends 17pt as the smallest comfortable reading size for extended text. We use 16pt for labels/buttons (short text) but never below.

**2. Line Height (Leading)**  
Line height = font size × multiplier. Dense text (1.2-1.3) for UI elements, comfortable (1.4-1.5) for reading.

**3. Weight Hierarchy**  
Use font weight to create visual hierarchy without changing size:
- **Bold/Black** - Primary actions, critical info
- **SemiBold** - Secondary headers, emphasis
- **Medium** - Button labels, navigation
- **Regular** - Body text, descriptions

### Godot Typography System

```gdscript
# res://ui/theme/typography_theme.gd
class_name TypographyTheme
extends RefCounted

# Font sizes in pixels (multiply by scale factor for points)
# Note: Godot uses pixels, but we think in points for cross-platform
const SCALE_FACTOR = 1.0  # Adjust based on target DPI

const SIZE_DISPLAY_LARGE = 52
const SIZE_DISPLAY_MEDIUM = 38
const SIZE_TITLE_LARGE = 30
const SIZE_TITLE_MEDIUM = 23
const SIZE_BODY_LARGE = 19
const SIZE_BODY_STANDARD = 17
const SIZE_BODY_SMALL = 15
const SIZE_CAPTION = 13
const SIZE_STAT_COMBAT = 26
const SIZE_CURRENCY = 22

# Create a theme resource with all text styles
static func create_game_theme() -> Theme:
    var theme = Theme.new()
    
    # Load your font resources
    var font_regular = load("res://fonts/your_font_regular.ttf")
    var font_medium = load("res://fonts/your_font_medium.ttf")
    var font_bold = load("res://fonts/your_font_bold.ttf")
    
    # Define label styles
    _add_label_style(theme, "DisplayLarge", font_bold, SIZE_DISPLAY_LARGE)
    _add_label_style(theme, "TitleLarge", font_bold, SIZE_TITLE_LARGE)
    _add_label_style(theme, "Body", font_regular, SIZE_BODY_STANDARD)
    _add_label_style(theme, "Caption", font_regular, SIZE_CAPTION)
    
    return theme

static func _add_label_style(theme: Theme, style_name: String, 
                             font: Font, size: int) -> void:
    theme.set_font(style_name, "Label", font)
    theme.set_font_size(style_name, "Label", size)
```

### Component-Based Typography

**Software Engineering Principle: Composition Over Inheritance**

Rather than creating 15 different Label subclasses, use a single component with variants:

```gdscript
# res://ui/components/styled_label.gd
@tool
class_name StyledLabel
extends Label

@export var text_style: TextStyle = TextStyle.BODY

enum TextStyle {
    DISPLAY_LARGE,
    DISPLAY_MEDIUM,
    TITLE_LARGE,
    TITLE_MEDIUM,
    BODY_LARGE,
    BODY,
    CAPTION,
    STAT_COMBAT,
    CURRENCY
}

func _ready():
    _apply_style()

func _apply_style():
    match text_style:
        TextStyle.DISPLAY_LARGE:
            add_theme_font_size_override("font_size", 
                TypographyTheme.SIZE_DISPLAY_LARGE)
            add_theme_color_override("font_color", Color.WHITE)
        TextStyle.BODY:
            add_theme_font_size_override("font_size", 
                TypographyTheme.SIZE_BODY_STANDARD)
            add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
        TextStyle.CAPTION:
            add_theme_font_size_override("font_size", 
                TypographyTheme.SIZE_CAPTION)
            add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
```

**Usage in scenes**:
```gdscript
# Just set the text_style export in the inspector
# No need to manually configure fonts/sizes
```

### Font Selection Best Practices

**For Mobile Games**:
1. **Use Sans-Serif** - More readable at small sizes
2. **Avoid Thin Weights** - Hard to read on varied backgrounds
3. **Test on Device** - Fonts render differently than on desktop
4. **Provide Fallbacks** - System fonts for unsupported characters

**Recommended Font Families**:
- **Open Sans** - Excellent readability, free, wide character support
- **Roboto** - Android system default, very readable
- **Inter** - Modern, optimized for UI
- **SF Pro** - iOS system font (if you can match it)

---

## 3. Spacing System

### Core Principle: 8-Point Grid System

**Definition**: All spacing values are multiples of 8pt (4pt for fine-tuning).

**Why?** 
- Creates visual rhythm and consistency
- Scales cleanly across different screen densities
- Reduces decision fatigue (use 8, 16, 24, 32 instead of arbitrary values)

**Software Engineering Concept: Constraint-Based Design**  
By limiting options, you make better decisions faster.

### Standard Spacing Values

| Size Name | Value (pt) | Use Case | Example |
|-----------|------------|----------|---------|
| **XXS** | 4 | Icon-to-text gap, fine adjustments | Padding between icon and button text |
| **XS** | 8 | Minimum between interactive elements | Space between two buttons side-by-side |
| **SM** | 12 | Compact vertical spacing | Gap in dense lists |
| **MD** | 16 | Standard spacing | Default margin, button padding |
| **LG** | 24 | Section spacing | Space between UI groups |
| **XL** | 32 | Major section breaks | Top/bottom screen margins |
| **XXL** | 48 | Screen-level padding | Space above/below main content |
| **XXXL** | 64 | Dramatic separation | Splash screen spacing |

### Safe Area Spacing (iOS)

**Critical for Notched Devices**: iPhone X and newer have "safe areas" you must respect.

```
┌────────────────────────────────────┐
│ ⚠️ Status Bar / Dynamic Island     │ ← 47pt+ from top
├────────────────────────────────────┤
│                                     │
│                                     │
│         SAFE CONTENT AREA           │
│                                     │
│                                     │
├────────────────────────────────────┤
│ ⚠️ Home Indicator Area              │ ← 34pt+ from bottom
└────────────────────────────────────┘
   ↑ 44pt+ from edges on iPhone 14 Pro
```

**Standard Safe Area Margins**:
- **Top**: 60-64pt (status bar + padding)
- **Bottom**: 40-44pt (home indicator + padding)
- **Left/Right**: 20-24pt on most devices, 44pt+ on notched phones in landscape

### Godot Safe Area Implementation

```gdscript
# res://ui/layout/safe_area_container.gd
class_name SafeAreaContainer
extends MarginContainer

@export var respect_safe_areas: bool = true
@export var minimum_top_margin: int = 60
@export var minimum_bottom_margin: int = 40
@export var minimum_side_margin: int = 20

func _ready():
    if respect_safe_areas:
        _apply_safe_area_margins()
    else:
        _apply_default_margins()

func _apply_safe_area_margins():
    # Get safe area from OS (iOS/Android provide this)
    var safe_rect = DisplayServer.get_display_safe_area()
    var window_size = get_viewport().get_visible_rect().size
    
    # Calculate margins
    var top = max(safe_rect.position.y, minimum_top_margin)
    var bottom = max(window_size.y - safe_rect.end.y, minimum_bottom_margin)
    var left = max(safe_rect.position.x, minimum_side_margin)
    var right = max(window_size.x - safe_rect.end.x, minimum_side_margin)
    
    # Apply to container
    add_theme_constant_override("margin_top", top)
    add_theme_constant_override("margin_bottom", bottom)
    add_theme_constant_override("margin_left", left)
    add_theme_constant_override("margin_right", right)

func _apply_default_margins():
    add_theme_constant_override("margin_top", minimum_top_margin)
    add_theme_constant_override("margin_bottom", minimum_bottom_margin)
    add_theme_constant_override("margin_left", minimum_side_margin)
    add_theme_constant_override("margin_right", minimum_side_margin)
```

### Spacing Constants

```gdscript
# res://ui/ui_constants.gd (continued from earlier)

# 8-point grid spacing system
const SPACING_XXS: int = 4
const SPACING_XS: int = 8
const SPACING_SM: int = 12
const SPACING_MD: int = 16
const SPACING_LG: int = 24
const SPACING_XL: int = 32
const SPACING_XXL: int = 48
const SPACING_XXXL: int = 64

# Safe area margins
const SAFE_AREA_TOP: int = 60
const SAFE_AREA_BOTTOM: int = 40
const SAFE_AREA_SIDES: int = 20
const SAFE_AREA_SIDES_LANDSCAPE: int = 44  # For notched phones in landscape

# Screen edge padding
const SCREEN_EDGE_PADDING: int = 20  # Standard left/right margin
const SCREEN_SECTION_SPACING: int = 24  # Between major UI sections

# Button internal padding
const BUTTON_PADDING_VERTICAL: int = 12
const BUTTON_PADDING_HORIZONTAL: int = 16
const BUTTON_PADDING_LARGE: int = 20  # For primary buttons

# Card/Panel padding
const CARD_PADDING_INTERNAL: int = 16
const CARD_SPACING_BETWEEN: int = 12  # Gap between cards in grid
```

### Layout Patterns

**Pattern 1: Full-Width Content with Margins**
```
┌─────────────────────────────────────┐
│ [20pt] ← SCREEN_EDGE_PADDING        │
│ ┌───────────────────────────────┐   │
│ │                               │   │
│ │     Full-Width Content        │   │
│ │                               │   │
│ └───────────────────────────────┘   │
│                           [20pt] →  │
└─────────────────────────────────────┘
```

**Pattern 2: Sectioned Content**
```
┌─────────────────────────────────────┐
│        [Section Header]              │
│ [24pt vertical spacing]              │
│        [Content Area]                │
│ [24pt vertical spacing]              │
│        [Another Section]             │
└─────────────────────────────────────┘
```

**Pattern 3: Button Groups**
```
┌──────────────────────────────┐
│ [Primary Button - 56pt tall] │
│ [8pt gap]                    │
│ [Secondary - 52pt tall]      │
│ [8pt gap]                    │
│ [Tertiary - 52pt tall]       │
└──────────────────────────────┘
```

---

## 4. Combat HUD Layout

### Core Principle: Minimize Occlusion, Maximize Accessibility

**Design Challenge**: During gameplay, players need:
1. **Critical info visible** (HP, wave count)
2. **Controls accessible** (pause, abilities)
3. **Gameplay area unobstructed** (thumbs will cover bottom third)

### Thumb Occlusion Zones

```
┌─────────────────────────────────────┐
│ ✅ VISIBLE: HP, Wave, Score          │ ← Top 20% of screen
│                                      │
│                                      │
│      ✅ VISIBLE: Gameplay            │ ← Middle 60% (main action)
│         Critical Zone                │
│                                      │
│                                      │
│ ⚠️ OCCLUDED: Controls Here           │ ← Bottom 20% (thumb rests)
│   [Joystick]         [Action Btns]  │
└─────────────────────────────────────┘
```

### Standard HUD Layout Measurements

**Top Bar (Information Display)**
- **Height**: 56-64pt
- **Position**: 60pt from top edge (safe area)
- **Elements**: HP bar, wave counter, currency, pause button
- **Background**: Semi-transparent dark overlay (rgba(0,0,0,0.3))

**Bottom Bar (Controls/Secondary Info)**
- **Height**: 40-48pt for info only, 120-160pt if controls included
- **Position**: 40pt from bottom edge (safe area)
- **Elements**: XP bar, ability cooldowns
- **Background**: Semi-transparent or none (depends on gameplay needs)

### Example HUD Layout with Measurements

```
┌─────────────────────────────────────┐ ← Device edge
│ [60pt safe area]                     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [HP: ███████░░░ 80/100]  Wave 5 │ │ ← 56pt tall top bar
│ │ [💰 1250]              [⏸ 52pt]│ │
│ └─────────────────────────────────┘ │
│                                      │
│                                      │
│          GAMEPLAY AREA               │ ← ~500-600pt on iPhone 14 Pro
│         (Minimal UI Here)            │
│                                      │
│                                      │
│ ┌─────────────────────────────────┐ │
│ │ [═══════XP Bar═══════════] 80%  │ │ ← 40pt tall bottom info
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [40pt safe area]                     │
└─────────────────────────────────────┘ ← Device edge
```

### Specific Component Measurements

| Component | Width | Height | Position | Distance from Edge |
|-----------|-------|--------|----------|-------------------|
| **HP Bar** | 140-160pt | 24pt | Top-left | 16pt from left, 16pt from top of bar |
| **Wave Counter** | 80-100pt | 28pt | Top-right | 80pt from right (leaves room for pause) |
| **Pause Button** | 52pt | 52pt | Top-right corner | 16pt from top, 16pt from right |
| **Currency Display** | 100-120pt | 24pt | Top-left or center | Below HP or separate row |
| **XP Bar** | Full width - 32pt | 8-12pt | Bottom | 8pt from bottom info area |

### HP Bar Design Specifications

**Visual Structure**:
```
┌────────────────────────────┐
│ ❤️ ████████████░░░░ 125/200│ ← Background: dark (rgba(0,0,0,0.5))
└────────────────────────────┘   Fill: gradient red
   ↑ Icon (20pt)                 Text: white, 18pt SemiBold
```

**Implementation**:
```gdscript
# res://ui/hud/hp_bar.gd
class_name HPBar
extends Control

@onready var fill_bar: ProgressBar = $ProgressBar
@onready var hp_label: Label = $HPLabel
@onready var heart_icon: TextureRect = $HeartIcon

var current_hp: int = 100
var max_hp: int = 100

func _ready():
    custom_minimum_size = Vector2(140, 24)
    _update_display()

func set_hp(new_hp: int, new_max: int = max_hp):
    current_hp = clamp(new_hp, 0, new_max)
    max_hp = new_max
    _update_display()

func _update_display():
    # Update progress bar
    fill_bar.value = (float(current_hp) / max_hp) * 100
    
    # Update label
    hp_label.text = "%d/%d" % [current_hp, max_hp]
    
    # Color based on HP percentage
    var hp_percent = float(current_hp) / max_hp
    if hp_percent < 0.25:
        fill_bar.modulate = Color(1.0, 0.2, 0.2)  # Critical red
    elif hp_percent < 0.5:
        fill_bar.modulate = Color(1.0, 0.6, 0.2)  # Warning orange
    else:
        fill_bar.modulate = Color(0.2, 1.0, 0.3)  # Healthy green
```

### Pause Button Design

**Specification**:
- **Size**: 52×52pt (exceeds minimum 44pt)
- **Icon**: Simple pause symbol (||) or hamburger menu
- **Contrast**: White icon on dark semi-transparent background
- **Hit area**: Slightly larger than visual (60×60pt touch area)

```gdscript
# res://ui/hud/pause_button.gd
class_name PauseButton
extends Button

signal pause_requested

func _ready():
    custom_minimum_size = Vector2(52, 52)
    # Extend touch area beyond visual bounds
    var touch_area = RectangleShape2D.new()
    touch_area.extents = Vector2(30, 30)  # 60×60pt touch area
    
    pressed.connect(_on_pressed)

func _on_pressed():
    # Haptic feedback (if available)
    if Input.is_joy_known(0):
        Input.start_joy_vibration(0, 0.2, 0, 0.05)  # Light tap
    
    pause_requested.emit()
```

### XP Bar Design

**Visual Structure**:
```
[═══════════════════════░░░░] 75%
 ↑ Full width minus margins    ↑ Optional percentage text
   Height: 8-12pt
   Gradient fill: blue to cyan
   Background: dark gray (rgba(50,50,50,0.8))
```

**Implementation**:
```gdscript
# res://ui/hud/xp_bar.gd
class_name XPBar
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var xp_label: Label = $XPLabel

var current_xp: int = 0
var xp_to_next_level: int = 100

func _ready():
    custom_minimum_size.y = 10
    _update_display()

func add_xp(amount: int):
    current_xp += amount
    _update_display()
    
    # Animate fill (optional)
    var tween = create_tween()
    tween.tween_property(progress_bar, "value", 
        (float(current_xp) / xp_to_next_level) * 100, 0.3)

func _update_display():
    var xp_percent = (float(current_xp) / xp_to_next_level) * 100
    progress_bar.value = xp_percent
    xp_label.text = "%d%%" % int(xp_percent)
```

### HUD Design Best Practices

**1. Contrast is King**
- Use semi-transparent dark backgrounds (rgba(0,0,0,0.4-0.6))
- White or high-contrast text
- Drop shadows for text legibility (1-2px offset, 50% opacity)

**2. Minimize Visual Noise**
- Only show critical info during gameplay
- Hide less important stats or put in pause menu
- Use icons instead of text where possible

**3. Test with Thumbs on Screen**
- Literally put your thumbs where controls would be
- Ensure critical info is still visible
- Adjust layout based on actual occlusion, not theory

**4. Consider Handedness**
- Don't put all controls on one side (right-handed bias)
- Allow players to swap joystick/button sides in settings
- Critical info (HP) should be centered or duplicated

---

## 5. Interaction Patterns & Animations

### Core Principle: Immediate Feedback

**Definition**: Every user action must receive visual/haptic feedback within 100ms.

**Why?** Human perception threshold for "instant" is ~100ms. Beyond this, actions feel laggy.

**Software Engineering Concept: Event-Driven Architecture**  
UI responds to events (touch, release) with predictable state transitions.

### Standard Animation Durations

| Interaction | Duration (ms) | Easing | Purpose |
|-------------|---------------|--------|---------|
| **Button Press** | 50-100 | ease-out | Immediate feedback |
| **Button Release** | 100-150 | ease-in | Return to normal |
| **Screen Transition** | 250-350 | ease-in-out | Smooth context change |
| **Modal Appear** | 200-300 | ease-out (slight overshoot) | Draw attention |
| **Modal Dismiss** | 150-250 | ease-in | Quick exit |
| **Success Feedback** | 300-400 | ease-out with bounce | Celebration |
| **Error Shake** | 400-500 | shake (4-6 oscillations) | Clear negative signal |
| **Loading Spinner** | Continuous | linear | Progress indication |
| **Tooltip/Popup** | 150-200 | ease-out | Subtle appearance |

### Button Interaction Specifications

**Press Animation**:
- **Scale**: 0.95× (5% shrink)
- **Duration**: 50ms
- **Easing**: Ease-out quad
- **Optional**: Slight brightness increase (+10%)

**Release Animation**:
- **Scale**: Return to 1.0×
- **Duration**: 100ms
- **Easing**: Ease-in-out
- **Optional**: Subtle bounce (1.02× overshoot)

```gdscript
# res://ui/components/animated_button.gd
class_name AnimatedButton
extends Button

const PRESS_SCALE = 0.95
const RELEASE_DURATION = 0.1
const PRESS_DURATION = 0.05

var original_scale: Vector2
var is_pressed_visual: bool = false

func _ready():
    original_scale = scale
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

func _on_button_down():
    if is_pressed_visual:
        return
    
    is_pressed_visual = true
    
    # Haptic feedback
    _trigger_haptic_light()
    
    # Scale animation
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", 
        original_scale * PRESS_SCALE, PRESS_DURATION)

func _on_button_up():
    is_pressed_visual = false
    
    # Return animation with slight bounce
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "scale", 
        original_scale, RELEASE_DURATION)

func _trigger_haptic_light():
    # iOS/Android light impact
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(30)  # 30ms light tap
```

### Screen Transition Patterns

**Pattern 1: Slide Transition** (Most Common)
- **Direction**: Right-to-left for forward navigation, left-to-right for back
- **Duration**: 300ms
- **Easing**: Ease-in-out cubic
- **Overlap**: Previous screen slides out as new slides in

```gdscript
# res://ui/screen_manager.gd
class_name ScreenManager
extends Control

const TRANSITION_DURATION = 0.3

func transition_to_screen(new_screen: Control, direction: Vector2 = Vector2.LEFT):
    var current_screen = get_child(0) if get_child_count() > 0 else null
    
    if current_screen:
        # Slide out current screen
        var tween_out = create_tween()
        tween_out.set_parallel(true)
        tween_out.tween_property(current_screen, "position:x", 
            -size.x if direction == Vector2.LEFT else size.x, 
            TRANSITION_DURATION)
        tween_out.tween_property(current_screen, "modulate:a", 
            0.0, TRANSITION_DURATION)
    
    # Slide in new screen
    add_child(new_screen)
    new_screen.position.x = size.x if direction == Vector2.LEFT else -size.x
    
    var tween_in = create_tween()
    tween_in.set_ease(Tween.EASE_IN_OUT)
    tween_in.set_trans(Tween.TRANS_CUBIC)
    tween_in.tween_property(new_screen, "position:x", 0, TRANSITION_DURATION)
    
    # Clean up old screen after transition
    if current_screen:
        await tween_in.finished
        current_screen.queue_free()
```

**Pattern 2: Fade Transition** (For Slow Pace)
- **Duration**: 200-300ms
- **Use case**: Settings screens, pause menu
- **Implementation**: Simple alpha fade

**Pattern 3: Scale + Fade** (For Emphasis)
- **Scale**: 0.9× to 1.0×
- **Duration**: 250ms
- **Use case**: Level up, achievement popups

### Modal Dialog Patterns

**Appearance**:
- **Background Dim**: Fade in dark overlay (rgba(0,0,0,0.7), 200ms)
- **Modal Animation**: Slide up from bottom OR scale from center
- **Overshoot**: Slight bounce effect (scale 1.05× then settle to 1.0×)

**Dismissal**:
- **Animation**: Reverse of appearance
- **Duration**: Slightly faster (150ms vs 250ms)
- **Background**: Fade out simultaneously

```gdscript
# res://ui/components/modal_dialog.gd
class_name ModalDialog
extends Control

@onready var background_dim: ColorRect = $BackgroundDim
@onready var dialog_panel: Panel = $DialogPanel

const APPEAR_DURATION = 0.25
const DISMISS_DURATION = 0.15

func show_modal():
    visible = true
    
    # Prepare initial state
    background_dim.modulate.a = 0.0
    dialog_panel.scale = Vector2(0.8, 0.8)
    dialog_panel.modulate.a = 0.0
    
    # Animate background
    var tween_bg = create_tween()
    tween_bg.tween_property(background_dim, "modulate:a", 
        1.0, APPEAR_DURATION)
    
    # Animate dialog with overshoot
    var tween_dialog = create_tween()
    tween_dialog.set_parallel(true)
    tween_dialog.set_ease(Tween.EASE_OUT)
    tween_dialog.set_trans(Tween.TRANS_BACK)  # Creates overshoot
    tween_dialog.tween_property(dialog_panel, "scale", 
        Vector2.ONE, APPEAR_DURATION)
    tween_dialog.tween_property(dialog_panel, "modulate:a", 
        1.0, APPEAR_DURATION)

func dismiss_modal():
    var tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_QUAD)
    
    tween.tween_property(background_dim, "modulate:a", 0.0, DISMISS_DURATION)
    tween.tween_property(dialog_panel, "scale", 
        Vector2(0.8, 0.8), DISMISS_DURATION)
    tween.tween_property(dialog_panel, "modulate:a", 0.0, DISMISS_DURATION)
    
    await tween.finished
    queue_free()
```

### Success/Error Feedback

**Success Animation**:
- **Visual**: Green checkmark scale in (0.5× to 1.2× to 1.0×)
- **Color Flash**: Green overlay (fade in/out, 300ms)
- **Haptic**: Success notification pattern (if available)
- **Optional**: Confetti particle effect

**Error Animation**:
- **Visual**: Shake horizontally (±10pt, 4 oscillations, 400ms)
- **Color Flash**: Red overlay (fade in/out, 200ms)
- **Haptic**: Error notification pattern (double buzz)
- **Text**: Red error message with fade in

```gdscript
# res://ui/utils/feedback_animator.gd
class_name FeedbackAnimator
extends RefCounted

static func shake_node(node: Control, intensity: float = 10.0, 
                       duration: float = 0.4):
    var original_position = node.position
    var tween = node.create_tween()
    
    # Create shake effect with 6 keyframes
    var shake_count = 6
    for i in range(shake_count):
        var offset_x = intensity * pow(-1, i) * (1.0 - float(i) / shake_count)
        tween.tween_property(node, "position:x", 
            original_position.x + offset_x, duration / shake_count)
    
    # Return to original position
    tween.tween_property(node, "position", original_position, 0.05)

static func success_flash(node: Control):
    # Create temporary green overlay
    var flash = ColorRect.new()
    flash.color = Color(0.2, 1.0, 0.3, 0.3)
    flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    node.add_child(flash)
    
    # Fade in and out
    var tween = node.create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, 0.3)
    await tween.finished
    flash.queue_free()

static func error_flash(node: Control):
    # Red flash + shake combo
    var flash = ColorRect.new()
    flash.color = Color(1.0, 0.2, 0.2, 0.4)
    flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    node.add_child(flash)
    
    # Flash and shake simultaneously
    var tween = node.create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, 0.25)
    
    shake_node(node)
    
    await tween.finished
    flash.queue_free()
```

### Loading States

**Spinner Design**:
- **Size**: 40×40pt standard, 24×24pt for inline
- **Animation**: Continuous rotation, 1-2s per revolution
- **Color**: Brand primary color or white
- **Position**: Centered on screen OR inline with content

**Progress Bar Design**:
- **Height**: 4-8pt
- **Width**: 200-300pt or percentage of container
- **Animation**: Smooth fill, determinate or indeterminate
- **Color**: Gradient (blue to cyan) or solid brand color

**Skeleton Screens** (Advanced):
- Use for content that's loading (better than blank screen)
- Animated shimmer effect across placeholder boxes
- Matches approximate layout of real content

```gdscript
# res://ui/components/loading_spinner.gd
class_name LoadingSpinner
extends Control

@onready var spinner_icon: TextureRect = $SpinnerIcon

const ROTATION_SPEED = 2.0  # Rotations per second

func _ready():
    custom_minimum_size = Vector2(40, 40)

func _process(delta):
    if visible:
        spinner_icon.rotation += TAU * ROTATION_SPEED * delta
```

### Haptic Feedback Integration

**iOS Haptic Types** (via CoreHaptics):
- **Light Impact**: Button presses, selection changes
- **Medium Impact**: Toggle switches, significant actions
- **Heavy Impact**: Confirmations, major state changes
- **Success Notification**: Level up, achievement unlocked
- **Warning Notification**: Low health, error state
- **Error Notification**: Failed action, invalid input

**Godot Haptic Implementation**:
```gdscript
# res://ui/utils/haptic_feedback.gd
class_name HapticFeedback
extends RefCounted

enum HapticType {
    LIGHT,
    MEDIUM,
    HEAVY,
    SUCCESS,
    WARNING,
    ERROR
}

static func trigger(type: HapticType):
    if not OS.has_feature("mobile"):
        return  # No haptic on desktop
    
    match type:
        HapticType.LIGHT:
            Input.vibrate_handheld(30)  # 30ms light
        HapticType.MEDIUM:
            Input.vibrate_handheld(50)  # 50ms medium
        HapticType.HEAVY:
            Input.vibrate_handheld(80)  # 80ms heavy
        HapticType.SUCCESS:
            # Double tap pattern
            Input.vibrate_handheld(30)
            await get_tree().create_timer(0.1).timeout
            Input.vibrate_handheld(30)
        HapticType.WARNING:
            Input.vibrate_handheld(60)
        HapticType.ERROR:
            # Harsh buzz
            Input.vibrate_handheld(100)
```

**When to Use Haptics**:
- ✅ Button presses (light)
- ✅ Important confirmations (medium/heavy)
- ✅ Success moments (success pattern)
- ✅ Errors (error pattern)
- ❌ NOT on every UI interaction (too much is annoying)
- ❌ NOT during continuous actions (scrolling, dragging)

---

## 6. Color Hierarchy & Accessibility

### Core Principle: WCAG 2.1 Compliance

**Definition**: Web Content Accessibility Guidelines ensure text is readable for users with visual impairments.

**Contrast Ratios**:
- **Level AA** (minimum): 4.5:1 for normal text, 3:1 for large text (18pt+)
- **Level AAA** (enhanced): 7:1 for normal text, 4.5:1 for large text

**Why This Matters**: ~8% of males and ~0.5% of females have color vision deficiency. High contrast benefits everyone, especially in bright sunlight (mobile context).

### Standard Color Palette (Example)

**Note**: These are example values. Choose your own brand colors, but maintain the contrast ratios.

| Color Purpose | Hex Code | RGB | Use Case | Contrast Ratio |
|---------------|----------|-----|----------|----------------|
| **Primary Action** | #4A90E2 | (74, 144, 226) | Play, confirm, primary buttons | 3.5:1 on white, 4.8:1 on dark |
| **Primary Dark** | #2E5C8A | (46, 92, 138) | Pressed state | Better contrast: 6.2:1 |
| **Secondary Action** | #7B7B7B | (123, 123, 123) | Back, cancel, less important | 4.5:1 on white |
| **Danger/Destructive** | #E74C3C | (231, 76, 60) | Delete, quit, warnings | 4.1:1 on white |
| **Success/Positive** | #2ECC71 | (46, 204, 113) | XP gain, level up, health | 3.1:1 (use for large text) |
| **Warning/Caution** | #F39C12 | (243, 156, 18) | Low health, alerts | 2.7:1 (use sparingly) |
| **Background Dark** | #1C1C1E | (28, 28, 30) | Main background (iOS dark mode style) | - |
| **Background Light** | #F5F5F7 | (245, 245, 247) | Card backgrounds, panels | - |
| **Text Primary (Dark BG)** | #FFFFFF | (255, 255, 255) | Main text on dark | 15.3:1 ✅ AAA |
| **Text Secondary (Dark BG)** | #B4B4B4 | (180, 180, 180) | Less important text | 7.1:1 ✅ AAA |
| **Text Primary (Light BG)** | #1C1C1E | (28, 28, 30) | Main text on light | 14.8:1 ✅ AAA |
| **Disabled State** | #4D4D4D | (77, 77, 77) | Locked items, unavailable | 2.5:1 (intentionally low) |

### Checking Contrast Ratios

**Tool**: WebAIM Contrast Checker (https://webaim.org/resources/contrastchecker/)

**In Godot**:
```gdscript
# res://ui/theme/color_palette.gd
class_name ColorPalette
extends RefCounted

# Primary actions
const PRIMARY: Color = Color(0.29, 0.56, 0.89)  # #4A90E2
const PRIMARY_DARK: Color = Color(0.18, 0.36, 0.54)  # #2E5C8A
const PRIMARY_HOVER: Color = Color(0.33, 0.62, 0.95)  # Lighter

# Secondary actions
const SECONDARY: Color = Color(0.48, 0.48, 0.48)  # #7B7B7B
const SECONDARY_DARK: Color = Color(0.32, 0.32, 0.32)

# Semantic colors
const DANGER: Color = Color(0.91, 0.30, 0.24)  # #E74C3C
const SUCCESS: Color = Color(0.18, 0.80, 0.44)  # #2ECC71
const WARNING: Color = Color(0.95, 0.61, 0.07)  # #F39C12

# Backgrounds
const BG_DARK: Color = Color(0.11, 0.11, 0.12)  # #1C1C1E
const BG_LIGHT: Color = Color(0.96, 0.96, 0.97)  # #F5F5F7
const BG_OVERLAY: Color = Color(0.0, 0.0, 0.0, 0.7)  # Semi-transparent

# Text
const TEXT_PRIMARY_DARK: Color = Color.WHITE
const TEXT_SECONDARY_DARK: Color = Color(0.71, 0.71, 0.71)  # #B4B4B4
const TEXT_PRIMARY_LIGHT: Color = Color(0.11, 0.11, 0.12)
const TEXT_DISABLED: Color = Color(0.30, 0.30, 0.30)

# Helper function to calculate contrast ratio
static func get_contrast_ratio(color1: Color, color2: Color) -> float:
    var l1 = _get_relative_luminance(color1)
    var l2 = _get_relative_luminance(color2)
    
    var lighter = max(l1, l2)
    var darker = min(l1, l2)
    
    return (lighter + 0.05) / (darker + 0.05)

static func _get_relative_luminance(color: Color) -> float:
    # sRGB to linear RGB conversion
    var r = _to_linear(color.r)
    var g = _to_linear(color.g)
    var b = _to_linear(color.b)
    
    # Calculate relative luminance
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

static func _to_linear(channel: float) -> float:
    if channel <= 0.03928:
        return channel / 12.92
    else:
        return pow((channel + 0.055) / 1.055, 2.4)
```

### Button State Colors

**State Progression**:
```
Normal → Hover → Pressed → Disabled
```

**Example Button Color States**:
```gdscript
# Primary button states
Normal:   #4A90E2 (Primary blue)
Hover:    #5BA0F2 (+10% brightness)
Pressed:  #2E5C8A (-30% brightness)
Disabled: #4A90E2 at 30% opacity
```

**Implementation**:
```gdscript
# res://ui/components/themed_button.gd
class_name ThemedButton
extends Button

enum ButtonVariant {
    PRIMARY,
    SECONDARY,
    DANGER
}

@export var variant: ButtonVariant = ButtonVariant.PRIMARY

func _ready():
    _apply_theme()
    mouse_entered.connect(_on_hover_start)
    mouse_exited.connect(_on_hover_end)

func _apply_theme():
    var normal_color: Color
    var hover_color: Color
    var pressed_color: Color
    
    match variant:
        ButtonVariant.PRIMARY:
            normal_color = ColorPalette.PRIMARY
            hover_color = ColorPalette.PRIMARY_HOVER
            pressed_color = ColorPalette.PRIMARY_DARK
        ButtonVariant.SECONDARY:
            normal_color = ColorPalette.SECONDARY
            hover_color = normal_color.lightened(0.1)
            pressed_color = ColorPalette.SECONDARY_DARK
        ButtonVariant.DANGER:
            normal_color = ColorPalette.DANGER
            hover_color = normal_color.lightened(0.1)
            pressed_color = normal_color.darkened(0.2)
    
    # Create StyleBoxFlat for each state
    var style_normal = StyleBoxFlat.new()
    style_normal.bg_color = normal_color
    style_normal.corner_radius_top_left = 8
    style_normal.corner_radius_top_right = 8
    style_normal.corner_radius_bottom_left = 8
    style_normal.corner_radius_bottom_right = 8
    
    var style_hover = style_normal.duplicate()
    style_hover.bg_color = hover_color
    
    var style_pressed = style_normal.duplicate()
    style_pressed.bg_color = pressed_color
    
    var style_disabled = style_normal.duplicate()
    style_disabled.bg_color = normal_color
    style_disabled.modulate = Color(1, 1, 1, 0.3)
    
    add_theme_stylebox_override("normal", style_normal)
    add_theme_stylebox_override("hover", style_hover)
    add_theme_stylebox_override("pressed", style_pressed)
    add_theme_stylebox_override("disabled", style_disabled)
```

### Color Blindness Considerations

**Don't Rely on Color Alone**:
- Use **icons + color** (not just color)
- Use **shape + color** (square = safe, triangle = warning)
- Use **text labels** where critical

**Common Color Blindness Types**:
- **Protanopia** (red-blind): ~1% of males
- **Deuteranopia** (green-blind): ~1% of males
- **Tritanopia** (blue-blind): Very rare

**Test Your Palette**:
- Use color blindness simulators (online tools)
- Ensure red/green are not the only differentiators
- Use blue/orange instead of red/green for primary contrasts

### Dark Mode Considerations

**Design Principle**: Mobile games typically default to dark themes (better for battery, less eye strain).

**Dark Mode Color Adjustments**:
- Backgrounds: True black (#000000) causes OLED smearing; use very dark gray (#1C1C1E)
- Text: Pure white is too harsh; use off-white (#FAFAFA or #F5F5F5)
- Shadows: Use subtle glows instead of drop shadows
- Color saturation: Slightly desaturate colors in dark mode (looks better)

---

## 7. Screen-Specific Patterns

### Main Menu

**Layout Structure**:
```
┌─────────────────────────────────────┐
│                                      │
│         [Game Logo/Title]            │ ← 80-120pt tall, centered
│                                      │
│                                      │
│     [Primary Action: PLAY]           │ ← 56-64pt tall, 280-320pt wide
│         [32pt gap]                   │
│     [Secondary: Continue]            │ ← 52pt tall, 240pt wide
│         [8pt gap]                    │
│     [Tertiary: Settings]             │ ← 52pt tall, 240pt wide
│         [8pt gap]                    │
│     [Tertiary: About]                │ ← 52pt tall, 240pt wide
│                                      │
│         [Version Info]               │ ← 13pt caption, bottom margin
└─────────────────────────────────────┘
```

**Measurements**:
- **Title/Logo**: 80-120pt vertical space, centered horizontally
- **Button Stack**: Vertically centered in remaining space
- **Primary Button**: 56-64pt tall, 280-320pt wide (or 80% screen width)
- **Secondary Buttons**: 52pt tall, slightly narrower (240-280pt)
- **Vertical Spacing**: 32pt after primary, 8pt between secondaries
- **Side Margins**: 20pt minimum, 32pt preferred
- **Bottom Padding**: 48pt from safe area

**Background Treatment**:
- Static image (parallax optional)
- Subtle animation (particles, gentle movement)
- Blur/dim for buttons area (readability)

**Implementation**:
```gdscript
# res://ui/screens/main_menu.gd
class_name MainMenu
extends Control

@onready var button_container: VBoxContainer = $SafeAreaContainer/CenterContainer/ButtonContainer
@onready var play_button: Button = $SafeAreaContainer/CenterContainer/ButtonContainer/PlayButton
@onready var continue_button: Button = $SafeAreaContainer/CenterContainer/ButtonContainer/ContinueButton

func _ready():
    # Apply spacing to button container
    button_container.add_theme_constant_override("separation", 
        UIConstants.SPACING_XS)  # 8pt between most buttons
    
    # Special spacing after primary button
    var spacer = Control.new()
    spacer.custom_minimum_size.y = UIConstants.SPACING_XL  # 32pt
    button_container.add_child(spacer)
    button_container.move_child(spacer, 1)  # After play button
    
    # Connect button signals
    play_button.pressed.connect(_on_play_pressed)
    continue_button.pressed.connect(_on_continue_pressed)

func _on_play_pressed():
    HapticFeedback.trigger(HapticFeedback.HapticType.MEDIUM)
    # Transition to character selection
    get_tree().change_scene_to_file("res://ui/screens/character_selection.tscn")
```

### Character Selection

**Layout Pattern**: Grid of Character Cards

```
┌─────────────────────────────────────┐
│ ← [Back]        Characters   [Info] │ ← Top bar: 56pt
├─────────────────────────────────────┤
│                                      │
│  ┌───────┐  ┌───────┐  ┌───────┐   │
│  │ Char1 │  │ Char2 │  │ Char3 │   │ ← Cards: 120-140pt wide
│  │ [Icon]│  │ [Icon]│  │ [Icon]│   │         160-180pt tall
│  │ Name  │  │ Name  │  │ Name  │   │
│  └───────┘  └───────┘  └───────┘   │
│      [12pt vertical gap]            │
│  ┌───────┐  ┌───────┐  ┌───────┐   │
│  │ Char4 │  │ Char5 │  │🔒Char6│   │ ← Locked: dimmed + icon
│  │ [Icon]│  │ [Icon]│  │Locked │   │
│  │ Name  │  │ Name  │  │       │   │
│  └───────┘  └───────┘  └───────┘   │
│                                      │
│         [Select Button]              │ ← Bottom: 56pt tall
└─────────────────────────────────────┘
```

**Grid Specifications**:
- **Columns**: 2-3 (responsive based on screen width)
- **Card Size**: 120-140pt wide × 160-180pt tall
- **Card Spacing**: 12pt horizontal and vertical gaps
- **Card Corner Radius**: 12pt (modern, friendly feel)
- **Selected State**: 2-3pt border, primary color
- **Locked State**: 30% opacity, lock icon overlay

**Implementation**:
```gdscript
# res://ui/screens/character_selection.gd
class_name CharacterSelection
extends Control

@onready var character_grid: GridContainer = $SafeAreaContainer/ScrollContainer/CharacterGrid
@onready var select_button: Button = $SafeAreaContainer/BottomBar/SelectButton

var selected_character: CharacterCard = null

func _ready():
    # Configure grid
    character_grid.columns = 3  # Adjust based on screen width
    character_grid.add_theme_constant_override("h_separation", 12)
    character_grid.add_theme_constant_override("v_separation", 12)
    
    # Populate characters
    _populate_character_grid()
    
    select_button.disabled = true
    select_button.pressed.connect(_on_select_pressed)

func _populate_character_grid():
    for character_data in GameData.available_characters:
        var card = preload("res://ui/components/character_card.tscn").instantiate()
        card.setup(character_data)
        card.selected.connect(_on_character_selected)
        character_grid.add_child(card)

func _on_character_selected(card: CharacterCard):
    # Deselect previous
    if selected_character:
        selected_character.set_selected(false)
    
    # Select new
    selected_character = card
    selected_character.set_selected(true)
    select_button.disabled = false
    
    HapticFeedback.trigger(HapticFeedback.HapticType.LIGHT)
```

### Shop/Upgrade Screen (Between Waves)

**Layout Pattern**: Horizontal Scrolling Cards

```
┌─────────────────────────────────────┐
│ [Currency: 💰 1250]      [Time: 30s]│ ← Top bar
├─────────────────────────────────────┤
│                                      │
│  ← ┌──────┐ ┌──────┐ ┌──────┐ →    │
│    │ Item │ │ Item │ │ Item │       │ ← Scrolling cards
│    │[Icon]│ │[Icon]│ │[Icon]│       │   120-140pt wide
│    │ Name │ │ Name │ │ Name │       │   180-200pt tall
│    │ $100 │ │ $150 │ │SOLD  │       │
│    └──────┘ └──────┘ └──────┘       │
│                                      │
│  [Item Description Panel]            │ ← Selected item details
│                                      │
│  [Buy Button - 56pt tall]            │ ← Full-width primary button
└─────────────────────────────────────┘
```

**Specifications**:
- **Currency Display**: Top-left, 22-24pt, SemiBold
- **Timer**: Top-right, 22-24pt, warning color when <10s
- **Item Cards**: 120-140pt wide × 180-200pt tall
- **Card Spacing**: 16pt between cards
- **Scroll Indicator**: Subtle fade at edges
- **Buy Button**: 56pt tall, full width, primary color

### Pause Menu

**Layout Pattern**: Centered Modal

```
┌─────────────────────────────────────┐
│                                      │
│         ███████████████████          │ ← 70% dim overlay
│         █                 █          │
│         █   ⏸️ PAUSED      █          │ ← 36pt title
│         █                 █          │
│         █  [Resume - 56pt]█          │ ← Primary action
│         █     [16pt gap]  █          │
│         █  [Restart-52pt] █          │ ← Secondary
│         █  [Settings-52pt]█          │
│         █  [Quit - 52pt]  █          │ ← Danger color
│         █                 █          │
│         ███████████████████          │
│                                      │
└─────────────────────────────────────┘
```

**Specifications**:
- **Overlay**: rgba(0, 0, 0, 0.7) full screen
- **Modal**: 320pt wide, auto height, centered
- **Modal Padding**: 24pt all sides
- **Title**: 36pt, centered
- **Resume Button**: 56pt tall, full modal width, primary color
- **Other Buttons**: 52pt tall, full width
- **Vertical Spacing**: 16pt between buttons
- **Corner Radius**: 16pt for modern feel

### Death/Game Over Screen

**Layout Pattern**: Stats Display + Actions

```
┌─────────────────────────────────────┐
│                                      │
│           💀 GAME OVER                │ ← 48pt display text
│                                      │
│         ┌─────────────────┐          │
│         │ Wave Reached: 15│          │ ← Stats panel
│         │ Enemies: 342    │          │   180-200pt wide
│         │ Time: 12:34     │          │   20pt body text
│         │ Gold: 2,450     │          │
│         └─────────────────┘          │
│                                      │
│       [Retry - 56pt tall]            │ ← Primary button
│            [8pt gap]                 │
│       [Main Menu - 52pt]             │ ← Secondary
│                                      │
└─────────────────────────────────────┘
```

**Specifications**:
- **Title**: 48pt, centered, display weight
- **Stats Panel**: Card with 16pt padding, centered
- **Stat Rows**: 20pt body text, 8pt vertical spacing
- **Retry Button**: 56-64pt tall, primary color (encouraging)
- **Main Menu**: 52pt tall, secondary color

---

## 8. Polish & Feedback Details

### Haptic Feedback Strategy

**When to Use**:
- ✅ Button press (light)
- ✅ Selection change (light)
- ✅ Level up / achievement (success pattern)
- ✅ Taking damage (medium)
- ✅ Death (heavy)
- ✅ Error state (error pattern)

**When NOT to Use**:
- ❌ Scrolling (too frequent)
- ❌ Every UI update (annoying)
- ❌ Background events (confusing)

**Implementation Reference**: See Section 5 (Interaction Patterns) for code examples.

### Sound Design

**UI Sound Categories**:
1. **Button Sounds** (50-100ms)
   - Press: Short "click" or "tap"
   - Release: Optional subtle "release" sound
   - Volume: -12dB to -8dB

2. **Transition Sounds** (200-300ms)
   - Screen change: "Whoosh" or "swoosh"
   - Modal appear: "Pop" or "bloom"
   - Volume: -15dB to -10dB

3. **Feedback Sounds** (100-500ms)
   - Success: "Chime", "ding", or positive tone
   - Error: "Buzz", "thud", or negative tone
   - Warning: "Alert" or pulsing tone
   - Volume: -10dB to -6dB

**Audio Implementation**:
```gdscript
# res://audio/ui_audio_manager.gd
class_name UIAudioManager
extends Node

var button_click: AudioStream = preload("res://audio/ui/button_click.ogg")
var button_release: AudioStream = preload("res://audio/ui/button_release.ogg")
var success_sound: AudioStream = preload("res://audio/ui/success.ogg")
var error_sound: AudioStream = preload("res://audio/ui/error.ogg")

@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func play_button_click():
    _play_sound(button_click, -10.0)

func play_success():
    _play_sound(success_sound, -8.0)

func play_error():
    _play_sound(error_sound, -8.0)

func _play_sound(stream: AudioStream, volume_db: float):
    sfx_player.stream = stream
    sfx_player.volume_db = volume_db
    sfx_player.play()
```

**Sound Design Principles**:
- **Short & Punchy**: UI sounds should be <200ms
- **Non-Intrusive**: Lower volume than gameplay sounds
- **Consistent**: Same sound for same action throughout
- **Optional**: Provide "Mute UI Sounds" setting

### Loading States

**Three Loading Patterns**:

**1. Full-Screen Loader** (Initial Load)
```
┌─────────────────────────────────────┐
│                                      │
│                                      │
│          [Spinner 40×40pt]           │ ← Centered
│          Loading...                  │ ← 18pt text
│                                      │
│                                      │
└─────────────────────────────────────┘
```

**2. Inline Loader** (Content Update)
```
[Spinner 24×24] Loading characters...
```

**3. Progress Bar** (Deterministic Progress)
```
Loading Assets...
[███████████████░░░░░░░░] 75%
```

**Implementation**:
```gdscript
# res://ui/components/loading_indicator.gd
class_name LoadingIndicator
extends Control

@onready var spinner: TextureRect = $Spinner
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var status_label: Label = $StatusLabel

enum LoadingType {
    SPINNER,
    PROGRESS_BAR
}

@export var loading_type: LoadingType = LoadingType.SPINNER

func show_loading(message: String = "Loading..."):
    status_label.text = message
    visible = true
    
    if loading_type == LoadingType.SPINNER:
        spinner.visible = true
        progress_bar.visible = false
    else:
        spinner.visible = false
        progress_bar.visible = true

func update_progress(percent: float):
    if loading_type == LoadingType.PROGRESS_BAR:
        progress_bar.value = percent

func hide_loading():
    visible = false
```

### Error Handling

**Error Display Patterns**:

**1. Toast Notification** (Non-Critical)
```
┌─────────────────────────────────┐
│ ⚠️ Connection lost. Retrying... │ ← Slides up from bottom
└─────────────────────────────────┘   Auto-dismiss after 3s
```

**2. Modal Dialog** (Critical)
```
┌─────────────────────────────────────┐
│         ⚠️ ERROR                     │
│                                      │
│  Failed to save game data.           │
│  Please check your connection.       │
│                                      │
│         [Retry] [Cancel]             │
└─────────────────────────────────────┘
```

**3. Inline Error** (Form Validation)
```
[Username Input]
❌ Username must be 3-20 characters
```

**Implementation**:
```gdscript
# res://ui/utils/error_handler.gd
class_name ErrorHandler
extends Node

signal error_occurred(message: String, severity: ErrorSeverity)

enum ErrorSeverity {
    INFO,     # Toast, auto-dismiss
    WARNING,  # Toast, manual dismiss
    ERROR,    # Modal, requires action
    CRITICAL  # Modal, blocks all interaction
}

func show_error(message: String, severity: ErrorSeverity = ErrorSeverity.ERROR):
    match severity:
        ErrorSeverity.INFO, ErrorSeverity.WARNING:
            _show_toast(message, severity)
        ErrorSeverity.ERROR, ErrorSeverity.CRITICAL:
            _show_modal(message, severity)
    
    HapticFeedback.trigger(HapticFeedback.HapticType.ERROR)

func _show_toast(message: String, severity: ErrorSeverity):
    var toast = preload("res://ui/components/toast_notification.tscn").instantiate()
    get_tree().root.add_child(toast)
    toast.show_message(message, severity)

func _show_modal(message: String, severity: ErrorSeverity):
    var modal = preload("res://ui/components/error_modal.tscn").instantiate()
    get_tree().root.add_child(modal)
    modal.show_error(message, severity)
```

### Empty States

**Purpose**: Show user guidance when there's no content.

**Example** (No Characters Unlocked):
```
┌─────────────────────────────────────┐
│                                      │
│          📦                          │ ← Large icon (64pt)
│                                      │
│    No Characters Unlocked            │ ← 24pt title
│                                      │
│  Complete tutorial to unlock your    │ ← 17pt body
│       first character!               │
│                                      │
│    [Start Tutorial]                  │ ← 56pt CTA button
│                                      │
└─────────────────────────────────────┘
```

**Empty State Components**:
- **Icon**: 64×64pt, centered, subtle color
- **Title**: 24pt, centered
- **Description**: 17pt body, 2-3 lines max, centered
- **CTA Button**: Primary action, 56pt tall
- **Spacing**: 24pt between elements

---

## Godot 4.5.1 Implementation Guide

### Project Structure

```
res://
├── ui/
│   ├── components/          # Reusable UI components
│   │   ├── adaptive_button.gd
│   │   ├── styled_label.gd
│   │   ├── modal_dialog.gd
│   │   ├── character_card.gd
│   │   └── loading_indicator.gd
│   ├── screens/             # Full screen UIs
│   │   ├── main_menu.tscn
│   │   ├── character_selection.tscn
│   │   ├── shop_screen.tscn
│   │   └── pause_menu.tscn
│   ├── hud/                 # In-game HUD elements
│   │   ├── hp_bar.gd
│   │   ├── xp_bar.gd
│   │   ├── pause_button.gd
│   │   └── combat_hud.tscn
│   ├── layout/              # Layout containers
│   │   ├── safe_area_container.gd
│   │   └── responsive_grid.gd
│   ├── theme/               # Theme and styling
│   │   ├── ui_constants.gd
│   │   ├── typography_theme.gd
│   │   ├── color_palette.gd
│   │   └── game_theme.tres
│   └── utils/               # Utility scripts
│       ├── haptic_feedback.gd
│       ├── feedback_animator.gd
│       └── error_handler.gd
├── fonts/                   # Font resources
│   ├── main_font_regular.ttf
│   ├── main_font_bold.ttf
│   └── main_font_medium.ttf
└── audio/
    └── ui/                  # UI sound effects
        ├── button_click.ogg
        ├── success.ogg
        └── error.ogg
```

### Setting Up UI Constants (Foundation)

**Step 1**: Create `res://ui/theme/ui_constants.gd`

This file contains all your magic numbers in one place (following the **Single Source of Truth** principle).

```gdscript
# res://ui/theme/ui_constants.gd
class_name UIConstants
extends RefCounted

# ==== TOUCH TARGETS ====
const TOUCH_TARGET_MIN: int = 44
const TOUCH_TARGET_STANDARD: int = 56
const TOUCH_TARGET_LARGE: int = 64
const TOUCH_TARGET_COMBAT: int = 72

# ==== SPACING (8pt Grid System) ====
const SPACING_XXS: int = 4
const SPACING_XS: int = 8
const SPACING_SM: int = 12
const SPACING_MD: int = 16
const SPACING_LG: int = 24
const SPACING_XL: int = 32
const SPACING_XXL: int = 48
const SPACING_XXXL: int = 64

# ==== SAFE AREAS ====
const SAFE_AREA_TOP: int = 60
const SAFE_AREA_BOTTOM: int = 40
const SAFE_AREA_SIDES: int = 20
const SAFE_AREA_SIDES_LANDSCAPE: int = 44

# ==== CORNER RADIUS ====
const CORNER_RADIUS_SM: int = 4
const CORNER_RADIUS_MD: int = 8
const CORNER_RADIUS_LG: int = 12
const CORNER_RADIUS_XL: int = 16

# ==== ANIMATION DURATIONS (seconds) ====
const ANIM_INSTANT: float = 0.05
const ANIM_FAST: float = 0.1
const ANIM_NORMAL: float = 0.2
const ANIM_SLOW: float = 0.3
const ANIM_VERY_SLOW: float = 0.4

# Helper functions
static func ensure_minimum_touch_target(size: Vector2) -> Vector2:
    return Vector2(
        max(size.x, TOUCH_TARGET_MIN),
        max(size.y, TOUCH_TARGET_MIN)
    )
```

**Why This Matters**: 
- **Maintainability**: Change spacing once, updates everywhere
- **Consistency**: No more guessing "should this be 16 or 20?"
- **Refactoring Safety**: Easy to find all uses of a constant

### Creating a Master Theme Resource

**Step 2**: Create your game's master theme

In Godot editor: Create New Resource → Theme → Save as `res://ui/theme/game_theme.tres`

Then configure it programmatically:

```gdscript
# res://ui/theme/theme_builder.gd
class_name ThemeBuilder
extends RefCounted

static func build_game_theme() -> Theme:
    var theme = Theme.new()
    
    # Load fonts
    var font_regular = load("res://fonts/main_font_regular.ttf")
    var font_bold = load("res://fonts/main_font_bold.ttf")
    
    # === LABELS ===
    _setup_label_styles(theme, font_regular, font_bold)
    
    # === BUTTONS ===
    _setup_button_styles(theme, font_regular)
    
    # === PANELS ===
    _setup_panel_styles(theme)
    
    return theme

static func _setup_label_styles(theme: Theme, font_regular: Font, font_bold: Font):
    # Default label
    theme.set_font("font", "Label", font_regular)
    theme.set_font_size("font_size", "Label", 17)
    theme.set_color("font_color", "Label", Color.WHITE)
    
    # Title Large
    theme.set_font("font", "TitleLarge", font_bold)
    theme.set_font_size("font_size", "TitleLarge", 30)
    
    # Caption
    theme.set_font("font", "Caption", font_regular)
    theme.set_font_size("font_size", "Caption", 13)
    theme.set_color("font_color", "Caption", Color(0.7, 0.7, 0.7))

static func _setup_button_styles(theme: Theme, font: Font):
    # Create default button style
    var style_normal = StyleBoxFlat.new()
    style_normal.bg_color = ColorPalette.PRIMARY
    style_normal.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
    style_normal.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
    style_normal.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
    style_normal.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD
    style_normal.content_margin_left = UIConstants.SPACING_MD
    style_normal.content_margin_right = UIConstants.SPACING_MD
    style_normal.content_margin_top = UIConstants.SPACING_SM
    style_normal.content_margin_bottom = UIConstants.SPACING_SM
    
    var style_hover = style_normal.duplicate()
    style_hover.bg_color = ColorPalette.PRIMARY.lightened(0.1)
    
    var style_pressed = style_normal.duplicate()
    style_pressed.bg_color = ColorPalette.PRIMARY_DARK
    
    theme.set_stylebox("normal", "Button", style_normal)
    theme.set_stylebox("hover", "Button", style_hover)
    theme.set_stylebox("pressed", "Button", style_pressed)
    
    theme.set_font("font", "Button", font)
    theme.set_font_size("font_size", "Button", 17)
    theme.set_color("font_color", "Button", Color.WHITE)

static func _setup_panel_styles(theme: Theme):
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)
    panel_style.corner_radius_top_left = UIConstants.CORNER_RADIUS_LG
    panel_style.corner_radius_top_right = UIConstants.CORNER_RADIUS_LG
    panel_style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_LG
    panel_style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_LG
    panel_style.shadow_size = 8
    panel_style.shadow_color = Color(0, 0, 0, 0.3)
    
    theme.set_stylebox("panel", "Panel", panel_style)
```

**Apply Theme Globally**:
```gdscript
# In your main scene or autoload
func _ready():
    var game_theme = ThemeBuilder.build_game_theme()
    get_tree().root.theme = game_theme
```

### Responsive Layout System

**Challenge**: Godot doesn't have built-in responsive breakpoints like CSS.

**Solution**: Create a responsive system using Container nodes and custom logic.

```gdscript
# res://ui/layout/responsive_container.gd
@tool
class_name ResponsiveContainer
extends Container

enum LayoutMode {
    PORTRAIT_PHONE,     # < 600pt wide
    LANDSCAPE_PHONE,    # 600-900pt wide
    TABLET              # > 900pt wide
}

var current_layout: LayoutMode = LayoutMode.PORTRAIT_PHONE

func _ready():
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _update_layout()

func _on_viewport_size_changed():
    _update_layout()

func _update_layout():
    var viewport_size = get_viewport_rect().size
    
    # Determine layout mode
    var previous_layout = current_layout
    
    if viewport_size.x < 600:
        current_layout = LayoutMode.PORTRAIT_PHONE
    elif viewport_size.x < 900:
        current_layout = LayoutMode.LANDSCAPE_PHONE
    else:
        current_layout = LayoutMode.TABLET
    
    # Notify children if layout changed
    if previous_layout != current_layout:
        _notify_layout_change()

func _notify_layout_change():
    # Emit signal or call method on children
    for child in get_children():
        if child.has_method("on_layout_changed"):
            child.on_layout_changed(current_layout)
```

### Safe Area Handling (iOS Notch)

**Critical for Modern iPhones**: Must respect safe areas.

```gdscript
# res://ui/layout/safe_area_container.gd
class_name SafeAreaContainer
extends MarginContainer

@export var respect_safe_areas: bool = true

func _ready():
    _apply_safe_area_margins()
    get_viewport().size_changed.connect(_apply_safe_area_margins)

func _apply_safe_area_margins():
    if not respect_safe_areas:
        return
    
    # Get safe area from DisplayServer (iOS/Android provide this)
    var safe_rect = DisplayServer.get_display_safe_area()
    var window_size = get_viewport().get_visible_rect().size
    
    # Calculate margins needed
    var margin_top = int(max(safe_rect.position.y, UIConstants.SAFE_AREA_TOP))
    var margin_bottom = int(max(window_size.y - safe_rect.end.y, 
                                UIConstants.SAFE_AREA_BOTTOM))
    var margin_left = int(max(safe_rect.position.x, UIConstants.SAFE_AREA_SIDES))
    var margin_right = int(max(window_size.x - safe_rect.end.x, 
                               UIConstants.SAFE_AREA_SIDES))
    
    # Apply margins
    add_theme_constant_override("margin_top", margin_top)
    add_theme_constant_override("margin_bottom", margin_bottom)
    add_theme_constant_override("margin_left", margin_left)
    add_theme_constant_override("margin_right", margin_right)
```

**Usage in Scene**:
```
SafeAreaContainer (script attached)
└── VBoxContainer (your content here)
    ├── TopBar
    ├── Content
    └── BottomBar
```

### Input Handling for Mobile

**Touch vs Mouse**: Godot treats touch as mouse events, but you need special handling.

```gdscript
# res://ui/utils/input_helper.gd
class_name InputHelper
extends RefCounted

# Check if we're on a touch device
static func is_touch_device() -> bool:
    return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")

# Get the primary input position (mouse or first touch)
static func get_primary_input_position() -> Vector2:
    if is_touch_device() and Input.get_current_cursor_shape() == Input.CURSOR_ARROW:
        # Try to get touch position
        var touches = Input.get_vector("touch_0_x", "touch_0_y", "touch_0_x", "touch_0_y")
        if touches != Vector2.ZERO:
            return touches
    
    return get_viewport().get_mouse_position()

# Check if input just started (mouse click or touch)
static func is_input_just_pressed() -> bool:
    return Input.is_action_just_pressed("ui_touch") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
```

### Autoload Singletons for UI Management

**Software Engineering Principle: Singleton Pattern**  
Some systems should have exactly one instance accessible globally.

Create these autoloads (Project Settings → Autoload):

1. **UIManager** (`res://ui/ui_manager.gd`)
2. **HapticFeedback** (`res://ui/utils/haptic_feedback.gd`)
3. **ErrorHandler** (`res://ui/utils/error_handler.gd`)

```gdscript
# res://ui/ui_manager.gd
extends Node

signal screen_changed(from_screen: String, to_screen: String)

var current_screen: Control = null
var screen_stack: Array[Control] = []

func change_screen(screen_path: String, transition_type: String = "slide"):
    var new_screen = load(screen_path).instantiate()
    
    if current_screen:
        # Push to stack for back navigation
        screen_stack.push_back(current_screen)
        
        # Transition out current screen
        await _transition_out(current_screen, transition_type)
        current_screen.queue_free()
    
    # Add and transition in new screen
    get_tree().root.add_child(new_screen)
    await _transition_in(new_screen, transition_type)
    
    current_screen = new_screen
    screen_changed.emit(str(screen_stack[-1] if screen_stack.size() > 0 else ""), 
                       screen_path)

func go_back():
    if screen_stack.size() == 0:
        return
    
    var previous_screen = screen_stack.pop_back()
    
    if current_screen:
        await _transition_out(current_screen, "slide_reverse")
        current_screen.queue_free()
    
    get_tree().root.add_child(previous_screen)
    await _transition_in(previous_screen, "slide_reverse")
    current_screen = previous_screen

func _transition_out(screen: Control, type: String):
    var tween = create_tween()
    tween.set_parallel(true)
    
    match type:
        "slide":
            tween.tween_property(screen, "position:x", -screen.size.x, 0.3)
        "fade":
            tween.tween_property(screen, "modulate:a", 0.0, 0.2)
    
    await tween.finished

func _transition_in(screen: Control, type: String):
    match type:
        "slide":
            screen.position.x = screen.size.x
            var tween = create_tween()
            tween.tween_property(screen, "position:x", 0, 0.3)
            await tween.finished
        "fade":
            screen.modulate.a = 0.0
            var tween = create_tween()
            tween.tween_property(screen, "modulate:a", 1.0, 0.2)
            await tween.finished
```

### Performance Optimization

**Mobile devices have limited resources**. Follow these patterns:

**1. Object Pooling for Frequent UI**:
```gdscript
# res://ui/utils/ui_pool.gd
class_name UIPool
extends Node

var pools: Dictionary = {}  # scene_path -> Array[Control]

func get_instance(scene_path: String) -> Control:
    if not pools.has(scene_path):
        pools[scene_path] = []
    
    var pool = pools[scene_path]
    
    # Check if we have an available instance
    for instance in pool:
        if not instance.visible:
            instance.visible = true
            return instance
    
    # Create new instance
    var new_instance = load(scene_path).instantiate()
    add_child(new_instance)
    pool.append(new_instance)
    return new_instance

func return_instance(instance: Control):
    instance.visible = false
    # Reset any state if needed
```

**2. Deferred Updates**:
```gdscript
# Don't update UI every frame if not needed
var ui_update_timer: float = 0.0
const UI_UPDATE_INTERVAL: float = 0.1  # 10 updates/second

func _process(delta):
    ui_update_timer += delta
    if ui_update_timer >= UI_UPDATE_INTERVAL:
        ui_update_timer = 0.0
        _update_ui()
```

**3. Visibility Culling**:
```gdscript
# Don't process invisible UI
func _process(delta):
    if not visible:
        set_process(false)  # Disable processing when not visible
        return
```

---

## Priority Matrix

### Implementation Order

**Phase 1: Foundation (Week 1)**
- [ ] Set up project structure (folders, autoloads)
- [ ] Create UIConstants with all measurements
- [ ] Create ColorPalette with accessible colors
- [ ] Create TypographyTheme with text styles
- [ ] Build master Theme resource
- [ ] Create SafeAreaContainer for all screens

**Phase 2: Core Components (Week 2)**
- [ ] AdaptiveButton with touch targets
- [ ] StyledLabel with text styles
- [ ] ModalDialog with animations
- [ ] LoadingIndicator (spinner + progress)
- [ ] HapticFeedback system
- [ ] Basic sound effects (click, success, error)

**Phase 3: Screens (Week 3)**
- [ ] Main Menu with button hierarchy
- [ ] Character Selection with grid
- [ ] Pause Menu with modal
- [ ] Game Over screen with stats

**Phase 4: Combat HUD (Week 4)**
- [ ] HP Bar with color states
- [ ] XP Bar with animations
- [ ] Pause Button in safe zone
- [ ] Wave counter display
- [ ] Currency display

**Phase 5: Polish (Week 5)**
- [ ] Button press animations
- [ ] Screen transitions
- [ ] Success/error feedback
- [ ] Toast notifications
- [ ] Error handling modals
- [ ] Empty states

**Phase 6: Testing & Refinement (Week 6)**
- [ ] Device testing (see Testing Framework below)
- [ ] Contrast ratio validation
- [ ] Touch target validation
- [ ] Safe area validation
- [ ] Performance profiling

---

## Testing Framework

### Device Testing Checklist

**Minimum Test Devices**:
1. **iPhone 14 Pro** (6.1", notch, Dynamic Island) - iOS 15+
2. **iPhone SE (3rd gen)** (4.7", no notch) - iOS 15+
3. **Android flagship** (Samsung Galaxy S23) - Android 13+
4. **Android budget** (Moto G Power) - Android 11+

**Test Matrix**:

| Test Case | iPhone 14 Pro | iPhone SE | Galaxy S23 | Moto G Power |
|-----------|---------------|-----------|------------|--------------|
| **Touch Targets** |  |  |  |  |
| All buttons ≥44pt? | ☐ | ☐ | ☐ | ☐ |
| Combat buttons reachable? | ☐ | ☐ | ☐ | ☐ |
| No accidental presses? | ☐ | ☐ | ☐ | ☐ |
| **Safe Areas** |  |  |  |  |
| Top content visible? | ☐ | ☐ | ☐ | ☐ |
| Bottom content accessible? | ☐ | ☐ | ☐ | ☐ |
| Landscape mode safe? | ☐ | ☐ | ☐ | ☐ |
| **Typography** |  |  |  |  |
| Body text readable? | ☐ | ☐ | ☐ | ☐ |
| Combat text visible? | ☐ | ☐ | ☐ | ☐ |
| No text truncation? | ☐ | ☐ | ☐ | ☐ |
| **Performance** |  |  |  |  |
| 60 FPS in menus? | ☐ | ☐ | ☐ | ☐ |
| 60 FPS in combat? | ☐ | ☐ | ☐ | ☐ |
| Transitions smooth? | ☐ | ☐ | ☐ | ☐ |

### Automated Testing

```gdscript
# res://tests/ui_validation_test.gd
extends Node

func test_touch_target_compliance():
    var ui_root = get_tree().root
    var buttons = _find_all_buttons(ui_root)
    
    for button in buttons:
        var size = button.custom_minimum_size
        assert(size.x >= UIConstants.TOUCH_TARGET_MIN, 
               "Button %s width too small: %d" % [button.name, size.x])
        assert(size.y >= UIConstants.TOUCH_TARGET_MIN, 
               "Button %s height too small: %d" % [button.name, size.y])

func test_contrast_ratios():
    var labels = _find_all_labels(get_tree().root)
    
    for label in labels:
        var text_color = label.get_theme_color("font_color")
        var bg_color = _get_background_color(label)
        
        var contrast = ColorPalette.get_contrast_ratio(text_color, bg_color)
        assert(contrast >= 4.5, 
               "Label %s has insufficient contrast: %.2f" % [label.name, contrast])

func _find_all_buttons(node: Node) -> Array[Button]:
    var buttons: Array[Button] = []
    
    if node is Button:
        buttons.append(node)
    
    for child in node.get_children():
        buttons.append_array(_find_all_buttons(child))
    
    return buttons
```

### Manual Testing Checklist

**Usability Tests** (with real users):
- [ ] Can user find primary action within 2 seconds?
- [ ] Can user complete character selection without errors?
- [ ] Can user pause game during combat easily?
- [ ] Can user understand error messages?
- [ ] Can user navigate back to main menu intuitively?

**Accessibility Tests**:
- [ ] Test with color blindness simulator
- [ ] Test with Dynamic Type (iOS larger text)
- [ ] Test with one-handed use (left and right)
- [ ] Test in bright sunlight (contrast)
- [ ] Test with VoiceOver/TalkBack (optional but good)

---

## Additional Resources

### Recommended Reading

1. **iOS Human Interface Guidelines** - https://developer.apple.com/design/human-interface-guidelines/
2. **Material Design** - https://m3.material.io/
3. **Game UI Database** - https://www.gameuidatabase.com/ (Study successful mobile games)
4. **Refactoring UI** - Book by Adam Wathan & Steve Schoger (excellent design principles)

### Tools

1. **Contrast Checker** - https://webaim.org/resources/contrastchecker/
2. **Color Blindness Simulator** - https://www.color-blindness.com/coblis-color-blindness-simulator/
3. **Device Metrics** - https://screensiz.es/ (Screen sizes and safe areas)
4. **Godot UI Design Tools** - Built-in theme editor

### Godot-Specific Resources

1. **Official UI Docs** - https://docs.godotengine.org/en/stable/tutorials/ui/index.html
2. **Control Node Reference** - https://docs.godotengine.org/en/stable/classes/class_control.html
3. **Theme Resource** - https://docs.godotengine.org/en/stable/classes/class_theme.html

---

## Conclusion & Next Steps

You now have a complete, production-ready mobile game UI design system based on industry best practices. This system:

✅ **Ensures Usability** - All touch targets meet iOS/Android minimums  
✅ **Maintains Readability** - Typography scales tested for mobile  
✅ **Respects Constraints** - Safe areas, thumb zones, performance  
✅ **Follows Standards** - WCAG accessibility, iOS HIG, Material Design  
✅ **Scales Systematically** - 8pt grid, consistent spacing  
✅ **Provides Code Examples** - Ready to implement in Godot 4.5.1  

**Your Next Actions**:

1. **Set up the foundation** (Phase 1) - This gives you a solid base
2. **Build one complete flow** (Main Menu → Character Selection → Game) to validate patterns
3. **Test on real devices early** - Desktop testing is not enough for mobile
4. **Iterate based on user feedback** - These are guidelines, not rigid rules
5. **Document your decisions** - Add project-specific notes to this document

**Remember**: Good UI is invisible. If players can focus on your game without fighting the interface, you've succeeded.

---

## Software Engineering Principles Applied

Throughout this document, we've applied several key principles:

1. **DRY (Don't Repeat Yourself)** - UIConstants, reusable components
2. **Single Responsibility Principle** - Each component does one thing well
3. **Separation of Concerns** - Layout, styling, and logic separated
4. **Composition Over Inheritance** - Use scene composition, not deep hierarchies
5. **Constraint-Based Design** - 8pt grid, touch target minimums reduce decisions
6. **Progressive Enhancement** - Build core functionality first, add polish later
7. **Design by Contract** - UI elements promise specific behaviors (touch targets, contrast)
8. **Fail-Safe Defaults** - If something goes wrong, degrade gracefully

**Good luck with your mobile game UI! 🎮📱**
