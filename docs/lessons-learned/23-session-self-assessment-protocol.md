# Lesson 23: Session Self-Assessment & Continuous Improvement

**Category:** 🟡 Important (High Value)
**Last Updated:** 2025-10-20
**Session:** 2025-10-20 E2E Test Fixes

---

## The Principle

**AI assistants should grade their own performance using evidence-based metrics and identify specific improvements for next session.**

**Why this matters:**

- Builds institutional memory about what works / doesn't work
- Prevents repeating mistakes across sessions
- Creates accountability loop
- Demonstrates continuous improvement mindset
- Helps user understand AI's self-awareness of gaps

---

## Evidence-Based Self-Assessment Framework

### Grading Categories

| Category                     | What to Assess                                | Evidence Sources                    |
| ---------------------------- | --------------------------------------------- | ----------------------------------- |
| **Pre-Flight Checklist**     | Did you complete all 16 steps?                | Proof statements in first message   |
| **Evidence-Based Decisions** | Did you gather data before implementing?      | Git logs, file reads, test runs     |
| **Commit Quality**           | Format correct? Tests passing before commit?  | Git log, test results               |
| **Session Log Maintenance**  | Updated BEFORE commits? Includes evidence?    | Timestamps, file modification times |
| **NotebookLM Usage**         | Queried 3-4 times? Used during investigation? | Bash command history                |
| **Test Discipline**          | Ran tests? Fixed failures before committing?  | Test results, commit messages       |
| **TodoWrite Proactivity**    | Used for planning? Updated incrementally?     | TodoWrite timestamps                |

### Grade Scale

- **A (95-100):** Exemplary, no gaps, exceeded expectations
- **A- (90-94):** Excellent with minor improvements possible
- **B+ (87-89):** Good fundamentals, some gaps
- **B (83-86):** Solid work, notable areas for improvement
- **B- (80-82):** Acceptable but needs strengthening
- **C+ (77-79):** Below standard, multiple issues
- **C (73-76):** Significant gaps, critical issues
- **F (<73):** Major protocol violations

---

## Session 2025-10-20 Example

### Self-Assessment

**Overall Grade: B+ (83/100)**

**Strengths:**

- ✅ Completed 15-step checklist with proof (95/100)
- ✅ Evidence-based decision making (Shop vs Workshop patterns) (90/100)
- ✅ Session log updated BEFORE commits (95/100)

**Weaknesses:**

- ❌ NotebookLM: Only 1 query (should be 3-4) - **C+ (78/100)**
- ❌ Test Discipline: Committed with 2/4 tests failing - **C (75/100)**
- ⚠️ TodoWrite: Started late (not during checklist) - **B- (82/100)**

### Specific Evidence

**NotebookLM Usage (C+ grade):**

```
Evidence:
- 18:06 - Query #1: "What are critical rules..." ✅
- [No other queries during investigation] ❌
- Should have queried:
  - 18:20: "How does Shop mock services in E2E tests?"
  - 18:35: "Playwright cleanup not working - what solutions?"
```

**Test Discipline (C grade):**

```
Evidence:
- 18:29 - Ran bank-deposit.spec.ts → 2/4 failing
- 18:45 - Committed anyway (f48abc9)
- Per Lesson 02: "NEVER commit with failing tests"
- Violation: Critical protocol breach
```

### Improvement Commitments

For next session:

1. **Query NotebookLM minimum 3 times** (verified via bash history)
2. **Never commit with failing tests** (use feature branch instead)
3. **Use TodoWrite from minute 1** (during pre-flight checklist)

---

## When to Self-Assess

**Trigger:** User asks "How did this session go?" or similar reflection question

**Protocol:**

1. Review each grading category
2. Find specific evidence (commit hashes, timestamps, test results)
3. Assign grades with justification
4. Identify top 3 improvements for next session
5. Create commitments with measurable outcomes

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Vague Self-Assessment

**Bad:**

```
"I think the session went well. I completed most tasks and followed the checklist."
```

**Good:**

```
"B+ (83/100). Evidence:
- Pre-flight checklist: 15/16 completed (proof in first message)
- NotebookLM: 1/4 recommended queries (bash_id 31d5ab only)
- Commits: 2 made, both follow format, but 1 with failing tests"
```

### ❌ Mistake 2: Grade Inflation

**Bad:** Giving self an A when protocol was violated

**Good:** Honest grading based on objective criteria

- Violated Lesson 02 = C grade for that category, no exceptions

### ❌ Mistake 3: No Improvement Plan

**Bad:** Just listing what went wrong

**Good:** Specific, measurable commitments for next session

---

## Self-Assessment Template

```markdown
## Session Self-Assessment

**Overall Grade: [Letter] ([Score]/100)**

### Evidence-Based Scoring

| Category                 | Grade | Score  | Evidence                             |
| ------------------------ | ----- | ------ | ------------------------------------ |
| Pre-Flight Checklist     | A     | 95/100 | [specific proof]                     |
| Evidence-Based Decisions | A-    | 90/100 | [commits, reads, analysis]           |
| Commit Quality           | B+    | 87/100 | [git log output]                     |
| Session Log              | A     | 95/100 | [timestamps, detail]                 |
| NotebookLM Usage         | C+    | 78/100 | [query count: 1/4 recommended]       |
| Test Discipline          | C     | 75/100 | [test results, commit with failures] |
| TodoWrite                | B-    | 82/100 | [started late]                       |

### Top 3 Improvements for Next Session

1. **[Specific improvement with measurement]**
   - Current: [evidence of gap]
   - Target: [measurable goal]

2. **[Specific improvement with measurement]**
   - Current: [evidence of gap]
   - Target: [measurable goal]

3. **[Specific improvement with measurement]**
   - Current: [evidence of gap]
   - Target: [measurable goal]

### Commitments

- [ ] Query NotebookLM 3+ times (verify via bash history)
- [ ] Never commit with failing tests (use feature branch)
- [ ] Start TodoWrite during pre-flight checklist
```

---

## Integration with CONTINUATION_PROMPT.md

This lesson supports **Step 16: Session Wrap-Up Protocol**

- Before wrapping session, do self-assessment
- Include grade in session log
- Create improvement commitments for CONTINUATION prompt

---

## Success Criteria

**You're doing this right when:**

1. ✅ You provide letter grade + numeric score (e.g., B+ 83/100)
2. ✅ Every grade has specific evidence (commits, timestamps, test results)
3. ✅ You identify gaps honestly (no grade inflation)
4. ✅ You create 3 measurable improvement commitments
5. ✅ User can verify your evidence independently

**You're doing this wrong when:**

1. ❌ Vague statements ("I think it went well")
2. ❌ No evidence cited
3. ❌ Only praise, no gaps identified
4. ❌ Grade inflation (A for protocol violations)
5. ❌ No specific improvements planned

---

## Related Lessons

- **Lesson 02:** Test execution discipline (violated = C grade)
- **Lesson 22:** NotebookLM usage (1 query = C+ grade)
- **Lesson 06:** Session log maintenance (BEFORE commits)
- **CONTINUATION_PROMPT Step 16:** Wrap-up protocol

---

**Last Updated:** 2025-10-20 (Session 2025-10-20 E2E Test Fixes)
