# SaveMigrator: Deferred Until Needed

**Decision Date:** November 9, 2025
**Status:** DEFERRED
**Rationale:** YAGNI (You Ain't Gonna Need It)

---

## The Decision

**We are NOT building SaveMigrator in Week 6 Days 4-5.**

Instead, we're building **CharacterService** to validate our save system with real usage.

---

## Why Skip SaveMigrator?

### 1. No Migration Needs Exist

**Current State:**
- Save format version: 1
- No previous versions to migrate from
- No v2 format designed yet
- No breaking changes planned

**Reality Check:**
- Building migration code for migrations that don't exist
- Solving a problem we don't have
- Classic speculative engineering

### 2. YAGNI Principle

**You Ain't Gonna Need It** - one of the core principles of agile development

**The Trap:**
```
"We'll need migrations eventually, so let's build it now..."
```

**The Reality:**
- Maybe we will, maybe we won't
- If we do, we'll know EXACTLY what we need
- Building now = guessing future requirements
- Code written today may be wrong for tomorrow's needs

**Better Approach:**
- Build when we have concrete migration to perform
- Design system based on real v1 → v2 needs
- Less code to maintain
- Fewer assumptions to unwind

### 3. SaveSystem Already Migration-Ready

**We already have the foundation:**

```gdscript
# SaveSystem has version field
[metadata]
version=1  # Ready for future migrations

# Each service has version field
[services.banking]
version=1  # Service-level versioning

# SaveSystem can handle unknown versions
func load_game(slot: int) -> LoadResult:
    var version = data.get("version", 0)
    if version != CURRENT_VERSION:
        push_warning("Save file version mismatch")
        # Future: call SaveMigrator here
```

**When we need migration:**
1. Add migration logic to `_load_save_file()`
2. Call migration function before deserializing
3. Ship it

**No pre-building needed** - the hooks are already there.

### 4. Real Work Waiting

**CharacterService is more valuable right now:**

**Immediate Benefits:**
- Core gameplay feature (manage characters)
- Validates save system with complex data
- Enables character-specific inventory later
- Unlocks equipment system
- Enables character progression

**SaveMigrator Benefits:**
- None (until we have migrations)

**Opportunity Cost:**
- 4-6 hours building SaveMigrator
- vs 4-6 hours building CharacterService
- CharacterService delivers real value NOW

---

## When Will We Build SaveMigrator?

### Trigger Conditions

Build SaveMigrator when ANY of these happen:

1. **Save Format Changes**
   - Add new service to save file
   - Change service data structure
   - Add new metadata fields

2. **Breaking Changes**
   - Rename service fields
   - Change data types
   - Remove old features

3. **Data Model Evolution**
   - Character stats change
   - Inventory structure changes
   - Equipment system additions

### Likely Timeline

**Week 8-10:** Combat system + progression
- Adding experience/level systems
- New character stats
- Equipment slots
- Skill trees

**This is when we'll need v2 format** - and that's when we build the migrator.

---

## What We'll Build Later

### SaveMigrator (Future Implementation)

**File:** `scripts/systems/save_migrator.gd`

**Design:**
```gdscript
class_name SaveMigrator
## Handles save file version migrations

const CURRENT_VERSION = 2  # When we implement

# Migration chain
static func migrate_save_data(data: Dictionary) -> Dictionary:
    var version = data.get("version", 0)

    if version == CURRENT_VERSION:
        return data  # Already current

    # Apply migrations sequentially
    if version < 1:
        data = _migrate_0_to_1(data)

    if version < 2:
        data = _migrate_1_to_2(data)  # Real migration!

    data["version"] = CURRENT_VERSION
    return data

# Real migration based on actual changes
static func _migrate_1_to_2(data: Dictionary) -> Dictionary:
    # Example: Add character equipment slots (Week 8)
    if data.has("services") and data.services.has("character"):
        for character in data.services.character.characters:
            if not character.has("equipment_slots"):
                character["equipment_slots"] = {
                    "weapon": null,
                    "armor": null,
                    "accessory": null
                }

    return data
```

**This will be EASY to build because:**
- We'll know exact changes needed
- We'll have test data in v1 format
- We'll know edge cases from real usage
- No guessing required

---

## Benefits of Waiting

### 1. Better Design

**Building now:**
- Guess at migration needs
- Generic, flexible system
- Complex, hard to maintain
- Probably wrong for actual needs

**Building later:**
- Know exact requirements
- Specific, simple solution
- Easy to understand
- Exactly right for actual needs

### 2. Less Code to Maintain

**SLOC Saved:** ~150-200 lines (migration system)

**Maintenance Burden:**
- Tests for unused code
- Documentation for unused feature
- Updates when save system changes
- Mental overhead

**Cost:** 4-6 hours initial + ongoing maintenance

**Benefit:** None until migrations needed

### 3. Faster Iteration

**Without SaveMigrator:**
- Change save format freely
- No migration tests to update
- No backward compatibility concerns
- Fast development

**Downside:**
- None (we're still in development)
- No users with old saves yet
- Can break save format at will

### 4. Validation First

**CharacterService proves SaveSystem works:**

**What we'll learn:**
- Does serialization handle complex data?
- Are save files performant?
- Do nested dictionaries work?
- Is error handling sufficient?

**If SaveSystem has issues:**
- Fix them BEFORE building migrations
- Migration system builds on proven foundation
- No wasted work

---

## Alternative Considered

### "Build SaveMigrator as Practice"

**Argument:**
> "We'll need it eventually, good learning experience, demonstrates thoroughness"

**Counter-Argument:**
- Learning for learning's sake → personal project
- We're building a game, not infrastructure demo
- Thorough = solving real problems well
- YAGNI is a professional discipline

**Better Learning:**
- Build CharacterService (real complexity)
- Learn about nested data structures
- Discover edge cases in SaveSystem
- Apply lessons to future migration system

---

## Decision Framework

### Build Infrastructure When:

✅ **Solving current problem**
- SaveSystem needed NOW
- SaveManager needed NOW
- Validators prevent current bugs

✅ **2+ real examples exist**
- Service API checker (5 services need it)
- Test validator (6 test files need it)

✅ **Preventing known issue**
- Native class checker (Logger taught us)
- Test method validator (test audit taught us)

❌ **Might need someday**
- SaveMigrator (no migrations yet)
- Version control for saves (no versions yet)
- Save conflict resolution (no multiplayer yet)

---

## Communication Plan

### For Future Sessions

**If AI suggests SaveMigrator:**
> "We decided to defer SaveMigrator until we have actual migration needs. See .system/docs/week-06/SAVEMIGRATOR-DECISION.md for rationale. Let's focus on CharacterService instead."

### For Team Members

**If someone asks "where's the migration system?":**
> "We're following YAGNI - building it when we need it (Week 8-10 when save format changes). Currently on v1 with no previous versions to migrate from."

### For Documentation

**SaveSystem docs mention:**
> "Future: SaveMigrator will handle version migrations when needed. Currently on v1 with migration hooks in place but not implemented."

---

## Success Criteria

### We Made the Right Decision If:

✅ CharacterService ships in Week 6
✅ Characters work with SaveSystem
✅ No migration needs arise in Week 6-7
✅ When we build SaveMigrator (Week 8+), it's straightforward

### We Made the Wrong Decision If:

❌ We need migrations in Week 6
❌ Save format changes unexpectedly
❌ CharacterService reveals SaveSystem flaws requiring migration

**Likelihood of Wrong:** Very low (~5%)

**Mitigation:** Can build SaveMigrator in 1-2 hours when needed

---

## Summary

**Skip SaveMigrator (Week 6 Days 4-5)**
**Build CharacterService instead**
**Add SaveMigrator when we have v2 format (Week 8-10)**

**Principle:** Solve real problems, not hypothetical ones

**Outcome:** Faster progress, less code, better design when we need it

🤖 Generated with [Claude Code](https://claude.com/claude-code)
