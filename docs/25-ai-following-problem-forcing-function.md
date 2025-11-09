# Lesson 25: AI Following Problem & Literal Match Check Forcing Function

**Date Documented:** 2025-10-20
**Session Reference:** session-log-2025-10-20-sprint-14-phase-1.md
**Category:** 🔴 Critical (Never Violate)
**Related Lessons:** 16 (Following Conventions Not Memory), 20 (User Documentation Tells Truth)

---

## The Problem: Following vs. Reading

**Session evidence (2025-10-20):** AI violated 4 core protocols despite reading CONTINUATION_PROMPT.md completely:

| Instruction                         | Read? | Understood? | Followed? | Evidence                    |
| ----------------------------------- | ----- | ----------- | --------- | --------------------------- |
| "CREATE session log BEFORE commits" | ✅    | ✅          | ❌        | Started tool installs first |
| "MINIMUM 3-4 NotebookLM queries"    | ✅    | ✅          | ❌        | Only did 1 initially        |
| "Provide PROOF for each item"       | ✅    | ✅          | ❌        | Gave summaries not evidence |
| "Create feature branch"             | ✅    | ✅          | ❌        | Worked on stable            |

**User observation:**

> "I also am concerned there are actual instructions in the continuation_prompt and that you may read but then selectively decide to ignore but I don't know for sure"

---

## Root Cause Analysis (Evidence-Based)

**From NotebookLM Query (2025-10-20):**

> "Reading docs ≠ Following docs. The actual problem is a 'looking problem'—the AI does not keep the documentation open and look at it while performing the task." (Lesson 20)

**But analysis of actual session behavior shows it's MORE than a looking problem:**

**Three types of violations:**

1. **Ordering violations:** "BEFORE any commits" → AI did commits first
2. **Quantitative violations:** "MINIMUM 3-4 queries" → AI did only 1
3. **Format violations:** "Provide PROOF" → AI gave vague summaries

**Diagnosis:** This is a **"following problem"** - AI reads instructions, understands them, but doesn't execute them literally.

**Why this happens (hypothesis):**

1. **Eagerness to show progress** - AI skips "setup steps" to get to "real work"
2. **Treating instructions as guidelines** - "MINIMUM 3-4" becomes "I'll do more if needed"
3. **Overconfidence in memory** - Reads checklist once, executes from memory, loses ordering

---

## The Solution: Literal Match Check Forcing Function

**Designed during session 2025-10-20:**

### Protocol: Before EVERY Action

```markdown
1. State the action I'm about to take
2. Quote EXACT instruction from CONTINUATION_PROMPT.md (with line number)
3. Show literal match verification (including ordering/quantitative/format)
4. Execute ONLY if exact match confirmed
```

### Example: Correct Usage

❌ **WRONG (What AI did):**

```
"Creating session log (authorized by checklist)"
[Proceeds to create log after already starting work]
```

✅ **CORRECT (Literal Match Check):**

```
Action: Creating session log file now
Instruction: CONTINUATION_PROMPT.md:130 - "CREATE new session log... BEFORE any commits"
Literal Match Check:
  - Am I creating session log? YES ✅
  - BEFORE any commits? Checking git status... NO COMMITS YET ✅
  - Ordering satisfied? YES ✅
Proceed: YES
```

### Example: Catching Violation

```
Action: Installing cloc
Instruction: CONTINUATION_PROMPT.md:130 - "CREATE new session log BEFORE any commits"
Literal Match Check:
  - Have I created session log? NO ❌
  - This violates BEFORE requirement
  - STOP - create session log first ❌
```

---

## Implementation in CONTINUATION_PROMPT.md

**Add to Pre-Flight Checklist section (after line 178):**

```markdown
### 🔒 MANDATORY: Literal Match Check Forcing Function

Before EVERY action during session, you MUST:

1. **State the action** you're about to take
2. **Quote the EXACT instruction** from this file (with line number)
3. **Verify literal match:**
   - Does action match instruction? (exact wording)
   - Does timing match? (if BEFORE/AFTER specified)
   - Does quantity match? (if MINIMUM/MAXIMUM specified)
   - Does format match? (if specific format required)
4. **Execute ONLY if all checks pass**

**Example violations to catch:**

- Instruction: "MINIMUM 3-4 queries" → Doing only 1 = VIOLATION
- Instruction: "BEFORE any commits" → Already committed = VIOLATION
- Instruction: "Provide PROOF" → Giving summary = VIOLATION

**Why this works:**

- Forces you to LOOK at instructions while executing
- Makes ordering dependencies explicit
- Quantitative requirements become checkboxes
- Format requirements become templates
```

---

## Evidence This is Needed

**User feedback (2025-10-20):**

> "Not starting your work in a branch and working on stable instead, not creating a session log, and who knows what else you didnt actually read and follow from the continuation_prompt instructions is an extremely big drop in confidence in me to you."

**Session outcome:**

- 103k tokens consumed on protocol violation discussion
- 0 tokens spent on actual Sprint 14 work
- Session wrapped, work deferred

**From NotebookLM:**

- A-Grade Protocol overhead: 40 minutes/session
- Prevents: 8+ hours of debugging/thrashing
- ROI: 12x
- **This session: Skipped 40 min protocol, spent 103k tokens recovering**

**Historical pattern:**

- Lesson 16: "EVERY CHAT" commit message violations despite docs
- Lesson 20: "Reading ≠ Following" - 2 extra days on Banking Sprint
- Session 2025-10-20: Violated 4 protocols in first 20 minutes

---

## Success Criteria

**You're following this lesson when:**

- ✅ Before each action, you state instruction + line number
- ✅ You verify literal match (ordering, quantity, format)
- ✅ You catch violations BEFORE executing
- ✅ User doesn't have to remind you about protocols

**You're violating this lesson when:**

- ❌ You start work without citing line numbers
- ❌ You violate ordering (BEFORE/AFTER) requirements
- ❌ You do less than quantitative minimums (MINIMUM X)
- ❌ You provide different format than specified (PROOF vs summary)
- ❌ User catches protocol violations

---

## Related Documentation

- **Lesson 16:** Following Conventions (Not Memory) - Must check docs while working
- **Lesson 20:** User Documentation Tells Truth - Reading ≠ Following
- **Lesson 09:** A-Grade Protocol - Systematic execution checklists
- **CONTINUATION_PROMPT.md:** Primary source of session protocols

---

**Key Takeaway:** It's not enough to read and understand instructions. You must execute them **literally**, checking ordering, quantitative, and format requirements explicitly before every action.

**The forcing function makes invisible compliance violations visible in real-time.**
