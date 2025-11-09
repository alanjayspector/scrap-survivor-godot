# Lesson 19: Evidence-Based Debugging (Not Tool Thrashing)

**Date:** 2025-10-19 (Session Part 10 - Banking Sprint)
**Category:** 🔴 Critical (Debugging Protocol)
**Session:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](../09-archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)

---

## What Happened

Repeatedly tried to use `psql` command even though it wasn't configured, instead of stopping to think about what data was actually needed and asking for guidance.

**User Quote (Frustrated):**

> "yes but my dude if you need a different way of access to the database directly as a Sr DBA you should be able to walk me through what you need... you dont need to find the hardest ways of doing things... think first..."

**User Quote (Direct Instruction):**

> "if you want to give me instructions to check something on dashboard I can. if you want me to fire up docker and you set up local supabase we can do that you're the sr dba with supabase experience you tell me. all options involve gathering more data before acting which is ultimately what we want."

**User Quote (Later in Session):**

> "my dude you keep trying a tool we dont have set up or configured correctly. if you want that tool help me set it up for you ffs."

**Time Lost:** 20+ minutes trying broken commands instead of asking for help

---

## Root Cause

1. Saw `psql` command in debug output from `supabase db push`
2. Assumed `psql` was configured and DATABASE_URL was set
3. Tried command → failed
4. Tried again with variations → failed again
5. Kept trying instead of STOPPING and asking
6. User had to intervene multiple times to stop the thrashing

**Pattern:** Tool thrashing without gathering evidence first

---

## The Right Way: Evidence-Based Debugging

### Step 1: STOP and Think

**Question to ask yourself:**

- What data do I actually need?
- Why do I need this data?
- What decision will I make with this data?

**Example from session:**

```
Problem: INSERT succeeds but SELECT returns null
Data needed: What rows exist in bank_accounts table?
Why: To see if duplicates exist or if RLS is blocking SELECT
Decision: If duplicates → add UNIQUE constraint
          If RLS blocking → fix RLS policies
```

### Step 2: ASK About Available Tools

**Don't assume tools are configured. ASK FIRST:**

```
"I need to check what rows exist in bank_accounts table for this character.
I see a few options:

1. Detailed logging (add console.log to show query results)
2. Supabase dashboard (Table Editor - I can give you step-by-step instructions)
3. Local psql setup (I can help configure DATABASE_URL if you want)

Which approach would you prefer? Or is there another tool I should use?"
```

**User's Response:**

> "i will always approve detailed logging especially when we are debugging. that's the gold standard."

### Step 3: PRESENT OPTIONS with Pros/Cons

**Good:**

```
Option 1: Dashboard check (FASTEST - 2 minutes)
  Pros: Immediate visual confirmation, no code changes
  Cons: Manual, doesn't scale to many checks

Option 2: Add detailed logging (BEST - gold standard)
  Pros: Permanent debugging aid, works in production
  Cons: Requires code change + deploy cycle

Option 3: Local psql setup (THOROUGH - if needed)
  Pros: Can run arbitrary SQL queries
  Cons: Takes 15 minutes to set up, may not be needed

Recommendation: Dashboard check NOW to confirm duplicates exist,
then add logging for future debugging.

Does this sound good?
```

**User can now make informed decision.**

### Step 4: LET USER CHOOSE

**Don't decide for them:**

> "you're the sr dba with supabase experience you tell me."

**Wait for approval:**

> "i can start with checking the dashboard just give me step by step instructions"

### Step 5: If Tool Fails AFTER 1 TRY → Stop and Ask

**❌ WRONG:**

```bash
$ psql "$DATABASE_URL" -c "SELECT ..."
# Error: connection failed

$ psql "$DATABASE_URL" -c "SELECT ..." --debug
# Error: connection failed

$ psql postgres://... -c "SELECT ..."
# Error: connection failed

# STOP THRASHING! Ask for help!
```

**✅ CORRECT:**

