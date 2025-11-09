# Lesson 22: Gemini Consult Throughout Session (Not Just Startup)

**Category:** 🟡 Important (Default Behavior)
**Last Updated:** 2025-10-21 (Migrated to Gemini Consult API skill)
**Sessions:**

- 2025-10-19 (NotebookLM exploration)
- 2025-10-20 (E2E test fixes - identified gap in usage)
- 2025-10-21 (Gemini Consult migration - 10x faster queries)

---

## 🚨 CRITICAL: Query 3-4 Times Per Session, Not Just Once

**The most common mistake:** AI assistants query documentation ONCE at session start, then never again.

**Correct approach:** Query THROUGHOUT the session whenever you need information.

**Minimum 3-4 queries per session:**

1. **START (18:00)** - "What are critical rules for my task?"
2. **DURING (18:20)** - "How does Shop mock services in E2E tests?"
3. **STUCK (18:35)** - "Playwright cleanup not working - what solutions exist?"
4. **BEFORE (18:45)** - "Should validation tests be in E2E or unit tests?"

**Evidence from Session 2025-10-20:**

- Only 1 query used (at start)
- Should have queried 3 more times during investigation
- Grade: C+ (78/100) for documentation query usage
- **25% of potential value captured**

**Think of Gemini Consult as your pair programming partner (1-3 second responses!), not just a reference manual.**

**Migration Note:** Now with Gemini Consult API (1-3s vs 15-30s), there's NO excuse not to query frequently!

---

## The Problem: Token Exhaustion from Manual File Reading

**Historical Pattern:**

AI assistants consume 40-60k tokens (20-30% of session budget) reading documentation files manually during session startup. This leaves less budget for actual productive work.

**Example from typical session:**

```
Step 1: Read CONTINUATION_PROMPT.md (640 lines) → 8k tokens
Step 2: Read lessons-learned README (200 lines) → 2k tokens
Step 3: Read 21 lesson files (9,000+ lines total) → 20k tokens
Step 4: Read DATA-MODEL.md (500 lines) → 6k tokens
Step 5: Read docs/README.md (700 lines) → 8k tokens
Step 6: Read commit-guidelines.md (380 lines) → 4k tokens
Step 7: Read testing docs (multiple files) → 8k tokens
...
Total: 50k-60k tokens consumed before starting work
```

**Impact:**

- 25-30% of session budget spent on context gathering
- Less budget for actual implementation
- Shorter sessions before hitting token limits
- Manual synthesis across documents (risks missing connections)

---

## The Solution: Query NotebookLM First

**New Approach (2025-10-19):**

All Scrap Survivor documentation is uploaded to NotebookLM. AI assistants can query it directly for synthesized, source-grounded answers.

**Token savings:**

```
Traditional: Read 10+ files → 50k tokens
NotebookLM: Ask 5 questions → 15k tokens
Savings: 35k tokens (17-22% of session budget)
```

**That's 35k more tokens available for productive work!**

---

## How to Use Gemini Consult

### Command Format

```bash
# Query a specific notebook:
cd /home/alan/.claude/skills/gemini-consult && python scripts/gemini_client.py query \
  --notebook "notebook_name_or_id" \
  --question "YOUR QUESTION HERE"

# List available notebooks:
python scripts/notebook_manager.py list

# Example query:
python scripts/gemini_client.py query \
  --notebook "testing_documentation" \
  --question "What are the E2E test conventions?"
```

### Available Notebooks

- `project_health_&_patterns` - Sprint 14, Pattern Catalog
- `architecture_&_data_model` - Core architecture, DATA-MODEL
- `development_guides` - Commit guidelines, standards
- `testing_documentation` - Testing, QA, Playwright
- `code_patterns_&_examples` - Real source code examples
- `features_documentation` - Banking, workshop, inventory
- `technical_debt_&_refactoring` - Refactor plans
- `getting_started_&_workflow` - Project overview
- `sprint_planning_&_roadmap` - Sprint docs
- `tier_experiences_&_monetization` - Free/Premium/Subscription

### Response Time

- Query execution: **1-3 seconds** (10x faster than browser automation!)
- Includes: API call + AI processing + source-grounded response
- **Fast enough to use continuously during the session**

---

## When to Use Gemini Consult

