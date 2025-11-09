# CharacterService Implementation Plan (Week 6 Days 4-5)

**Goal:** Port HybridCharacterService → Local-first CharacterService
**Scope:** Character management WITHOUT cloud sync
**Timeline:** 2 days (~5-7 hours)

---

## Philosophy: Start Simple, Add Complexity Later

### What We're Building (Week 6)

**Local-Only Character Management:**
- Create/read/update/delete characters
- Character validation
- Active character selection
- Persistence via SaveManager
- Character limits based on tier (from BankingService)

### What We're NOT Building (Yet)

**Cloud Sync (Week 7+):**
- Supabase integration
- Conflict resolution
- Offline queue
- Retry logic
- Cross-device sync

**Why Start Local:**
1. Simpler to test
2. Faster iteration
3. Works offline
4. Validates SaveSystem
5. Cloud becomes enhancement layer

---

## Day 4: CharacterService Core

### File Structure

```
scripts/services/character_service.gd
scripts/tests/character_service_test.gd
scenes/tests/character_service_test.tscn
```

### Data Model

**CharacterData Class:**
```gdscript
class CharacterData:
    ## Represents a player character instance

    var id: String                  # UUID (generated)
    var user_id: String             # Empty for local-only
    var name: String                # Display name (3-20 chars)
    var character_type: String      # "scavenger", "soldier", etc
    var level: int = 1              # Character level
    var experience: int = 0         # XP points
    var stats: Dictionary = {}      # Base stats
    var weapons: Array = []         # Equipped weapon IDs
    var currency: Dictionary = {    # Character-specific currency
        "scrap": 0,
        "premium": 0
    }
    var current_wave: int = 0       # Gameplay progress
    var highest_wave: int = 0       # Best wave reached
    var death_count: int = 0        # Times died
    var total_kills: int = 0        # Enemies killed
    var is_active: bool = false     # Currently selected?
    var created_at: String          # ISO timestamp
    var updated_at: String          # ISO timestamp
```

### Core API

**Character CRUD:**
```gdscript
class_name CharacterService
extends Node

# Signals
signal character_created(character: Dictionary)
signal character_updated(character: Dictionary)
signal character_deleted(character_id: String)
signal active_character_changed(character: Dictionary)

# Character management
func create_character(name: String, character_type: String) -> Dictionary:
    # Validate name
    # Check slot limits (tier-based)
    # Generate UUID
    # Create CharacterData
    # Mark as active if first character
    # Emit signal
    # Trigger auto-save
    # Return character dict

func get_character(character_id: String) -> Dictionary:
    # Find in _characters array
    # Return dict or empty dict

func update_character(character_id: String, updates: Dictionary) -> bool:
    # Find character
    # Apply updates
    # Update updated_at timestamp
    # Emit signal
    # Trigger auto-save
    # Return success

func delete_character(character_id: String) -> bool:
    # Find character
    # Remove from array
    # If was active, select first remaining
    # Emit signal
    # Trigger auto-save
    # Return success

func list_characters() -> Array:
    # Return all characters
    # Sorted by created_at (newest first)

# Active character management
func set_active_character(character_id: String) -> bool:
    # Deactivate current active
    # Set new active
    # Emit signal
    # Trigger auto-save
    # Return success

func get_active_character() -> Dictionary:
    # Return active character or empty dict

# Validation
func validate_character_name(name: String) -> bool:
    # Length check (3-20 chars)
    # Alphanumeric + spaces + hyphens only
    # No leading/trailing spaces
    # Not reserved names ("admin", "system", etc)
    # No profanity (simple list)
    # Return valid or not

func get_character_slot_limit() -> int:
    # Query BankingService.current_tier
    # FREE: 2 slots
    # PREMIUM: 5 slots
    # SUBSCRIPTION: 10 slots
    # Return limit

# Persistence (implements SaveableService interface)
func serialize() -> Dictionary:
    return {
        "version": 1,
        "characters": _characters_to_dicts(),
        "active_character_id": _active_character_id,
        "timestamp": Time.get_unix_time_from_system()
    }

func deserialize(data: Dictionary) -> void:
    if data.get("version") != 1:
        push_warning("CharacterService: Unknown save version")
        return

    _characters = _dicts_to_characters(data.get("characters", []))
    _active_character_id = data.get("active_character_id", "")

    # Emit signal for active character (UI update)
    if _active_character_id:
        character_loaded.emit(get_active_character())

func reset() -> void:
    _characters.clear()
    _active_character_id = ""
```

### Internal State

```gdscript
# Private state
var _characters: Array[CharacterData] = []
var _active_character_id: String = ""

# Constants
const NAME_MIN_LENGTH = 3
const NAME_MAX_LENGTH = 20
const RESERVED_NAMES = ["admin", "system", "moderator", "god"]
const PROFANITY_LIST = ["badword1", "badword2"]  # Minimal for now
```

