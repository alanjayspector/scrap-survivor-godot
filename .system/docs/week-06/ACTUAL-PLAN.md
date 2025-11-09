# Week 6: Actual Execution Plan

**Status:** Days 1-3 ✅ Complete | Days 4-5 📋 Planned
**Theme:** Local-First Save System + CharacterService

---

## Overview

Week 6 took a **hybrid approach** between two competing plans:

1. **Original Migration Plan**: Supabase + CharacterService
2. **Custom Week 6 Plan**: SaveSystem + Health improvements

**Actual Execution:** Built local save system FIRST, then use it for CharacterService (skip cloud for now)

**Strategic Rationale:**
- Local-first enables offline gameplay
- Simpler to test and iterate
- CharacterService validates save system with real usage
- Supabase becomes enhancement layer (Week 7+)

---

## Days 1-3: Save System + Quality Infrastructure ✅

### Day 1: SaveSystem Foundation

**Deliverable:** `scripts/systems/save_system.gd`

**Features:**
- ConfigFile-based local storage
- Multiple save slots (0-9)
- Atomic writes (corruption-safe)
- Save metadata tracking
- Comprehensive tests

**Quality Tool:** Native Class Checker
- Prevents Godot native class conflicts
- BLOCKING validator

---

### Day 2: Service Serialization

**Updated Services:**
- BankingService → serialize/deserialize
- ShopRerollService → serialize/deserialize
- RecyclerService → serialize/deserialize (stateless)

**Quality Tool:** Service API Consistency Checker
- Enforces required methods
- Detects naming inconsistencies

---

### Day 3: SaveManager + Test Quality

**Deliverable:** `scripts/systems/save_manager.gd`

**Features:**
- Coordinates all service saves
- Auto-save every 5 minutes
- Unsaved changes tracking
- Comprehensive integration tests

**Quality Tools:**
- Test Method Validator (BLOCKING) - prevents calling non-existent APIs
- User Story Validator (non-blocking) - tracks test coverage

**Crisis Averted:** Found and fixed 10 critical test bugs during audit

---

## Days 4-5: CharacterService (Local-First) 📋

**Goal:** Port HybridCharacterService with local persistence (NO Supabase yet)

### Day 4: CharacterService Core

**Deliverable:** `scripts/services/character_service.gd`

**Scope:** Local-only character management

**Features:**
```gdscript
class CharacterService:
    # Character CRUD (local-only)
    func create_character(data: Dictionary) -> Dictionary
    func get_character(character_id: String) -> Dictionary
    func update_character(character_id: String, data: Dictionary) -> bool
    func delete_character(character_id: String) -> bool
    func list_characters() -> Array

    # Active character management
    func set_active_character(character_id: String) -> bool
    func get_active_character() -> Dictionary

    # Character validation
    func validate_character_name(name: String) -> bool
    func validate_character_data(data: Dictionary) -> bool

    # Persistence (uses SaveManager)
    func serialize() -> Dictionary
    func deserialize(data: Dictionary) -> void
    func reset() -> void
```

**Data Model:**
```gdscript
class CharacterData:
    var id: String              # UUID
    var user_id: String         # User ID (empty for local-only)
    var name: String            # Display name
    var level: int              # Character level
    var experience: int         # XP
    var stats: Dictionary       # Base stats
    var equipment: Array        # Equipped items
    var inventory: Array        # Item IDs
    var created_at: String      # ISO timestamp
    var updated_at: String      # ISO timestamp
```

**Signals:**
```gdscript
signal character_created(character: Dictionary)
signal character_updated(character: Dictionary)
signal character_deleted(character_id: String)
signal active_character_changed(character: Dictionary)
```

**Integration:**
- Uses SaveManager for persistence
- Stores in SaveSystem under "services.character"
- No Supabase dependencies
- Ready for cloud sync later

**Time Estimate:** 3-4 hours

---

### Day 5: Character Tests + Polish

**Deliverable:** `scripts/tests/character_service_test.gd`

**Test Coverage:**
- Character creation/deletion
- Name validation
- Active character management
- Save/load persistence
- Multiple character support
- Data validation

**Integration Test:**
- Create character → Save → Load → Verify
- Test with BankingService (character-specific currency)
- Cross-service state consistency

**Polish:**
- Error handling
- Edge cases (missing data, invalid IDs)
- Performance (character list pagination)

**Time Estimate:** 2-3 hours

---

## What We're NOT Doing (Yet)

### Deferred to Week 7+:

**SaveMigrator:**
- **Why skip:** No v2 save format exists yet
- **When needed:** When we change save format (Week 8-10)
- **Rationale:** YAGNI - don't build unused infrastructure

**Supabase Setup:**
- **Why skip:** Local-first approach sufficient for now
- **When needed:** Week 7 (cloud sync layer)
- **Benefit:** Simpler testing, offline gameplay

**SyncService:**
- **Why skip:** Depends on Supabase
- **When needed:** Week 7 (after Supabase setup)
- **Strategy:** Build sync as enhancement, not requirement

**HybridCharacterService (full version):**
- **Doing:** Local-only character management
- **Skipping:** Cloud sync, conflict resolution
- **Rationale:** Get characters working locally first

---

## Strategic Decisions

### 1. Local-First Architecture

**Decision:** Build local save system before cloud sync

**Benefits:**
- Works offline
- Simpler to test
- Faster iteration
- No network dependencies
- Supabase becomes optional enhancement

**Trade-offs:**
- No cross-device sync (yet)
- Must add sync later
- More complex migration when adding cloud

**Verdict:** Worth it - enables rapid development

---

### 2. Skip SaveMigrator (For Now)

**Decision:** Don't build migration system until needed

**Rationale:**
- Currently on save version 1
- No migrations to perform
- Building unused code = waste
- Can add when v2 format is designed

**When to revisit:**
- Week 8-10 when gameplay expands
- When save format changes
- When we have real migration needs

---

### 3. CharacterService Before Inventory

**Decision:** Characters → Inventory (not in parallel)

**Rationale:**
- Characters are foundation
- Inventory depends on characters
- SaveSystem needs validation with complex data
- Sequential is clearer than parallel

---

## Week 6 Completion Criteria

- [x] SaveSystem implemented
- [x] All services serializable
- [x] SaveManager coordinating saves
- [x] Auto-save functional
- [x] Quality validators (4 new)
- [ ] CharacterService (local-only)
- [ ] Character tests passing
- [ ] Characters persist via SaveManager

**Progress:** 60% complete (Days 1-3 done)

---

## Time Summary

**Days 1-3:** 8 hours (actual)
**Days 4-5:** 5-7 hours (estimated)

**Total Week 6:** 13-15 hours (on track)

---

## Next Week Preview

### Week 7: Cloud Integration

**Theme:** Supabase + SyncService

**Goals:**
1. Supabase client setup
2. Cloud character sync
3. Conflict resolution
4. Offline-first sync strategy

**Builds on:**
- Week 6 local save system
- Week 6 CharacterService
- Ready to add cloud layer

---

## Lessons Applied

1. **YAGNI:** Don't build SaveMigrator until needed
2. **Validate Early:** CharacterService proves save system works
3. **Local-First:** Offline gameplay > cloud dependency
4. **Quality Infrastructure:** Validators prevent bugs architecturally
5. **Incremental:** Characters → Inventory → Combat (sequential)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
