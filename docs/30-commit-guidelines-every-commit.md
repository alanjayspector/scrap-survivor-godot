# Lesson 30: Commit Guidelines Must Be Checked Before EVERY Commit

**Date:** 2025-10-22
**Context:** Sprint 16 Phase 3 - Error handling implementation
**Severity:** 🔴 Critical Process Violation

---

## 🚨 THE PROBLEM

During Sprint 16 Phase 3, I made **4 git commits** and got commitlint errors on **3 of them** for capital letters in subject lines:

1. ❌ `feat(error): add Error**S**ervice...` → Capital "S"
2. ❌ `feat(telemetry): add error tracking with Error**E**vent**P**ayload...` → Capital "E" and "P"
3. ❌ `feat(circuit-breaker): add onError callback to protected supabase **C**lient` → Capital "C"
4. ✅ `docs(protocol): update pre-flight checklist...` → Correct

**Root Cause:** I relied on memory instead of consulting the commit guidelines before each commit.

---

## 📖 WHAT THE CHECKLIST SAYS

From [before-you-start-checklist.md:76-82](../development-guide/before-you-start-checklist.md):

```markdown
**🚨 CRITICAL - Before FIRST Commit:**

- [ ] Open `docs/development-guide/commit-guidelines.md`
- [ ] Read lines 76-96 (Subject Line Rules)
- [ ] Keep file open while writing commits
- [ ] Check each rule: lowercase, imperative, no period, under 100 chars
- [ ] **DO NOT** rely on memory or commitlint to catch errors
```

**Key phrase:** "Keep file open while writing commits" - not just for the first commit!

---

## ❌ WHAT I DID WRONG

### Mistake 1: Only Checked Guidelines Once

- ✅ I read the guidelines after context rollover
- ❌ I did NOT re-check them before subsequent commits
- ❌ I assumed I "remembered" the rules

### Mistake 2: Didn't Use Query System

I should have queried before each commit:

```bash
./scripts/ask-session-history.sh "What are the commit message rules? Include format requirements and common mistakes."
```

This would have reminded me:

- **lowercase** subjects (not "Service", "EventPayload", "Client")
- **imperative mood** ("add" not "adds")
- **no period** at end
- **<100 chars**

### Mistake 3: Relied on Commitlint as Safety Net

- Commitlint catches errors, but creates rework
- Each failed commit = wasted time fixing and re-running pre-commit hooks
- The checklist explicitly says: "**DO NOT rely on memory or commitlint**"

---

## ✅ CORRECT PROCESS

### Option 1: Query Before Each Commit (Recommended for AI)

```bash
# Before writing ANY commit message:
./scripts/ask-session-history.sh "What are the commit subject line rules? Show lowercase requirement."
```

**Why this works:**

- 1-3 second query time (minimal overhead)
- Fresh reminder every time
- Prevents ALL mistakes, not just some

### Option 2: Keep Guidelines Open (For Humans)

```bash
# Open in separate terminal/editor:
cat docs/development-guide/commit-guidelines.md
```

Then check against lines 76-96 before each commit.

### Option 3: Use Template Pattern

Create commit message template first, then fill in:

```bash
# Template (all lowercase, imperative):
feat(scope): add [feature name] with [key capability]

# Examples:
feat(error): add error service with singleton pattern
feat(telemetry): add error tracking with event payload interface
feat(circuit-breaker): add on error callback to protected client
```

---

## 🎯 THE ACTUAL RULE (From commit-guidelines.md:76-96)

```markdown
**Subject Line Rules:**

1. **Lowercase**: Subject must be entirely lowercase
   ❌ "Add ErrorService"
   ✅ "add error service"

2. **Imperative Mood**: Use "add", "fix", "remove" (not "adds", "fixed")
   ✅ "add feature"
   ❌ "adds feature"

3. **No Period**: Subject must not end with a period
   ✅ "add error service"
   ❌ "add error service."

4. **Length**: Subject ≤100 characters
```

