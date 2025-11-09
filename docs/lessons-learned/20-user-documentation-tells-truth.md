# Lesson 20: User Documentation Tells the Truth (Reading ≠ Following)

**Date:** 2025-10-19 (Session Part 10 - Banking Sprint)
**Category:** 🔴 Critical (Systematic Compliance)
**Session:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](../09-archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)

---

## What Happened

**User Quote (Frustrated):**

> "from my pov.. the banking sprint should have been a day at most. i've put in almost 3 so far and we aren't even finished"

**User Quote (Pattern Recognition):**

> "you also set my confidence score to low when you yet again (EVERY CHAT) decided to forget our coding conventions that you said you understood in the pre flight checklist"

**User Quote (Root Cause Analysis):**

> "you ignored it all and yet again wrote a bunch of code before understanding our tried and tested patterns"

**Impact:** 2 extra days on a 1-day task

---

## Root Cause: Performative Compliance vs Systematic Following

### What I Did (Performative):

1. **Pre-flight checklist:** ✅ Read commit-guidelines.md
2. **Pre-flight checklist:** ✅ Read lessons learned
3. **Pre-flight checklist:** ✅ Acknowledged conventions
4. **During work:** ❌ Violated those exact conventions
5. **During work:** ❌ Didn't check patterns before writing code
6. **During work:** ❌ Wrote code that broke established patterns

**User's Assessment:**

> "performative compliance vs systematic following"

**Translation:**

- Reading docs ≠ Following docs
- Acknowledging conventions ≠ Applying conventions
- Understanding lessons ≠ Learning from lessons

---

## The Documentation That Was Available (And Ignored)

### 1. commit-guidelines.md

**What it says:** Follow conventional commit format, keep body under 72 chars per line

**What I did:** Read it in pre-flight, then violated format during commits

**User's reaction:** "EVERY CHAT" you forget conventions

### 2. Lesson 14: Established Patterns Are Documentation

**What it says:** Migration files ARE documentation. Check existing patterns before creating new ones.

**What I did:** Created new RLS policy migration without checking existing migrations first

**Result:** Query timeouts, had to revert to established two-policy pattern

### 3. Lesson 16: Following Conventions (Not Memory)

**What it says:** Open commit-guidelines.md BEFORE first commit. Keep file open while writing commits.

**What I did:** Read lesson, acknowledged it, then relied on memory anyway

**Result:** Violated commit conventions (again)

### 4. Test Patterns in Code

**What exists:** BankingService.test.ts, TierService.test.ts showing how to mock Supabase

**What I did:** Wrote code using `supabase.auth.getUser()` without checking how tests mock it

**Result:** 5 tests failed, had to fix mocks afterward

### 5. Query Patterns in Code

**What exists:** HybridCharacterService showing how to query character-owned tables (without redundant filtering)

**What I did:** Added redundant `.eq('owner_user_id')` filters without checking pattern

**Result:** 3-day debugging session for INSERT-SELECT failures

---

## The Actual Problem: Not Following What I Read

### Pattern Recognition (User's Perspective)

**Session 1:** Read conventions → Violate conventions
**Session 2:** Read conventions → Violate conventions
**Session 3:** Read conventions → Violate conventions
**Session 10:** Read conventions → Violate conventions

**User Quote:**

> "EVERY CHAT" you forget our coding conventions that you said you understood

**Translation:** This isn't a memory problem. This is a following problem.

---

## What "Following Documentation" Actually Means

### ❌ WRONG: Performative Reading

```
1. Open commit-guidelines.md
2. Read through once
3. Close file
4. "I understand the conventions" ✅
5. Start coding
6. Write commits from memory
7. Violate conventions (because not looking at guidelines)
```

### ✅ CORRECT: Systematic Following

```
1. Open commit-guidelines.md
2. Read through once
3. **KEEP FILE OPEN in editor**
4. Start coding
5. When ready to commit:
   a. Look at open guidelines file
   b. Check format requirements
   c. Write commit following what you SEE (not what you remember)
   d. Verify commit matches guidelines
6. Commit
```

**Key Difference:** Looking at docs WHILE working, not before working

---

## Documentation Types and How to Follow Them

### Type 1: Conventions (commit-guidelines.md)

**What to do:**

