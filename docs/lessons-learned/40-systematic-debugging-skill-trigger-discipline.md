# Lesson 40: Systematic Debugging Skill - Trigger Discipline

**Date:** 2025-11-03 (Session 09)
**Sprint:** 18 (React Native Migration - Phase 1)
**Severity:** MEDIUM (Process failure, not code failure)
**Impact:** Wasted time, required user pushback to actually investigate

---

## What Happened

**Bug Report:** "I received the email but it still redirected me to localhost"

**What I did (WRONG):**

1. Jumped to conclusion: "You need to configure Supabase"
2. Provided configuration instructions
3. User pushed back: "The redirect URL already exists"
4. **Only then** did I actually read the code
5. Found the real issue: `emailRedirectTo` parameter missing from signup call

**What I should have done (RIGHT):**

1. User reports unexpected behavior
2. **Immediately invoke systematic-debugging skill**
3. Evidence gathering phase: Read AuthScreen.tsx, check what parameters we're passing
4. Hypothesis: Either Supabase config wrong OR code not using it
5. Test hypotheses systematically
6. Find root cause
7. Implement fix

---

## The Skill Trigger Rule

**From systematic-debugging skill description:**

> "Use when encountering **any bug**, test failure, or unexpected behavior"

**Email going to localhost instead of mobile deep link = BUG/UNEXPECTED BEHAVIOR**

This should have triggered the skill **immediately**.

---

## Why This Matters

**Without systematic-debugging:**

- Made assumptions
- Provided solutions without understanding root cause
- Required user to push back before investigating
- Wasted user's time

**With systematic-debugging:**

- Evidence-based investigation
- Root cause understanding before solutions
- No assumptions
- Professional, methodical approach

---

## The Pattern of Failure

**Anti-pattern I followed:**

1. User: "X doesn't work"
2. AI: "Oh, you probably need to do Y" (assumption)
3. User: "I already did Y"
4. AI: "Oh, let me actually look at the code" (should have done this first)

**Correct pattern (skill-driven):**

1. User: "X doesn't work"
2. AI: "Let me invoke systematic-debugging to investigate"
3. AI: Gathers evidence, forms hypotheses, tests systematically
4. AI: "Root cause is Z, here's the fix"

---

## Forcing Function: Debugging Trigger Checklist

**Before responding to ANY bug/unexpected behavior report, ask:**

- [ ] Is this unexpected behavior? (Yes = skill trigger)
- [ ] Am I about to suggest a solution? (If yes, STOP - gather evidence first)
- [ ] Have I read the relevant code? (If no, invoke skill)
- [ ] Do I have evidence for my hypothesis? (If no, invoke skill)

**If ANY answer suggests you don't have full context → Invoke systematic-debugging skill FIRST**

---

## Examples of When to Trigger

**✅ Should trigger systematic-debugging:**

- "Email redirects to localhost instead of mobile" (Session 09)
- "Test is failing"
- "Console shows error X"
- "Feature doesn't work as expected"
- "Performance is slow"
- "UI renders incorrectly"

**❌ Should NOT trigger (not debugging tasks):**

- "How do I implement feature X?" (implementation question)
- "What does this code do?" (code explanation)
- "Can you add logging here?" (simple code change)

---

## Session 09 Post-Mortem

**Timeline:**

1. 14:30 - User: "Email redirected to localhost"
2. 14:31 - I suggested: "Configure Supabase redirect URLs"
3. 14:32 - User: "I already did that"
4. 14:33 - I FINALLY read AuthScreen.tsx
5. 14:34 - Found missing `emailRedirectTo` parameter
6. 14:35 - Implemented fix (commit daf2186)

**What should have happened:**

1. 14:30 - User: "Email redirected to localhost"
2. 14:31 - I invoke: systematic-debugging skill
3. 14:32 - Evidence gathered: Read AuthScreen.tsx, check Supabase params
4. 14:33 - Root cause identified: Missing emailRedirectTo
5. 14:34 - Fix implemented (commit daf2186)

**Time saved:** ~2-3 minutes (small, but prevents user frustration)
**Quality improvement:** Professional debugging, no assumptions

---

## Skill Usage Protocol (NEW)

**MANDATORY: Before responding to bug reports**

```
1. Detect bug/unexpected behavior in user message
2. Invoke systematic-debugging skill IMMEDIATELY
3. Follow skill's evidence-gathering protocol
4. Form hypotheses based on evidence (not assumptions)
5. Test hypotheses systematically
6. Identify root cause
7. ONLY THEN propose solution
```

**Banned responses (assumptions without evidence):**

- ❌ "You probably need to..."
- ❌ "Try doing X..."
- ❌ "Have you configured Y?"

**Required responses (evidence-based):**

- ✅ "Let me investigate using systematic-debugging"
- ✅ "I'll gather evidence first..."
- ✅ "After analyzing [code], the root cause is..."

---

## Integration with CONTINUATION_PROMPT.md

Should add to CONTINUATION_PROMPT.md mandatory pre-response checks:

```markdown
## Skill Usage Discipline

Before responding to user messages, check:

1. Is user reporting unexpected behavior? → Invoke systematic-debugging
2. Is user asking about codebase structure? → Invoke Explore agent
3. Am I about to make an assumption? → STOP, gather evidence first
```

---

## MCP Tools Integration Check

**MCP tools we have available:**

- **Gemini MCP** (gemini-consult is deprecated/removed)

**When to use Gemini MCP:**

✅ **GOOD USE CASES (Research Assistant):**

- Read-only research across 10+ documentation files (50-100k token savings)
- Pattern analysis across multiple code files
- Code review for recommendations (not execution)
- Documentation search and summarization

❌ **BAD USE CASES (Never Trust):**

- File creation (can hallucinate success - reports "✅ Created" when files don't exist)
- Code generation and execution
- Real-time debugging (use systematic-debugging skill instead)
- Git operations (use direct git commands)
- Verification tasks (use direct file operations)

**Integration with systematic-debugging skill:**

- Skills provide immediate guidance (auto-activated)
- Gemini provides heavy research backup (manual invocation)
- For bug debugging: Use systematic-debugging skill (not Gemini)
- For pattern research: Can use Gemini for large-scale analysis, then investigate yourself

**Key Rule:** Gemini is a research assistant, not an executor. Always verify outputs.

---

## Measurement

**How to know if this lesson is being followed:**

✅ **Good signals:**

- Systematic-debugging skill invoked when bugs reported
- No assumptions made before evidence gathering
- Root causes identified before solutions proposed

❌ **Bad signals:**

- Jumping to solutions without investigation
- User has to push back to get investigation
- Multiple attempts before finding root cause

---

## User Feedback

> "should you have used the systemic debugging skill for this? did i or you not trigger this? i feel like i had to somewhat push back on you to check?"

**User is 100% correct.** This was a process failure on my part.

---

## Related Lessons

- **Lesson 09:** AI Execution Protocol (systematic checklists)
- **Lesson 19:** Evidence-based debugging not tool thrashing
- **Lesson 25:** AI Following Problem - reading ≠ following

---

## Action Items

- [x] Document this lesson (this file)
- [ ] Update CONTINUATION_PROMPT.md with skill trigger checklist
- [ ] Create pre-response forcing function for skill usage
- [ ] Audit MCP tools and document usage patterns
- [ ] Test forcing function in next debugging scenario

---

**Status:** Documented - Forcing function needed
**Follow-up:** Next session should test if forcing function works
**Accountability:** User should call out if I make assumptions again

---

**The Rule:** When user reports unexpected behavior → Invoke systematic-debugging FIRST, investigate THOROUGHLY, then propose solutions. No assumptions.