**Commitlint enforces these rules**, but catching errors wastes time.

---

## 📊 IMPACT ANALYSIS

**Time Cost per Failed Commit:**

1. Write commit message with error
2. Commitlint fails
3. Re-write commit message
4. Pre-commit hooks re-run (linting, formatting, tsc)
5. Commit succeeds

**Estimated time per error:** 30-60 seconds
**Total wasted in this session:** 1.5-3 minutes (3 errors)

**Preventable with 3-second query:** YES

---

## 🔄 WHEN TO CHECK GUIDELINES

### ❌ WRONG: "Only once per session"

- First commit after context rollover ✓
- All subsequent commits ✗ (relying on memory)

### ✅ RIGHT: "Before EVERY commit"

- First commit after context rollover ✓
- Second commit ✓
- Third commit ✓
- Fourth commit ✓
- ...every single commit ✓

**Why:** Memory is fallible, especially for syntax rules (lowercase vs PascalCase, etc.)

---

## 🎓 DEEPER LESSON: PATTERN VERIFICATION

This mistake revealed a **second** issue: I also didn't verify my implementations against **PATTERN-CATALOG.md** and **PATTERN-CATALOG-SUPPLEMENTARY.md**.

**What I should have checked:**

1. Does ErrorService follow the Service Pattern? (PATTERN-CATALOG.md:30-115)
2. Does it use ProtectedSupabaseClient where needed?
3. Does it integrate logger/telemetry correctly?
4. Are there Supabase-specific patterns I missed?

**Lesson:** Pre-flight checklist includes:

- Step 0: Query session history
- Step 1: Read relevant documentation
- Step 2: Check existing source code
- **Step 2.5:** Verify against PATTERN-CATALOG.md (I missed this!)

---

## 💡 WHY THIS MATTERS

### For AI Assistants (Claude)

- No "muscle memory" for commit syntax
- Easy to confuse PascalCase (code) with lowercase (commits)
- Query system exists specifically to prevent this
- **Each mistake erodes user confidence**

### For Human Developers

- Commitlint is a safety net, not the primary check
- Guidelines should be consulted, not memorized
- Consistent commits improve git history readability

---

## ✅ ACTION ITEMS

### Immediate Fix

- [ ] Before EVERY commit, query: `./scripts/ask-session-history.sh "commit subject line rules"`
- [ ] OR keep [commit-guidelines.md:76-96](../development-guide/commit-guidelines.md) open in editor

### Process Improvement

- [ ] Add "Before Commit Checklist" section to pre-flight guide
- [ ] Add reminder to query guidelines before first AND subsequent commits
- [ ] Consider creating a git commit-msg hook that shows the rules before accepting input

### Pattern Verification

- [ ] Always cross-check implementations against PATTERN-CATALOG.md
- [ ] Query: "What patterns should [FeatureName] follow?" before implementing
- [ ] Verify Service Pattern compliance for all services
- [ ] Verify Supabase patterns for all database interactions

---

## 📝 RELATED LESSONS

- [Lesson 16: Following Conventions (Not Memory)](./16-following-conventions-not-memory.md) - Same root cause
- [Lesson 22: NotebookLM Documentation Queries](./22-notebooklm-documentation-queries.md) - Query system usage
- [Before You Start Checklist](../development-guide/before-you-start-checklist.md) - Pre-flight protocol

---

## 🎯 SUMMARY

**The Rule:** Check commit guidelines before **EVERY** commit, not just the first one.

**The Method:** Query session history OR keep guidelines open.

**The Reason:** Memory fails, query succeeds. 3 seconds prevents 60 seconds of rework.

**The Evidence:** 3 errors in 4 commits = 75% failure rate when relying on memory.

**User Quote:** "the fact you made the git commit error means you either had a context rollover or you didnt do the pre-flight check again after the first rollover?"

**Takeaway:** Pre-flight checks apply to **recurring actions** (like commits), not just session start.
