# UI Audit Report - Week 16 Phase 1

Generated: 2025-11-22T09:09:26

---

## Summary Across All Scenes

- **Total Issues**: 15
- **Buttons < 44pt**: 0 🚨
- **Buttons < 60pt**: 0 ⚠️
- **Labels < 13pt**: 15 🚨
- **Labels < 17pt**: 16 ⚠️

---

## scrapyard

**Scene**: `res://scenes/hub/scrapyard.tscn`

### Summary

- Labels: 2 (0 under 13pt, 0 under 17pt)
- Buttons: 5 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| PlayButton | 77.0pt | 32pt |  |
| CharactersButton | 77.0pt | 32pt |  |
| SettingsButton | 132.0pt | 32pt |  |
| QuitButton | 63.0pt | 28pt |  |
| DebugQAButton | 60.0pt | 18pt |  |

---

## character_roster

**Scene**: `res://scenes/ui/character_roster.tscn`

### Summary

- Labels: 5 (0 under 13pt, 0 under 17pt)
- Buttons: 5 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| DetailsButton | 99.0pt | 20pt |  |
| PlayButton | 99.0pt | 20pt |  |
| DeleteButton | 99.0pt | 18pt |  |
| CreateNewButton | 132.0pt | 24pt |  |
| BackButton | 132.0pt | 24pt |  |

---

## character_creation

**Scene**: `res://scenes/ui/character_creation.tscn`

### Summary

- Labels: 4 (0 under 13pt, 0 under 17pt)
- Buttons: 6 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| @Button@275 | 200.0pt | 16pt |  |
| @Button@276 | 200.0pt | 16pt |  |
| @Button@277 | 200.0pt | 16pt |  |
| @Button@278 | 200.0pt | 16pt |  |
| BackButton | 132.0pt | 24pt |  |
| CreateButton | 132.0pt | 24pt |  |

---

## character_selection

**Scene**: `res://scenes/ui/character_selection.tscn`

### Summary

- Labels: 35 (15 under 13pt, 10 under 17pt)
- Buttons: 2 (0 under 44pt, 0 under 60pt)
- Issues: 15

### Issues

- Label '@Label@360' is 12pt (< 13pt minimum)
- Label '@Label@363' is 12pt (< 13pt minimum)
- Label '@Label@365' is 12pt (< 13pt minimum)
- Label '@Label@374' is 12pt (< 13pt minimum)
- Label '@Label@377' is 12pt (< 13pt minimum)
- Label '@Label@380' is 12pt (< 13pt minimum)
- Label '@Label@382' is 12pt (< 13pt minimum)
- Label '@Label@391' is 12pt (< 13pt minimum)
- Label '@Label@394' is 12pt (< 13pt minimum)
- Label '@Label@397' is 12pt (< 13pt minimum)
- Label '@Label@399' is 12pt (< 13pt minimum)
- Label '@Label@414' is 12pt (< 13pt minimum)
- Label '@Label@417' is 12pt (< 13pt minimum)
- Label '@Label@420' is 12pt (< 13pt minimum)
- Label '@Label@422' is 12pt (< 13pt minimum)

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| BackButton | 60.0pt | 28pt |  |
| CreateButton | 60.0pt | 28pt |  |

### Problematic Labels

