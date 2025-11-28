# Next Session Handoff

**Updated:** 2025-11-28 (Post Architecture Fix)
**Current Branch:** `main`
**Status:** BankingService Architecture Fix - COMPLETE ✅ Ready for QA

---

## SESSION ACCOMPLISHMENTS (2025-11-28)

### BankingService ↔ CharacterService Sync - COMPLETE ✅

**Problem Fixed:**
Currency was stored in TWO places that weren't synchronized:
1. `CharacterService.characters[id].starting_currency` (per-character, source of truth)
2. `BankingService.balances` (global singleton, was ignoring character data)

**Root Cause:**
- BankingService had its own `serialize()`/`deserialize()` that stored balances independently
- When active character changed, BankingService never synced from character's currency
- Debug menu updated CharacterService but Shop read from BankingService (always 0)

**Solution Implemented:**

1. **BankingService is now a "view"** of active character's currency:
   - Connects to `CharacterService.active_character_changed` signal
   - On character change → loads character's `starting_currency` into balances
   - On `add_currency`/`subtract_currency` → writes back to CharacterService immediately
   - `serialize()` no longer stores balances (v2 format, tier only)
   - `deserialize()` ignores v1 balance data (CharacterService is source of truth)

2. **SaveManager load order fixed:**
   - CharacterService now loads FIRST (was last)
   - BankingService syncs via signal after CharacterService loads

3. **Debug menu simplified:**
   - Only updates CharacterService
   - Calls `BankingService._sync_from_character()` to refresh view

4. **Tests updated:**
   - 7 tests fixed to reflect new architecture
   - All 855/879 tests passing

### Files Modified

| File | Changes |
|------|---------|
| `scripts/services/banking_service.gd` | Complete rewrite - now syncs with CharacterService |
| `scripts/systems/save_manager.gd` | Reordered load: CharacterService first |
| `scripts/debug/debug_menu.gd` | Simplified currency application |
| `scripts/tests/banking_service_test.gd` | Updated serialize/deserialize tests |
| `scripts/tests/save_integration_test.gd` | Updated 4 tests for new architecture |
| `scripts/tests/service_integration_test.gd` | Fixed FREE tier test |

---

## QA TESTING REQUIRED

**Manual QA Checklist:**

1. [ ] Create new character
2. [ ] Open Debug Menu → Set currency to Rich (10K)
3. [ ] Close Debug Menu
4. [ ] Open Shop → Verify currency shows 10,000 scrap
5. [ ] Purchase an item → Verify currency decreases
6. [ ] Return to Hub
7. [ ] Open Debug Menu → Verify currency shows updated value
8. [ ] Create SECOND character
9. [ ] Switch to second character (Barracks)
10. [ ] Open Shop → Verify currency is 0 (per-character!)
11. [ ] Switch back to first character
12. [ ] Open Shop → Verify original currency restored

---

## SUGGESTED COMMIT

```bash
git add -A
git commit -m "fix: BankingService now syncs currency from active character

BREAKING: Currency is now per-character (stored in CharacterService)

Architecture changes:
- BankingService connects to CharacterService.active_character_changed
- On character change: load character's starting_currency into balances  
- On add/subtract: write-through to CharacterService immediately
- serialize() no longer stores balances (v2 format)
- SaveManager loads CharacterService FIRST (order matters for signals)

This enables:
- Per-character currency (core design principle)
- Quantum Banking subscription feature (transfer between characters)
- Debug menu currency controls now work correctly

Tests: Updated 7 tests, all 855/879 passing

Fixes: Debug menu currency not updating Shop display"
```

---

## NEXT PHASE: 6.5 Hub Bank UI

### Scope
Implement the Bank UI in the Hub for depositing/withdrawing scrap.

### Now Possible (Architecture Fixed!)
With BankingService properly synced to CharacterService:
- Bank deposits update character's `starting_currency`
- Switching characters loads correct bank balance
- Quantum Banking (subscription) can transfer between characters

### Phase 6.5 Tasks
1. Create Bank scene (`scenes/hub/bank.tscn`)
2. Bank UI: deposit/withdraw interface
3. Premium tier gate (FREE tier sees "Upgrade to unlock")
4. Connect to Scrapyard hub navigation

---

## KEY FILES REFERENCE

| Purpose | File |
|---------|------|
| BankingService | `scripts/services/banking_service.gd` |
| CharacterService | `scripts/services/character_service.gd` |
| SaveManager | `scripts/systems/save_manager.gd` |
| Debug menu | `scripts/debug/debug_menu.gd` |
| Banking System Design | `docs/game-design/systems/BANKING-SYSTEM.md` |

---

## ARCHITECTURE NOTES

### Currency Flow (New)
```
CharacterService.characters[id].starting_currency  ← Source of Truth
           ↑                           ↓
           │                    (on active_character_changed)
           │                           ↓
    (write-through)          BankingService.balances  ← View
           ↑                           ↓
           │                    (currency_changed signal)
           │                           ↓
    BankingService.add_currency()    UI Components
    BankingService.subtract_currency()
```

### Save/Load Order
1. CharacterService.deserialize() → emits `state_loaded`, `active_character_changed`
2. BankingService receives signal → calls `_sync_from_character()`
3. BankingService.deserialize() → restores tier only (balances come from signal)

---

## LESSONS LEARNED THIS SESSION

1. **Single Source of Truth** - Currency must live in ONE place (CharacterService)
2. **Signal-based sync** - Services should communicate via signals, not duplicate data
3. **Load order matters** - When using signals, dependent services must load after their sources
4. **Test the architecture** - Integration tests caught the sync issue
