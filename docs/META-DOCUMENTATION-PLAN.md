# Meta Documentation Plan
**Created:** November 9, 2025
**Purpose:** Comprehensive documentation expansion roadmap
**Timeline:** Execute when fresh (no rushing)
**Quality Standard:** Match PERKS-SYSTEM.md depth (15 sections, implementation details, examples)

---

## Status: Ready for Execution

This plan outlines all documentation work needed to capture brainstormed systems and complete the game design documentation. Execute in order, taking time for quality.

---

## ⚠️ TESTING DOCUMENTATION - READ BEFORE ANY IMPLEMENTATION

**CRITICAL**: This is a DOCUMENTATION plan. When implementing ANY features described in these docs, you MUST consult the testing documentation first:

📚 **[TESTING-INDEX.md](TESTING-INDEX.md)** - Central hub for all testing standards

**Key Documents**:
- [godot-testing-research.md](godot-testing-research.md) - GUT framework patterns and best practices
- [test-file-template.md](test-file-template.md) - Template for ALL new test files
- [test-quality-enforcement.md](test-quality-enforcement.md) - Pre-commit checklist and quality gates

**Quality Requirements**:
- ✅ All tests must verify real functionality (no smoke tests)
- ✅ All tests must use Arrange-Act-Assert pattern
- ✅ Run quality validator before EVERY commit: `python3 .system/validators/test_quality_validator.py`

**See [IMPLEMENTATION-ROADMAP.md](core-architecture/IMPLEMENTATION-ROADMAP.md) Section 10 for testing milestones.**

---

## Phase 1: Expand Existing Rushed Docs

These docs exist but need expansion to match PERKS-SYSTEM.md / MINIONS-SYSTEM.md quality.

### 1.1 SPECIAL-EVENTS-SYSTEM.md
**Current:** 7 sections (too brief)
**Target:** 12-15 sections

**Add:**
- Detailed event scheduling system
- Event activation/deactivation logic
- Server-side event distribution
- Event analytics and metrics
- Implementation phases (by week)
- Data model (LocalStorage + Supabase)
- Integration with Perks system
- Balancing considerations
- Open questions section

**Estimated Time:** 2-3 hours

---

### 1.2 TRADING-CARDS-SYSTEM.md
**Current:** 7 sections (missing details)
**Target:** 12-15 sections

**Add:**
- Card rendering system (Godot implementation)
- Image export formats (PNG, social media specs)
- Referral tracking implementation
- Analytics (card shares, referral conversions)
- Hall of Fame architecture (Subscription archives)
- Data model (card generation, storage)
- Integration with Social APIs (Twitter, Instagram, etc.)
- Implementation phases
- Open questions

**Estimated Time:** 2-3 hours

---

### 1.3 BLACK-MARKET-SYSTEM.md
**Current:** 7 sections (functional but brief)
**Target:** 10-12 sections

**Add:**
- Item spawn algorithm (rarity weighting)
- Curse removal scroll mechanics (detailed)
- Integration with Shop reroll system
- Data model (black market inventory)
- UI mockups and navigation
- Implementation phases
- Balancing (pricing, spawn rates)
- Analytics (purchases, conversion)

**Estimated Time:** 1-2 hours

---

### 1.4 ATOMIC-VENDING-MACHINE.md
**Current:** 8 sections (good start, needs depth)
**Target:** 12-15 sections

**Add:**
- Weekly refresh scheduling system
- Personalization algorithm (detailed matching logic)
- Item generation rules (quality, type distribution)
- Minion inclusion logic
- Purchase tracking and history
- Data model (vending machine state)
- Integration with Personalization System (deep dive)
- UI navigation and purchase flow
- Implementation phases
- Analytics and A/B testing

**Estimated Time:** 2-3 hours

---

## Phase 2: Create New Comprehensive Docs

These docs don't exist yet. Create with full depth (12-15 sections).

### 2.1 SUBSCRIPTION-SERVICES.md (NEW)
**Purpose:** Document all subscription idle/automation features
**Target:** 15+ sections

**Contents:**
1. System Overview (all 4 services)
2. Cultivation Chamber (offline stat grinding)
   - How it works
   - Stat selection
   - Time calculations
   - Balance protection (prevent exploits)
