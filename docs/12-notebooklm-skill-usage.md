# Lesson 12: Gemini Consult Skill Usage (Documentation Queries)

**Category:** 🟡 Important (Best Practice)
**Last Updated:** 2025-10-21
**Sessions:** 2025-10-20 (E2E Test Fixes), 2025-10-21 (Gemini Consult Migration)

---

## CRITICAL RULE: Use Gemini Consult BEFORE Reading Documentation

**Context:** CONTINUATION_PROMPT.md mandates documentation queries BEFORE reading docs to save 30-45k tokens per session.

**Lesson:** Gemini Consult is a live resource with 1-3 second responses. Use it DURING investigation, not just during pre-flight.

**Migration Note:** This lesson was updated to reflect the migration from browser-based NotebookLM skill (15-30s latency) to Gemini Consult API skill (1-3s latency).

**Why This Matters:**

- Saves 30-45k tokens per session (claimed by CONTINUATION_PROMPT)
- Faster pattern discovery vs reading full documentation files
- Access to lessons learned without re-reading session logs
- Cross-session knowledge continuity

---

## Gemini Consult Workflow

### When To Use Gemini Consult

**✅ Use Gemini Consult When:**

1. **Before reading documentation**
   - "What does the commit guide say about line length?"
   - "What are the E2E testing conventions?"

2. **When stuck on a pattern**
   - "How do other overlays handle character props?"
   - "What's the established pattern for testHarness helpers?"

3. **For lessons learned**
   - "What are common E2E test mistakes?"
   - "What should I avoid based on past sessions?"

4. **Cross-project knowledge**
   - "How did we solve similar overlay issues before?"
   - "What's the history of the Banking feature?"

5. **Protocol verification**
   - "What's the correct order for session log updates?"
   - "When should I use TodoWrite?"

**❌ Don't Use Gemini Consult When:**

1. **Needle queries** - Finding specific function name (use Grep instead)
2. **Reading specific file** - Use Read tool directly for current code state
3. **Latest code state** - Gemini Consult has snapshot from last regenerate.sh run, not live code
4. **Implementation details** - Need actual code, not summarized docs

---

## Integrated Workflow Pattern

### The Documentation-First Protocol

**Old Approach (Token Inefficient):**

```bash
# Problem: Need to understand E2E test patterns
1. Read docs/testing/playwright-guide.md (15k tokens)
2. Read tests/shop/shop-purchasing.spec.ts (5k tokens)
3. Read docs/lessons-learned/02-testing-conventions.md (20k tokens)
Total: 40k tokens used
```

**New Approach (Token Efficient):**

```bash
# Problem: Need to understand E2E test patterns
1. Query Gemini Consult (1-3 seconds): "What are the E2E testing conventions?"
   Command: python scripts/gemini_client.py query \
     --notebook "testing_documentation" \
     --question "What are the E2E testing conventions?"

   Response: (2k tokens, source-grounded with citations)
   - Use testHarness helpers
   - Compare with passing tests first
   - Follow Shop pattern for overlays

2. Based on response, read SPECIFIC sections:
   - tests/shop/shop-purchasing.spec.ts (5k tokens, targeted)

Total: 7k tokens used (saved 33k tokens!)
```

### Query During Investigation

**Session 2025-10-20 - What I Should Have Done:**

```markdown
# Actual flow:

1. E2E tests failing with currency=0
2. I read BankOverlay.tsx (5k tokens)
3. I read BankDepositTab.tsx (3k tokens)
4. I read testHarness.ts (8k tokens)
5. User prompted: "did you check existing patterns?"
6. I read shop-purchasing.spec.ts (5k tokens)
7. Found the answer
   Total: 21k tokens, user had to prompt me

# What I should have done:

1. E2E tests failing with currency=0
2. Query Gemini Consult (3 seconds): "How do Bank/Shop overlays receive character data?"
   Command: python scripts/gemini*client.py query \
    --notebook "code_patterns*&\_examples" \
    --question "How do Bank/Shop overlays receive character data in testHarness?"
   Response: "Shop pattern passes character prop to overlay manager"
3. Grep to verify: "grep 'ShopOverlayManager.\*show' src/utils/testHarness.ts"
4. Compare with Bank: "grep 'BankOverlayManager.\*show' src/utils/testHarness.ts"
5. Found the answer
   Total: 2k tokens, no user prompting needed

Savings: 19k tokens + faster resolution + 3 second response time
```

---

## Query Quality

### Good Queries (Specific, Targeted)

```markdown
✅ "What does bank-tier-upsell.spec.ts show about setUserTier usage?"
✅ "How did we solve overlay data flow issues in past sessions?"
✅ "What are common testHarness bugs based on lessons learned?"
✅ "What's the established pattern for E2E test setup?"
```

### Bad Queries (Too Generic)

```markdown
❌ "Tell me about banking tests"
❌ "How do tests work?"
❌ "What's in the documentation?"
❌ "Explain the codebase"
```

**Why Specific is Better:**

- Gets targeted answer (not general overview)
- Saves tokens (less fluff in response)
- Points to exact files/patterns to read next
- Reduces need for follow-up queries

---

## Background Process Management

### CRITICAL: Check Query Results

**Problem (Session 2025-10-20):**

```bash
# Started NotebookLM queries during pre-flight
Bash d09cb8: NotebookLM query about E2E conventions
Bash fed871: NotebookLM query about common mistakes

# Never checked results!
# System reminders show "has new output available"
# I ignored them and read files manually instead
```

