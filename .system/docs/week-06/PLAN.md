# Week 6 Plan: Data Persistence + Health System Improvements

**Duration:** Week 6
**Main Theme:** Local save system for service state persistence
**Secondary Theme:** Continuous process improvement

## Overview

Week 6 has dual objectives:
1. **Primary:** Implement local data persistence for Week 5 services
2. **Secondary:** Enhance health enforcement system based on Week 5 learnings

Both objectives run in parallel, with health improvements implemented incrementally each day.

---

## Daily Breakdown

### Day 1: Save System Foundation + Native Class Checker

**Main Work: Save System Architecture**

**Deliverable:** `scripts/systems/save_system.gd`

**Features:**
- Godot ConfigFile-based save system
- Save file versioning
- Corruption detection and recovery
- Atomic writes (write to temp, rename)
- Multiple save slot support

**API:**
```gdscript
# SaveSystem (autoload)
func save_game(slot: int = 0) -> SaveResult
func load_game(slot: int = 0) -> LoadResult
func has_save(slot: int = 0) -> bool
func delete_save(slot: int = 0) -> bool
func get_save_metadata(slot: int = 0) -> SaveMetadata
```

**File structure:**
```
user://saves/
  ├── save_0.cfg        # Primary save slot
  ├── save_0.cfg.bak    # Backup (previous version)
  ├── save_1.cfg        # Additional slots...
  └── metadata.json     # Save slot metadata
```

**Testing:**
- Create `scripts/tests/save_system_test.gd`
- Test save/load cycle
- Test corruption recovery
- Test version migration
- Test atomic writes

**Health Improvement: Native Class Checker**

**Time:** 30 minutes
**Deliverable:** `.system/validators/native_class_checker.py`
**Integration:** Add to pre-commit hooks (blocking)

---

### Day 2: Service Serialization + API Consistency Checker

**Main Work: Service State Serialization**

**Update all Week 5 services to support persistence:**

**BankingService:**
```gdscript
func serialize() -> Dictionary:
    return {
        "version": 1,
        "balances": balances.duplicate(),
        "tier": current_tier,
        "timestamp": Time.get_unix_time_from_system()
    }

func deserialize(data: Dictionary) -> void:
    if data.get("version", 0) != 1:
        GameLogger.warning("BankingService: Unknown save version", data)
        return

    balances = data.get("balances", {"scrap": 0, "premium": 0})
    current_tier = data.get("tier", UserTier.FREE)

    currency_loaded.emit()
```

**ShopRerollService:**
```gdscript
func serialize() -> Dictionary:
    return {
        "version": 1,
        "game_day": _current_state.game_day,
        "reroll_count": _current_state.reroll_count,
        "timestamp": Time.get_unix_time_from_system()
    }

func deserialize(data: Dictionary) -> void:
    if data.get("version", 0) != 1:
        GameLogger.warning("ShopRerollService: Unknown save version", data)
        return

    _current_state.game_day = data.get("game_day", "")
    _current_state.reroll_count = data.get("reroll_count", 0)

    # Auto-reset if day changed
    var today = _get_game_day()
    if _current_state.game_day != today:
        _reset_for_new_day(today)
```

**RecyclerService:**
- No persistent state needed (stateless service)
- Implement serialize/deserialize for API consistency (returns empty dict)

**Testing:**
- Update all service tests to test serialization
- Test save→quit→load→verify state
- Test version migration

**Health Improvement: Service API Consistency Checker**

**Time:** 45 minutes
**Deliverable:** `.system/validators/service_api_checker.py`
**Requirements enforced:**
- All services have `reset()` method
- All services have `serialize()` method (Week 6+)
- All services have `deserialize()` method (Week 6+)

---

### Day 3: Integrated Save Flow + Integration Test Checker

**Main Work: End-to-End Save System**

**Create SaveManager coordinator:**

`scripts/systems/save_manager.gd`

```gdscript
extends Node
## SaveManager - Coordinates saving/loading across all services

signal save_started()
signal save_completed(success: bool)
signal load_started()
signal load_completed(success: bool)

func save_all_services(slot: int = 0) -> bool:
    save_started.emit()

    var save_data = {
        "version": 1,
        "timestamp": Time.get_unix_time_from_system(),
        "services": {
            "banking": BankingService.serialize(),
            "shop_reroll": ShopRerollService.serialize(),
            "recycler": RecyclerService.serialize(),
        }
    }

    var result = SaveSystem.save_game(save_data, slot)
    save_completed.emit(result.success)

    return result.success

func load_all_services(slot: int = 0) -> bool:
    load_started.emit()

    var result = SaveSystem.load_game(slot)
    if not result.success:
        load_completed.emit(false)
        return false

    var save_data = result.data

    # Deserialize all services
    if save_data.has("services"):
        var services = save_data.services

        if services.has("banking"):
            BankingService.deserialize(services.banking)

        if services.has("shop_reroll"):
            ShopRerollService.deserialize(services.shop_reroll)

        if services.has("recycler"):
            RecyclerService.deserialize(services.recycler)

    load_completed.emit(true)
    return true

func auto_save() -> void:
    GameLogger.info("Auto-saving game...")
    save_all_services(0)
```

