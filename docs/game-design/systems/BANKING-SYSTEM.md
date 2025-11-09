# Banking System

**Status:** MID-TERM - Implement after core economy
**Tier Access:** Premium (basic), Subscription (quantum banking)
**Implementation Phase:** Weeks 10-12 (after currency system stable)

---

## 1. System Overview

The Banking System allows players to **protect currency from death penalties** by depositing scrap into a character-specific bank account. This is a Premium+ tier feature that mitigates the harsh death penalty of losing all carried currency.

**Key Features:**
- Deposit scrap into bank before entering The Wasteland
- Bank balance survives character death
- Withdraw from bank at Scrapyard
- **Quantum Banking** (Subscription): Transfer currency between characters

---

## 2. Core Concepts

### 2.1 Why Banking Exists

**Problem:** Players lose all carried currency on death (harsh penalty).

**Solution:** Bank currency before risky runs to preserve wealth.

**Strategic Trade-off:**
- **Carry currency:** Can spend in mid-run shops, but risk losing it
- **Bank currency:** Safe from death, but can't access during run

This creates meaningful decisions:
- "Should I bank my 10,000 scrap before this boss wave?"
- "I need to buy that weapon from the shop, but if I die I lose everything..."

### 2.2 Death Penalties (Recap)

When a character dies:
- ✅ **Carried scrap:** Lost (wiped to 0)
- ✅ **Banked scrap:** Safe (preserved)
- ✅ **Workshop components:** Lost (wiped to 0)
- ✅ **Item durability:** Damaged (can be destroyed)
- ✅ **Character XP:** Progress to next level reset
- ✅ **Random stat:** -1 point (random stat)

**Banking mitigates one death penalty: scrap loss.**

---

## 3. Basic Banking (Premium + Subscription)

### 3.1 Bank Account Structure

Each character instance has its own bank account:

```gdscript
class BankAccount:
    var character_id: String       # Owning character ID
    var balance: int = 0            # Banked scrap
    var repair_fund_balance: int = 0 # Repair Fund allocation (NEW)
    var total_deposited: int = 0    # Lifetime deposits (stat tracking)
    var total_withdrawn: int = 0    # Lifetime withdrawals (stat tracking)
    var created_at: String          # Account creation timestamp
```

**Key points:**
- **Character-bound:** Each character has separate bank account
- **No shared balance:** Characters can't access each other's banks (unless Subscription Quantum Banking)
- **No fees:** Deposits and withdrawals are free
- **Repair Fund:** Optional scrap allocation for auto-repair service (see section 3.4)

### 3.2 Banking Operations

#### Deposit

```gdscript
# Deposit scrap into bank
func deposit(character_id: String, amount: int) -> Result:
    var character = CharacterService.get_character(character_id)
    if character.currency < amount:
        return Result.error("Insufficient scrap")

    # Deduct from carried currency
    character.currency -= amount

    # Add to bank balance
    var bank = get_or_create_bank_account(character_id)
    bank.balance += amount
    bank.total_deposited += amount

    # Save
    await save_bank_account(bank)
    await CharacterService.update_character(character)

    return Result.success(bank)
```

#### Withdraw

```gdscript
# Withdraw scrap from bank
func withdraw(character_id: String, amount: int) -> Result:
    var bank = get_bank_account(character_id)
    if bank.balance < amount:
        return Result.error("Insufficient bank balance")

    # Deduct from bank
    bank.balance -= amount
    bank.total_withdrawn += amount

    # Add to carried currency
    var character = CharacterService.get_character(character_id)
    character.currency += amount

    # Save
    await save_bank_account(bank)
    await CharacterService.update_character(character)

    return Result.success(bank)
```

### 3.3 Banking UI

**Location:** Scrapyard → Banking

