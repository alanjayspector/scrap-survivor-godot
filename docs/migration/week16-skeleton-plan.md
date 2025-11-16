# Week 16 - IAP Integration + Debug Tooling (Skeleton Plan)

**Status:** Planning
**Estimated Effort:** 10-12 hours

---

## Priority 1: Debug/QA Tooling (MUST HAVE - 1-2 hours)

### Debug Menu for Tier Testing
**Problem:** Can't test tier-gated features (FREE/PREMIUM/SUBSCRIPTION) without debug tooling
**Solution:** Debug-only tier switcher + account reset tools

**Requirements (from Sr QA Engineer):**
- Only visible in debug builds (`OS.is_debug_build()`)
- Accessible via gesture (3-finger triple-tap) or debug button in Hub
- NEVER ships to production (wrap in debug checks)

**Features:**
1. **Tier Switching:**
   - Buttons: FREE | PREMIUM | SUBSCRIPTION
   - Changes `CharacterService.current_tier`
   - Saves immediately
   - Options:
     - Change tier only (keep characters) - test "upgrade" flow
     - Change tier + reset characters - test fresh account
     - Full nuclear reset - delete all saves

2. **Account Reset:**
   - Delete all characters
   - Clear all saves
   - Reset to specific tier
   - Confirmation dialog: "DELETE ALL DATA?"

3. **Status Display:**
   - Current tier
   - Character count / slot limit
   - Save file size
   - Visual indicator when debug mode active

**Implementation:**
```
scenes/debug/debug_menu.tscn - Debug popup dialog
scripts/debug/debug_menu.gd - Tier switching logic
```

**Add to Hub Scene:**
- Bottom-right corner "QA" button
- Only visible if `OS.is_debug_build()`
- Opens debug menu popup

**Safety:**
- Log all debug actions: `GameLogger.warning('[DEBUG] Tier changed to X')`
- Confirmation dialogs for destructive actions
- Visual badge showing "DEBUG MODE ACTIVE"

---

## Priority 2: IAP Integration (8-10 hours)

### Tier Upgrade Flow
1. Replace `_show_purchase_stub()` with real IAP calls
2. StoreKit (iOS) + Google Play integration
3. Receipt validation
4. `TierService.upgrade_tier()` on successful purchase
5. Refresh UI after purchase

### Slot Pack Purchases (PREMIUM tier)
- +5 slots: $0.99
- +25 slots: $3.99
- Update `CharacterService.SLOT_LIMITS` dynamically
- Store purchased slot packs in save file

### Product IDs
```
com.scrapsurvival.premium          - $4.99 (one-time)
com.scrapsurvival.subscription     - $2.99/month (recurring)
com.scrapsurvival.slots_5          - $0.99 (consumable)
com.scrapsurvival.slots_25         - $3.99 (consumable)
```

---

## Priority 3: Meta Progression System (Week 16+ OR Week 17)

**Recommendation from Week 15 Plan:**
- MetaProgressionService
- Post-run meta-currency conversion
- Permanent upgrade shop in hub
- Apply upgrades to new runs

**Decision:** Defer to Week 17? Or implement in Week 16 after IAP?

---

## Priority 4: Character Roster Virtual Scrolling (Technical Debt)

**Context:** Phase 3 (Week 15) delivered character roster with reusable CharacterCard components. Current implementation uses VBoxContainer with all character cards rendered (acceptable for 15 characters). Virtual scrolling deferred per Sr Godot Specialist recommendation.

**Problem:**
- Current roster renders ALL character cards (15 for Premium, 50 for Subscription)
- On older devices (iPhone 8/A11), 50 cards could cause scroll lag
- Hall of Fame (200 archived characters) would definitely need virtual scrolling

**When to implement:**
- **NOW (Week 16)**: If subscription tier launches (50 active characters)
- **DEFER (Week 17+)**: If subscription launch delayed or performance acceptable on target devices

**Solution Options:**

**Option A: Virtual Scroll Container (2-3 hours)**
- Custom ScrollContainer that only instances visible cards
- Reuse CharacterCard.tscn (architecture already supports this)
- Only render cards in viewport + 1-2 buffer cards above/below
- Example: Godot's ItemList uses this pattern

**Option B: Godot ItemList Widget (1-2 hours, simpler)**
- Replace VBoxContainer with ItemList
- ItemList has built-in virtual scrolling
- Tradeoff: Less visual customization than custom cards
- Would need to redesign CharacterCard as ItemList entry

**Option C: Paginated Roster (1 hour, quick fix)**
- Show 10 characters per page with Previous/Next buttons
- Simple to implement, no performance concerns
- Tradeoff: Worse UX than scrolling (extra taps)

**Recommendation from Sr Godot Specialist:**
> "Defer virtual scrolling until subscription tier launches. If launching now, use Option A (custom virtual scroll). The CharacterCard.tscn architecture makes this straightforward - just change the container logic."

**Testing:**
- Use debug helper `create_mock_characters.gd` to create 50 characters
- Test scroll performance on iPhone 8 (A11 chip)
- If FPS drops below 55, implement virtual scrolling
- If FPS stays above 55, defer to Week 17

**Priority:** LOW (defer unless subscription launching in Week 16)

---

## Testing Requirements

**Manual QA with Debug Menu:**
- [ ] Test FREE tier slot limit (3 slots)
- [ ] Test PREMIUM tier slot limit (15 slots)
- [ ] Test SUBSCRIPTION tier slot limit (50 slots)
- [ ] Test tier upgrade flow (FREE → PREMIUM keeps characters)
- [ ] Test slot pack purchases (PREMIUM +5, +25)
- [ ] Test fresh account at each tier
- [ ] Test full reset (nuclear option)

**Automated Tests:**
- [ ] IAP receipt validation
- [ ] Tier upgrade state management
- [ ] Slot pack purchase accounting

---

## Notes

**Week 15 Completion Status (UPDATED 2025-11-16):**
- ✅ Phase 1: Hub/Scrapyard (complete)
- ✅ Phase 2: Character Creation (complete + QA fixes)
- ✅ Phase 3: Character Roster (complete - reusable components, details panel, expert review)
- ⏸️ Phase 4: First-Run Flow (deferred to Week 17)
- ⏸️ Phase 5: Post-Run Flow (deferred to Week 17)

**Week 16 Focus:**
1. Debug tooling (enable QA testing) - Priority 1
2. IAP integration (monetization live) - Priority 2
3. Meta Progression (decide: Week 16 or defer to Week 17) - Priority 3
4. Virtual Scrolling (if subscription tier launches) - Priority 4 (technical debt)

---

**Created:** 2025-11-16
**Next Review:** Week 16 planning session
