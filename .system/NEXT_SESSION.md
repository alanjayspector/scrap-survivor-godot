# Next Session Handoff

**Updated:** 2025-11-28 (End of Session)
**Current Branch:** `main`
**Status:** Phase 6 Shop UI Rework - COMPLETE ✅ Ready to Commit

---

## SESSION ACCOMPLISHMENTS (2025-11-28)

### Phase 6 Shop UI Rework - COMPLETE ✅

**All issues identified and fixed:**

1. **Shop Background Art** - Generated new UI-optimized background
   - Used expert panel criteria for art review
   - Final: `inside-shop-3.png` - dark center, shop elements at edges
   - Processed to `assets/ui/backgrounds/shop_interior.jpg` (811KB, 2048x2048)

2. **Shop Scene Rewrite** (`scenes/ui/shop.tscn`)
   - `TextureRect` background with shop_interior.jpg
   - `StyleBoxFlat` on ScrollContainer
   - Added InfoRow with refresh timer AND reroll count
   - 3×2 grid layout (changed from 2×3 for better horizontal fill)
   - Cards centered via CenterContainer

3. **Shop Item Cards** - Polished and resized
   - Increased size: 170×200 → 220×190 (wider for 3-column layout)
   - iOS-safe tap animations
   - Haptic feedback

4. **Debug Menu Currency Fix** - BUG FIXED
   - Currency is per-character (stored in `CharacterService.starting_currency`)
   - Debug menu was only updating `BankingService` (global singleton)
   - Now updates BOTH character currency AND BankingService
   - Shows error if no active character selected

5. **Art Pipeline Tools** - NEW
   - `scripts/tools/optimize-art-asset.sh` - Process art assets for game
   - `scripts/tools/process-qa-screenshot.sh` - Process QA screenshots for Claude review
   - `docs/ART-PIPELINE.md` - Documentation
   - Updated `CLAUDE_RULES.md` with art review protocols

### QA Status
- ✅ Manual QA passed on device
- ✅ Background displays correctly
- ✅ 3×2 card layout fills space well
- ✅ Purchase flow works
- ✅ Reroll flow works
- ✅ Currency controls now work (fixed!)
- ✅ All tests pass (855/879)

---

## FILES TO COMMIT

### Modified:
- `.gitignore` (added processed/archive dirs)
- `.system/CLAUDE_RULES.md` (art review protocols)
- `scenes/ui/shop.tscn` (complete rewrite)
- `scripts/ui/shop.gd` (updated node paths)
- `scenes/ui/components/shop_item_card.tscn` (new size)
- `scripts/ui/components/shop_item_card.gd` (tap animations)
- `scenes/debug/debug_menu.tscn` (currency controls)
- `scripts/debug/debug_menu.gd` (currency controls - fixed per-character)

### New:
- `assets/ui/backgrounds/shop_interior.jpg`
- `docs/ART-PIPELINE.md`
- `scripts/tools/optimize-art-asset.sh`
- `scripts/tools/process-qa-screenshot.sh`
- `qa/` directory structure

---

## SUGGESTED COMMIT

```bash
git add -A
git commit -m "feat: complete Phase 6 shop UI rework with new background art

- Add new shop interior background (dark center, shop elements at edges)
- Rewrite shop.tscn with TextureRect background and StyleBoxFlat
- Change grid layout from 2x3 to 3x2 for better horizontal fill
- Increase shop item card size to 220x190
- Add CenterContainer for proper card centering
- Add reroll count display to header info row
- Add currency controls to debug menu (presets: Poor/Medium/Rich/Whale)
- Fix debug menu currency to update per-character storage
- Add art asset optimization scripts for Claude workflow
- Add QA screenshot processing script
- Document art pipeline in docs/ART-PIPELINE.md
- Update CLAUDE_RULES.md with art review protocols

QA: Manual testing passed on device"
```

---

## NEXT PHASE: 6.5 Hub Bank UI

### Scope
Implement the Bank UI in the Hub for depositing/withdrawing scrap.

### ⚠️ CRITICAL ARCHITECTURAL ISSUE TO FIX FIRST

**Problem Discovered:** `BankingService` and `CharacterService.starting_currency` are **not synchronized**.

- Currency is stored per-character in `CharacterService.starting_currency`
- `BankingService` is a global singleton with its own `balances` dictionary
- Shop UI reads from `BankingService.get_balance()`
- When you switch characters, `BankingService` doesn't update
- This caused the debug menu currency bug we just fixed

**Required Fix for Phase 6.5:**
1. `BankingService` should sync with active character on `active_character_changed` signal
2. When character becomes active → load their currency into BankingService
3. When BankingService currency changes → save back to active character
4. OR: Refactor all UI to read directly from CharacterService (breaking change)

**Recommended Approach:** Option 1 - make BankingService a "view" of the active character's currency.

```gdscript
# In BankingService._ready() or initialization:
CharacterService.active_character_changed.connect(_on_active_character_changed)

func _on_active_character_changed(character_id: String) -> void:
    if character_id.is_empty():
        reset()
        return
    
    var character = CharacterService.get_character(character_id)
    var currency = character.get("starting_currency", {})
    
    # Load character's currency into BankingService
    balances["scrap"] = currency.get("scrap", 0)
    balances["components"] = currency.get("components", 0)
    balances["nanites"] = currency.get("nanites", 0)
    
    # Emit signals so UI updates
    currency_changed.emit(CurrencyType.SCRAP, balances["scrap"])
    currency_changed.emit(CurrencyType.COMPONENTS, balances["components"])
    currency_changed.emit(CurrencyType.NANITES, balances["nanites"])
```

### Phase 6.5 Tasks (After Arch Fix)
1. Fix BankingService ↔ CharacterService sync (see above)
2. Create Bank scene (`scenes/hub/bank.tscn`)
3. Bank UI: deposit/withdraw interface
4. Bank balance display
5. Connect to Scrapyard hub navigation

---

## KEY FILES REFERENCE

| Purpose | File |
|---------|------|
| Shop scene | `scenes/ui/shop.tscn` |
| Shop script | `scripts/ui/shop.gd` |
| Item card scene | `scenes/ui/components/shop_item_card.tscn` |
| Item card script | `scripts/ui/components/shop_item_card.gd` |
| Shop background | `assets/ui/backgrounds/shop_interior.jpg` |
| Debug menu | `scripts/debug/debug_menu.gd` |
| BankingService | `scripts/services/banking_service.gd` |
| CharacterService | `scripts/services/character_service.gd` |
| Banking System Design | `docs/game-design/systems/BANKING-SYSTEM.md` |
| Art pipeline docs | `docs/ART-PIPELINE.md` |

---

## LESSONS LEARNED THIS SESSION

1. **Currency is per-character** - Always check design docs before assuming global state
2. **BankingService needs sync** - It's currently disconnected from character data
3. **Art backgrounds need UI optimization** - Dark center, detail at edges
4. **3×2 layout beats 2×3** - Better horizontal fill for landscape mobile
