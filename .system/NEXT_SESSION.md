# Next Session: Continue Week16 Phases

**Last Updated**: 2025-11-21
**Current Branch**: `main`
**Next Task**: Continue with Week16 independent phases (ButtonAnimation, ScreenContainer)

---

## Theme System Phase 1 (COMPLETED)

### What Was Built

**Branch**: `feature/theme-system` (merged to main)
**Commits**: `72ae23b`, `21f4c24`

**New Files Created**:
```
themes/
├── game_theme.tres              # Main theme resource
└── styles/
    ├── button_primary.tres      # Purple filled button
    ├── button_primary_pressed.tres
    ├── button_secondary.tres    # Outlined button
    ├── button_secondary_pressed.tres
    ├── button_danger.tres       # Red filled button
    ├── button_danger_pressed.tres
    ├── button_ghost.tres        # Transparent button
    ├── button_ghost_pressed.tres
    ├── panel_card.tres          # Card background
    ├── panel_elevated.tres      # Elevated panel with shadow
    ├── tab_selected.tres        # Selected tab style
    └── tab_unselected.tres      # Unselected tab style

scripts/ui/theme/
└── theme_helper.gd              # Programmatic styling utilities

scripts/ui/components/
└── ui_icon.gd                   # iOS-safe icon system (text fallbacks)
```

**Key Changes**:
- All emojis replaced with colored ASCII text (iOS-safe)
- Theme applied to CharacterDetailsPanel
- Buttons styled (close button = secondary, collapsible headers = ghost)
- TabContainer has styled selected/unselected states

---

## Theme System Phase 2 (COMPLETED)

**Applied theme to ALL screens**:
- `character_roster.tscn` - Theme + button styling (Primary/Secondary)
- `character_card.tscn` - Theme + button styling (Primary/Secondary/Danger)
- `character_creation.tscn` - Theme + button styling (Primary/Secondary)
- `wave_complete_screen.tscn` - Theme + button styling (Primary/Secondary)
- `scrapyard.tscn` - Theme + button styling (Primary/Secondary/Ghost) + removed emoji from QA button
- `hud.tscn` - Theme applied

**Scripts updated with ThemeHelper**:
- `scripts/ui/character_roster.gd`
- `scripts/ui/character_card.gd`
- `scripts/ui/character_creation.gd`
- `scripts/hub/scrapyard.gd`
- `scenes/ui/wave_complete_screen.gd`

**Button style assignments**:
- PRIMARY: Play, Create, Next Wave (call to action)
- SECONDARY: Back, Details, Hub, Characters (secondary action)
- DANGER: Delete buttons (destructive action)
- GHOST: Quit, collapsible headers (tertiary/subtle)

### iOS Emoji Issue - Root Cause

Godot only supports **bitmap (PNG) emoji fonts**. iOS system fonts use COLR/SVG formats which Godot cannot render. Solution: Use TextureRect icons or text fallbacks.

---

## Icon Research (RECONCILED)

### Asset Sources (Priority Order)

| Priority | Source | Details | Use For |
|----------|--------|---------|---------|
| **1** | **Kenney Game Icons** | 105 assets, CC0, vector | Base icons (tint with colors) |
| **2** | **7Soul's RPG Graphics** | 1700+ icons, CC0 | RPG-specific (potions, armor variants) |
| **3** | **Kenney UI Pack RPG** | 85 assets, panels/buttons | Structural UI elements |
| **4** | **CraftPix Post-Apocalypse** | 512px painted | Hero images for level-up screens only |

### Wasteland Visual Motifs

**Key Insight**: Icons must be "translated" from generic RPG to wasteland theme.

| Stat | Generic RPG | **Wasteland Motif** | Visual Anchor (24px) |
|------|-------------|---------------------|----------------------|
| Health | Red Heart | **Taped Heart / Blood Bag** | Cross-hatch "tape" or IV tube |
| Armor | Shield | **Car Door / Scrap Plate** | Rivet pixel in corner |
| Damage | Sword | **Spiked Bat / Serrated Knife** | Jagged edges / nails |
| Speed | Boot | **Winged Tire** | Tread pattern on circle |
| Attack Spd | Lightning | **Firing Piston** | Motion lines / spark |
| Luck | Clover | **Fuzzy Dice / Mutated Clover** | Dice pips or glowing veins |
| Currency | Gold Coin | **Rusted Cog / Hex Nut** | Missing tooth on cog |
| XP/Level | Star | **Dog Tag** | Ball-chain detail |

### Technical Requirements

**Display**: 24px visual size
**Touch Target**: 48x48px minimum (use `custom_minimum_size`)
**Format**: PNG with 1px dark outline for readability
**Rendering**: Consider MSDF for HUD icons (infinite scaling)

