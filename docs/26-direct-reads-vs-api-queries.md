# Lesson 26: Direct File Reads vs API Queries - Know Your Strengths

**Date Learned:** 2025-10-22
**Context:** Sprint 15 context rollover, hit Gemini API rate limits
**Severity:** High
**Category:** AI Efficiency, Token Budget, Development Velocity

---

## The Problem

During Sprint 15 context rollover, we discovered the Gemini API query approach had critical issues:

**Rate Limits Hit Immediately:**

- Gemini free tier: 250K tokens/minute
- Large consolidated notebooks (ss_documentation at 1MB+) exceeded quota in SINGLE query
- Pre-flight checklist consumed 100% of 200K token session budget
- Hit rate limits after 2-3 queries per session

**Root Cause:**

- Blindly following "query API first" pattern from CONTINUATION_PROMPT
- Large notebooks (lessons-learned 321KB + session-handoffs 721KB + benchmarks 28KB = 1070KB)
- Each query sent ENTIRE notebook content to API (~265K tokens)
- Math: 4 pre-flight queries × ~50K tokens = ~200K tokens (entire budget on startup!)

**User Question That Uncovered It:**

> "Can you explain what the current usage is typical to the API call? I'm trying to understand our usage pattern before making large changes."

This forced evidence-based analysis instead of assumptions.

---

## The Key Insight

**AI assistants (like Claude Code) have different strengths than humans:**

**Humans:**

- Slow at reading files (minutes per file)
- Good at semantic search across large corpus
- Need indexing/search to find info

**AI Assistants:**

- **FAST at reading files** (~1 second per file, up to 2000 lines)
- **EXCELLENT at synthesizing** multiple files
- **GREAT at grep/search** to find relevant files
- Token-efficient (reading 8 files = ~12K tokens)

**The Anti-Pattern:** Using semantic search (Gemini API) for queries that are faster/cheaper with direct reads.

---

## The Solution

**Primary Approach: Direct File Reads**

Pre-flight checklist now reads 8 specific files:

1. `docs/development-guide/commit-guidelines.md`
2. `docs/development-guide/coding-standards.md`
3. `docs/development-guide/before-you-start-checklist.md`
4. `docs/lessons-learned/README.md`
5. `docs/sprints/SPRINT-15-BACKLOG.md`
6. `docs/project-health/SPRINT-14-HEALTH-ASSESSMENT-FINAL.md`
7. `docs/core-architecture/DATA-MODEL.md`
8. `docs/core-architecture/technical-architecture.md`

**Secondary Approach: Gemini API (sparingly)**

Only use for genuinely hard queries:

- Pattern ranking: "What are top 10 most critical lessons?" (hard to rank without semantic search)
- Cross-document synthesis: "What patterns are most commonly violated?" (cross-cutting analysis)
- When grep fails: Don't know where info lives and searches haven't helped

---

## Impact Metrics

### Token Budget Savings

| Approach         | Pre-Flight Tokens | % of Budget | Remaining for Work    |
| ---------------- | ----------------- | ----------- | --------------------- |
| **Old (Gemini)** | ~200K tokens      | 100%        | 0K (nothing left!)    |
| **New (Direct)** | ~12K tokens       | 6%          | 188K (94% available!) |

**Savings: 17x more efficient, 188K tokens freed per session**

### Speed Improvement

| Approach         | Pre-Flight Time | Notes                                 |
| ---------------- | --------------- | ------------------------------------- |
| **Old (Gemini)** | ~15 seconds     | API round-trips, rate limits possible |
| **New (Direct)** | ~5 seconds      | Instant file reads, no network        |

**Speed: 3x faster, no rate limits, always current**

### Accuracy

| Approach         | Currency       | Notes                                                |
| ---------------- | -------------- | ---------------------------------------------------- |
| **Old (Gemini)** | Notebook lag   | regenerate.sh updates notebooks (could be hours old) |
| **New (Direct)** | Always current | Reading live files, instant updates                  |

**Accuracy: 100% current, no lag**

---

## The Meta-Lesson

**Don't blindly follow patterns - understand WHY they exist and WHEN they apply.**

**Questions to Ask:**

1. "What are my strengths as an AI assistant?" (fast reading, synthesis, grep)
2. "What is this pattern optimizing for?" (semantic search? speed? token efficiency?)
3. "Is there a simpler approach that leverages my strengths?" (direct reads vs API)
4. "What are the actual costs?" (tokens, time, rate limits)

**User's Insight:**

> "As an AI code assist, what makes the most sense, provides you the most value, is most efficient for you?"

This reframed the problem from "follow the pattern" to "what actually works best?"

---

## Implementation Details

**Files Changed:**

- `CONTINUATION_PROMPT.md` (lines 38-251) - Critical Rule #2 rewritten
- `docs/notebooklm-uploads/regenerate.sh` (lines 691-712) - Notebook mappings split
- Gemini Consult notebooks - Split ss_documentation into 3 focused notebooks

**Workflow Now:**

1. **Pre-flight:** Read 8 specific files (~5 seconds, ~12K tokens)
2. **During work:** Use Read tool + Grep for specific needs
3. **Stuck:** Grep for examples, read session logs, THEN Gemini if still stuck
4. **Hard queries only:** Use Gemini for ranking/synthesis that grep can't do

---

## When This Lesson Applies

**Use Direct Reads When:**

- ✅ You know exactly which file has the info
- ✅ Info is in specific, known locations (commit guidelines, data model, etc.)
- ✅ Need line-by-line accuracy (exact code, exact rules)
- ✅ Files recently updated (always current)
- ✅ Budget-conscious (save tokens for actual work)

**Use Gemini API When:**

- ❓ Ranking across many files ("top 10 lessons")
- ❓ Cross-document patterns ("what patterns are most violated?")
- ❓ Don't know where to look (grep failed, no idea where info lives)
- ❓ Semantic synthesis needed (combining concepts from multiple sources)

---

## Prevention Checklist

Before querying an API:

```
[ ] Can I find this with grep? (try first)
[ ] Do I know which file has this? (read it directly)
[ ] Is this in a specific doc? (commit-guidelines.md, DATA-MODEL.md, etc.)
[ ] Will this query cost >10K tokens? (direct read probably cheaper)
[ ] Is this genuinely a ranking/synthesis query? (then API makes sense)
```

**Default to direct reads. API is the exception, not the rule.**

---

## Success Metrics

**This lesson is being followed when:**

- Pre-flight completes in <10 seconds
- Pre-flight uses <20K tokens (10% of budget)
- No rate limit errors in sessions
- Gemini API queries are rare (0-2 per session, not 4+ per session)
- Token budget available for actual work (>150K remaining after pre-flight)

---

## Related Lessons

- Lesson 1: Documentation Before Assumptions (read docs first)
- Lesson 2: NotebookLM Throughout Session (when to use semantic search)
- Lesson 22: NotebookLM Documentation Queries (optimization patterns)
- Lesson 25: AI Following Problem (don't blindly follow patterns)

---

## Final Thought

**The best tool is the one that:**

1. Solves the problem
2. Leverages your strengths
3. Is fast and efficient
4. Doesn't hit artificial limits

Direct file reads check all four boxes for most queries. Use them.

**Remember:** You're excellent at reading and synthesizing files. Don't pay API costs (tokens, rate limits, lag) for something you do better natively.
