# Lesson 16: Following Conventions (Not Memory)

**Category:** 🔴 Critical (Every Session)
**Last Updated:** 2025-10-19 (Session Part 10 - Commit Convention Violation)
**Sessions:** 2025-10-19 Part 10 (Every chat, every session)

---

## The Problem

**Context:** User reports "EVERY CHAT" I confirm understanding of conventions, then violate them.

**Example from This Session:**

```bash
# First attempt
git commit -m "fix(banking): remove explicit owner_user_id from INSERT - let trigger set it"
✖ subject must be lower-case [subject-case]

# Had to retry
git commit -m "fix(banking): remove explicit owner_user_id from insert - let trigger set it"
✅ Success
```

**User Feedback:**

> "you also set my confidence score to low when you yet again (EVERY CHAT) decided to forget our coding conventions that you said you understood in the pre flight checklist"

---

## The Real Problem

### It's Not About Memory

**I'm not forgetting conventions.**

**I'm failing to FOLLOW them.**

**There's a difference:**

- ❌ **Memory:** "I remember commit messages should be lowercase"
- ✅ **Following:** "I'm reading commit-guidelines.md before committing"

### The Pattern

**Every session:**

1. I read CONTINUATION_PROMPT.md
2. I acknowledge Before You Start Checklist
3. I say "I understand conventions"
4. I commit without actually checking the file
5. Commitlint catches the error
6. User loses confidence

**This is treating the checklist as performative**, not as actual workflow.

---

## What I'm Doing Wrong

### Performative Compliance

```
User: "Did you read the checklist?"
Me: "Yes, I've reviewed it"
Me: *proceeds to commit without checking commit-guidelines.md*
Commitlint: ✖ subject must be lower-case
User: *loses confidence*
```

**This is checkbox thinking, not systematic following.**

### Relying on Safety Nets

**The tools I rely on:**

- Commitlint catches format errors
- Pre-commit hooks catch linting
- TypeScript catches type errors

**The problem:** These are LAST resorts, not first-line defense.

**User's expectation:** Get it right the FIRST time by following docs.

---

## The Solution

### Actual Following (Not Performative)

**Before FIRST commit in ANY session:**

1. **Open the file**

   ```bash
   cat docs/development-guide/commit-guidelines.md
   ```

2. **Read lines 76-96** (Subject Line Rules)

   ```
   1. Lowercase: Subject must be all lowercase
   2. No period: Don't end subject with a period
   3. Imperative mood: Use "add" not "added"
   4. Max length: Keep under 100 characters
   ```

3. **Keep it open while writing commit**
   - Reference it directly
   - Don't trust memory
   - Check each rule

4. **Write commit following EXACT format**

   ```bash
   git commit -m "type(scope): lowercase imperative description"
   ```

5. **THEN commit**

### Why This Works

**Reading file = Evidence-based**

- Not relying on memory
- Not relying on tools to catch errors
- Not guessing

**Following = Systematic**

- Repeatable process
- Works every session
- Builds user confidence

---

## The Specific Convention

### Commit Message Rules (From commit-guidelines.md)

**Format:**

```
type(scope): subject

Optional body.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Subject Line MUST:**

1. **Be lowercase**
   - ✅ `fix(banking): remove explicit owner_user_id from insert`
   - ❌ `fix(banking): remove explicit owner_user_id from INSERT`

2. **Use imperative mood**
   - ✅ `add feature`
   - ❌ `added feature` or `adds feature`

3. **Have no trailing period**
   - ✅ `fix bug`
   - ❌ `fix bug.`

4. **Be under 100 characters**

**Valid types:**

- `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`, `build`, `ci`, `revert`

**Source:** [docs/development-guide/commit-guidelines.md](../../development-guide/commit-guidelines.md)

---

## Why "EVERY CHAT"

### Pattern Recognition

**This isn't a one-time mistake.**

**User reports it happens EVERY CHAT:**

- Session 1: Violate conventions
- Session 2: Acknowledge mistake, violate again
- Session 3: Acknowledge mistake, violate again
- Session 10: _Still violating_

**Why?**

1. **Summary context doesn't preserve the habit**
   - I get knowledge transfer
   - I don't get behavioral transfer

2. **I treat checklists as acknowledgment, not workflow**
   - "Yes I've seen it" ≠ "Yes I'm following it"

3. **I rely on memory between steps**
   - Read checklist at start
   - Commit 30 minutes later
   - Don't re-check the file

---

## The Fix for Every Session

### CONTINUATION_PROMPT.md Must Remind

**Add to mandatory pre-flight checklist:**

```markdown
**CRITICAL: Before FIRST commit:**

1. Open commit-guidelines.md
2. Read Subject Line Rules (lines 76-96)
3. Keep it open while writing commit message
4. Check each rule before committing

DO NOT rely on:

- Memory of format
- Commitlint to catch errors (last resort)
- "I know how commit messages work"