### ✅ ALWAYS Use Gemini Consult For:

1. **Session startup questions**
   - "What are the critical rules for commits, testing, and git operations?"
   - "What patterns should I follow for [task type]?"
   - "What are the most common mistakes to avoid?"

2. **Pattern discovery**
   - "What established patterns exist for [feature type] implementation?"
   - "How should I structure [component type]?"
   - "What's the standard approach for [problem]?"

3. **Cross-cutting concerns**
   - "What are all the rules around database queries?"
   - "What must I check before making commits?"
   - "What testing conventions apply to [area]?"

4. **Historical context**
   - "Why was [decision] made this way?"
   - "What problems led to [pattern] being established?"
   - "What failures informed [lesson]?"

5. **Quick refreshers**
   - "What's the commit message format?"
   - "What are the tier gating rules?"
   - "How do I use ProtectedSupabaseClient?"

6. **Mistake prevention**
   - "What mistakes have been made with [area]?"
   - "What should I avoid when implementing [feature]?"
   - "What verification steps are required for [task]?"

### 📄 Use Direct File Reads For:

1. **Line-by-line code review**
   - Need exact line numbers
   - Editing specific sections
   - Analyzing implementation details

2. **Editing documentation**
   - Can't edit files through NotebookLM
   - Must use Read/Edit tools

3. **Very recent changes**
   - Documentation updated in last few hours
   - NotebookLM may not have latest version
   - Re-upload to NotebookLM if critical

---

## Example: Session Startup with NotebookLM

**Old Approach (50k tokens):**

```bash
# Read 10+ files manually
Read CONTINUATION_PROMPT.md
Read lessons-learned/README.md
Read 21 lesson files
Read DATA-MODEL.md
Read docs/README.md
Read commit-guidelines.md
Read testing docs
...
# 50k tokens consumed
```

**New Approach (15k tokens):**

```bash
# Query 1: Critical rules
ask-docs "What are the most critical rules I must follow for git commits, testing, and code patterns?"

# Query 2: Pattern guidance
ask-docs "What established patterns should I copy for implementing service-based features with Supabase?"

# Query 3: Common mistakes
ask-docs "What are the most common mistakes to avoid based on lessons learned, especially around testing and commits?"

# Query 4: Data model
ask-docs "Where are weapons and items stored? What are the valid item types?"

# Query 5: Verification steps
ask-docs "What verification steps must I complete before making any commits?"

# 15k tokens consumed (35k savings!)
```

---

## Quality Benefits Beyond Token Savings

NotebookLM provides **superior answers** compared to manual file reading:

### 1. Cross-Document Synthesis

**Manual reading:**

- Read commit-guidelines.md: "Use lowercase"
- Read lesson 16: "Open file before committing"
- Read lesson 09: "A-Grade protocol requires verification"
- **You must connect these yourself**

**NotebookLM:**

- Synthesizes all three automatically
- Presents integrated answer with priorities
- Shows relationships between rules

### 2. Source Citations

Every claim includes citations:

- "According to commit-guidelines.md line 80..."
- "Lesson 09 mandates..."
- "This pattern is documented in..."

**You know exactly where information comes from.**

### 3. Hierarchical Organization

NotebookLM prioritizes information:

1. Most critical rules first
2. Supporting context second
3. Edge cases third
4. Historical rationale fourth

**Manual reading gives you chronological order, not priority order.**

### 4. Follow-Up Prompting

Every NotebookLM response ends with:

> "EXTREMELY IMPORTANT: Is that ALL you need to know?"

This encourages you to:

- Review answer against your task
- Identify gaps
- Ask follow-up questions
- Continue until context is complete

---

## Real-World Example

**Task:** Implement banking E2E tests

**NotebookLM Query:**

```
ask-docs "What are the critical conventions for E2E tests? Include selector types, test IDs, patterns to copy, and common mistakes to avoid."
```

**NotebookLM Response (synthesized from 5+ files):**

- Use `data-testid` attributes (playwright-guide.md)
- Follow hierarchical naming: `ui.feature.component` (testIds.ts)
- Copy shop E2E test patterns (tests/shop/\*.spec.ts)
- Common mistake: Using text selectors (lesson 17)
- Common mistake: Not checking existing patterns first (lesson 08)
- Verification: Must run tests before claiming completion (lesson 02)