### Helper Methods

```gdscript
# UUID generation (simple version for local-only)
func _generate_uuid() -> String:
    return "%s-%s-%s-%s" % [
        _random_hex(8),
        _random_hex(4),
        _random_hex(4),
        _random_hex(12)
    ]

func _random_hex(length: int) -> String:
    var chars = "0123456789abcdef"
    var result = ""
    for i in range(length):
        result += chars[randi() % chars.length()]
    return result

# Character conversion
func _character_to_dict(char: CharacterData) -> Dictionary:
    return {
        "id": char.id,
        "user_id": char.user_id,
        "name": char.name,
        "character_type": char.character_type,
        "level": char.level,
        "experience": char.experience,
        "stats": char.stats.duplicate(),
        "weapons": char.weapons.duplicate(),
        "currency": char.currency.duplicate(),
        "current_wave": char.current_wave,
        "highest_wave": char.highest_wave,
        "death_count": char.death_count,
        "total_kills": char.total_kills,
        "is_active": char.is_active,
        "created_at": char.created_at,
        "updated_at": char.updated_at
    }

func _dict_to_character(data: Dictionary) -> CharacterData:
    var char = CharacterData.new()
    char.id = data.get("id", "")
    char.user_id = data.get("user_id", "")
    char.name = data.get("name", "")
    char.character_type = data.get("character_type", "scavenger")
    char.level = data.get("level", 1)
    char.experience = data.get("experience", 0)
    char.stats = data.get("stats", {})
    char.weapons = data.get("weapons", [])
    char.currency = data.get("currency", {"scrap": 0, "premium": 0})
    char.current_wave = data.get("current_wave", 0)
    char.highest_wave = data.get("highest_wave", 0)
    char.death_count = data.get("death_count", 0)
    char.total_kills = data.get("total_kills", 0)
    char.is_active = data.get("is_active", false)
    char.created_at = data.get("created_at", "")
    char.updated_at = data.get("updated_at", "")
    return char
```

### Character Types (from original)

```gdscript
# Character type templates (from CHARACTER_TYPES config)
const CHARACTER_TYPES = {
    "scavenger": {
        "name": "Scavenger",
        "base_stats": {
            "max_health": 100,
            "movement_speed": 200,
            "starting_weapon": "pistol",
            "luck": 15
        }
    },
    "soldier": {
        "name": "Soldier",
        "base_stats": {
            "max_health": 150,
            "movement_speed": 180,
            "starting_weapon": "rifle",
            "luck": 5
        }
    },
    "engineer": {
        "name": "Engineer",
        "base_stats": {
            "max_health": 80,
            "movement_speed": 190,
            "starting_weapon": "wrench",
            "luck": 10
        }
    }
}
```

### Time Estimate: 3-4 hours

**Breakdown:**
- Character data model: 30 min
- CRUD operations: 1.5h
- Validation logic: 45 min
- Serialization: 30 min
- Testing/debugging: 30-45 min

---

## Day 5: Tests + Integration

### Test Coverage

**File:** `scripts/tests/character_service_test.gd`

**Test Functions:**
```gdscript
func test_initial_state()
    # No characters
    # No active character
    # Clean state

func test_create_character()
    # Create valid character
    # Verify UUID generated
    # Verify timestamps
    # Verify default values
    # Signal emitted

func test_create_multiple_characters()
    # Create 3 characters
    # Verify list_characters()
    # Verify count

func test_character_slot_limits()
    # FREE tier: create 2 chars (success), 3rd fails
    # PREMIUM tier: create 5 chars (success), 6th fails
    # SUBSCRIPTION tier: create 10 chars (success)

func test_name_validation()
    # Valid names pass
    # Too short (< 3) fail
    # Too long (> 20) fail
    # Invalid chars fail
    # Reserved names fail
    # Profanity fails

func test_active_character_management()
    # First character auto-active
    # Switch active character
    # Active character signal
    # Get active character

func test_update_character()
    # Update name
    # Update level/xp
    # Update stats
    # Update currency
    # Verify updated_at changes

func test_delete_character()
    # Delete character
    # Verify removed from list
    # Active character auto-selects
    # Signal emitted

func test_serialization()
    # Create characters
    # Serialize
    # Reset
    # Deserialize
    # Verify all data restored

func test_save_load_integration()
    # Create characters
    # SaveManager.save_all_services()
    # Reset service
    # SaveManager.load_all_services()
    # Verify characters restored
```

### Integration Tests

