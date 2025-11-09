# Lesson 27: Task-Specific Checklist Forcing Function

**Created:** 2025-10-22
**Session:** Sprint 16 - Error Handling
**Category:** 🔴 Critical - Process Protocol
**Related:** Lesson 25 (AI Following Problem), Lesson 16 (Following Conventions)

---

## The Problem

**AI assistants skip task-specific checklists even when they exist in documentation.**

### What Happened (Sprint 16, 2025-10-22):

**Task:** Implement user-facing error components (ErrorToast, ErrorModal)

**What I Did:**

1. ✅ Read CONTINUATION_PROMPT.md
2. ✅ Read commit-guidelines.md
3. ✅ Read coding-standards.md **WITH `limit=100` PARAMETER** ❌
4. ❌ **SKIPPED Component Creation Checklist at line 96**
5. ❌ **NEVER READ ui-design-system.md**
6. ❌ Started planning implementation without Storybook stories
7. ❌ Planned implementation-first instead of test-first

**User Caught It:**

> "shouldn't our startup make sure this was in your context or at the very least have a protocol to check when doing ui?"

**Root Cause:**

- Used `Read(file, limit=100)` which cut off before Component Creation Checklist (line 96)
- No forcing function to verify task-specific checklist completion
- CONTINUATION_PROMPT.md says "Read docs" but doesn't say "Complete Component Creation Checklist"

---

## The Pattern

**This is the THIRD TIME this failure mode has occurred:**

### Instance 1: Sprint 13 - Banking E2E Tests

- Started writing tests without reading playwright-guide.md
- Missed test ID requirements
- User: _"our testing documentation should clearly state we use test ids"_

### Instance 2: Sprint 13 - Session Log Cross-Verification

- Didn't check Component Creation Checklist before UI work
- Forgot Storybook stories requirement
- User corrected: _"did you notice you didn't have any tasks for unit tests"_

### Instance 3: Sprint 16 - Error Components (THIS SESSION)

- Read coding-standards.md with `limit=100` (cut off at line 100, checklist starts at line 96!)
- Never read ui-design-system.md
- Skipped Storybook stories
- User: _"shouldn't our startup make sure this was in your context or at the very least have a protocol to check when doing ui?"_

---

## Why This Keeps Happening

**Reading ≠ Following (Lesson 25)**

The issue is **NOT** knowledge - it's **SYSTEMATIC VERIFICATION**.

**Current CONTINUATION_PROMPT.md approach:**

```
Step 1: READ DOCUMENTATION
- Working on UI? → Read ui-design-system.md
- Working on services? → Read existing service patterns
```

**The gap:**

- Says "read" but doesn't enforce "complete checklist"
- No verification that checklist was followed
- No task-type detection forcing function

---

## The Solution: Task-Specific Checklist Protocol

**Add to CONTINUATION_PROMPT.md after "Critical Rule #2":**

```markdown
## 🚨 CRITICAL RULE #3: TASK-SPECIFIC CHECKLIST FORCING FUNCTION

**BEFORE planning ANY implementation, identify task type and complete mandatory checklist.**

### Step 1: Identify Task Type

| Task Type              | Indicators                                           |
| ---------------------- | ---------------------------------------------------- |
| **UI Component**       | Creating/modifying files in `src/components/ui/`     |
| **Service**            | Creating/modifying files in `src/services/`          |
| **E2E Test**           | Creating/modifying files in `tests/` with `.spec.ts` |
| **Database Migration** | Creating files in `supabase/migrations/`             |
| **Unit Test**          | Creating/modifying `.test.ts` files                  |

### Step 2: Execute Mandatory Checklist

**UI Component Checklist** (coding-standards.md:96-145):
```

[ ] Read ui-design-system.md IN FULL (no limit parameter!)
[ ] Read Component Creation Checklist (coding-standards.md:96-145)
[ ] Verify: Component file (.tsx) + Test file (.test.tsx) + Storybook (.stories.tsx)
[ ] Verify: Test-first approach (write tests BEFORE implementation)
[ ] Verify: 90%+ coverage requirement
[ ] Verify: Accessibility requirements (ARIA, keyboard, touch targets)

