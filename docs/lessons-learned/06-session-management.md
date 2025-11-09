# Lesson 06: Session Management & Handoffs

**Category:** 🟡 Important (Default Behavior)
**Last Updated:** 2025-10-19
**Sessions:** Multiple sessions, especially Sprint 13

---

## CRITICAL RULE: Cross-Verify Session Logs Against Code

**Context:** Session 2025-10-19, AI read session log claiming "Remaining Work: Add DebugMenu scenarios" but the work was already complete.

**User Feedback:**

> "can you explain with all the session logging we are doing and session hand off you didnt know from the start that thee debug menu work was done?"

**Lesson:** Session logs are written by humans and may have omissions. ALWAYS verify claims against actual code state.

**Why This Matters:**

- Session logs may be outdated or incomplete
- "TODO" items may have been completed but not updated
- Wastes time redoing completed work
- User has to point out what you missed

---

## The Session Log Cross-Verification Protocol

### Step 1: Read Session Log

**Find and read latest session log:**

```bash
ls -la docs/archive/session-handoffs/ | tail -5
cat docs/archive/session-handoffs/session-log-YYYY-MM-DD-latest.md
```

**Note all claims:**

- ✅ What was completed
- ⏳ What remains
- 📋 Follow-up tasks
- 🔢 Phase numbering (check for gaps)

### Step 2: Verify "Completed" Claims

**Cross-check against git log:**

```bash
# Session log says "Phase X: Feature Y completed ✅"
# Verify with git log:
git log --oneline --grep="feature-y" -n 10
git log --oneline --since="2025-10-18" | grep -i "feature"

# Check if commits exist
git show COMMIT_HASH
```

**Why:** Confirms work was actually committed, not just marked complete.

### Step 3: Verify "Remaining Work" Claims

**Cross-check against current code:**

```bash
# Session log says "Remaining Work: Add DebugMenu banking scenarios"
# Verify they're actually incomplete:
grep -r "handleBankScenario\|banking scenario" src/components/ui/DebugMenu.tsx

# If you find the code, it's NOT remaining work
# If you don't find it, it IS remaining work
```

**Why:** Prevents redoing already-completed work.

### Step 4: Verify "Follow-up Tasks"

**Check if tasks are actually incomplete:**

```bash
# Session log says "Follow-up: Add Bank to debug menu"
# Search codebase:
grep -r "Bank" src/components/ui/DebugMenu.tsx
find src -name "*Bank*.stories.tsx"

# If found, reconcile with session log
# Update mental model of what's truly pending
```

### Step 5: Check for Phase Numbering Gaps

**Look for discontinuities:**

```
Session log shows:
✅ Phase 1 complete
✅ Phase 2 complete
✅ Phase 6 complete  # ⚠️ Wait, where are Phases 3-5?
```

**Action:**

- Search git log for phases 3-5
- Search code for features from phases 3-5
- Ask user if phases 3-5 were skipped or completed but not documented

### Step 6: Reconcile File Counts

**Session log says "12 files created", verify:**

```bash
# Compare current branch to base
git diff --stat origin/stable...HEAD

# Count files changed
git diff --name-only origin/stable...HEAD | wc -l

# If counts don't match, investigate
```

---

## Real-World Example: DebugMenu Banking Scenarios

### What Happened (Session 2025-10-19)

**Step 1: Read Session Log**

- Found: "Follow-up: Add Bank to debug menu scenarios"
- Interpreted: This work is NOT done yet

**What I Should Have Done (Step 2-3):**

```bash
# Verify claim against code
grep -r "handleBank\|banking" src/components/ui/DebugMenu.tsx
```

**What I Would Have Discovered:**

```typescript
// 8 banking scenarios already implemented!
{ id: 'bank-free-tier', label: 'Free Tier (Banking Blocked)', ... }
{ id: 'bank-premium-empty', label: 'Premium: Empty Bank', ... }
{ id: 'bank-premium-low', label: 'Premium: Low Balance (1000)', ... }
// ... 5 more scenarios
```

**Conclusion:** Work was COMPLETE, session log just didn't mark it done.

**What I Did:**

- Trusted session log without verification
- Reported to user that DebugMenu work was pending
- User corrected me

**User's Feedback:**

> "can you explain with all the session logging we are doing and session hand off you didnt know from the start that thee debug menu work was done?"

**Grade: F** - Should have verified before trusting session log.

---

## Session Log Update Timing

### CRITICAL: Update BEFORE Commits, Not After

**Problem:** Session logs document investigation findings AFTER code is committed

**Why This is Wrong:**

