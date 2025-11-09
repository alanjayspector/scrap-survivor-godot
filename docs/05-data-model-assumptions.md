# Lesson 05: Data Model Assumptions

**Category:** 🔴 Critical (Never Violate)
**Last Updated:** 2025-10-19
**Sessions:** Multiple sessions (Sprint 11, Sprint 12, Sprint 13)

---

## CRITICAL RULE: Read DATA-MODEL.md Before Assuming Anything

**Context:** Multiple AI assistants wasted hours making wrong assumptions about data structures.

**User Feedback:**

> "i'm getting increasing concerned you dont understand the gameplay we've been defining for almost a month now"

> "did you look at the unit tests for other services?" (Sprint 13)

**Lesson:** NEVER assume where data is stored or how it's structured. ALWAYS read `docs/core-architecture/DATA-MODEL.md` first.

**Why This Matters:**

- Wrong assumptions lead to hours of wasted debugging
- User has to repeat explanations multiple times
- Destroys trust and confidence
- The correct answer is already documented

---

## The DATA-MODEL.md Protocol

### Before Working With ANY Data

**MANDATORY READING:**

```bash
cat docs/core-architecture/DATA-MODEL.md
```

**This file documents:**

- Where weapons are stored (`character.weapons` array)
- Where items are stored (via `inventoryService.getCharacterInventory()`)
- What item types exist (weapon, armor, consumable, trinket - ONLY 4)
- How to query for complete inventory
- Database schema structure
- Relationships between tables

### Why This File Exists

**From DATA-MODEL.md:**

> This document was created because an AI assistant wasted 2 hours making wrong assumptions about where data is stored. Alan had to repeat himself multiple times explaining:
>
> - Weapons are in `character.weapons` array
> - Items (armor/consumable/trinket) are stored separately via `inventoryService`
> - You must query BOTH sources for complete inventory
> - There are only 4 item types: weapon, armor, consumable, trinket

**If you skip this document, you will:**