```

**Service Checklist:**
```

[ ] Read ProtectedSupabaseClient pattern
[ ] Read telemetry requirements (coding-standards.md Section 7)
[ ] Verify: Uses protectedSupabase.query() not raw supabase calls
[ ] Verify: Telemetry tracking for all user-facing operations
[ ] Verify: Error handling with try/catch + logger

```

**E2E Test Checklist:**
```

[ ] Read playwright-guide.md IN FULL
[ ] Review existing E2E tests in same domain (tests/shop/, tests/workshop/)
[ ] Verify: Uses data-testid attributes (testIds.ts convention)
[ ] Verify: Mobile-first viewport
[ ] Verify: Test user journeys not implementation details

```

### Step 3: Literal Match Verification

Before claiming "checklist complete", provide PROOF:

**Example - UI Component:**
```

Task Type: UI Component (creating ErrorToast.tsx)
Checklist: Component Creation Checklist (coding-standards.md:96-145)

Proof of Completion:
✅ Read ui-design-system.md (200 lines, noted OVERLAY_COLORS, SHADOWS, accessibility)
✅ Read Component Creation Checklist (coding-standards.md:96-145 IN FULL)
✅ Verified file structure: ErrorToast.tsx + ErrorToast.test.tsx + ErrorToast.stories.tsx
✅ Verified test-first: Write tests BEFORE implementation
✅ Verified coverage: 90%+ requirement (from coding-standards.md:122)
✅ Verified accessibility: ARIA labels, keyboard nav, touch targets 44px minimum

Ready to proceed: YES

```

### Step 4: Anti-Pattern Detection

**❌ WRONG - What I Did This Session:**
```

1. Read coding-standards.md with limit=100
2. Skipped Component Creation Checklist (line 96)
3. Never read ui-design-system.md
4. Started planning without Storybook stories
5. User had to correct me

```

**✅ CORRECT - What I Should Have Done:**
```

1. Identify task type: UI Component
2. Open coding-standards.md:96 (Component Creation Checklist)
3. Read ui-design-system.md IN FULL (no limit!)
4. Complete checklist with proof
5. THEN plan with: Component + Test + Stories + Test-first approach

```

```

---

## Implementation

**File to Update:** `CONTINUATION_PROMPT.md`

**Location:** After line 110 (end of Critical Rule #2)

**New Section:** Critical Rule #3 (Task-Specific Checklist Forcing Function)

---

## Success Criteria

**This lesson is successful when:**

1. ✅ CONTINUATION_PROMPT.md includes task-specific checklist protocol
2. ✅ Future sessions detect task type BEFORE planning
3. ✅ Future sessions provide proof of checklist completion
4. ✅ Zero user corrections for "you forgot to read X"
5. ✅ Zero user corrections for "you forgot to create Y test/story file"

---

## Key Takeaway

**Reading documentation ≠ Following checklists**

The forcing function must:

- Detect task type automatically
- Require checklist completion with proof
- Verify ALL required artifacts (Component + Test + Stories)
- Enforce test-first approach

**Quote from User (2025-10-22):**

> "shouldn't our startup make sure this was in your context or at the very least have a protocol to check when doing ui?"

**Answer:** YES. This lesson establishes that protocol.

---

## Related Lessons

- **Lesson 16:** Following Conventions (Not Memory) - Keep docs open WHILE working
- **Lesson 25:** AI Following Problem Forcing Function - Reading ≠ Following
- **Lesson 20:** User Documentation Tells Truth - Keep docs open while working

---

**Status:** Protocol improvement required (update CONTINUATION_PROMPT.md)
**Priority:** 🔴 Critical - Prevents repeated user corrections
**Next Action:** Update CONTINUATION_PROMPT.md with Critical Rule #3