**Features:**
- View current bank balance
- View current carried scrap
- View Repair Fund balance (NEW)
- Deposit interface (input amount or "Deposit All")
- Withdraw interface (input amount or "Withdraw All")
- Repair Fund allocation (input amount)
- Transaction history (recent deposits/withdrawals)

**UI Mock:**
```
┌─────────────────────────────────────┐
│        SCRAPYARD BANK               │
├─────────────────────────────────────┤
│ Character: Scavenger #1             │
│                                     │
│ 💰 Carried Scrap:    15,420        │
│ 🏦 Banked Scrap:     42,850        │
│ 🔧 Repair Fund:       5,000        │
│                                     │
│ [Deposit] [Withdraw] [Repair Fund]  │
│                                     │
│ Recent Transactions:                │
│ - Deposited 10,000 scrap (1h ago)  │
│ - Withdrew 5,000 scrap (3h ago)    │
│ - Deposited 20,000 scrap (1d ago)  │
└─────────────────────────────────────┘
```

---

### 3.4 Repair Fund (NEW)

**The Repair Fund** is a convenience feature that allows players to **allocate banked scrap for automatic item repairs** through the Workshop.

**How it works:**
1. Player allocates scrap from bank balance → Repair Fund
2. When item needs repair, Workshop can auto-deduct from Repair Fund
3. Repair Fund costs **3x more scrap** than Workshop Components

**Why Repair Fund exists:**
- ✅ **Convenience:** Passive auto-repair without managing Workshop Components
- ✅ **Bank integration:** Another use for banked scrap
- ✅ **Trade-off:** 3x cost vs free Workshop Components (recycling rewards)

**Repair Cost Comparison:**

| Repair Method | Cost Example (T4 item, 10% durability lost) | Notes |
|--------------|---------------------------------------------|-------|
| Workshop Components | 40 components (free, earned via recycling) | Strategic, requires recycling items |
| Repair Fund (scrap) | 120 scrap (3x Workshop cost) | Convenient, passive auto-deduct |

**Implementation:**

```gdscript
# Allocate scrap to Repair Fund
func allocate_to_repair_fund(character_id: String, amount: int) -> Result:
    var bank = get_bank_account(character_id)
    if bank.balance < amount:
        return Result.error("Insufficient bank balance")

    # Move scrap from bank to repair fund
    bank.balance -= amount
    bank.repair_fund_balance += amount

    await save_bank_account(bank)
    return Result.success(bank)

# Deduct from Repair Fund (called by Workshop)
func deduct_repair_fund(character_id: String, amount: int) -> bool:
    var bank = get_bank_account(character_id)
    if bank.repair_fund_balance < amount:
        return false

    bank.repair_fund_balance -= amount
    await save_bank_account(bank)
    return true
```

**Strategic Decision:**
- Players can choose to recycle items for free Workshop Components (strategic)
- OR allocate banked scrap to Repair Fund for convenience (3x cost)
- Repair Fund is **passive** - Workshop auto-deducts when repairing items

---

## 4. Quantum Banking (Subscription Only)

### 4.1 What is Quantum Banking?

**Quantum Banking** allows Subscription users to **transfer currency between character bank accounts.**

**Example:**
- Character A (Scavenger): 50,000 scrap in bank
- Character B (Soldier): 5,000 scrap in bank
- Transfer 20,000 from A → B
- Result: A has 30,000, B has 25,000

**Why "Quantum"?**
- Fits the sci-fi theme (Quantum Storage, etc.)
- Implies "instant transfer across space"
- Sounds cool 😎

### 4.2 Quantum Transfer UI

**Location:** Scrapyard → Quantum Banking (Subscription only)

**Features:**
- Select source character
- Select destination character
- Enter transfer amount
- Confirm transfer