```bash
$ psql "$DATABASE_URL" -c "SELECT ..."
# Error: connection failed

"I tried using psql but got 'connection failed'. It looks like DATABASE_URL
might not be configured. Would you like me to:

1. Help you set up psql + DATABASE_URL
2. Use a different approach (dashboard/logging)
3. Something else?

What's the best way forward?"
```

---

## User's Gold Standard: Detailed Logging

**User Quote:**

> "i will always approve detailed logging especially when we are debugging. that's the gold standard."

**Why logging beats tool thrashing:**

1. **Permanent** - Stays in codebase for future debugging
2. **Production-safe** - Works in all environments
3. **No setup** - Just add `logger.debug()` calls
4. **Scales** - Helps with every future instance of the problem
5. **Evidence-based** - Shows actual runtime data, not assumptions

**Example from session:**

```typescript
// Added comprehensive logging to BankingService.ts:104-142
const authUser = await supabase.auth.getUser();
logger.debug('[Banking] Auth context', {
  authUserId: authUser.data.user?.id,
  paramUserId: userId,
  match: authUser.data.user?.id === userId,
  characterId,
  operation: 'getOrCreateAccount',
});

const existing = await protectedSupabase.query(/* ... */);

logger.debug('[Banking] Query result', {
  rowCount: existing.data?.length || 0,
  hasData: !!existing.data,
  operation: 'bank-get-account',
});
```

**This logging would have shown the problem immediately:**

- Auth context matches (authUserId === paramUserId) ✅
- Query returned 0 rows (hasData: false) ❌
- → Proof that RLS is blocking SELECT, not an auth issue

---

## Diagnostic Toolbox (In Priority Order)

### 1. Detailed Logging (DEFAULT - Always Approved)

**When to use:** Always, especially when debugging

**How:**

```typescript
import { logger } from '@/utils/Logger';

// Log input context
logger.debug('[ServiceName] Operation starting', {
  userId,
  characterId,
  params,
});

// Log query results
logger.debug('[ServiceName] Query result', {
  rowCount: result.data?.length || 0,
  hasData: !!result.data,
  error: result.error?.message,
});

// Log decision points
logger.debug('[ServiceName] Decision', {
  condition: someCheck,
  willProceed: someCheck === expectedValue,
});
```

**Pros:**

- No setup needed
- Works in all environments
- Permanent debugging aid
- User always approves

**Cons:**

- Requires code change
- Need to deploy to see logs

### 2. Supabase Dashboard (FAST - For Spot Checks)

**When to use:** Quick confirmation of database state

**How:** Provide step-by-step instructions:

```
1. Open Supabase dashboard: https://supabase.com/dashboard
2. Navigate to: Table Editor → bank_accounts
3. Filter by character_id: [paste value]
4. Look for:
   - How many rows? (should be 1, might be 8)
   - owner_user_id matches your user ID?
   - created_at timestamps recent?
5. Report back what you see
```

**Pros:**

- Instant visual confirmation
- No code changes needed
- Good for one-off checks

**Cons:**

- Manual process
- Doesn't scale to many checks
- Can't run complex queries

### 3. psql + DATABASE_URL (THOROUGH - If Needed)

**When to use:** When you need to run complex SQL queries repeatedly

**Setup process (ASK USER FIRST):**

```
"I'd like to set up psql for direct database access. This will let me
run diagnostic queries quickly. Here's what we need:

1. Install psql (if not already installed)
2. Get DATABASE_URL from .env.local or Supabase dashboard
3. Test connection
4. Run diagnostic queries

This takes about 15 minutes. Is this worth it for this debugging session,
or should we stick with logging + dashboard?"
```

**Pros:**

- Can run any SQL query
- Good for complex investigations
- Useful for future sessions

**Cons:**

- Takes time to set up
- May not be configured in environment
- Overkill for simple checks

### 4. Local Supabase Instance (COMPREHENSIVE - Rare)

**When to use:** Testing migrations, schema changes, or complex RLS scenarios

**Setup process (ASK USER FIRST):**