**Cross-Service Testing:**
```gdscript
func test_character_specific_currency()
    # Create 2 characters
    # Character 1: add scrap
    # Character 2: add scrap
    # Verify separate balances
    # Switch active character
    # Verify currency follows character

func test_character_tier_integration()
    # BankingService.set_tier(FREE)
    # Create 2 characters (success)
    # Try 3rd character (fail)
    # BankingService.set_tier(PREMIUM)
    # Create 3 more characters (success)
    # Verify tier limit enforcement
```

### Time Estimate: 2-3 hours

**Breakdown:**
- Unit tests: 1.5h
- Integration tests: 1h
- Edge case testing: 30 min

---

## Integration with Existing Systems

### SaveManager Integration

**CharacterService registers with SaveManager:**
```gdscript
# SaveManager already knows how to save CharacterService
# Just needs to be in the services list

# In SaveManager:
var SERVICES = [
    "BankingService",
    "ShopRerollService",
    "RecyclerService",
    "CharacterService"  # Add this
]
```

**Auto-save triggers:**
- Character created
- Character updated
- Character deleted
- Active character changed

### BankingService Integration

**CharacterService queries BankingService for tier:**
```gdscript
func get_character_slot_limit() -> int:
    var tier = BankingService.current_tier
    match tier:
        BankingService.UserTier.FREE:
            return 2
        BankingService.UserTier.PREMIUM:
            return 5
        BankingService.UserTier.SUBSCRIPTION:
            return 10
        _:
            return 2  # Default to FREE
```

**Future: Character-specific currency (Week 7)**
- Each character has own scrap/premium balance
- BankingService tracks per-character
- Requires BankingService update

---

## Success Criteria

### Day 4 Complete When:
- [x] CharacterService file created
- [x] CharacterData class defined
- [x] CRUD operations implemented
- [x] Name validation working
- [x] Slot limits enforced
- [x] Serialization working
- [x] Code passes all validators

### Day 5 Complete When:
- [x] All unit tests passing
- [x] Integration tests passing
- [x] Save/load verified
- [x] Cross-service tests passing
- [x] Edge cases handled
- [x] Documentation updated

### Week 6 Complete When:
- [x] CharacterService in production
- [x] Can create/manage characters
- [x] Characters persist across sessions
- [x] Tier limits enforced
- [x] All tests green
- [x] Ready for inventory system (Week 7)

---

## Deferred Features (Future Weeks)

### Week 7+: Cloud Sync
- Supabase character table
- Sync local → cloud
- Conflict resolution
- Offline queue

### Week 8+: Character Progression
- Level up system
- Experience calculation
- Skill trees
- Stat upgrades

### Week 9+: Character Equipment
- Equipment slots
- Weapon instances
- Armor system
- Accessory management

### Week 10+: Character Stats
- Combat stats
- Derived stats
- Buff/debuff system
- Status effects

---

## Risk Mitigation

### Potential Issues:

**1. UUID Collisions**
- **Risk:** Random UUIDs might collide
- **Mitigation:** Use timestamp + random for uniqueness
- **Severity:** Low (very rare)

**2. Character Limits**
- **Risk:** Users hit limits, frustrated
- **Mitigation:** Clear error messages, upgrade prompts
- **Severity:** Low (by design)

**3. Name Validation**
- **Risk:** Profanity filter too strict/too loose
- **Mitigation:** Simple list for now, improve later
- **Severity:** Low (can iterate)

**4. Save File Size**
- **Risk:** Many characters = large saves
- **Mitigation:** Monitor in testing, optimize if needed
- **Severity:** Low (10 characters ~2KB)

---

## Documentation Updates

### Files to Update:

1. **docs/godot/services-guide.md**
   - Add CharacterService section
   - Document API
   - Provide examples

2. **docs/migration/week6-days4-5-completion.md**
   - Create completion report
   - Document decisions
   - Report metrics

3. **README.md**
   - Update progress (Week 6 complete)

4. **.system/docs/week-06/COMPLETION.md**
   - Final Week 6 report
   - All 5 days documented

---

## Validation

**Pre-commit will check:**
- ✅ Native class name (no conflicts)
- ✅ Service API (has reset/serialize/deserialize)
- ✅ Test methods (call real APIs)
- ✅ All tests pass

**Manual validation:**
- Create character → save → quit → load → verify
- Test tier limits at each tier level
- Test name validation edge cases
- Verify signals emit correctly

---

## Next Steps After CharacterService

**Week 7 Preview:**
1. Supabase client setup
2. Cloud character sync
3. Inventory system (depends on characters)
4. Equipment basics

**Dependencies Unlocked:**
- ✅ Characters enable inventory
- ✅ Characters enable progression
- ✅ Characters enable equipment
- ✅ Characters enable stats

🤖 Generated with [Claude Code](https://claude.com/claude-code)
