# Lesson 42: CONTINUATION_PROMPT Stability - Separate Protocols from State

**Date:** 2025-11-04
**Session:** 23
**Category:** Architecture / Documentation
**Severity:** Medium (Process improvement)

---

## The Problem

CONTINUATION_PROMPT.md contained both:

- ✅ Stable core protocols (approval, directory awareness, checklists)
- ❌ Sprint-specific state (current session, last commit, what's next)

**Consequence:**

- CONTINUATION_PROMPT changed every session
- Mixed stable protocols with volatile state
- Less deterministic workflows (rules drifted with state updates)
- Unclear what should change vs what should be stable

---

## The Root Cause

**Original design assumption:** "Put everything in one place for convenience"

**Why this failed:**

- Core protocols (Lesson 38, 39, 40) should be stable
- Sprint state (current session, commits) changes constantly
- Mixing them caused drift and confusion
- Hard to tell "what changed?" when reviewing CONTINUATION_PROMPT

---

## The Solution

**Architectural separation:**

```
CONTINUATION_PROMPT.md
├─ Core protocols (STABLE - changes only when adding new lessons)
├─ Approval protocol
├─ Directory awareness
├─ Task-specific checklists
├─ Systematic debugging
└─ Philosophy alignment

docs/sprints/sprint-{N}/INDEX.md
├─ Sprint state (VOLATILE - updated every session)
├─ Current session number
├─ Last commit hash
├─ What was just completed
├─ What's next
└─ Progress metrics (4/6 screens migrated)

SESSION-XX-PLAN.md
├─ Task-specific context
├─ Implementation steps
├─ Success metrics
└─ Quick start instructions
```

**Session startup:**

1. Read CONTINUATION_PROMPT.md (core protocols - stable)
2. Read docs/sprints/sprint-{N}/INDEX.md (current state - volatile)
3. Read SESSION-XX-PLAN.md (task context - one-time)

---

## Evidence

**Before fix:**

- CONTINUATION_PROMPT.md: 2633 lines (Session 0) → 2650 lines (Session 15) → drift
- "Session Resumption Quick Start" section updated every session
- Hard to tell what changed vs what's protocol

**After fix:**

- CONTINUATION_PROMPT.md: 750 lines (stable core protocols)
- Sprint state lives in INDEX.md (already updated every session)
- Clear separation of concerns

---

## The Pattern

**General rule:** Separate **contracts** from **state**

**Contracts (stable):**

- Operating procedures
- Quality standards
- Mandatory checklists
- Lessons learned
- Philosophy/principles

**State (volatile):**

- Current progress
- Last commit
- What's next
- Session numbers
- Completion status

**Task context (one-time):**

- Specific implementation steps
- Template to follow
- Success criteria

---

## Benefits

1. **Deterministic workflows:** Core protocols don't drift with state changes
2. **Single source of truth:** Sprint state lives in INDEX.md only
3. **Easier to review:** "What changed?" is clearer when state is separate
4. **Scalable:** Sprint 19, 20, 21 will all use the same CONTINUATION_PROMPT
5. **Versioning:** Can track protocol changes vs state changes separately

---

## Implementation

**Changed in Session 23:**

- Removed "Session Resumption Quick Start" from CONTINUATION_PROMPT.md (85 lines)
- Added pointer section explaining separation
- Sprint state already lived in INDEX.md (no new files needed)

**Pre-flight checklist already had:**

- Step 0.5: "READ CURRENT SPRINT SESSION LOG" (docs/sprints/sprint-{N}/INDEX.md)
- Infrastructure was already in place!

---

## When to Apply This

**Use this pattern when:**

- Documentation mixes protocols and state
- Files change every session but shouldn't
- Hard to tell "what's a rule" vs "what's current progress"
- Multiple sprints/projects share core protocols

**Signs you need this:**

- "Why did CONTINUATION_PROMPT change again?"
- "What's the stable version to reference?"
- "Are these new rules or just state updates?"

---

## Related Lessons

- **Lesson 22:** Session planning standards (created global template)
- **Lesson 21:** Documentation modularization (split protocols by topic)
- **Session 22 work:** Created docs/standards/ and sprint-18-protocols.md

**This completes the modularization started in Session 22.**

---

## Key Insight

**User's observation:** "i think continuation prompt shouldn't change very often it's like core operating process"

**Exactly right.** Stable protocols enable deterministic workflows. State changes are expected, but rules should only change when we learn new lessons.

---

**Status:** ✅ Fixed
**Commit:** c47d540 - refactor(docs): Make CONTINUATION_PROMPT stable by removing sprint state
**Impact:** All future sprints benefit from this separation
