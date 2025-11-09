# Scrap Survivor - Data Model Reference

**CRITICAL: READ THIS FIRST WHEN WORKING ON CHARACTER/INVENTORY/WORKSHOP FEATURES**

**Last Updated:** October 31, 2025
**Status:** ✅ CANONICAL REFERENCE - This is the source of truth

---

## Purpose

This document describes **exactly where and how data is stored** in Scrap Survivor. If you're an AI assistant working on this codebase, **read this document BEFORE making assumptions about data storage**.

---

## Storage Architecture: Hybrid Model

**Pattern:** LocalStorage (IndexedDB) + Supabase (PostgreSQL)

**Primary Storage:** LocalStorage (fast, offline-first)
**Backup Storage:** Supabase (sync, cross-device)
**Sync Strategy:** Background sync via `SyncService`

---

## 1. Character Data

### Location: Multiple Stores

Characters are **split across multiple storage locations**:

#### A. Character Instance (Core Data)

**Storage:** `LocalStorageService.STORES.CHARACTERS`
**Type:** `CharacterInstance` (see `src/types/models.ts`)
**Supabase Table:** `character_instances`

```typescript
interface CharacterInstance {
  id: string;
  user_id: string;
  character_type: string;
  name: string;
  level: number;
  experience: number;
  stats: CharacterStats; // JSONB in Supabase
  weapons: Weapon[]; // ⚠️ STORED HERE
  currency: number;
  workshopComponents: number; // ✅ Workshop components (simple currency like scrap)
  current_wave: number;
  highest_wave: number;
  death_count: number;
  total_kills: number;
  created_at: string;
  last_played: string;
  is_active: boolean;
}
```

**Key Fields:**

- `weapons: Weapon[]` - **Weapons are stored INSIDE the character object**
- `stats: CharacterStats` - All character stats (including inventory stats)

#### B. Inventory Items (Armor, Consumables, Trinkets)

**Storage:** `LocalStorageService.STORES.ITEMS`
**Type:** `InventoryItem` (see `src/types/items.ts`)
**Supabase Table:** NOT YET IMPLEMENTED (LocalStorage only for now)

```typescript
interface InventoryItem {
  id: string; // Unique instance ID
  character_id: string; // ⚠️ Links to character
  base_item_id: string; // Template ID
  name: string;
  description: string;
  type: ItemType; // 'armor' | 'consumable' | 'trinket'
  rarity: ItemRarity;
  stats: StatModifier[];
  durability: number;
  maxDurability: number;
  isCursed: boolean;
  tags: string[];
  level: number;
  xp: number;
}
```

**How to Retrieve:**

```typescript
// Get character
const character = await HybridCharacterService.getCharacter(characterId);

// Get character's items (armor, consumables, trinkets)
const items = await inventoryService.getCharacterInventory(characterId);

// COMBINED inventory = character.weapons + items
const fullInventory = [...character.weapons, ...items];
```

**⚠️ CRITICAL: Weapons vs Items**

- **Weapons:** Stored in `character.weapons` array
- **Items:** Stored separately in `ITEMS` store, retrieved via `inventoryService`
- **WHY?** Legacy design decision from early sprints
- **Workshop/Recycler:** Must query BOTH sources

---

## 2. Item Types

**Defined in:** `src/types/items.ts`

```typescript
export type ItemType = 'weapon' | 'armor' | 'consumable' | 'trinket';
```

**DO NOT invent other item types.** These are the ONLY four types.

**Special Types (excluded from workshop):**

- `minion` - May be added later, not currently implemented
- `blueprint` - Not an item type, different system

---

## 3. Weapons

### Storage

**Location:** `character.weapons` array in `CharacterInstance`
**Type:** `Weapon` (see `src/types/game.ts`)

```typescript
interface Weapon {
  instanceId?: string; // ⚠️ Unique instance ID (optional for backwards compatibility)
  id: string; // Template ID
  name: string;
  rarity: ItemRarity; // Power level - affects workshop costs, fusion limits (common/uncommon/rare/epic/legendary)
  isPremium: boolean; // User tier access control - determines if Free or Premium tier required
  durability: number;
  maxDurability: number;
  baseDamage: number;
  damageType?: DamageType; // Physical, energy, etc.
  baseRange: number;
  fireRate: number;
  projectileSpeed: number;
  ammoCount?: number;
  sprite: string;
  fuseTier?: number; // Fusion level (0 to maxFuseTier)
  maxFuseTier?: number; // Max fusion level (varies by rarity)
  hasMutagenAura?: boolean; // Has mutagen aura effect
  mutagenAuraSource?: string | null; // Source of mutagen aura
}
```

**How to Access:**

```typescript
const character = await HybridCharacterService.getCharacter(characterId);
const weapons = character.weapons; // Array of Weapon objects
```

**⚠️ Instance ID Normalization:**