- Session log explains the "why" behind the fix
- If code committed without documentation, you lose the thought process
- Next session can't understand the reasoning
- Makes it harder to learn from past mistakes

**Correct Workflow:**

```bash
# 1. Investigation phase
grep -r "BankOverlayManager" src/
# Found the issue: missing character prop

# 2. UPDATE SESSION LOG with findings
echo "## Investigation: Bank E2E Tests
Root Cause: testHarness.showBankOverlay() missing character prop
Evidence: Compared with Shop pattern, Bank doesn't pass character
Fix: Add character prop following Shop pattern" >> session-log.md

# 3. Implement fix
vim src/utils/testHarness.ts
# Add character prop

# 4. Commit BOTH code + session log together
git add src/utils/testHarness.ts docs/archive/session-handoffs/session-log.md
git commit -m "fix(tests): add missing character prop to bank overlay"
```

**Wrong Workflow:**

```bash
# ❌ BAD: Commit code first
git add src/utils/testHarness.ts
git commit -m "fix"

# ❌ BAD: Session log added later (or never)
# (Context/quota runs out, session ends without documentation)
```

**When To Update Session Log:**

| Event            | Update Session Log? | When                                    |
| ---------------- | ------------------- | --------------------------------------- |
| Found root cause | ✅ YES              | Immediately after discovery             |
| Implemented fix  | ✅ YES              | Before committing                       |
| Tests passing    | ✅ YES              | Document test results                   |
| About to commit  | ✅ YES              | Final check, ensure findings documented |
| After commit     | ❌ NO               | Too late! Should have done before       |

---

## Session Log Common Issues

### Issue 1: Incomplete Updates

**Problem:** Work completed but session log not updated

**Example:**

```markdown
## Remaining Work

- [ ] Add DebugMenu banking scenarios
```

**Reality:** Scenarios already added in later commit

**How to Detect:**

```bash
grep -r "banking scenario" src/components/ui/DebugMenu.tsx
# Found code = work is done, session log outdated
```

### Issue 2: Phase Numbering Gaps

**Problem:** Phases completed but not documented

**Example:**

```markdown
✅ Phase 1: Database schema
✅ Phase 2: Service layer
✅ Phase 6: Documentation
```

**Question:** What about Phases 3-5?

**How to Detect:**

```bash
# Search git log for phases 3-5
git log --oneline --grep="phase 3\|phase 4\|phase 5" -i

# Check if commits exist but not documented
```

### Issue 3: File Count Mismatches

**Problem:** Session log file count doesn't match git diff

**Example:**

```markdown
Created 12 new files this session
```

**How to Verify:**

```bash
git diff --name-only origin/stable...HEAD | wc -l
# Returns: 8 files

# Discrepancy = either files missing or count wrong
```

### Issue 4: Ambiguous Status

**Problem:** Unclear if work is done or in-progress

**Example:**

```markdown
- Banking UI (mostly complete)
```

**What does "mostly" mean?**

**How to Resolve:**

```bash
# Check if committed
git log --oneline | grep -i "banking ui"

# Check test coverage
grep -r "BankOverlay" tests/

# Determine actual state, not ambiguous claim
```

---

## Session Log Format Best Practices

### Clear Status Markers

**✅ GOOD:**

```markdown
## Completed This Session

- ✅ Phase 1: Database schema (commit abc123)
- ✅ Phase 2: Service layer (commit def456)

## Remaining Work

- ⏳ Phase 3: UI components
- ⏳ Phase 4: E2E tests
```

**❌ BAD:**

```markdown
## Work Done

- Database stuff (done-ish)
- Services (mostly working)

## TODO

- UI (next time maybe)
```

### Commit References

**✅ GOOD:**

```markdown
✅ BankingService complete (commit 3344aa5)
✅ BankOverlay UI complete (commit eeda715)
```

**Why:** Allows verification via `git show 3344aa5`

**❌ BAD:**

```markdown
✅ BankingService complete
✅ BankOverlay UI complete
```

**Why:** No way to verify, just trust

### Phase Numbering

**✅ GOOD:**

```markdown
✅ Phase 1: X
✅ Phase 2: Y
✅ Phase 3: Z
✅ Phase 4: Complete
```

**Why:** Sequential, no gaps, clear progression

**❌ BAD:**

```markdown
✅ Phase 1: X
✅ Phase 2: Y
✅ Phase 6: Z # ⚠️ What about 3-5?
```

---

## CONTINUATION_PROMPT.md Pre-Flight Step 11

**From CONTINUATION_PROMPT.md:**

```markdown
[ ] 11. CROSS-VERIFY session log claims against actual code state (see below)
```

**What to check:**

