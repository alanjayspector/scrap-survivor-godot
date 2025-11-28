# Next Session Handoff

**Updated:** 2025-11-28
**Current Branch:** `main`
**Status:** Week 18 Phase 3 COMPLETE - Phase 4 NEXT (with course corrections applied)

---

## ⚠️ CRITICAL COURSE CORRECTION (2025-11-28)

**ShopService was implemented incorrectly.** The shop is a HUB SERVICE, not a combat feature.

### What Was Wrong:
- ShopService used `generate_shop(wave, tier)` - wave-based generation
- Assumed shop appears between combat waves (like Brotato)

### What's Correct (per SHOPS-SYSTEM.md):
- Shop is accessed from Scrapyard hub (like Barracks, Workshop, Lab)
- Uses time-based refresh (4 hours), NOT wave-based
- API should be `generate_shop(tier)` with timestamp tracking

### Phase 5 Will Fix:
- Remove wave parameter from generate_shop()
- Add last_refresh_timestamp tracking
- Implement check_refresh_needed() - 4-hour cycle
- Implement check_empty_stock_refresh() - FREE refresh when all items purchased
- Add get_time_until_refresh() for UI countdown

### New Protocol Added:
- **Design Doc Requirement Protocol** added to CLAUDE_RULES.md
- MUST read design doc and quote key decisions BEFORE implementing any feature
- See CLAUDE_RULES.md "Design Document Requirement Protocol" section

---

## IMMEDIATE NEXT ACTION

**Begin Phase 4: InventoryService**

Phase 3 (ShopService) is complete but needs refactor in Phase 5.
Phase 4 can proceed - InventoryService is independent of shop refresh mechanism.

---

## SESSION ACCOMPLISHMENTS (Course Correction Session)

1. Identified ShopService misalignment (hub vs combat)
2. Reviewed hub art and store concept art
3. Determined correct hub layout:
   - Barracks (15%) | Shop (35%) | Bank (55%) | Start Run (85%)
4. Added Phase 5: ShopService Refactor for Hub Model
5. Added Phase 6.5: Hub Bank UI
6. Renamed Workshop → Foundry (avoid "shop" confusion)
7. Added Design Doc Requirement Protocol to CLAUDE_RULES.md
8. Updated Week 18 plan with all corrections

---

## WEEK 18 PHASE ORDER (UPDATED)

| Phase | Description | Est. Time | Status |
|-------|-------------|-----------|--------|
| **1** | Item Database + ItemService | 1.5h | ✅ COMPLETE |
| **2** | Character Type System | 1.5h | ✅ COMPLETE |
| **3** | ShopService | 1.5h | ✅ COMPLETE (needs refactor in Phase 5) |
| **4** | InventoryService | 1.5h | ⏭️ NEXT |
| **5** | ShopService Refactor for Hub Model | 1h | PENDING (course correction) |
| **6** | Hub Shop UI | 2h | PENDING |
| **6.5** | Hub Bank UI | 1h | PENDING (NEW) |
| **7** | Integration & QA | 1h | PENDING |
| **8** | Try-Before-Buy | 2h | STRETCH |

**Total Estimated**: 12-14 hours (was 10-12h before course correction)

---

## HUB LAYOUT REFERENCE

### Week 18 Layout (4 buttons - single row):
```
┌─────────────────────────────────────────────────────────────┐
│ [SCRAP SURVIVOR]                        [Settings ⚙️]       │
│                                                             │
│   [Barracks]    [Shop]    [Bank]        [Start Run]        │
│     (15%)       (35%)     (55%)           (85%)            │
│                                                             │
│ [Survivor Panel]                                            │
└─────────────────────────────────────────────────────────────┘
```