USER REPORTS: "EVERY CHAT" AI forgets conventions despite saying
they understand. The issue is not knowledge, it's systematic following.
```

### Before-You-Start-Checklist.md Must Enforce

**Change from:**

```
- [ ] Read commit-guidelines.md
```

**To:**

```
- [ ] Open commit-guidelines.md (keep it open)
- [ ] Read lines 76-96 (Subject Line Rules)
- [ ] BEFORE FIRST COMMIT: Re-read these rules
- [ ] Use file as reference while writing commits
```

---

## Other Conventions to Follow (Not Memorize)

### TypeScript Conventions

**Source:** [docs/development-guide/coding-standards.md](../../development-guide/coding-standards.md)

**Rule:** Type-only imports

```typescript
// ✅ Correct
import type { MyType } from './types';

// ❌ Wrong
import { MyType } from './types';
```

**How to follow:** Check file before writing imports

### Testing Conventions

**Source:** [docs/development-guide/testing-strategy.md](../../development-guide/testing-strategy.md)

**Rules:**

- 90%+ coverage
- Test files end in `.test.ts` or `.test.tsx`
- Use vitest, not jest

**How to follow:** Check file before writing tests

### Component Conventions

**Source:** [docs/development-guide/coding-standards.md](../../development-guide/coding-standards.md) lines 94-211

**Rules:**

- Use design tokens (no hardcoded values)
- React.memo() for performance
- Accessibility (ARIA, keyboard)

**How to follow:** Check file before creating components

---

## Self-Check Questions

Before ANY commit, ask:

1. **Have I opened commit-guidelines.md this session?**
   - If no → Open it now
   - If yes → When? If > 30 minutes ago, re-read it

2. **Am I looking at the file while writing this commit?**
   - If no → Open it now
   - If yes → Good, check each rule

3. **Does my subject line match the rules?**
   - Lowercase? (check letter by letter if needed)
   - Imperative? (add, not added)
   - No period? (check end of string)
   - Under 100 chars? (count if unsure)

4. **Am I relying on memory or docs?**
   - Memory → WRONG
   - Docs → CORRECT

---

## The Meta-Lesson

### From Lesson 01 (Git Operations)

**Quote from Line 199:**

> "Even when you KNOW commit guidelines exist, you must CHECK them before every commit."

**What Happened (Session 2025-10-19 Part 3):**

- I spent 2+ hours documenting "read docs before doing things"
- Then immediately committed with WRONG format (uppercase "Problem")
- Pre-commit hook rejected it
- I had to fix it (lowercase "problem")

**User's Response:**

> "so commit messages is something we covered extensively in under docs/01 getting started .. what did you just learn? :) while doing this wrap up ?"

### The Fundamental Issue

**Knowing docs exist ≠ Following docs**

**This lesson system exists BECAUSE:**

- I can document lessons
- Then immediately violate them
- Without systematic reminders

**The solution is NOT:**

- Better documentation
- More lessons learned
- Clearer explanations

**The solution IS:**

- Systematic workflow
- Check file EVERY time
- Don't trust memory

---

## Testing This Lesson

### Scenario: Writing a Commit

**❌ Wrong Approach:**

```
1. Make code changes
2. git add .
3. Write commit from memory
4. git commit -m "Fix(Banking): Remove Owner User ID"
5. ✖ Commitlint error
6. Fix and retry
7. User loses confidence
```

**✅ Correct Approach:**

```
1. Make code changes
2. git add .
3. OPEN commit-guidelines.md
4. READ lines 76-96
5. WRITE commit following rules
6. CHECK against file
7. git commit -m "fix(banking): remove owner user id"
8. ✅ Success first try
9. User confidence maintained
```

---

## Summary

**Following conventions isn't about memory - it's about systematic checking.**

**The Protocol:**

1. **Before first commit** - Open commit-guidelines.md
2. **Read the rules** - Lines 76-96 (Subject Line Rules)
3. **Keep it open** - Reference while writing
4. **Check each rule** - Lowercase, imperative, no period, under 100 chars
5. **Then commit** - Only after checking

**Why this matters:**

- User reports "EVERY CHAT" I violate conventions
- This destroys confidence in my work
- It's not a knowledge problem - it's a behavior problem
- Systematic following solves it

**What doesn't work:**

- ❌ "I understand conventions" (performative)
- ❌ Relying on memory from session start
- ❌ Relying on commitlint to catch errors
- ❌ "I know how this works from other projects"

**What works:**

- ✅ Open the file before committing
- ✅ Read the specific rules
- ✅ Check commit against file
- ✅ Use docs as reference, not memory

**The real lesson:**

This is Lesson 16, but it's really Lesson 1 repeated:
**READ THE DOCS BEFORE DOING THE THING.**

Every lesson is a variation of this same fundamental issue:

- I acknowledge docs exist
- I don't actually use them as workflow
- I treat checklist as performative
- User loses confidence

**Fix:** Make docs usage SYSTEMATIC, not optional.

---

## Related Lessons

- [Lesson 01: Git Operations](01-git-operations.md) - Lines 197-253 (same issue!)
- [Lesson 09: AI Execution Protocol](09-ai-execution-protocol.md) - Read docs BEFORE coding
- [Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md) - Code IS docs

---

**Session Reference:** Every session, but especially [session-log-2025-10-19-part10-bank-duplicate-rows.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)

**User Quote:**

> "you also set my confidence score to low when you yet again (EVERY CHAT) decided to forget our coding conventions that you said you understood in the pre flight checklist"