**Auto-save triggers:**
- Every 5 minutes (Timer node)
- On currency changes (listen to service signals)
- On game exit (via `_notification(NOTIFICATION_WM_CLOSE_REQUEST)`)

**Testing:**
- Create `scripts/tests/save_integration_test.gd`
- Test complete save→load→verify flow
- Test auto-save behavior
- Test save corruption recovery
- Test cross-service state consistency

**Health Improvement: Integration Test Checker**

**Time:** 20 minutes
**Deliverable:** `.system/validators/integration_test_checker.py`
**Trigger:** Remind when 3+ services exist without integration tests

---

### Day 4: Save File Migration + Autoload Static Checker

**Main Work: Version Migration System**

**Handle save file version upgrades:**

`scripts/systems/save_migrator.gd`

```gdscript
extends Node
## SaveMigrator - Handles save file version migrations

const CURRENT_VERSION = 1

func migrate_save_data(data: Dictionary) -> Dictionary:
    var version = data.get("version", 0)

    if version == CURRENT_VERSION:
        return data  # No migration needed

    GameLogger.info("Migrating save from v%d to v%d" % [version, CURRENT_VERSION])

    # Apply migrations in sequence
    if version < 1:
        data = _migrate_0_to_1(data)
        version = 1

    # Future migrations:
    # if version < 2:
    #     data = _migrate_1_to_2(data)
    #     version = 2

    data["version"] = CURRENT_VERSION
    return data

func _migrate_0_to_1(data: Dictionary) -> Dictionary:
    # Example: Week 5 → Week 6 migration
    # Add default values for new fields
    if not data.has("services"):
        data["services"] = {}

    if not data["services"].has("banking"):
        data["services"]["banking"] = {
            "balances": {"scrap": 0, "premium": 0},
            "tier": 0  # UserTier.FREE
        }

    return data
```

**Testing:**
- Create `scripts/tests/save_migration_test.gd`
- Test migration from v0 to v1
- Test skipping migrations (already current version)
- Test multiple migrations in sequence

**Additional Work:**
- Add save/load UI indicators
- Add "unsaved changes" warning
- Add save slot selection menu

**Health Improvement: Autoload Static Checker**

**Time:** 30 minutes
**Deliverable:** `.system/validators/autoload_static_checker.py`
**Detection:** Warn when autoload scripts have static functions

---

### Day 5: Documentation + Coverage Checker

**Main Work: Week 6 Documentation**

**Create comprehensive documentation:**

`.system/docs/week-06/COMPLETION.md`
- Daily breakdown of all Week 6 work
- Save system design decisions
- Migration strategy
- Testing coverage
- Health system improvements implemented

`.system/docs/week-06/ARCHITECTURE.md`
- Save system architecture diagram
- File format specification
- Serialization patterns
- Migration system design
- Error handling strategy

**Additional Documentation:**

`.system/docs/SAVE-FORMAT.md`
- Complete save file format specification
- All service schemas
- Version history
- Migration guide

**Testing:**
- Final integration test pass
- Manual testing of all save flows
- Edge case testing (corrupted saves, old versions)

**Health Improvement: Documentation Coverage Checker**

**Time:** 20 minutes
**Deliverable:** `.system/validators/doc_coverage_checker.py`
**Reminder:** Create weekly documentation (non-blocking)

---

## Success Criteria

### Main Work (Data Persistence)
- ✅ All Week 5 services persist state across sessions
- ✅ Save/load cycle completes successfully
- ✅ Auto-save works reliably
- ✅ Corrupted saves recover gracefully
- ✅ Version migration works end-to-end
- ✅ All tests pass (unit + integration)

### Health System Improvements
- ✅ All 5 validators implemented and integrated
- ✅ Pre-commit hooks updated
- ✅ All existing code passes new validators
- ✅ Documentation complete for validator usage

---

## File Structure (End of Week 6)