- ❌ Assume items are in `character.items` (WRONG - doesn't exist)
- ❌ Invent item types that don't exist
- ❌ Make Alan repeat the same explanations
- ❌ Lose Alan's confidence in AI assistants

---

## Common Wrong Assumptions (Don't Make These)

### Wrong Assumption 1: "Items are in character.items"

**❌ WRONG:**

```typescript
const items = character.items; // This field doesn't exist!
```

**✅ RIGHT (from DATA-MODEL.md):**

```typescript
// Weapons are in character.weapons array
const weapons = character.weapons;

// Items are fetched via InventoryService
const items = await inventoryService.getCharacterInventory(character.id);
```

**Why:** Data model uses separate storage for weapons vs. items. Read DATA-MODEL.md to understand why.

### Wrong Assumption 2: "There must be more item types"

**❌ WRONG:**

```typescript
type ItemType = 'weapon' | 'armor' | 'consumable' | 'trinket' | 'accessory' | 'material';
// Last two don't exist!
```

**✅ RIGHT (from DATA-MODEL.md):**

```typescript
type ItemType = 'weapon' | 'armor' | 'consumable' | 'trinket';
// ONLY these 4 types exist
```

**Why:** Game design has exactly 4 item types. No accessories, materials, or other types. Documented in DATA-MODEL.md.

### Wrong Assumption 3: "I can assume the schema structure"

**❌ WRONG:**

```typescript
// Assuming workshop_items table structure
const result = await supabase.from('workshop_items').select('*').eq('character_id', characterId);
```

**✅ RIGHT (from DATA-MODEL.md):**

```typescript
// Read DATA-MODEL.md first, discover it's in inventory table with item_type filter
const result = await supabase
  .from('inventory')
  .select('*')
  .eq('character_id', characterId)
  .in('item_type', ['armor', 'consumable', 'trinket']);
```

**Why:** Table names, column names, and relationships are documented. Don't guess.

### Wrong Assumption 4: "Currency must be in a transactions table"

**❌ WRONG:**

```typescript
// Assuming currency is separate
const currency = await supabase
  .from('currency')
  .select('amount')
  .eq('character_id', characterId)
  .single();
```

**✅ RIGHT (from DATA-MODEL.md):**

```typescript
// Currency is a column on characters table
const { data: character } = await supabase
  .from('characters')
  .select('currency')
  .eq('id', characterId)
  .single();
```

**Why:** Currency is denormalized on characters table for performance. Documented in DATA-MODEL.md.

---

## Real-World Example: Workshop Item Types

### What Happened (Sprint 11-12)

**Task:** Extend Workshop to support all item types (not just weapons)

**What AI Did Wrong:**

1. Assumed items were in `character.items`
2. Invented new item types beyond the 4 documented
3. Created complex queries without checking schema
4. Wasted 2 hours debugging incorrect assumptions

**User Had to Explain:**

> "Weapons are in `character.weapons` array"
> "Items (armor/consumable/trinket) are stored separately via `inventoryService`"
> "You must query BOTH sources for complete inventory"
> "There are only 4 item types: weapon, armor, consumable, trinket"

**What AI Should Have Done:**

**Step 1: Read DATA-MODEL.md**

```bash
cat docs/core-architecture/DATA-MODEL.md
```

**Discovered:**

- Weapons: `character.weapons` array
- Items: `inventory` table via `inventoryService`
- Item types: weapon, armor, consumable, trinket (ONLY 4)
- Complete inventory: Query both sources

**Step 2: Use correct data access**

```typescript
// Get weapons
const weapons = character.weapons;

// Get items
const items = await inventoryService.getCharacterInventory(character.id);

// Complete inventory
const allItems = [...weapons, ...items];
```

**Result:** Would have worked immediately, no user correction needed.

---

## The "Where Is Data?" Checklist

**Before accessing ANY data in code:**

- [ ] Have I read DATA-MODEL.md for this data type?
- [ ] Do I know which table stores this data?
- [ ] Do I know which columns exist?
- [ ] Do I understand relationships to other tables?
- [ ] Have I checked existing service code for this data access?

**If you answer "NO" to any:**

1. Stop what you're doing
2. Read DATA-MODEL.md section for that data type
3. Check existing service code that accesses this data
4. THEN write your query

---

## Where to Find the Truth

### Primary Source: DATA-MODEL.md

**Location:** `docs/core-architecture/DATA-MODEL.md`

**What it covers:**

- All database tables and columns
- Character data structure
- Inventory system (weapons vs. items)
- Item types (canonical list)
- Currency and progression
- Relationships and foreign keys

### Secondary Source: Existing Services

**After reading DATA-MODEL.md, check:**

```bash
# How does InventoryService access items?
cat src/services/InventoryService.ts

# How does WorkshopService query inventory?
cat src/services/WorkshopService.ts

# What does Character type look like?
grep -A 20 "interface Character" src/types/
```

### Tertiary Source: Database Migrations

**If DATA-MODEL.md and services unclear:**

```bash
# Check actual schema creation
ls supabase/migrations/
cat supabase/migrations/LATEST_MIGRATION_FILE.sql
```

---

## Pattern: How to Handle New Data Access

### ✅ Example 1: Adding Banking Balance Query

**Task:** Query character's bank balance

**Step 1: Check DATA-MODEL.md**

```bash
cat docs/core-architecture/DATA-MODEL.md
# Look for "bank" or "banking" section
```

**If not found:**

**Step 2: Check recent migrations**

```bash
ls -la supabase/migrations/ | grep -i bank
cat supabase/migrations/YYYYMMDDHHMMSS_create_bank_accounts.sql
```

**Step 3: Check existing service**

```bash
cat src/services/BankingService.ts
# See how BankingService queries bank_accounts table
```

**Step 4: Copy pattern exactly**

```typescript
// From BankingService.ts
const { data: account } = await supabase
  .from('bank_accounts')
  .select('balance')
  .eq('character_id', characterId)
  .single();
```

**Result:** Works immediately, no assumptions made.

---

## Anti-Patterns Checklist

**You're making assumptions when you:**

- ❌ Write queries without checking DATA-MODEL.md
- ❌ Invent field names that "seem logical"
- ❌ Assume table structures without verifying
- ❌ Create new item types beyond the 4 documented
- ❌ Access data differently than existing services

**You're checking the truth when you:**

- ✅ Read DATA-MODEL.md before writing queries
- ✅ Copy field names exactly from documentation
- ✅ Verify table structures in migrations
- ✅ Use only documented item types
- ✅ Follow existing service patterns

---

## Why Assumptions Are Expensive

### Time Cost

**Assumption-driven development:**

- Write code based on assumptions: 30 min
- Debug why it doesn't work: 1 hour
- User explains correct approach: 15 min
- Rewrite with correct approach: 30 min
- **Total: 2 hours 15 min**

**Documentation-driven development:**

- Read DATA-MODEL.md: 10 min
- Write code using documented structure: 30 min
- **Total: 40 min**

**Time saved: 1 hour 35 min**

### Trust Cost

**User's perspective:**

> "i'm getting increasing concerned you dont understand the gameplay we've been defining for almost a month now"

**Each assumption that's wrong:**

- Reduces user confidence
- Makes user repeat explanations
- Signals you're not reading documentation
- Creates frustration

**Reading DATA-MODEL.md signals:**

- You respect documented work
- You're thorough and careful
- You learn from past mistakes
- You're productive (not thrashing)

---

## The Four Item Types (Memorize This)

**ONLY these 4 types exist:**

1. **weapon** - Stored in `character.weapons` array
2. **armor** - Stored in `inventory` table
3. **consumable** - Stored in `inventory` table
4. **trinket** - Stored in `inventory` table

**No other types exist. Period.**

**Not accessories. Not materials. Not components. Not gear.**

**Just: weapon, armor, consumable, trinket.**

**If you find yourself typing any other item type, STOP and read DATA-MODEL.md.**

---

## Quick Reference: Common Data Locations

| Data                | Location                    | How to Access                              |
| ------------------- | --------------------------- | ------------------------------------------ |
| Weapons             | `character.weapons` array   | Direct property access                     |
| Items               | `inventory` table           | `inventoryService.getCharacterInventory()` |
| Currency            | `character.currency` column | Direct property access                     |
| Bank Balance        | `bank_accounts` table       | `BankingService.getBalance()`              |
| Character Stats     | `character` table           | Direct property access                     |
| Workshop Components | `workshop_components` table | Via WorkshopService                        |
| User Tier           | `user_tiers` table          | `TierService.getUserTier()`                |

**Source of truth:** `docs/core-architecture/DATA-MODEL.md`

---

## Success Criteria

**You understand the data model when:**

- ✅ You can explain where weapons vs. items are stored
- ✅ You can list all 4 item types without checking
- ✅ You know to check DATA-MODEL.md before querying
- ✅ Your queries work on first try
- ✅ User doesn't correct your data access

**You're making assumptions when:**

- ❌ User says "did you read DATA-MODEL.md?"
- ❌ You query tables that don't exist
- ❌ You use field names that aren't in schema
- ❌ You create item types beyond the 4
- ❌ Queries fail due to wrong table/column names

---

## Related Lessons

- [04-context-gathering.md](04-context-gathering.md) - Read docs before searching code
- [03-user-preferences.md](03-user-preferences.md) - No assumptions, verify everything

## Related Documentation

- **CRITICAL:** [docs/core-architecture/DATA-MODEL.md](/home/alan/projects/scrap-survivor/docs/core-architecture/DATA-MODEL.md)
- [docs/development-guide/before-you-start-checklist.md](/home/alan/projects/scrap-survivor/docs/development-guide/before-you-start-checklist.md)

## Session References

- CONTINUATION_PROMPT.md - "INVENTED NEW PATTERNS" and "ASSUMED data structures" sections
- Multiple Sprint 11-12 sessions where data model confusion occurred
