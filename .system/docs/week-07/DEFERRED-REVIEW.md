# Week 7 Deferred Review Items

**Context:** During Week 6 Day 2 implementation, we identified several potential health system improvements. Some were integrated into Week 6 (Days 4-5), while others were deferred to Week 7 for assessment.

**Review Timing:** End of Week 7 (after gaining more experience with current patterns)

---

## Items for Review

### 1. Stateless Service Pattern Validator

**Priority:** LOW (deferred from Week 6)

**Context:**
During Week 6 Day 2, we implemented serialization across all services. Some services (RecyclerService, ErrorService, StatService) are stateless and only implement serialize/deserialize as no-ops for API consistency.

**Potential Value:**
A validator could detect when services have no state and warn developers that they might not need serialization:
```python
# Example detection
if service has no instance variables:
    if service has serialize() that returns minimal dict:
        warn "Service appears stateless - consider documenting why"
```

**Why Deferred:**
- Current implementation is clear and consistent (all services have same API)
- No-op implementations are well-documented with comments
- Validator might create more noise than value
- Need more service examples to determine if pattern is actually problematic

**Review Question for Week 7:**
After implementing Week 7 services (inventory, equipment), do we have:
- More stateless services that feel awkward?
- Developer confusion about stateless serialization?
- Evidence this validator would prevent real bugs?

**Decision Criteria:**
- **Implement:** If we have 3+ cases where stateless serialization caused confusion
- **Don't Implement:** If current pattern is working well and well-understood

---

### 2. GDScript Style Guide Validator

**Priority:** LOW (deferred from Week 6)

**Context:**
We currently use gdlint for style enforcement. Question arose: should we add custom style checks beyond gdlint's scope?

**Potential Value:**
Could enforce project-specific conventions:
- Signal naming patterns (e.g., `past_tense` vs `verb_noun`)
- Documentation comment style
- Variable naming prefixes (e.g., `_private` vs `private`)
- Method ordering (public before private)

**Why Deferred:**
- gdlint already covers most style issues
- No specific pain points identified yet
- Risk of over-engineering validation
- Better to accumulate real style issues first, then validate

**Review Question for Week 7:**
After Week 7 development, do we have:
- Recurring style inconsistencies that gdlint misses?
- Code review comments about style that could be automated?
- Patterns that new developers consistently get wrong?

**Decision Criteria:**
- **Implement:** If we have 5+ instances of the same style issue that gdlint doesn't catch
- **Don't Implement:** If gdlint + code review is sufficient

---

## Week 6 Day 2 Analysis Summary

**What We Implemented (Week 6 Days 4-5):**
1. ✅ Improved naming consistency warnings in service_api_checker
2. ✅ Validator test suite (.system/validators/tests/)
3. ✅ Service patterns guide (PATTERNS.md)

**What We Deferred (Above):**
1. ⏸️ Stateless service pattern validator
2. ⏸️ GDScript style guide validator

**Rationale:**
Prioritized high-value, clear-benefit improvements. Deferred speculative improvements until we have more data from Week 7 development.

---

## How to Use This Document

**At the end of Week 7:**

1. Review the "Review Questions" for each item
2. Check if decision criteria are met
3. Make implementation decision for Week 8+

**If implementing:**
- Add to Week 8 health system improvements
- Reference this document for context

**If not implementing:**
- Archive this document
- Update decision with reasoning for future reference

**If still unclear:**
- Defer to end of Week 8 with updated criteria

---

## Additional Notes

This deferred review pattern is itself a meta-improvement:
- Prevents over-engineering validators
- Accumulates real data before deciding
- Avoids premature optimization
- Maintains focus on high-value work

**Philosophy:** Build validators when pain is clear, not when pain is speculative.