**Token cost:** ~2k tokens

**vs Traditional approach:**

- Read playwright-guide.md (2k tokens)
- Read testIds.ts (500 tokens)
- Read tests/shop/\*.spec.ts (3k tokens)
- Read lesson 17 (800 tokens)
- Read lesson 08 (600 tokens)
- Read lesson 02 (400 tokens)
- **Total: 7.3k tokens** (and you still have to synthesize yourself)

**Savings: 5k tokens (73% reduction)**

---

## The Follow-Up Protocol

**CRITICAL:** NotebookLM responses are starting points, not final answers.

### Required Steps After Each Response:

1. **Review answer against your task**
   - Does it cover all aspects?
   - Are there gaps?
   - Do you need more detail on specific points?

2. **Ask follow-up questions for gaps**

   ```bash
   # First query gave overview, now drill down:
   ask-docs "Can you provide specific examples of the test ID naming pattern from existing tests?"

   # Or:
   ask-docs "What exactly does the A-Grade protocol require for pre-commit verification?"
   ```

3. **Continue until complete**
   - Don't stop at first answer
   - Keep querying until you have full context
   - Each query is cheap (1-2k tokens)

4. **Synthesize for your task**
   - NotebookLM gives you the building blocks
   - You assemble them for your specific use case

---

## Documentation Upload Guidelines

**When creating new documentation, decide: Upload to NotebookLM or keep on filesystem?**

### ✅ UPLOAD TO NOTEBOOKLM:

**Reference Documentation** (permanent, reusable knowledge):

- Architecture documents
- Design patterns
- Coding standards
- Testing conventions
- Lessons learned
- Feature documentation
- Data models
- API references

**Criteria:**

- Will AI assistants need this info in future sessions?
- Does it document patterns, standards, or rules?
- Is it reference material (not session-specific)?

**Upload frequency:** Whenever reference docs are created or significantly updated

### 📁 KEEP ON FILESYSTEM ONLY:

**Session-Specific Content** (temporary, contextual):

- Session logs
- Work-in-progress notes
- Temporary analysis
- Debug logs
- Draft documents
- Personal notes
- Code-specific line numbers

**Criteria:**

- Is this specific to one session?
- Is it temporary or draft?
- Does it reference exact line numbers (which change)?

### Decision Template

When creating documentation, add to bottom:

```markdown
## NotebookLM Upload Status

- [ ] Upload to NotebookLM (Reference documentation)
- [ ] Filesystem only (Session-specific/temporary)
- [ ] N/A (Not documentation)

Reason: [Brief explanation of decision]
```

### Upload Process

```bash
# 1. Open NotebookLM
open https://notebooklm.google.com/notebook/140efd46-c173-4748-81f6-d949cae418d0

# 2. Add source (Upload or link)
# 3. Wait for processing (~30 seconds)
# 4. Verify upload successful
# 5. Test with query:
ask-docs "What does the newly uploaded [doc name] say about [topic]?"
```

**Upload frequency recommendations:**

- Critical lessons: Immediately after creation
- Architecture docs: After review and approval
- Standards/patterns: When finalized
- Batch uploads: Weekly for minor updates

---

## Integration with Existing Lessons

**This lesson enhances:**

- **Lesson 09 (A-Grade Protocol):** Add NotebookLM queries to session start checklist
- **Lesson 04 (Context Gathering):** NotebookLM is now Step 1 in context gathering
- **Lesson 20 (Documentation First):** Query NotebookLM before reading files

**This lesson is enhanced by:**

- **Lesson 16 (Following Conventions):** Still need to keep docs open while working
- **Lesson 02 (Testing):** Still must verify with actual test execution

**NotebookLM doesn't replace execution discipline - it accelerates context gathering.**

---

## Token Budget Impact Analysis

### Before NotebookLM (200k token session):

- Startup: 50k tokens (25%)
- Work: 100k tokens (50%)
- Documentation: 30k tokens (15%)
- Buffer: 20k tokens (10%)

### After NotebookLM (200k token session):

- Startup: 15k tokens (7.5%)
- **Work: 135k tokens (67.5%)** ← 35% more productive work!
- Documentation: 30k tokens (15%)
- Buffer: 20k tokens (10%)

