# Lesson 45: Single Source of Truth for Service Data

**Date:** 2025-11-28
**Context:** BankingService currency not syncing with CharacterService
**Hours Lost:** ~4 hours debugging

## The Problem

Currency data was stored in TWO places:
1. `CharacterService.characters[id].starting_currency` (per-character)
2. `BankingService.balances` (global singleton)

These were never synchronized. Debug menu updated CharacterService, but Shop UI read from BankingService (always showed 0).

## Root Cause

BankingService was designed as an independent service with its own `serialize()`/`deserialize()`. It never listened to `CharacterService.active_character_changed` signal.

## The Fix

**Single Source of Truth Pattern:**
- CharacterService stores currency (source of truth)
- BankingService becomes a "view" that syncs via signals
- Write-through: mutations update CharacterService immediately
- Load order: CharacterService loads first, BankingService syncs via signal

```gdscript
# BankingService connects to CharacterService
func _connect_to_character_service() -> void:
    CharacterService.active_character_changed.connect(_on_active_character_changed)
    CharacterService.state_loaded.connect(_on_character_service_loaded)

func _on_active_character_changed(character_id: String) -> void:
    _sync_from_character(character_id)  # Load character's currency

func add_currency(type: CurrencyType, amount: int) -> bool:
    # ... update balances ...
    _sync_to_character()  # Write-through to CharacterService
```

## Prevention Checklist

Before creating a new service that stores data also stored elsewhere:

- [ ] Is there already a source of truth for this data?
- [ ] Should this service own the data or view it?
- [ ] If viewing, what signals trigger sync?
- [ ] What's the load order dependency?
- [ ] Are there write-through requirements?

## Key Principle

> **One service owns each piece of data. Other services subscribe to changes.**

Don't duplicate data across services. Use signals for reactive updates.

## Related Patterns

- **Observer Pattern**: Services subscribe to state changes
- **Write-Through Cache**: Mutations propagate to source immediately
- **Dependency Ordering**: Load order matters when using signals