```
scrap-survivor-godot/
├── scripts/
│   ├── systems/
│   │   ├── save_system.gd          # NEW: Core save/load
│   │   ├── save_manager.gd         # NEW: Service coordinator
│   │   └── save_migrator.gd        # NEW: Version migrations
│   ├── services/
│   │   ├── banking_service.gd      # UPDATED: +serialize/deserialize
│   │   ├── recycler_service.gd     # UPDATED: +serialize/deserialize
│   │   └── shop_reroll_service.gd  # UPDATED: +serialize/deserialize
│   └── tests/
│       ├── save_system_test.gd     # NEW
│       ├── save_integration_test.gd # NEW
│       ├── save_migration_test.gd  # NEW
│       └── banking_service_test.gd # UPDATED: +serialization tests
├── .system/
│   ├── validators/
│   │   ├── native_class_checker.py         # NEW
│   │   ├── service_api_checker.py          # NEW
│   │   ├── integration_test_checker.py     # NEW
│   │   ├── autoload_static_checker.py      # NEW
│   │   └── doc_coverage_checker.py         # NEW
│   └── docs/
│       ├── week-06/
│       │   ├── PLAN.md                 # This file
│       │   ├── HEALTH-IMPROVEMENTS.md  # Validator specs
│       │   ├── COMPLETION.md           # Week summary
│       │   └── ARCHITECTURE.md         # Save system design
│       └── SAVE-FORMAT.md              # Save format spec
└── .git/hooks/
    └── pre-commit                      # UPDATED: +5 new validators
```

---

## Code Quality Targets

### Test Coverage
- **Unit tests:** All new systems (SaveSystem, SaveManager, SaveMigrator)
- **Integration tests:** Complete save→load→verify flows
- **Migration tests:** All version upgrades
- **Target:** 100% critical path coverage

### Documentation
- **Architecture docs:** Save system design, rationale
- **API docs:** All public methods documented
- **Format specs:** Complete save file schema
- **Target:** New team member can understand in <1 hour

### Validator Coverage
- **Native class conflicts:** 100% detection
- **Service API consistency:** All services checked
- **Integration tests:** Reminded when 3+ services
- **Autoload statics:** All instances flagged
- **Documentation:** Weekly reminders

---

## Risks and Mitigations

### Risk 1: Save Corruption
**Impact:** Player loses progress
**Mitigation:**
- Atomic writes (write to temp, rename)
- Backup previous save (.bak file)
- Checksum validation
- Graceful fallback to backup

### Risk 2: Migration Failures
**Impact:** Old saves become unusable
**Mitigation:**
- Test migrations with real Week 5 saves
- Never delete old version during migration
- Log migration errors clearly
- Provide "start fresh" option

### Risk 3: Performance (Auto-save)
**Impact:** Game stutters during save
**Mitigation:**
- Save on separate thread (if needed)
- Limit auto-save frequency (5 min minimum)
- Skip auto-save if previous save still in progress

### Risk 4: Validator False Positives
**Impact:** Valid code rejected by validators
**Mitigation:**
- Non-blocking for low-priority validators
- Clear error messages with examples
- Easy to override if needed (git commit --no-verify)

---

## Time Estimates

| Day | Main Work | Health Work | Total |
|-----|-----------|-------------|-------|
| 1 | 3-4 hours | 30 min | 4 hours |
| 2 | 3-4 hours | 45 min | 4.5 hours |
| 3 | 3-4 hours | 20 min | 4 hours |
| 4 | 3-4 hours | 30 min | 4.5 hours |
| 5 | 2-3 hours | 20 min | 3 hours |
| **Total** | **14-19 hours** | **2.5 hours** | **20 hours** |

**Weekly capacity:** ~20-25 hours
**Buffer:** 0-5 hours for unexpected issues

---

## Dependencies

### External
- Godot 4.5+ (ConfigFile API)
- Python 3.8+ (validators)

### Internal
- Week 5 services complete ✅
- Testing infrastructure in place ✅
- Pre-commit hooks working ✅

---

## Next Steps (Week 7 Preview)

**Week 7: Inventory System + UI Foundation**

With persistence in place, Week 7 can focus on:
1. Player inventory management
2. Item equipment system
3. Basic UI for services (currency display, shop, recycling)
4. UI→Service integration patterns

Save system makes this possible by persisting:
- Inventory contents
- Equipped items
- Shop state
- Currency balances

---

## Conclusion

Week 6 delivers two critical foundations:
1. **Data Persistence:** Services retain state across sessions
2. **Process Improvement:** Enhanced health enforcement prevents issues

Both foundations enable rapid iteration in Week 7+ with high confidence.

**Philosophy:** Invest in tooling early, reap benefits later.

Let's build! 🚀