### Grunge Processing Pipeline

To unify clean Kenney icons with wasteland aesthetic:

**Option A: ImageMagick Batch**
```bash
# Apply rust texture + edge roughening
magick "$icon" \
  \( "rust_overlay.png" -resize 24x24^ -gravity center -crop 24x24+0+0 \) \
  -compose Multiply -composite \
  -spread 1 \
  "$OUTPUT_DIR/$filename"
```

**Option B: Python/Pillow**
- Procedural "salt and pepper" decay
- 5% pixel transparency (chips)
- 10% rust tint overlay

**Option C: Godot Shader** (runtime)
- Glitch effect on damage feedback
- Horizontal UV displacement + noise

---

## Next Session Tasks

### ~~1. Source Icon Assets~~ (COMPLETED)
- [x] Download Kenney Game Icons pack (https://kenney.nl/assets/game-icons)
- [x] Select icons for game use (25 icons in themes/icons/game/)
- [x] Create `UIIcons` class (`scripts/ui/theme/ui_icons.gd`)
- [ ] Download 7Soul's RPG Graphics (optional - if more icons needed)
- [ ] Process through grunge pipeline (optional wasteland effect)

### 2. ~~Apply Theme to Remaining Screens~~ (DONE)
- [x] `character_roster.tscn` - Theme + Primary/Secondary buttons
- [x] `character_creation.tscn` - Theme + Primary/Secondary buttons
- [x] `character_card.tscn` - Theme + Primary/Secondary/Danger buttons
- [x] `wave_complete_screen.tscn` - Theme + Primary/Secondary buttons
- [x] `scrapyard.tscn` (hub) - Theme + Primary/Secondary/Ghost buttons
- [x] `hud.tscn` - Theme applied

### 3. ~~Haptic Feedback System~~ (COMPLETED)
- [x] Created `scripts/ui/theme/haptic_feedback.gd` with tap/select/warning/error/impact methods
- [x] Integrated into hub, roster, creation, card, and wave complete screens
- [x] Platform-aware (iOS/Android only, no-op on desktop)
- [x] Commit: `26c8c19`

### 4. Continue with Independent Phases (Week16)
- [ ] ButtonAnimation component
- [ ] ScreenContainer for safe areas

---

## Files Reference

**Theme System**:
- `themes/game_theme.tres` - Main theme
- `scripts/ui/theme/theme_helper.gd` - Programmatic button styling
- `scripts/ui/theme/ui_icons.gd` - Icon loader (UIIcons class)
- `scripts/ui/theme/haptic_feedback.gd` - Mobile haptic/vibration feedback
- `scripts/ui/components/ui_icon.gd` - iOS-safe text fallbacks

**Icons** (Kenney Game Icons - CC0):
- `themes/icons/game/` - 25 white icons (2x resolution)
- gear, home, return, audioOn/Off, musicOn/Off, trashcan, cross, info, warning, star, plus, locked, checkmark, target, trophy, medals, arrows, etc.

**Existing Infrastructure**:
- `scripts/ui/theme/ui_constants.gd` - Measurements
- `scripts/ui/theme/color_palette.gd` - Colors

**Screens Updated** (All have theme + button styling):
- `scenes/ui/character_roster.tscn` ✅
- `scenes/ui/character_creation.tscn` ✅
- `scenes/ui/character_card.tscn` ✅
- `scenes/ui/wave_complete_screen.tscn` ✅
- `scenes/hub/scrapyard.tscn` ✅
- `scenes/ui/hud.tscn` ✅
- `scenes/ui/character_details_panel.tscn` ✅ (Phase 1)

---

## Success Criteria (Theme System Phase 2) ✅ COMPLETE

1. ✅ All UI screens use `game_theme.tres`
2. ✅ All buttons styled appropriately (primary/secondary/danger/ghost)
3. ✅ Icon textures available via `UIIcons` class (25 Kenney icons in themes/icons/game/)
4. ✅ Consistent look across all screens
5. ✅ Tests still passing (647/671)

---

## Reference: Full Research Document

See attached "Wasteland Survivor Game Iconography Guide.md" for:
- Detailed semiotic analysis of each icon type
- Case studies (Fallout, Metro, Vampire Survivors, Borderlands)
- Godot 4.5.1 SVG/MSDF rendering pipeline details
- Python/ImageMagick automation scripts
- Mobile UX guidelines (portrait vs landscape, thumb zones)

---

**Session Date**: 2025-11-21
**Recent Commits**:
- `26c8c19` - feat: add haptic feedback system for mobile UI
- `2414b13` - fix: apply DANGER style to delete confirmation OK button