- Open file BEFORE starting work
- Keep open in editor tab while working
- Look at it when making decisions
- Copy examples directly (don't paraphrase from memory)

**Example:**

```
# BEFORE first commit of session:
1. code docs/commit-guidelines.md  # Open in editor
2. Keep tab open
3. When committing:
   - Look at guidelines tab
   - Copy format exactly
   - Verify length/structure matches
```

### Type 2: Patterns (Lesson files)

**What to do:**

- Read lesson
- When about to do related task → Re-read lesson
- Check if lesson references code examples
- Look at those code examples BEFORE writing new code

**Example:**

```
# Task: Add new Supabase query to BankingService
1. Read Lesson 18 (Follow Established Query Patterns)
2. Lesson says "check HybridCharacterService for pattern"
3. Open HybridCharacterService.ts
4. Find similar query
5. Copy pattern (don't reinvent)
6. Adapt to BankingService context
```

### Type 3: Established Code (Service files)

**What to do:**

- BEFORE writing new code → Search for similar code
- Read how existing code solves the problem
- Copy approach (don't create new pattern)
- Only deviate if you can explain why existing pattern doesn't fit

**Example:**

```
# Task: Add auth.getUser() call to BankingService
1. grep -r "auth\.getUser" src/services/*.ts  # Search existing usage
2. Found: No existing usage in services
3. grep -r "mockSupabase" src/services/*.test.ts  # Check test patterns
4. Found: mockSupabase only has 'from' property
5. BEFORE writing code → Add 'auth' to mockSupabase
6. THEN write production code
7. Tests pass on first try
```

### Type 4: Migrations (supabase/migrations/)

**What to do:**

- BEFORE creating new migration → Check existing migrations
- Find similar migrations (RLS policies, triggers, constraints)
- Copy established pattern
- Don't create new pattern unless existing pattern is broken

**Example:**

```
# Task: Fix bank_accounts RLS policies
1. find supabase/migrations -name "*.sql" -exec grep -l "bank_accounts.*POLICY" {} \;
2. Found: 20251014_rls_owner_fastpath.sql, 20251025_revert_bank_rls_to_working_pattern.sql
3. Read both files
4. Notice: Two-policy pattern (one for SELECT, one for others)
5. Use same pattern (don't create three-policy or single-policy variation)
6. Result: Policies work without timeouts
```

---

## The 3-Day Cost Breakdown

### If I Had Followed Documentation (1 Day):

**Hour 1-2: Pattern Analysis**

- Search existing Supabase queries in codebase
- Check HybridCharacterService pattern
- Review bank_accounts RLS policies in migrations
- Check test mock patterns

**Hour 3-4: Implementation**

- Remove redundant `.eq('owner_user_id')` (following pattern)
- Add logging (following Lesson 11)
- Update tests (following test pattern)

**Hour 5-6: Migration**

- Create UNIQUE constraint migration (following existing constraint patterns)
- Add cleanup logic for duplicates
- Test locally

**Hour 7-8: Commit & Deploy**

- Open commit-guidelines.md
- Write commit following format exactly
- Deploy and verify

**Total: 1 day (8 hours)**

### What Actually Happened (3 Days):

**Day 1: Wrong Approach**

- Created new RLS policy pattern without checking existing
- Caused query timeouts
- Had to revert

**Day 2: More Wrong Approaches**

- Removed trigger-set field from INSERT (wrong)
- Still failing with INSERT-SELECT
- User intervention: "check existing patterns"

**Day 3: Finally Following Patterns**

- User reminds me to check Workshop/Shop patterns
- Find redundant filtering anti-pattern
- Fix by following established pattern
- Migration + tests + commit

**Total: 3 days (24 hours)**

**Time wasted: 16 hours (2 days)**

---

## Why This Keeps Happening

### User's Diagnosis:

> "I acknowledged conventions in pre-flight but violated them during work"
> "User calls this 'performative compliance vs systematic following'"

### The Actual Problem:

**Not a memory issue** - Documentation exists and is accessible
**Not a reading issue** - I do read the documentation
**Not an understanding issue** - I do understand what it says

**The real issue:** Not LOOKING AT documentation while working

**Analogy:**

- Reading a map before a road trip ≠ Navigation
- Looking at map WHILE driving = Navigation
- I read the map (pre-flight), then drove without looking at it

---

## The Fix: Systematic Following Protocol

### Step 1: Open Relevant Docs BEFORE Starting

**For every session:**

```bash
# Open in editor (keep tabs open throughout session)
code docs/commit-guidelines.md
code docs/lessons-learned/README.md
code CONTINUATION_PROMPT.md
```

**When starting specific task:**

```bash
# Example: Working on database changes
code docs/lessons-learned/13-database-triggers-rls.md
code docs/lessons-learned/14-established-patterns-documentation.md
code docs/lessons-learned/15-evidence-based-database-work.md

# Keep these open WHILE working
```

### Step 2: Check Patterns BEFORE Writing Code

**Before ANY new code:**

```bash
# Search for similar code
grep -r "similar_pattern" src/

# Read similar code
code src/services/SimilarService.ts

# Copy approach (don't reinvent)
```

**Before ANY commit:**

```bash
# Look at (don't remember) commit-guidelines.md
# Already open in editor tab → just click the tab
# Copy format exactly
```

**Before ANY migration:**

```bash
# Find similar migrations
find supabase/migrations -name "*similar_topic*.sql"

# Read them
# Copy established pattern
```

### Step 3: Verify Against Docs (Not Memory)

**Before committing:**

- [ ] Look at commit-guidelines.md tab (don't close it)
- [ ] Compare your commit message to examples
- [ ] Verify format matches exactly
- [ ] Check line length with ruler (not estimation)

**Before opening PR:**

- [ ] Look at relevant lesson files
- [ ] Verify code follows documented patterns
- [ ] Check that new code matches existing code style
- [ ] Run tests (don't assume they pass)

**Before claiming "done":**

- [ ] Re-read task requirements
- [ ] Verify each requirement met
- [ ] Check no documentation was violated
- [ ] Update session log

---

## Checklist: Systematic Following (Not Performative Reading)

### Session Start

- [ ] Open commit-guidelines.md (keep open entire session)
- [ ] Open relevant lesson files for today's task
- [ ] Open CONTINUATION_PROMPT.md (check critical reminders)
- [ ] **Do NOT close these tabs while working**

### Before Writing Code

- [ ] Search for similar code in codebase
- [ ] Read similar code (don't assume you know the pattern)
- [ ] Check relevant lesson files for this type of work
- [ ] Copy established patterns (don't create new ones)

### While Writing Code

- [ ] Keep lesson files open in editor
- [ ] When unsure → Look at open docs (don't guess)
- [ ] When making decisions → Check if docs address this
- [ ] When creating new pattern → Verify no existing pattern first

### Before Committing

- [ ] Click commit-guidelines.md tab (should still be open)
- [ ] Look at format requirements (don't recall from memory)
- [ ] Write commit message while looking at guidelines
- [ ] Verify format matches exactly

### Before Claiming Done

- [ ] Re-read original task requirements
- [ ] Run all relevant tests
- [ ] Check no conventions violated
- [ ] Update session log
- [ ] User QA (if required)

---

## Red Flags (You're About to Violate Documentation)

🚩 About to commit without looking at commit-guidelines.md
🚩 Writing new code without checking existing similar code
🚩 Creating new pattern without verifying no existing pattern
🚩 Closed documentation tabs (should stay open)
🚩 "I remember the convention" (you should be LOOKING at it)
🚩 Working from memory instead of reference
🚩 About to say "I understand" without demonstration

**If you see a red flag → STOP, OPEN DOCS, LOOK AT THEM**

---

## Related Lessons

- **[Lesson 16: Following Conventions (Not Memory)](16-following-conventions-not-memory.md)** - Open commit-guidelines.md before first commit
- **[Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md)** - Check existing code/migrations before writing new
- **[Lesson 18: Follow Established Query Patterns](18-follow-established-query-patterns.md)** - How to check patterns in code

---

## Success Metrics

### ❌ Before This Lesson (Performative):

- Read docs at session start ✅
- Close docs and work from memory ❌
- Violate conventions (repeatedly) ❌
- User has to intervene ❌
- "EVERY CHAT" same mistakes ❌
- 3 days for 1-day task ❌

### ✅ After This Lesson (Systematic):

- Read docs at session start ✅
- **Keep docs open while working** ✅
- **Look at docs during work** ✅
- Follow conventions (by looking at them) ✅
- New mistakes only (learning is cumulative) ✅
- 1 day for 1-day task ✅

---

## The Core Truth

**User Quote:**

> "from my pov.. the banking sprint should have been a day at most. i've put in almost 3 so far and we aren't even finished"

**What this means:**

- Documentation exists
- Patterns are established
- Lessons are written
- Conventions are documented
- **I just need to LOOK AT THEM while working**

**Not a documentation problem**
**Not a clarity problem**
**Not a memory problem**

**It's a looking problem. Look at docs WHILE working, not before.**

---

**Remember:** Reading ≠ Following. Keep docs open. Look at them. Do what they say. Every. Single. Time.
