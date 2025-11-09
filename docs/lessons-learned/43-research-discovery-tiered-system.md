# Lesson 43: Research Discovery - Tiered Strategic + Tactical System

**Date:** 2025-11-04
**Session:** 23
**Category:** Architecture / Knowledge Management
**Severity:** High (Quality management)

---

## The Problem

We had excellent research in two directories, but only one was being actively used:

1. **docs/research/** (Sprint 18 tactical) - ✅ Referenced in session plans
2. **docs/project-health/industry-benchmarks/** (Strategic standards) - ❌ "Forgotten" since Sprint 14

**Consequence:**

- Strategic research (testing coverage 80-90%, performance benchmarks, game design patterns) wasn't being referenced
- Quality targets like "80-90% unit test coverage" existed but weren't visible during implementation
- We're at 27% test coverage but had no forcing function to recognize the 53-63 percentage point gap
- Good research from Sprint 14 effectively discarded after React Native pivot in Sprint 15-18

**User's observation:** "we do good research and then we promptly forget to reference it when needed"

---

## The Root Cause

**Knowledge management gap:** No mechanism to surface strategic research during tactical sessions.

**Why this happened:**

1. **Sprint 14 research** was created for comprehensive health review
2. **Sprint 15-18** focused on React Native migration (tactical urgency)
3. **No integration point** - strategic research not in startup protocol or session plans
4. **AI memory limitation** - assistants read CONTINUATION_PROMPT + SESSION-XX-PLAN, but not industry-benchmarks/
5. **Out of sight, out of mind** - no forcing function to check "what's the quality target?"

**Example:**

- Industry standard: 80-90% unit test coverage
- Our current: 27% unit test coverage
- Gap: 53-63 percentage points below standard
- **This should be visible in every session, but wasn't**

---

## The Solution

**Tiered research system:** Strategic (evergreen) + Tactical (sprint-specific)

### Architecture

```
docs/
├── standards/
│   └── RESEARCH-INDEX.md          # NEW - Master index (strategic + tactical)
│
├── research/                       # Sprint-specific tactical research
│   ├── SYNTHESIS.md
│   ├── prompts/
│   └── responses/
│
└── project-health/
    └── industry-benchmarks/        # Strategic/evergreen research
        ├── optimized/
        └── ... (8 benchmark files)
```

### Key Changes

**1. Created docs/standards/RESEARCH-INDEX.md**

- Single source of truth for ALL research
- Strategic section: Testing coverage, performance, game design, mobile UX, monetization, documentation
- Tactical section: Sprint 18 React Native migration research
- "When to reference" guidance for each topic
- Gap analysis: Current state vs industry standards

**2. Updated Startup Protocol (STARTUP-GUIDE.md step 0.5)**

```markdown
0.5. Research & Quality Targets Review

- Read docs/standards/RESEARCH-INDEX.md for this session type
- Screen migration: Review testing (80-90%), performance (60 FPS), UX (44x44px)
- Testing: Review test pyramid (70:20:10), mutation testing (≥85%)
- Performance: Review LCP ≤2.5s, INP ≤200ms, bundle <500KB
- UI/UX: Review touch targets, safe areas, game design patterns
- Note quality targets in session plan
- Check tactical research for similar problems solved previously
```

**3. Updated SESSION-24-PLAN.md with Quality Targets Section**

```markdown
## Quality Targets (Industry Benchmarks)

**Testing Coverage:**

- Target: 80-90% unit test coverage (currently 27% ❌)
- Critical path: 100% coverage
- Test pyramid: 70% unit : 20% integration : 10% E2E

**Performance:**

- Frame rate: 60 FPS desktop, 30+ FPS mobile
- Bundle size: <500KB gzipped main, <1.5MB total

**Mobile UX:**

- Touch targets: 44x44px minimum
- Safe areas: iOS notch handling
- Accessibility: WCAG 2.1 AA (4.5:1 contrast)

**Logging:**

- Minimum: 15+ strategic log points
- Coverage: Lifecycle, observables, interactions, transforms, errors
```

---

## Benefits

### 1. Discoverability

- Strategic research surfaced in mandatory pre-flight checklist
- "When to reference" guidance prevents guesswork
- RESEARCH-INDEX.md as single entry point

### 2. Quality Bar Enforcement

- Session plans explicitly state quality targets
- Can measure "did we meet industry standards?" per session
- Prevents regression (gap now visible: 27% vs 80-90% target)

### 3. Knowledge Retention

- Strategic research doesn't get "forgotten" between sprints
- New AI sessions automatically see quality targets in pre-flight
- Reduces "reinventing the wheel" for standards

### 4. Sprint Isolation

- Tactical research namespaced by sprint (future: docs/research/sprint-18/)
- Easy to archive old sprint research without losing strategic benchmarks
- Clear separation: sprint-specific vs evergreen

### 5. CTO-Ready Context

- When asked "how are we doing?", can compare against industry benchmarks
- Quality targets documented and traceable
- Gaps visible and measurable

---

## Implementation (Session 23)

**Changed:**

1. Created `docs/standards/RESEARCH-INDEX.md` (master research index)
2. Updated `docs/sprints/sprint-18/STARTUP-GUIDE.md` (added step 0.5: Research review)
3. Updated `SESSION-24-PLAN.md` (added Quality Targets section)

**Deferred to Session 24:**

- Namespace sprint-specific research (move docs/research/ → docs/research/sprint-18/)
- Update SESSION-TEMPLATE.md with quality targets boilerplate
- Update all sprint research references after namespace change

---

## The Pattern

**General rule:** Separate **strategic** from **tactical** research

**Strategic Research (Evergreen):**

- Industry benchmarks and standards
- Quality targets (testing coverage, performance, UX)
- Game design patterns from authoritative sources
- Applicable across multiple sprints
- **Location:** docs/project-health/industry-benchmarks/
- **Indexed in:** docs/standards/RESEARCH-INDEX.md

**Tactical Research (Sprint-Specific):**

- Debugging specific implementation issues
- Platform-specific technical investigations
- One-time problem-solving research
- **Location:** docs/research/ (future: docs/research/sprint-XX/)
- **Indexed in:** docs/standards/RESEARCH-INDEX.md
- **Referenced in:** SESSION-XX-PLAN.md files

**Integration Points:**

- Startup protocol step 0.5: Review RESEARCH-INDEX.md for session type
- Session plans: Include "Quality Targets" section with benchmarks
- Session logs: Compare actual vs target metrics

---

## When to Apply This

**Use this pattern when:**

- Multiple research sources exist (strategic + tactical)
- Research is created but not referenced later
- Quality targets exist but aren't visible during implementation
- Hard to answer "what's the industry standard for X?"

**Signs you need this:**

- "We did research on this before, where is it?"
- "What's the target quality bar for this work?"
- "Why didn't we reference the benchmarks we already have?"
- Current state diverges from known standards without visibility

---

## Gap Analysis Examples

### Testing Coverage

- **Industry standard:** 80-90% unit test coverage
- **Our current:** 27%
- **Gap:** -53 to -63 percentage points ❌
- **Action:** Prioritize test coverage in future sessions

### Performance (When Testing Unblocks)

- **Industry standard:** LCP ≤2.5s, 60 FPS desktop, 30+ FPS mobile
- **Our current:** Not measured (testing blocked)
- **Action:** Measure on first runtime test, compare against benchmarks

### Mobile UX

- **Industry standard:** 44x44px touch targets, iOS safe area handling
- **Our current:** Implemented but not verified
- **Action:** Audit touch target sizes, verify safe area handling

---

## Related Lessons

- **Lesson 42:** CONTINUATION_PROMPT stability (separate contracts from state)
- **Lesson 22:** Session planning standards (created global template)
- **Lesson 21:** Documentation modularization (split protocols by topic)

**This completes the knowledge management architecture started in Sessions 22-23.**

---

## Key Insight

**User's observation was exactly right:** Good research loses value if it's not discoverable when needed.

**Solution:** Make strategic research part of the startup protocol (mandatory pre-flight checklist step 0.5)

**Why this works for AI assistants:**

- Limited memory - need forcing functions to read strategic research
- Pre-flight checklist guarantees research review before starting work
- "When to reference" guidance helps AI know which benchmarks apply
- Quality targets in session plans create measurable success criteria

---

**Status:** ✅ Partially implemented (RESEARCH-INDEX.md created, startup protocol updated)
**Remaining Work:** Namespace sprint research (defer to Session 24)
**Commits:**

- (TBD) - feat(standards): Add research index for strategic benchmarks discovery
  **Impact:** All future sessions benefit from strategic research visibility

---

## Future Improvements (Optional)

**Potential enhancements:**

1. **Research discovery tool:** CLI command to search RESEARCH-INDEX.md by keyword
2. **Gap tracking:** Automated comparison of current metrics vs benchmarks
3. **Session templates:** Auto-populate quality targets based on session type
4. **NotebookLM integration:** Upload RESEARCH-INDEX.md for RAG queries

**Not urgent - current implementation solves core problem.**