3. Murder Hobo Mode (offline currency farming)
   - How it works
   - Currency generation rates
   - Mutual exclusivity with Cultivation Chamber
4. Workshop Idle Repair Queue (replaces MrFixit)
   - Queue 1 item for slow repair
   - Repair time calculations
   - While-repairing item is unusable
5. Minion Fabricator (cloning)
   - Pattern storage costs
   - Clone generation
   - Viability degradation
   - Pattern destruction
6. Mutual Exclusivity Rules (can't run all 4 at once)
7. Data Model (idle job tracking)
8. UI Design (Scrapyard → Subscription Services)
9. Implementation Phases
10. Integration with other systems
11. Balancing (time vs reward)
12. Analytics
13. Open Questions

**Estimated Time:** 4-5 hours

---

### 2.2 PERSONALIZATION-SYSTEM.md (NEW)
**Purpose:** Foundational system for Goals, Perks, Atomic Vending
**Target:** 15+ sections

**Contents:**
1. System Overview
2. Questionnaire (Hybrid Approach)
   - Initial 5-question setup (on Subscription activation)
   - Questions: favorite character, playstyle, weapon type, risk tolerance, perk preferences
3. Auto-Learning System
   - Track actual gameplay behavior
   - Hours played per character
   - Weapon usage stats
   - Aggressive vs defensive playstyle detection
   - Override questionnaire if behavior differs
4. Profile Data Model
5. Profile Matching Algorithm
6. Integration Points
   - Goals System (personalized monthly goals)
   - Perks System (tailored weekly perks)
   - Atomic Vending Machine (item recommendations)
7. UI Design (questionnaire, profile view)
8. Privacy Considerations (data collection)
9. Implementation Phases
10. Analytics (profile accuracy, engagement lift)
11. A/B Testing Strategy
12. Open Questions

**Estimated Time:** 3-4 hours

---

### 2.3 ADVISOR-SYSTEM.md (NEW)
**Purpose:** Subscription AI gameplay feedback
**Target:** 12-15 sections

**Contents:**
1. System Overview (post-wave and weekly summaries)
2. Post-Wave Analysis
   - What went well
   - What could improve
   - Death analysis (glass cannon detection, etc.)
3. Weekly Summary
   - Performance across all characters
   - Suggestions for improvement
   - Scrapyard recommendations (what to buy/upgrade)
4. Heuristics System
   - Glass cannon detection (high damage, low survivability)
   - Tank detection (high HP, low damage)
   - Inefficient builds (contradictory stats)
5. Recommendation Engine
   - "Invest in dodge or armor"
   - "Try life steal items"
   - "Focus on ranged weapons"
6. Data Collection Requirements
   - Must log all Scrapyard decisions
   - Must log combat performance
7. Data Model (gameplay logs, analysis cache)
8. UI Design (Advisor modal, weekly report)
9. Implementation Phases
10. NLP/AI Considerations (GPT integration?)
11. Privacy and Data Storage
12. Open Questions

**Estimated Time:** 3-4 hours

---

### 2.4 ACHIEVEMENTS-SYSTEM.md (NEW)
**Purpose:** Standard achievement system for retention
**Target:** 10-12 sections

**Contents:**
1. System Overview
2. Achievement Types
   - Combat (kills, waves, bosses)
   - Progression (levels, character unlocks)
   - Economy (scrap earned, items crafted)
   - Social (referrals, card shares)
   - Secret achievements
3. Achievement Tiers (Bronze, Silver, Gold, Platinum)
4. Rewards (scrap, components, titles, cosmetics?)
5. Platform Integration (Game Center, Google Play)
6. Data Model
7. UI Design (achievement list, notifications)
8. Implementation Phases
9. Analytics
10. Open Questions

**Estimated Time:** 2-3 hours

---

### 2.5 FEATURE-REQUEST-SYSTEM.md (NEW)
**Purpose:** Community engagement and monetization experiment
**Target:** 10-12 sections

**Contents:**
1. System Overview (user ideas → voting → tip goal → prioritization)
2. Submission Flow
3. Voting Mechanism
4. Tip Goal System
   - Two-week cycles
   - $1,000 tip goal example
   - Payment processing (Stripe, PayPal)
5. Premium Perk Voting (monthly perk request)
6. A/B Testing Strategy
7. Moderation (spam prevention, inappropriate requests)
8. Data Model
9. UI Design
10. Implementation Phases
11. Legal/Financial Considerations
12. Open Questions

**Estimated Time:** 2-3 hours

---

### 2.6 CONTROLLER-SUPPORT.md (NEW)
**Purpose:** Premium feature with real-world accessibility impact
**Target:** 12-15 sections

**Contents:**
1. System Overview
2. Research Summary (Brotato, Godot 4.5.1, Backbone)
   - ⚠️ DEPENDENCY: Wait for research results from other AI
3. Control Scheme
   - Twin-stick aiming (left stick move, right stick aim)
   - Button mapping (A/B/X/Y actions)
   - Shoulder buttons (weapon switch, dodge)
   - Menu navigation (D-pad vs left stick)
4. Godot 4.5.1 Implementation
   - Input mapping system
   - Controller detection (MFi, Bluetooth)
   - Mixed input handling (switch between touch and controller)
5. Backbone Hardware Integration
6. UI Adaptations (show "Press A" instead of "Tap")
7. Controller Disconnect Handling
8. Haptic Feedback
9. Tier Access (Premium feature)
10. Implementation Phases
11. Testing Strategy
12. Accessibility Benefits
13. Open Questions

**Estimated Time:** 3-4 hours (after research results)

---

## Phase 3: Update Core Documentation

### 3.1 GAME-DESIGN.md
**Task:** Add all 14+ new systems to consolidation doc

**Add Sections:**
- 12. Perks System (server-injected mods)
- 13. Minions System (combat companions)
- 14. Banking System (death protection)
- 15. Goals System (daily/weekly/monthly quests)
- 16. Special Events (wasteland modifiers)
- 17. Trading Cards (social sharing, referrals)
- 18. Black Market (premium shop)
- 19. Atomic Vending Machine (personalized shop)
- 20. Subscription Services (idle features)
- 21. Personalization System (profile matching)
- 22. Advisor System (AI feedback)
- 23. Achievements
- 24. Feature Request/Voting
- 25. Controller Support

**Update Table of Contents**

**Estimated Time:** 2-3 hours

---

### 3.2 tier-experiences/free-tier.md
**Task:** Update with all new systems (access restrictions)

**Add:**
- No Perks (except marketing campaigns)
- No Minions
- No Banking
- Basic Goals (login, holiday events)
- No Special Events
- Trading Cards (YES - for referrals to earn Premium)
- No Black Market
- No Atomic Vending
- No Subscription Services
- No Personalization
- No Advisor
- Achievements (YES)
- No Feature Voting
- No Controller Support

**Estimated Time:** 30 minutes

---

### 3.3 tier-experiences/premium-tier.md
**Task:** Update with new Premium features

**Add:**
- Perks (TBD frequency)
- Minions (3 total slots)
- Banking (basic deposit/withdraw)
- Goals (daily/weekly)
- Special Events (YES)
- Trading Cards (YES)
- Black Market (YES)
- No Atomic Vending (Subscription only)
- No Subscription Services
- No Personalization (Subscription only)
- No Advisor (Subscription only)
- Achievements (YES)
- Feature Voting (monthly perk vote)
- Controller Support (YES)

**Estimated Time:** 30 minutes

---

### 3.4 tier-experiences/subscription-tier.md
**Task:** Update with all Subscription features

**Add:**
- Perks (1 per week, personalized)
- Minions (3 base + 1 per character)
- Quantum Banking (transfer between characters)
- Goals (all Premium + monthly personalized)
- Special Events (YES + exclusive events)
- Trading Cards (YES + Hall of Fame archives)
- Black Market (YES)
- Atomic Vending Machine (YES)
- **Subscription Services (ALL 4)**
  - Cultivation Chamber
  - Murder Hobo Mode
  - Workshop Idle Repair Queue
  - Minion Fabricator
- Personalization System (questionnaire + auto-learning)
- Advisor System (post-wave + weekly summaries)
- Achievements (YES)
- Feature Voting (YES)
- Controller Support (YES)

**Estimated Time:** 1 hour

---

## Phase 4: Architecture Documentation

### 4.1 PERKS-ARCHITECTURE.md (NEW)
**Purpose:** Hook point reference for all services
**Target:** Comprehensive hook catalog

**Contents:**
1. Overview (why hooks matter)
2. Complete Hook Catalog
   - CharacterService hooks
   - CombatService hooks
   - MovementService hooks
   - ShopService hooks
   - WorkshopService hooks
   - BankingService hooks
   - GoalsService hooks
3. Hook Implementation Pattern (code examples)
4. Perk Execution Flow (FIFO queue)
5. Testing Hooks (unit tests for each hook)
6. Migration Guide (adding hooks to existing services)
7. Security Considerations (hook validation)

**Estimated Time:** 2-3 hours

---

### 4.2 IMPLEMENTATION-ROADMAP.md (NEW)
**Purpose:** Phased rollout plan for all systems
**Target:** Week-by-week roadmap

**Contents:**
1. Overview (16+ week plan)
2. Week 6: CharacterService + Perk Hooks
3. Week 7: TierService
4. Week 8-9: Minions (data model, Barracks, combat)
5. Week 10-11: Banking + Economy stabilization
6. Week 12-14: Goals, Events, Cards
7. Week 15-16: Subscription Services, Personalization
8. Week 17+: Advisor, Achievements, Feature Voting
9. Post-Launch: Controller Support
10. Dependencies Chart (what depends on what)
11. Testing Milestones
12. Go/No-Go Gates (quality checks before advancing)

**Estimated Time:** 2-3 hours

---

## Phase 5: CharacterService Update

### 5.1 Update .system/docs/week-06/CHARACTER-SERVICE-PLAN.md
**Task:** Add perk hook architecture to Week 6 plan

**Add Section:**
- Perk Hook Points (signals to emit)
- `character_created` signal
- `character_leveled_up` signal
- `character_died` signal
- Hook implementation examples
- Testing strategy for hooks

**Estimated Time:** 30 minutes

---

## Phase 6: Commit & Summary

### 6.1 Commit All Documentation
**Task:** Create comprehensive commit with all changes

**Files Changed:** ~25 files
- 8 expanded docs
- 6 new system docs
- 3 tier-experience updates
- 1 GAME-DESIGN.md update
- 2 architecture docs
- 1 roadmap
- 1 CharacterService update
- 1 DATA-MODEL.md update (death penalties clarification)

**Commit Message Pattern:**
```
docs: Comprehensive game design expansion from brainstorm session

Added 14 new system specifications:
- PERKS-SYSTEM.md (server-injected mods, hook architecture)
- MINIONS-SYSTEM.md (combat companions, Barracks)
- BANKING-SYSTEM.md (Quantum Banking for Subscription)
- GOALS-SYSTEM.md (daily/weekly/monthly quests)
- SPECIAL-EVENTS-SYSTEM.md (wasteland modifiers)
- TRADING-CARDS-SYSTEM.md (social sharing, referrals)
- BLACK-MARKET-SYSTEM.md (premium shop)
- ATOMIC-VENDING-MACHINE.md (personalized shop)
- SUBSCRIPTION-SERVICES.md (4 idle features)
- PERSONALIZATION-SYSTEM.md (profile matching)
- ADVISOR-SYSTEM.md (AI gameplay feedback)
- ACHIEVEMENTS-SYSTEM.md
- FEATURE-REQUEST-SYSTEM.md (community voting)
- CONTROLLER-SUPPORT.md (Premium feature)

Updated tier experiences with all new features
Created PERKS-ARCHITECTURE.md (hook point catalog)
Created IMPLEMENTATION-ROADMAP.md (16+ week plan)

All documentation matches PERKS-SYSTEM.md quality standard
(12-15 sections, implementation details, examples, open questions)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Estimated Time:** 15 minutes

---

## Phase 7: Collaborate on Missing Systems

**⚠️ EXECUTE THIS PHASE LAST (after all documentation above)**

These systems were mentioned in brainstorm but need elaboration with Alan:

### 7.1 Aura System
**Questions to Answer:**
- What does Aura do? (passive buff radius? damage aura? visual effect?)
- How does it differ from regular stats?
- Is it character-specific or item-based?
- What's "aura mastery" - a skill tree? stat that scales aura power?
- Legacy code context (what was implemented before?)

**Output:** Create AURA-SYSTEM.md or add to CHARACTER-SYSTEM.md

---

### 7.2 Radioactivity
**Questions to Answer:**
- Environmental hazard (like acid pools)?
- Character stat (radiation resistance)?
- Damage type (weapons deal radiation damage)?
- All of the above?

**Output:** Clarify and document (possibly in SPECIAL-EVENTS-SYSTEM.md or COMBAT-SYSTEM.md)

---

### 7.3 Scrap Craft Skill
**Questions to Answer:**
- Is this a character stat that affects Workshop costs/quality?
- Or a separate crafting system from Workshop?
- Does higher skill = better crafting results, lower costs, faster craft?

**Output:** Clarify and document (possibly in WORKSHOP-SYSTEM.md or CHARACTER-SYSTEM.md)

---

### 7.4 Wasteland Environment Effects
**Questions to Answer:**
- Are these the Special Events hazards already documented?
- Or permanent environmental features?
- Different biomes with different effects?

**Output:** Expand SPECIAL-EVENTS-SYSTEM.md or create WASTELAND-SYSTEM.md

---

### 7.5 Character Attributes (Brotato Review)
**Questions to Answer:**
- Should we review Brotato's full stat system?
- Create research prompt for another AI?
- Or review together in conversation?
- What stats are we missing from current CHARACTER-SYSTEM.md?

**Output:** Expand CHARACTER-SYSTEM.md with complete stat list

---

### 7.6 Global Stats Dashboard
**Questions to Answer:**
- Internal analytics tool (not player-facing)?
- What metrics to track?
- What visualization/UI needed?
- Supabase queries vs custom dashboard?

**Output:** Create ANALYTICS-DASHBOARD.md (internal tool spec)

---

### 7.7 Log Feature for Users
**Questions to Answer:**
- In-game messaging system (developer → players)?
- Inbox UI in Scrapyard?
- Categories (announcements, events, marketing)?
- Push notifications integration?

**Output:** Create USER-LOG-SYSTEM.md or MESSAGING-SYSTEM.md

---

## Execution Strategy

### Time Estimates
- **Phase 1 (Expand 4 docs):** 8-11 hours
- **Phase 2 (Create 6 new docs):** 18-24 hours
- **Phase 3 (Update core docs):** 4-5 hours
- **Phase 4 (Architecture docs):** 4-6 hours
- **Phase 5 (CharacterService update):** 30 minutes
- **Phase 6 (Commit):** 15 minutes
- **Phase 7 (Collaborate on missing):** 3-4 hours

**Total:** ~38-51 hours of documentation work

### Approach
- **No rushing** - Quality matches PERKS-SYSTEM.md standard
- **Work in blocks** - 2-3 hour focused sessions
- **Review checkpoints** - Review each doc before moving to next
- **Mark incomplete sections** - Use ⚠️ NEEDS ELABORATION pattern
- **Commit often** - After each major doc completion

### Dependencies
1. **Controller Support** depends on research results (prompt already provided)
2. **Personalization System** should be done before Advisor (uses same profile)
3. **Phase 7** depends on Alan's input (collaborate when fresh)

---

## Success Criteria

✅ All systems documented to PERKS-SYSTEM.md quality standard
✅ All tier-experience docs updated with new features
✅ GAME-DESIGN.md includes all 14+ new systems
✅ PERKS-ARCHITECTURE.md provides complete hook catalog
✅ IMPLEMENTATION-ROADMAP.md shows clear week-by-week plan
✅ CharacterService plan includes perk hooks
✅ All commits use quality commit message pattern
✅ Missing systems (Phase 7) documented after collaboration

---

## Notes

- This is a **marathon, not a sprint**
- Documentation = code (treat with same rigor)
- Every doc should be useful for years, not just weeks
- When tired, stop and resume later
- Ask clarifying questions before assumptions
- Mark incomplete sections clearly
- Commit early, commit often

---

**Status:** Ready to execute when fresh
**Next Step:** Start Phase 1.1 (expand SPECIAL-EVENTS-SYSTEM.md)
**Blocker:** None (controller research can happen in parallel)