**UI Mock:**
```
┌─────────────────────────────────────┐
│     QUANTUM BANKING                 │
├─────────────────────────────────────┤
│ Transfer scrap between characters   │
│                                     │
│ From: [Scavenger #1 ▼]             │
│       🏦 Bank: 50,000 scrap        │
│                                     │
│ To:   [Soldier #2 ▼]               │
│       🏦 Bank: 5,000 scrap         │
│                                     │
│ Amount: [________] scrap            │
│         [Max: 50,000]               │
│                                     │
│ [Cancel] [Transfer]                 │
└─────────────────────────────────────┘
```

### 4.3 Quantum Transfer Rules

**Restrictions:**
1. **Subscription only** - Premium users cannot transfer
2. **Bank-to-bank only** - Cannot transfer carried scrap
3. **Same user only** - Cannot transfer to other users' characters
4. **No fees** - Transfers are free (QoL feature)
5. **Alive characters only** - Dead characters cannot send/receive

**Anti-Exploit:**
- Transfers are logged (audit trail)
- Rate limiting: Max 10 transfers per day
- Minimum transfer: 100 scrap (prevent spam)

### 4.4 Quantum Banking Implementation

```gdscript
func quantum_transfer(
    from_character_id: String,
    to_character_id: String,
    amount: int
) -> Result:
    # Verify subscription tier
    var user = get_current_user()
    if user.tier < UserTier.SUBSCRIPTION:
        return Result.error("Quantum Banking requires Subscription")

    # Verify ownership
    var from_char = CharacterService.get_character(from_character_id)
    var to_char = CharacterService.get_character(to_character_id)
    if from_char.user_id != user.id or to_char.user_id != user.id:
        return Result.error("Can only transfer between your own characters")

    # Verify both alive
    if not from_char.is_alive or not to_char.is_alive:
        return Result.error("Cannot transfer with dead characters")

    # Verify sufficient balance
    var from_bank = get_bank_account(from_character_id)
    if from_bank.balance < amount:
        return Result.error("Insufficient bank balance")

    # Verify minimum
    if amount < 100:
        return Result.error("Minimum transfer: 100 scrap")

    # Execute transfer
    from_bank.balance -= amount
    var to_bank = get_or_create_bank_account(to_character_id)
    to_bank.balance += amount

    # Log transaction
    log_quantum_transfer(from_character_id, to_character_id, amount)

    # Save
    await save_bank_account(from_bank)
    await save_bank_account(to_bank)

    return Result.success({ "from_balance": from_bank.balance, "to_balance": to_bank.balance })
```

---

## 5. Data Model

### 5.1 Local Storage

```gdscript
# Stored in SaveSystem (LocalStorage)
class BankAccount:
    var character_id: String
    var balance: int = 0
    var total_deposited: int = 0
    var total_withdrawn: int = 0
    var created_at: String
```

### 5.2 Supabase Sync (Future)

```sql
CREATE TABLE bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  character_id UUID REFERENCES character_instances(id) NOT NULL,
  balance BIGINT DEFAULT 0 CHECK (balance >= 0),
  total_deposited BIGINT DEFAULT 0,
  total_withdrawn BIGINT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(character_id)  -- One bank per character
);

-- Quantum transfer transaction log
CREATE TABLE quantum_transfers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  from_character_id UUID REFERENCES character_instances(id) NOT NULL,
  to_character_id UUID REFERENCES character_instances(id) NOT NULL,
  amount BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bank_accounts_character_id ON bank_accounts(character_id);
CREATE INDEX idx_quantum_transfers_user_id ON quantum_transfers(user_id);
```

---

## 6. Integration with Other Systems

### 6.1 Death System

When character dies:
- Carried scrap → 0
- **Banked scrap → preserved**
- **Repair Fund → preserved** (stays intact)
- Workshop components → 0

### 6.2 Workshop System

**Repair Fund Integration:**

When repairing items in Workshop, players have two payment options:
1. **Workshop Components** (free, earned via recycling)
2. **Repair Fund** (scrap, 3x cost, passive auto-deduct)

Workshop queries Banking System for Repair Fund balance:

```gdscript
# Workshop repair logic
func repair_item(item: Item, use_repair_fund: bool) -> Result:
    var repair_cost_components = calculate_repair_cost(item.tier, 100 - item.durability)

    if use_repair_fund:
        var scrap_cost = repair_cost_components * 3
        if BankingService.deduct_repair_fund(character_id, scrap_cost):
            item.durability = 100
            return Result.success("Repaired with Repair Fund")
        else:
            return Result.error("Insufficient Repair Fund balance")
    else:
        if WorkshopService.has_components(repair_cost_components):
            WorkshopService.spend_components(repair_cost_components)
            item.durability = 100
            return Result.success("Repaired with Workshop Components")
        else:
            return Result.error("Insufficient Workshop Components")
```

See [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) for full repair documentation.

### 6.3 Tier System

Banking access by tier:
- **Free:** No access (banking disabled)
- **Premium:** Basic banking (deposit/withdraw) + Repair Fund
- **Subscription:** Basic banking + Repair Fund + Quantum Banking

### 6.4 Perks System

Perks can affect banking:
- "Bank interest: +5% per week" (compound interest)
- "Double deposit bonuses this week"
- "Free Quantum Transfers (no rate limit)"
- "Repair Fund efficiency: -50% repair costs this week" (NEW)

**Hook point:** `bank_deposit`, `bank_withdraw`, `quantum_transfer`, `repair_fund_allocate`

---

## 7. Balancing Considerations

### 7.1 Strategic Depth

Banking should create **meaningful decisions:**

**Good:** "I have 50,000 scrap. Should I bank it or spend it in the shop?"
**Bad:** "Banking is always optimal, never carry scrap."

**Solution:** Some features require carried scrap:
- Mid-run shops (can't access bank during combat)
- Emergency purchases (revive tokens, consumables)
- High-stakes gambling (risk/reward)

### 7.2 Quantum Banking Power

Quantum Banking is **powerful but not game-breaking:**

**Balanced:**
- Allows resource pooling (fund one character)
- QoL feature for Subscription tier
- Doesn't grant new scrap (just redistributes)

**Not Exploitable:**
- Can't trade with other users
- Can't bypass death penalties (scrap still lost if not banked)
- Rate limited (10 transfers/day)

---

## 8. Implementation Phases

### Phase 1: Basic Banking (Week 10)
- Create BankAccount data model
- Add BankingService (deposit/withdraw)
- Local storage only (no Supabase yet)
- Basic UI (Scrapyard → Banking)

### Phase 2: UI Polish (Week 11)
- Transaction history
- Deposit/Withdraw all buttons
- Balance displays
- Animations and feedback

### Phase 3: Quantum Banking (Week 12)
- Quantum transfer logic
- Tier verification (Subscription only)
- Rate limiting
- Quantum Banking UI

### Phase 4: Supabase Sync (Week 13+)
- Sync bank accounts to Supabase
- Transaction logging (audit trail)
- Cross-device banking

---

## 9. Open Questions

1. **Bank Interest:** Should banked scrap earn passive interest over time?
2. **Bank Capacity:** Should there be a max bank balance? Or unlimited?
3. **Quantum Transfer Fees:** Should transfers cost a % fee (e.g., 5%)?
4. **Bank Heists:** Should there be a rare event where bank can be "raided" (lose %)?
5. **Loan System:** Should players be able to borrow scrap (with interest)?

---

## 10. Summary

The Banking System provides:
- **Basic Banking** (Premium+): Deposit/withdraw scrap to protect from death
- **Quantum Banking** (Subscription): Transfer scrap between character banks
- **Strategic Depth:** Bank vs carry scrap decisions
- **Death Mitigation:** Preserve wealth across deaths

**Next Steps:**
1. Create BankAccount data model (Week 10)
2. Implement BankingService
3. Build Banking UI
4. Add Quantum Banking for Subscription

**Status:** Ready for Week 10 implementation planning.