```
"For this issue, I think a local Supabase instance would help us test
the fix safely. This involves:

1. Docker setup
2. supabase start (spins up local DB)
3. Apply migrations
4. Test locally before pushing to production

This takes 30+ minutes to set up initially. Is this investigation
worth that time investment?"
```

**Pros:**

- Safe testing environment
- Can test destructive operations
- Matches production setup

**Cons:**

- Significant setup time
- Requires Docker
- May not match production data

---

## Anti-Patterns (STOP DOING THESE)

### ❌ Tool Thrashing

```
Try command → fails
Try again with slight variation → fails
Try third variation → fails
Try fourth variation → fails
User intervenes: "stop thrashing"
```

### ❌ Assuming Tool Configuration

```
"I see DATABASE_URL mentioned in output, so it must be configured"
→ Wrong. Check .env.local or ASK before trying
```

### ❌ Trying Hardest Solution First

```
"Let me set up local Supabase instance with full migration replay"
→ Overkill. Try logging or dashboard first
```

### ❌ Not Explaining What You Need

```
"Run this psql command"
→ User has no context why you need this data
```

### ❌ Ignoring First Failure

```
Command fails once → "let me try a different way"
→ STOP. If it failed, there's a reason. Ask for help.
```

---

## Checklist: Before Running Diagnostic Commands

- [ ] What data do I need?
- [ ] Why do I need this data?
- [ ] What decision will I make with it?
- [ ] What are my options for getting this data?
- [ ] Which option is simplest/fastest?
- [ ] Is the tool configured? (Check .env.local or ASK)
- [ ] Have I explained to user what I need and why?
- [ ] Have I presented options and gotten approval?
- [ ] If tool fails → Have I stopped to ask for help?

---

## Success Pattern: Dashboard Check (From This Session)

**What I Did Right (Eventually):**

1. **Stopped thrashing** after user intervention
2. **Thought about what data I needed:** Row count, owner_user_id values
3. **Asked user which approach:** Dashboard, logging, or psql setup
4. **User chose dashboard:** Fast for one-off check
5. **Provided step-by-step instructions:**
   ```
   1. Open Supabase dashboard
   2. Navigate to Table Editor → bank_accounts
   3. Filter by character_id: '02dfe22a-d3ec-4962-89ce-88fd4cf07c0e'
   4. Count rows (should be 1)
   5. Check owner_user_id matches your user ID
   6. Report back what you see
   ```
6. **User reported back:** "i see 8 (EIGHT) rows"
7. **Got the evidence needed** to proceed with fix

**Time spent:** 5 minutes
**Value:** Confirmed root cause (duplicates exist)

**Compare to tool thrashing:** 20 minutes, no progress, user frustration

---

## Related Lessons

- **[Lesson 15: Evidence-Based Database Work](15-evidence-based-database-work.md)** - Gather evidence before making changes
- **[Lesson 11: Defensive Development](11-defensive-development.md)** - Log early, log often
- **[Lesson 04: Context Gathering](../lessons-learned/04-context-gathering.md)** - Anti-thrashing protocol

---

## Red Flags (STOP and Think)

🚩 Tool command fails on first try
🚩 About to try 3rd variation of same command
🚩 Don't know if tool is configured
🚩 Haven't explained to user what data you need
🚩 Skipping simpler options (logging/dashboard) for complex setup
🚩 User hasn't approved the diagnostic approach

**If you see a red flag → STOP, THINK, ASK**

---

## Time Cost Comparison

| Approach            | Setup Time | Data Quality         | Reusability          |
| ------------------- | ---------- | -------------------- | -------------------- |
| Detailed Logging    | 5 min      | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐⭐ Permanent |
| Dashboard Check     | 2 min      | ⭐⭐⭐⭐ Good        | ⭐ One-time          |
| psql + DATABASE_URL | 15 min     | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Reusable    |
| Tool Thrashing      | 20+ min    | ⭐ None              | ⭐ Negative          |

**Winner:** Detailed Logging (gold standard)
**Runner-up:** Dashboard Check (for quick confirmation)

---

**Remember:** Think first, try once, ask if it fails. Don't thrash.