**Correct Approach:**

```bash
# 1. Start query
Bash d09cb8: NotebookLM query about E2E conventions

# 2. Continue with other work while it runs

# 3. BEFORE reading files, check query results
BashOutput d09cb8
# Read the response!

# 4. Use response to guide what files to read
# NotebookLM says: "Shop pattern shows character prop usage"
# → Read tests/shop/shop-purchasing.spec.ts (targeted read)
```

---

## Integration with CONTINUATION_PROMPT

### Pre-Flight Checklist Usage

**Step 2 from CONTINUATION_PROMPT.md:**

```markdown
[ ] 2. Query NotebookLM for critical rules BEFORE reading docs: - "What are the most common mistakes to avoid based on lessons learned?" - "What are the [relevant domain] conventions and patterns?"

    Wait for responses and READ THEM before proceeding!
```

**What I Did Wrong (Session 2025-10-20):**

- Started queries ✅
- Never checked BashOutput ❌
- Didn't use responses to guide investigation ❌
- Read files manually instead (wasted tokens) ❌

**What I Should Do:**

- Start queries ✅
- Use BashOutput to read responses ✅
- Reference findings in analysis ("Per NotebookLM...") ✅
- Only read files that NotebookLM suggests ✅

---

## Token Savings Calculation

### Actual vs Potential (Session 2025-10-20)

**Actual Token Usage:**

- Pre-flight queries: 2k tokens (checked results: NO)
- Manual file reads: 20k tokens
- Repeated pattern searches: 5k tokens
- Total: 27k tokens
- **NotebookLM Value Realized: 7%**

**Potential Token Usage (If Used Correctly):**

- Pre-flight queries: 2k tokens (check results: YES)
- Targeted file reads based on NotebookLM: 5k tokens
- No repeated searches (NotebookLM guided directly to answer)
- Total: 7k tokens
- **NotebookLM Value Realized: 74%**

**Savings: 20k tokens (74% reduction)**

---

## Evidence-Based Queries

### During Debugging

**Pattern: Always query when stuck**

```markdown
# Stuck: Why is currency showing as 0?

# ❌ Bad approach:

1. Read all overlay files
2. Read all test files
3. Trial and error
4. Ask user

# ✅ Good approach:

1. Query NotebookLM: "How do overlays receive character data in E2E tests?"
2. Read NotebookLM response
3. Verify with targeted grep/read
4. Fix based on evidence
```

### Before Making Assumptions

```markdown
# Question: Should I change setUserTier order?

# ❌ Bad approach:

Try moving it before seedCharacter, see what happens

# ✅ Good approach:

Query NotebookLM: "What does bank-tier-upsell.spec.ts show about setUserTier timing?"
Response: "setUserTier called AFTER seedCharacter, order doesn't matter"
→ Don't waste time on order changes
```

---

## Success Criteria

**You're using NotebookLM well when:**

- ✅ You query BEFORE reading files
- ✅ You check BashOutput for query results
- ✅ You reference NotebookLM findings in your analysis
- ✅ You use responses to guide targeted file reads
- ✅ You query when stuck (not just during checklist)
- ✅ User never prompts "did you check existing patterns?"

**You're underutilizing NotebookLM when:**

- ❌ Only use during pre-flight checklist
- ❌ Start queries but never check results
- ❌ Read files manually without querying first
- ❌ User has to remind you to check patterns
- ❌ Burning 30k+ tokens on manual documentation reads
- ❌ Reinventing patterns that NotebookLM could have shown you

---

## Quick Reference

### NotebookLM Query Template

```bash
# Bash command (via Skill tool)
python scripts/run.py ask_question.py \
  --question "What are the [DOMAIN] conventions? How should I [TASK]?" \
  --notebook-url "https://notebooklm.google.com/notebook/[ID]"
```

### Check Results

```bash
# Find running queries
# System will show: "Background Bash [ID] has new output available"

# Read results
BashOutput [ID]
```

### Workflow Integration

```markdown
1. Problem identified
2. Query NotebookLM (specific question)
3. Check BashOutput for response
4. Use response to guide file reads (targeted, not exhaustive)
5. Reference NotebookLM in analysis ("Per NotebookLM, Shop pattern shows...")
6. Implement fix based on evidence
```

---

## Grade Scale

**A (90-100)**: Used NotebookLM proactively during investigation, checked results, saved 30k+ tokens
**B (80-89)**: Used NotebookLM for checklist, checked some results, saved 15-30k tokens
**C (70-79)**: Used NotebookLM for checklist only, didn't check results, saved <15k tokens ← Session 2025-10-20
**D (60-69)**: Ignored NotebookLM queries, read files manually, 0 savings
**F (<60)**: Didn't use NotebookLM at all despite CONTINUATION_PROMPT mandate

---

## Related Lessons

- [04-context-gathering.md](04-context-gathering.md) - Documentation-first approach
- [06-session-management.md](06-session-management.md) - Cross-verify session logs
- [02-testing-conventions.md](02-testing-conventions.md) - Pattern analysis before fixes

## Related Documentation

- [CONTINUATION_PROMPT.md](/home/alan/projects/scrap-survivor/CONTINUATION_PROMPT.md) - Step 2: Query NotebookLM
- [.claude/skills/notebooklm/](/home/alan/.claude/skills/notebooklm/) - NotebookLM skill implementation

## Session References

- [session-log-2025-10-20-e2e-test-fixes.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-20-e2e-test-fixes.md) - Example of underutilization