- [ ] Cross-check "Completed Phases" sections against git log (verify commits exist)
- [ ] Cross-check "Remaining Work" sections against current code (verify NOT already done)
- [ ] If session log lists "Follow-up Tasks", grep codebase to confirm they're incomplete
- [ ] Check for phase numbering gaps (e.g., "Phase 6 complete" but 7 phases planned = something missing)
- [ ] Reconcile session log file counts with actual git diff stats

**Commands to run:**

```bash
# Verify completed work
git log --oneline --since="YYYY-MM-DD" | grep -i "phase\|feature"

# Verify remaining work
grep -r "feature-name" src/

# Check file counts
git diff --stat origin/stable...HEAD
```

---

## When Session Logs Conflict With Code

**Priority order (most reliable to least):**

1. **Git commits** - Source of truth (code is committed or it isn't)
2. **Current code state** - What's actually in files right now
3. **Git log messages** - What was committed and when
4. **Session logs** - Human-written, may have omissions
5. **Memory/assumptions** - Least reliable, verify everything

**If session log conflicts with git/code:**

- Trust git/code
- Reconcile session log claims
- Report discrepancy to user
- Update understanding based on actual state

---

## Session Start Checklist

**Every session, complete this checklist:**

```markdown
## Session Start Verification

- [ ] Read latest session log
- [ ] Verify "Completed" claims against git log
- [ ] Verify "Remaining" claims against current code
- [ ] Check for phase numbering gaps
- [ ] Reconcile file counts (session log vs git diff)
- [ ] Update mental model based on actual code state

## Discrepancies Found

- Session log says X is TODO, but code shows X is done (commit abc123)
- Session log shows Phases 1,2,6 but no 3-5 (search git for missing phases)

## Actual State (After Verification)

- ✅ Feature X: Complete (verified in code + git log)
- ⏳ Feature Y: Incomplete (verified NOT in code)
- ❓ Feature Z: Unclear (ask user)
```

---

## Communication Pattern

**When you find discrepancies:**

**✅ GOOD:**

```
"I read the session log which lists 'Add DebugMenu banking scenarios' as
remaining work. However, I checked the code and found 8 banking scenarios
already implemented (grep shows handleBankScenario in DebugMenu.tsx).

Should I mark this as complete, or is there additional work beyond the
existing 8 scenarios?"
```

**❌ BAD:**

```
"The session log says to add DebugMenu scenarios, so I'll implement them."
```

**Why good approach works:**

- Shows you verified against code
- Provides specific evidence (grep results)
- Asks for clarification on discrepancy
- Doesn't waste time redoing completed work

---

## Session Handoff Template

**Use this template for clean handoffs:**

````markdown
# Session Log - YYYY-MM-DD - Task Name

## Summary

<One paragraph of what was accomplished>

## Completed This Session

- ✅ Phase 1: Feature X (commit abc123, 123 lines)
- ✅ Phase 2: Feature Y (commit def456, 89 lines)

## Remaining Work (Verified Against Code)

- ⏳ Phase 3: Feature Z (verified NOT in codebase)
- ⏳ Phase 4: Tests for Z (verified NOT in tests/)

## Verification Commands Run

```bash
git log --oneline --since="2025-10-19"
grep -r "Feature Z" src/
find tests -name "*feature-z*.spec.ts"
```
````

## Next Session Start Here

1. Read this session log
2. Run verification commands above
3. Verify "Remaining Work" still accurate
4. Continue with Phase 3

```

---

## Success Criteria

**You're managing sessions well when:**
- ✅ You verify session log claims before trusting them
- ✅ You catch when "TODO" work is already done
- ✅ You reconcile discrepancies between log and code
- ✅ You don't redo completed work
- ✅ User doesn't correct your understanding of what's done

**You're trusting blindly when:**
- ❌ User says "did you check if that's already done?"
- ❌ You start implementing something that exists
- ❌ You miss phase numbering gaps
- ❌ You report wrong status to user
- ❌ Session logs conflict with reality and you didn't notice

---

## Related Lessons
- [04-context-gathering.md](04-context-gathering.md) - Verify with code, not assumptions
- [03-user-preferences.md](03-user-preferences.md) - Read requests twice, verify everything

## Related Documentation
- [CONTINUATION_PROMPT.md](/home/alan/projects/scrap-survivor/CONTINUATION_PROMPT.md) - Pre-flight Step 11
- [docs/README.md](/home/alan/projects/scrap-survivor/docs/README.md) - Session Log format

## Session References
- CONTINUATION_PROMPT.md - Session Log Cross-Verification section (lines 57-87)
- [session-log-2025-10-19-part3-lessons-learned.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part3-lessons-learned.md)
```