- Old weapons may not have `instanceId`
- Use `ensureWeaponInstanceIds()` helper to normalize
- See `src/services/workshop/WeaponInstanceIdService.ts`

**🔑 Understanding isPremium vs rarity:**

These are **two independent fields** with different purposes:

| Field       | Purpose                        | Values                                            | Affects                                                     |
| ----------- | ------------------------------ | ------------------------------------------------- | ----------------------------------------------------------- |
| `isPremium` | User tier access control       | `true` or `false`                                 | Whether Free tier or Premium tier users can use this weapon |
| `rarity`    | Power level / workshop scaling | `common`, `uncommon`, `rare`, `epic`, `legendary` | Workshop repair costs, fusion tier limits, crafting costs   |

**Example:**

- `nano_swarm`: `isPremium: true`, `rarity: 'uncommon'` - Premium access required, but uncommon power level
- `hydraulic_hammer`: `isPremium: false`, `rarity: 'epic'` - Free tier can use, but epic power level (high workshop costs)

**Why both fields exist:**

- A Premium weapon can have low power (`nano_swarm` is uncommon rarity)
- A Free weapon can have high power (`hydraulic_hammer` is epic rarity)
- Premium status = monetization / user access
- Rarity = game balance / workshop economy

---

## 4. Workshop Resources

### Workshop Components (Local-First Migration - Phase 1 Complete)

**Storage:** `character.workshopComponents` in `CharacterInstance`
**Type:** `number` (simple currency like scrap)
**Supabase Table:** `character_instances.workshop_components` (INTEGER)

**Terminology:**

- Old name: "Blueprint Parts" (Supabase-based, per-template Record)
- New name: "Workshop Components" (Local storage-based, simple currency)
- Used for: Repair, Fusion, Crafting costs

**How to Access:**

```typescript
// ✅ Get total workshop components
const availableComponents = await localStorageService.getWorkshopComponents(characterId);

// Increment/decrement
await localStorageService.incrementWorkshopComponents(
  characterId,
  delta // positive to add, negative to subtract
);

// Set directly
await localStorageService.setWorkshopComponents(characterId, quantity);
```

**Migration Status:**

- ✅ Phase 1 Complete: Migrated to simple currency model
- ✅ Phase 2 Complete: Type definitions updated across codebase
- ✅ Phase 3 Complete: Workshop UI updated to read from LocalStorage

**Storage Details:**

```typescript
// Stored in character object as simple number
character.workshopComponents = 500; // Total available for all repairs
```

---

## 5. Services & How to Use Them

### HybridCharacterService

**File:** `src/services/HybridCharacterService.ts`

**Purpose:** CRUD operations for characters

```typescript
// Get character (includes weapons)
const character = await HybridCharacterService.getCharacter(characterId);

// Update character (including weapons)
await HybridCharacterService.updateCharacter(characterId, {
  weapons: updatedWeapons,
  currency: newCurrency,
});
```

**⚠️ Does NOT include items (armor/consumable/trinket)**

---

### InventoryService

**File:** `src/services/InventoryService.ts`

**Purpose:** CRUD operations for items (armor, consumables, trinkets)

```typescript
// Get all items for a character
const items = await inventoryService.getCharacterInventory(characterId);

// Add item
await inventoryService.addItemToCharacter(characterId, item);

// Remove item
await inventoryService.removeItemFromCharacter(characterId, itemId);
```

---

### WorkshopService (Current Implementation)

**File:** `src/services/WorkshopService.ts`

**Current State:** WEAPONS ONLY
**Needs Refactor:** To support all item types

**Current Methods:**

```typescript
// Repair weapon (weapons only)
await workshopService.repairWeaponDurability({
  userId,
  characterId,
  weaponInstanceId,
  templateId,
  rarity,
});

// Fuse weapons (weapons only)
await workshopService.fuseWeapons({
  userId,
  characterId,
  primaryWeaponInstanceId,
  secondaryWeaponInstanceId,
  templateId,
  rarity,
});
```

**⚠️ TODO:** Refactor to support items via `inventoryService`

---

## 6. How to Get Full Inventory

**Pattern for Workshop/Recycler/Inventory UI:**

```typescript
async function getFullInventory(characterId: string): Promise<{
  weapons: Weapon[];
  items: InventoryItem[];
  all: (Weapon | InventoryItem)[];
}> {
  // Get character (includes weapons)
  const character = await HybridCharacterService.getCharacter(characterId);

  // Get separate items (armor, consumables, trinkets)
  const items = await inventoryService.getCharacterInventory(characterId);

  return {
    weapons: character.weapons,
    items: items,
    all: [...character.weapons, ...items],
  };
}
```

**Use this pattern for:**

- Workshop repair tab (show all damaged items)
- Workshop fusion tab (show duplicate items)
- Recycler (show all recyclable items)
- Inventory screen (show complete inventory)

---