### Future Layout (Week 19+, second row):
```
┌─────────────────────────────────────────────────────────────┐
│   [Barracks]    [Shop]    [Bank]        [Start Run]        │
│     (15%)       (35%)     (55%)           (85%)            │
│                                                             │
│        [Foundry]   [Lab]   [Black Mkt]   [Atomic]          │
│          (20%)     (40%)     (60%)        (80%)            │
└─────────────────────────────────────────────────────────────┘
```

### Hub Art Reference:
- "SCRAP TRUST & EXCHANGE" truck (center) = Bank
- Vendor stands (left-center) = Shop
- Shanty buildings (left) = Barracks
- Gate/road (right) = Start Run

---

## QUICK START PROMPT

```
Continue Week 18 Phase 4: InventoryService.

⚠️ IMPORTANT: Read CLAUDE_RULES.md "Design Document Requirement Protocol" first!

Read (IN THIS ORDER):
1. .system/CLAUDE_RULES.md (development protocols + NEW design doc requirement)
2. docs/game-design/systems/INVENTORY-SYSTEM.md (MUST read before implementing!)
3. docs/migration/week18-plan.md (Phase 4 section)
4. scripts/services/shop_service.gd (reference pattern)

📋 **DESIGN DOC CHECKPOINT REQUIRED**
Before implementing, output:
- Key design decisions from INVENTORY-SYSTEM.md
- Hub/Combat context verification
- Get user approval before proceeding

Tasks:
1. Create scripts/services/inventory_service.gd
2. Implement add_item with slot validation (total + weapon limits)
3. Implement remove_item
4. Implement get_inventory
5. Implement stack limit enforcement by rarity
6. Implement auto-active stat calculation
7. Add perk hooks (inventory_add_pre/post, inventory_remove_pre/post)
8. Create scripts/tests/inventory_service_test.gd
```

---

## KEY DOCUMENTS

- `docs/migration/week18-plan.md` - Master plan (UPDATED with course corrections)
- `docs/game-design/systems/SHOPS-SYSTEM.md` - Shop design ("Location: Hub → Shop")
- `docs/game-design/systems/INVENTORY-SYSTEM.md` - Inventory design
- `docs/game-design/systems/BANKING-SYSTEM.md` - Bank design
- `.system/CLAUDE_RULES.md` - Development protocols (NEW: Design Doc Requirement)

---

## ARCHITECTURE DECISIONS

### Shop is a HUB SERVICE:
- Accessed from scrapyard hub (button at 35% position)
- Time-based refresh (4 hours)
- NOT wave-based (wrong assumption from Brotato pattern)

### Bank is a HUB SERVICE:
- "SCRAP TRUST & EXCHANGE" truck in hub art
- Deposit/withdraw scrap
- Quantum Storage (Subscription) = cross-character transfer

### Foundry (formerly Workshop):
- Renamed to avoid "shop" confusion
- Hub service for crafting/repair
- Week 19+ implementation

---

## KNOWN ISSUES / NOTES

1. **ShopService Needs Refactor**: Phase 5 will remove wave parameter, add time-based refresh

2. **InventoryService Missing**: ShopService purchase flow returns item but doesn't add to inventory. Phase 4 will complete the loop.

3. **Salvager Discount**: Already implemented in `calculate_purchase_price()` - reads `shop_discount` from character stats.

4. **No Shop/Bank Icons Yet**: Need to create/commission for Phase 6/6.5

---

## LESSONS LEARNED (This Session)

**Always read design docs before implementing.**

The SHOPS-SYSTEM.md clearly stated "Location: Hub → Shop" but this wasn't checked before Phase 3 implementation. This led to incorrect wave-based design that required course correction.

**New protocol added to prevent this:**
- Design Doc Requirement Protocol in CLAUDE_RULES.md
- MUST read and quote design doc before implementing
- MUST verify hub vs combat context
- MUST get user approval before proceeding

---

**Git Status:** Course corrections documented, ready for Phase 4
**Tests:** 836/860 passing (24 pending)
**Last Commit:** `1f3330b` feat: implement Week 18 Phase 3 - ShopService