**Result: 35% more session budget available for actual implementation work.**

---

## Limitations and Caveats

### NotebookLM Cannot:

1. **Edit files** - Still need Read/Edit tools
2. **Execute code** - Still need Bash/test tools
3. **See very recent changes** - May lag by hours
4. **Reference exact line numbers** - Line numbers change frequently
5. **Replace systematic verification** - Still must run tests, verify commits

### When NotebookLM May Fail:

1. **Rate limits** - Google limits queries (50/day for free accounts)
2. **Stale data** - If docs updated very recently
3. **Ambiguous questions** - Need to be specific
4. **Code-level details** - Better to read actual source

### Mitigation Strategies:

- **Rate limits:** Use targeted questions (quality over quantity)
- **Stale data:** Re-upload critical docs after major changes
- **Ambiguous questions:** Include context in query
- **Code details:** Fall back to direct file reads

---

## Success Metrics

**Grade yourself on NotebookLM usage:**

✅ **A Grade (Excellent):**

- Used NotebookLM for 80%+ of doc queries
- Asked follow-up questions when needed
- Saved 30k+ tokens on startup
- Fell back to file reads only when necessary

✅ **B Grade (Good):**

- Used NotebookLM for 60%+ of doc queries
- Some follow-ups, some missed
- Saved 20k+ tokens
- Occasional unnecessary file reads

❌ **C Grade (Needs Improvement):**

- Used NotebookLM for <50% of queries
- Rare follow-ups
- Saved <15k tokens
- Reverted to old file-reading habits

❌ **F Grade (Not Using):**

- Didn't use NotebookLM
- Read files manually
- Consumed 50k+ tokens on startup
- Ignored this lesson

---

## Quick Reference

### Command Shortcuts

```bash
# Full command:
cd /home/alan/.claude/skills/notebooklm && python scripts/run.py ask_question.py --question "..." --notebook-url "https://notebooklm.google.com/notebook/140efd46-c173-4748-81f6-d949cae418d0"

# Wrapper:
ask-docs "..."

# Alias (add to ~/.bashrc if desired):
alias nbq='ask-docs'
```

### Common Queries

```bash
# Startup
ask-docs "What are the critical rules for commits, testing, and patterns?"

# Patterns
ask-docs "What pattern should I follow for [feature type]?"

# Mistakes
ask-docs "What mistakes have been made with [area]?"

# Verification
ask-docs "What must I verify before committing [type] changes?"

# Quick reference
ask-docs "What's the commit message format?"
```

### Decision Tree

```
Need documentation info?
├─ Is it reference material? (patterns, standards, rules)
│  ├─ YES → Query NotebookLM first
│  │  ├─ Answer sufficient? → Use it
│  │  └─ Need more detail? → Follow-up query or read file
│  └─ NO → Continue
└─ Is it code-level detail? (line numbers, exact implementation)
   ├─ YES → Read file directly
   └─ NO → Query NotebookLM
```

---

## Related Lessons

- [04-context-gathering.md](04-context-gathering.md) - Now starts with NotebookLM
- [09-ai-execution-protocol.md](09-ai-execution-protocol.md) - A-Grade checklist includes NotebookLM
- [20-user-documentation-tells-truth.md](20-user-documentation-tells-truth.md) - NotebookLM surfaces documentation

---

## Commitment

**Starting 2025-10-19, all AI assistants must:**

1. ✅ Query NotebookLM BEFORE reading files manually
2. ✅ Use NotebookLM for 80%+ of documentation queries
3. ✅ Ask follow-up questions when needed
4. ✅ Fall back to file reads only when NotebookLM insufficient
5. ✅ Track token savings (aim for 30k+ per session)

**This is not optional. This is how efficient AI assistance works.**

---

**Session References:**

- [session-log-2025-10-19-notebooklm-exploration.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-notebooklm-exploration.md)

---

## NotebookLM Upload Status

- [x] Upload to NotebookLM (Reference documentation - this is a lesson learned)
- [ ] Filesystem only
- [ ] N/A

Reason: This lesson documents a permanent pattern (NotebookLM-first queries) that all future AI assistants need to follow. Must be uploaded to NotebookLM so it can be queried.