## 7. Auto-Active Inventory System

**Design Philosophy:** All items you own are active (no equip/unequip)

**How Stats Work:**

```typescript
// Character base stats
const baseStats = character.stats;

// Stats from weapons
const weaponStats = calculateStatsFromWeapons(character.weapons);

// Stats from items
const itemStats = calculateStatsFromItems(items);

// Final stats = base + weapons + items
const finalStats = combineStats(baseStats, weaponStats, itemStats);
```

**Implementation:** `src/services/statService.ts`

**All items contribute to stats automatically.**

---

## 8. Durability System

**All items have durability:**

- `durability: number` - Current HP
- `maxDurability: number` - Max HP

**Death Penalty:**

- When character dies, ALL items lose durability
- Items at 0 durability are destroyed
- Implementation: `ItemDurabilityService` (planned)

**Workshop Repair:**

- Restores durability to max
- Costs scrap + workshop components
- Currently weapons only, needs refactor for all items

---

## 9. Workshop Refactor Requirements

**Goal:** Support repair/fusion for ALL item types

**Current Problem:**

```typescript
// WorkshopService only looks here ❌
const weapons = character.weapons;
```

**Correct Implementation:**

```typescript
// Must look in BOTH places ✅
const weapons = character.weapons;
const items = await inventoryService.getCharacterInventory(characterId);

// Find item in either location
const allItems = [...weapons, ...items];
const targetItem = allItems.find((i) => i.instanceId === itemInstanceId || i.id === itemInstanceId);
```

**Item Type Validation:**

```typescript
const REPAIRABLE_TYPES: ItemType[] = ['weapon', 'armor', 'consumable', 'trinket'];
const EXCLUDED_TYPES = ['minion', 'blueprint']; // Not items, different systems
```

---

## 10. Quick Reference Checklist

**Before working on character/inventory features, verify:**

- [ ] Do I need weapons? → `character.weapons`
- [ ] Do I need items? → `inventoryService.getCharacterInventory(characterId)`
- [ ] Do I need both? → Query both sources
- [ ] Am I updating weapons? → Update `character.weapons` array, call `HybridCharacterService.updateCharacter()`
- [ ] Am I updating items? → Use `inventoryService.addItemToCharacter()` / `removeItemFromCharacter()`
- [ ] Do I need workshop components? → `localStorageService.getWorkshopComponents(characterId, templateId)`

---

## 11. Common Mistakes to Avoid

### ❌ WRONG: Assuming items are in character object

```typescript
const items = character.items; // ❌ Does not exist
```

### ✅ CORRECT: Query items separately

```typescript
const items = await inventoryService.getCharacterInventory(characterId); // ✅
```

---

### ❌ WRONG: Only checking weapons for workshop

```typescript
const damagedItems = character.weapons.filter((w) => w.durability < w.maxDurability);
```

### ✅ CORRECT: Check both weapons and items

```typescript
const weapons = character.weapons;
const items = await inventoryService.getCharacterInventory(characterId);
const damagedItems = [...weapons, ...items].filter((i) => i.durability < i.maxDurability);
```

---

### ❌ WRONG: Inventing item types

```typescript
if (item.type === 'gear') // ❌ Not a valid type
```

### ✅ CORRECT: Use defined types only

```typescript
type ItemType = 'weapon' | 'armor' | 'consumable' | 'trinket'; // ✅
```

---

## 12. Related Documentation

**Type Definitions:**

- `src/types/models.ts` - CharacterInstance, CharacterStats
- `src/types/game.ts` - Weapon
- `src/types/items.ts` - Item, InventoryItem, ItemType, ItemRarity

**Services:**

- `src/services/HybridCharacterService.ts` - Character CRUD
- `src/services/InventoryService.ts` - Item CRUD
- `src/services/LocalStorageService.ts` - Low-level storage
- `src/services/WorkshopService.ts` - Workshop operations (needs refactor)

**Design Documents:**

- `docs/features/planned/inventory-system.md` - Inventory design philosophy
- `docs/technical-debt/WORKSHOP-ITEM-TYPES-REFACTOR-PLAN.md` - Workshop refactor plan

---

## 13. Summary

**Key Takeaways:**

1. **Characters store weapons directly** (`character.weapons`)
2. **Items stored separately** (retrieved via `inventoryService`)
3. **Always query BOTH** for complete inventory
4. **Four item types only:** weapon, armor, consumable, trinket
5. **Workshop needs refactor** to query both sources

**If you're an AI assistant:**

- ✅ Read this document FIRST
- ✅ Don't assume data locations
- ✅ Query both `character.weapons` AND `inventoryService` for full inventory
- ✅ Verify your assumptions by reading the code
- ❌ Don't invent item types or storage locations

---

**Document Status:** ✅ CANONICAL REFERENCE
**Maintained By:** Alan + AI Assistants
**Update Frequency:** As data model evolves