| Name | Font Size | Text | Issue |
|------|-----------|------|-------|
| @Label@357 | 13pt | Efficient resource gatherer with auto-collect aura | SMALL (< 17pt recommended for body text) |
| @Label@360 | 12pt | +5 Scavenging | TOO SMALL (< 13pt) |
| @Label@363 | 12pt | +20 Pickup Range | TOO SMALL (< 13pt) |
| @Label@365 | 12pt | Aura: Collect | TOO SMALL (< 13pt) |
| @Label@366 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |
| @Label@371 | 13pt | Heavy armor specialist with protective aura | SMALL (< 17pt recommended for body text) |
| @Label@374 | 12pt | +20 Max Hp | TOO SMALL (< 13pt) |
| @Label@377 | 12pt | +3 Armor | TOO SMALL (< 13pt) |
| @Label@380 | 12pt | -20 Speed | TOO SMALL (< 13pt) |
| @Label@382 | 12pt | Aura: Shield | TOO SMALL (< 13pt) |
| @Label@383 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |
| @Label@388 | 13pt | High DPS glass cannon with no defensive aura | SMALL (< 17pt recommended for body text) |
| @Label@391 | 12pt | +5 Ranged Damage | TOO SMALL (< 13pt) |
| @Label@394 | 12pt | +15 Attack Speed | TOO SMALL (< 13pt) |
| @Label@397 | 12pt | -2 Armor | TOO SMALL (< 13pt) |
| @Label@399 | 12pt | Aura: None | TOO SMALL (< 13pt) |
| @Label@400 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |
| @Label@406 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |
| @Label@411 | 13pt | Mutation specialist with powerful damage aura | SMALL (< 17pt recommended for body text) |
| @Label@414 | 12pt | +10 Resonance | TOO SMALL (< 13pt) |
| @Label@417 | 12pt | +5 Luck | TOO SMALL (< 13pt) |
| @Label@420 | 12pt | +20 Pickup Range | TOO SMALL (< 13pt) |
| @Label@422 | 12pt | Aura: Damage | TOO SMALL (< 13pt) |
| @Label@423 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |
| @Label@429 | 14pt | Tap for details | SMALL (< 17pt recommended for body text) |

---

## character_card

**Scene**: `res://scenes/ui/character_card.tscn`

### Summary

- Labels: 3 (0 under 13pt, 0 under 17pt)
- Buttons: 3 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| DetailsButton | 99.0pt | 20pt |  |
| PlayButton | 99.0pt | 20pt |  |
| DeleteButton | 99.0pt | 18pt |  |

---

## character_details_panel

**Scene**: `res://scenes/ui/character_details_panel.tscn`

### Summary

- Labels: 28 (0 under 13pt, 1 under 17pt)
- Buttons: 1 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| CloseButton | 60.0pt | 20pt |  |

### Problematic Labels

| Name | Font Size | Text | Issue |
|------|-----------|------|-------|
| ItemsNote | 16pt | Inventory system coming soon! | SMALL (< 17pt recommended for body text) |

---

## wave_complete_screen

**Scene**: `res://scenes/ui/wave_complete_screen.tscn`

### Summary

- Labels: 1 (0 under 13pt, 0 under 17pt)
- Buttons: 2 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| HubButton | 132.0pt | 24pt |  |
| NextWaveButton | 132.0pt | 24pt |  |

---

## wasteland

**Scene**: `res://scenes/game/wasteland.tscn`

### Summary

- Labels: 11 (0 under 13pt, 0 under 17pt)
- Buttons: 4 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| HubButton | 70.0pt | 24pt |  |
| NextWaveButton | 70.0pt | 24pt |  |
| RetryButton | 70.0pt | 24pt |  |
| MainMenuButton | 70.0pt | 24pt |  |

---

## debug_menu

**Scene**: `res://scenes/debug/debug_menu.tscn`

### Summary

- Labels: 5 (0 under 13pt, 5 under 17pt)
- Buttons: 10 (0 under 44pt, 0 under 60pt)
- Issues: 0

### Buttons

| Name | Height | Font Size | Issues |
|------|--------|-----------|--------|
| @Button@468 | 80.0pt | 16pt |  |
| @Button@469 | 80.0pt | 16pt |  |
| @Button@470 | 80.0pt | 16pt |  |
| @Button@472 | 60.0pt | 16pt |  |
| @Button@473 | 60.0pt | 16pt |  |
| @Button@474 | 60.0pt | 16pt |  |
| @Button@476 | 60.0pt | 16pt |  |
| @Button@477 | 60.0pt | 16pt |  |
| @Button@479 | 60.0pt | 16pt |  |
| @Button@480 | 60.0pt | 16pt |  |

### Problematic Labels

| Name | Font Size | Text | Issue |
|------|-----------|------|-------|
| TierLabel | 16pt | Select Tier: | SMALL (< 17pt recommended for body text) |
| @Label@471 | 16pt | Reset Options: | SMALL (< 17pt recommended for body text) |
| @Label@475 | 16pt | Visual Regression (Week 16): | SMALL (< 17pt recommended for body text) |
| @Label@478 | 16pt | UI Audit (Week 16 Phase 1): | SMALL (< 17pt recommended for body text) |
| StatusLabel | 16pt | CURRENT STATE:
• Tier: SUBSCRIPTION
• Characters:  | SMALL (< 17pt recommended for body text) |

---

