# Documentation Audit & Reorganization Proposal

**Date**: 2025-11-22
**Auditor**: Claude Code (Sonnet 4.5)
**Scope**: Complete documentation inventory and improvement strategy
**Project**: Scrap Survivor Godot Migration

---

## Executive Summary

### Current State

The Scrap Survivor Godot project has **200+ markdown documentation files** spanning multiple directories. The documentation is **generally high quality** but shows signs of **organic growth without periodic consolidation**. Key findings:

- **44 lessons-learned files** - valuable but potentially overwhelming
- **40+ migration week logs** - historical artifacts of completed work
- **75+ docs/ root files** - mixed current/historical content
- **19 experiments/** files - debugging journals from Week 14-15
- **.system/ effectively manages AI context** - well designed
- **Excellent recent additions** - Parent-First protocol, iOS research

### Key Issues Identified

1. **Migration Logs Are Complete Work** - 40+ week-by-week files from completed migration
2. **Experiments Directory Is Debugging History** - 19 files from specific bug hunts
3. **Lessons Learned Volume** - 44 files may be hard to navigate without index
4. **Redundancy** - Multiple files cover similar topics (testing, mobile UX, iOS)
5. **Missing Hierarchy** - No master index connecting strategic vs tactical docs
6. **Staleness Unclear** - Hard to distinguish active vs historical documentation

### Recommended Priority Actions

1. **Archive completed migration logs** (Week 2-15 day-by-day logs)
2. **Create lessons-learned index** with categorization and search
3. **Archive experiments directory** with summary document
4. **Consolidate redundant testing docs** into unified guide
5. **Enhance CLAUDE_RULES.md** with lessons-learned quick reference
6. **Create documentation hierarchy map** (strategic vs tactical)

### Impact Assessment

- **Low risk** - Primarily archiving and indexing, not deletion
- **High value for AI** - Easier context loading and discovery
- **Maintenance burden** - Reduces future doc sprawl
- **Time estimate** - 4-6 hours implementation

---

## Documentation Inventory

### 1. .system/ Directory (6 files)

**Purpose**: AI agent context and enforcement system

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| CLAUDE_RULES.md | 761 | Mandatory AI protocols | Active ✅ |
| NEXT_SESSION.md | 370 | Session handoff state | Active ✅ |
| README.md | 186 | Enforcement philosophy | Active ✅ |
| CLAUDE_GIT_PROTECTION.md | - | Git safety rules | Active ✅ |

**Assessment**:
- ✅ Well-organized, clear separation of concerns
- ✅ CLAUDE_RULES.md is comprehensive and up-to-date
- ✅ NEXT_SESSION.md protocol works well
- ⚠️ Could benefit from lessons-learned quick reference section

**Archive Subfolder**: `/archive/` contains 1 old NEXT_SESSION backup ✅

**Docs Subfolder**: `/docs/` contains week-specific planning (8 files)
- Week 5-8 architecture decisions
- Testing guides
- Generally good, could archive pre-Week 8 content

### 2. docs/lessons-learned/ (44 files)

**Purpose**: Institutional memory for AI and humans

**Breakdown by Category**:

| Category | Count | Examples |
|----------|-------|----------|
| **Git Operations** | 4 | 01-git-operations, 38-git-reset-disaster |
| **Testing Discipline** | 8 | 02-testing-conventions, 17-check-test-patterns |
| **AI Session Management** | 6 | 06-session-management, 23-self-assessment |
| **Evidence-Based Engineering** | 5 | 15-evidence-based-database, 19-not-tool-thrashing |
| **Godot-Specific** | 4 | 44-parent-first-protocol, 10-established-patterns |
| **Quality Gates** | 3 | 25-forcing-function, 39-quality-gate-engineering |
| **Architecture** | 4 | 43-research-tiered-system, 37-modal-architecture |
| **Database/Supabase** | 4 | 13-database-triggers-rls, 21-auth-usage-patterns |
| **Migration Philosophy** | 6 | 41-migration-not-quick-fixes, 42-optimize-quality |

**Issues**:
- ❌ **No index file** - hard to find relevant lessons
- ❌ **No categorization** - flat namespace
- ❌ **Duplicate numbering** - Multiple #30, #38, #39, #40, #42 files
- ⚠️ **Volume may overwhelm** - 44 files to scan

**Critical Lessons** (Must remain easily accessible):
1. **44-godot4-parent-first-ui-protocol** - iOS SIGKILL prevention (MANDATORY)
2. **01-git-operations** - Git approval protocol
3. **23-session-self-assessment-protocol** - Quality management
4. **43-research-discovery-tiered-system** - Knowledge management
5. **19-evidence-based-debugging-not-tool-thrashing** - Investigation discipline

**Recommendation**:
- Create `00-INDEX.md` with categorization
- Fix duplicate numbering
- Consider archiving pre-Godot lessons (React/Phaser specific)

### 3. docs/migration/ (40 files)

**Purpose**: Week-by-week migration planning and logs

**Breakdown**:

| Type | Count | Status |
|------|-------|--------|
| **Planning docs** | 5 | Active (PLAN, SUMMARY, TIMELINE) |
| **Week 2-5 day logs** | 14 | Historical (migration complete) |
| **Week 6-17 plans** | 15 | Mixed (10-15 historical, 16-17 current) |
| **Handoff docs** | 3 | Week 14-15 (historical) |
| **Other** | 3 | VALIDATION-REPORT, phase reviews |

**Key Active Documents**:
- `GODOT-MIGRATION-SUMMARY.md` - Executive summary ✅
- `week16-implementation-plan.md` - Current work (124K) ✅
- `week17-tentative.md` - Future planning ✅

**Completed Historical Documents** (Candidates for Archive):
- `week2-day1-summary.md` through `week2-day5-completion.md` (5 files)
- `week3-day1-completion.md` through `week3-day5-completion.md` (5 files)
- `week4-day1-completion.md` through `week4-completion.md` (5 files)
- `week6-days1-3-completion.md` (1 file)
- `week7-implementation-plan.md` through `week15-implementation-plan.md` (9 files)
- `week13-phase3.5-handoff.md`, `WEEK14_HANDOFF.md`, `WEEK14_NEXT_SESSION.md`

**Total Archive Candidates**: ~32 files (80% of migration directory)

**Recommendation**:
- Archive `week2-week15` logs to `migration/archive/` or `migration/historical/`
- Keep SUMMARY, TIMELINE-UPDATED, week16+, VALIDATION-REPORT
- Create `migration/README.md` explaining archive structure

### 4. docs/godot/ (11 files)

**Purpose**: Technical reference for Godot development

**Files**:
- `architecture-decisions.md` (2.2K) - Design choices ✅
- `debugging-guide.md` (12K) - Troubleshooting ✅
- `gdscript-conventions.md` (1.0K) - Coding style ✅
- `godot-quick-start.md` (15K) - Setup guide ✅
- `godot-weekly-action-items.md` (73K) - Weekly checklists (⚠️ historical?)
- `platform-abstraction-patterns.md` (28K) - Cross-platform code ✅
- `services-guide.md` (1.6K) - Service architecture ✅
- `setup-guide.md` (1.1K) - Initial setup ✅
- `supabase-setup.md` (1.4K) - Backend integration ✅
- `ui-development-best-practices.md` (6.6K) - **NEW**, Parent-First ✅
- `vscode-windsurf-setup.md` (9.1K) - Editor setup ✅

**Assessment**:
- ✅ Generally excellent, focused technical reference
- ⚠️ `godot-weekly-action-items.md` at 73K may need review (is it historical?)
- ✅ `ui-development-best-practices.md` is critical recent addition
- ✅ Good balance of setup vs ongoing reference

**Recommendation**:
- Review `godot-weekly-action-items.md` - if historical, archive
- Keep all other files active
- Consider cross-linking to lessons-learned index

### 5. docs/ Root (75+ files)

**Purpose**: Mixed - game design, testing, mobile UX, research, planning

**Major Categories**:

#### Game Design (4 files)
- `GAME-DESIGN.md` (49K) - Consolidated design doc ✅
- `brotato-reference.md` - Competitor analysis ✅
- `Wasteland Survivor Game Iconography Guide.md` - Art direction ✅
- `brainstorm.md` - Ideation (⚠️ current or historical?)

#### Testing (12 files)
- `TESTING-INDEX.md` - Test documentation index ✅
- `godot-testing-research.md` (2097 lines) - Comprehensive ✅
- `test-file-template.md`, `test-quality-enforcement.md` ✅
- `RUNNING-TESTS-IN-GODOT.md`, `RUNNING-RESOURCE-TESTS.md` ✅
- `RESOURCE-TESTS-GUIDE.md`, `gut-migration-phase3-status.md` ✅
- Plus 4 more testing-related docs

**Redundancy Alert**: 12 testing files with some overlap

#### Mobile UX (15+ files)
- `mobile-ui-specification.md` (1841 lines) ✅
- `claude-mobile-game-ui-design-system.md` (2395 lines) ✅
- `MOBILE-TOUCH-CONTROLS-PLAN.md` ✅
- `MOBILE-UX-OPTIMIZATION-PLAN.md` ✅
- `MOBILE-UX-QA-ROUND-3-PLAN.md`, `MOBILE-UX-QA-ROUND-4-PLAN.md` ✅
- `perplexity-brotato-ui-mobile-research.md` ✅
- Plus 8+ more mobile UX files

**Redundancy Alert**: Significant overlap in mobile UX guidance

#### iOS-Specific (10+ files)
- `godot-ios-sigkill-research.md` - **CRITICAL**, forensic analysis ✅
- `godot-ios-audio-research.md` ✅
- `godot-ios-canvasitem-ghost.md`, `godot-ios-metal-canvas.md` ✅
- `godot-ios-settings-privacy.md`, `godot-ios-temp-ui.md` ✅
- `IOS-DEVICE-TESTING-CHECKLIST.md`, `IOS-PRIVACY-PERMISSIONS-FIX.md` ✅
- Plus more iOS files

#### Camera/Performance (6 files)
- `CAMERA-BOUNDARY-FIX-PLAN.md` (2325 lines) ✅
- `godot-camera-research-2025-11-16.md` ✅
- `godot-camera2d-boundaries.md`, `godot-camera2d-movement.md` ✅
- `godot-performance-patterns.md` (1410 lines) ✅

#### Reference Guides (10+ files)
- `godot-reference.md`, `godot-coordinates-reference.md` ✅
- `godot-rect2-reference.md`, `godot-performance-monitors-reference.md` ✅
- `godot-data-tree-null.md`, `godot-label-pooling-ios.md` ✅

#### Plans & Status (12+ files)
- `CRITICAL-BUGS-PHASE2-FIXES.md`, `CRITICAL-FIXES-PLAN.md` ✅
- `QUICK-FIX-REFERENCE.md` ✅
- `PHASE-1.5-COMPLETION-SUMMARY.md` ✅
- `week16-phase1-summary.md`, `week16-phase3.5-completion-summary.md` ✅
- `week16-phase3.5-validation-guide.md`, `week16-phase4-completion-summary.md` ✅
- Plus more week-specific status docs

#### Setup & Onboarding (5 files)
- `DEMO-INSTRUCTIONS.md`, `DEVELOPMENT-RULES.md` ✅
- `SHELL-INTEGRATION-SETUP.md` ✅
- `simulator-first-time-guide.md`, `iphone12mini-simulator-quick-guide.md` ✅
- `quick-ios-export-guide.md`, `TESTFLIGHT-DISTRIBUTION-GUIDE.md` ✅

#### Meta-Documentation (3 files)
- `README.md` - Docs index ✅
- `META-DOCUMENTATION-PLAN.md` - Documentation strategy ✅
- `DOCUMENTATION-RECONCILIATION-FINDINGS.md` - Previous audit ✅

#### Research (15+ files)
- `godot-service-architecture.md` (2068 lines) ✅
- `godot-asset-import-research.md`, `godot-asset-optimization.md` ✅
- `godot-community-research.md` ✅
- `gemini-haptic-research.md`, `gemini-mobile-ui-research.md` ✅
- Plus more research docs

#### Week-Specific Status (8+ files)
- `week16-phase1-summary.md` ✅
- `week16-phase3.5-completion-summary.md` ✅
- `week16-phase3.5-validation-guide.md` ✅
- `week16-phase3.5-validation-report.md` ✅
- `week16-phase4-completion-summary.md` ✅
- `week16-phase4-dialog-audit.md` ✅

**Issues**:
- ❌ **Too many files in root** - 75+ files is hard to navigate
- ❌ **Redundancy** - Testing (12 files), Mobile UX (15+), iOS (10+)
- ❌ **Historical vs Current unclear** - Which week16 docs are current?
- ⚠️ **Some very large files** - 2395 lines (design system), 2325 lines (camera)

**Recommendations**:
1. Move week-specific status docs to `docs/status/week16/` subdirectory
2. Consolidate testing docs (keep TESTING-INDEX.md + 2-3 core files)
3. Consolidate mobile UX docs (keep mobile-ui-specification.md + ui-standards/)
4. Move research docs to `docs/research/godot/` subdirectory
5. Create `docs/ios/` subdirectory for iOS-specific content

### 6. docs/experiments/ (19 files)

**Purpose**: Debugging journals from specific bug investigations

**Files** (all from Nov 14-15):
- Bug 11 enemy persistence (3 files)
- iOS ghost rendering (3 files)
- iOS cleanup iterations (3 files)
- iOS tween failures (3 files)
- Enhanced diagnostics (2 files)
- HUD regression, screen flash, validator warnings, etc.

**Assessment**:
- ✅ Valuable forensic records
- ❌ **All are historical** - bugs resolved or superseded
- ❌ **No index or summary** - hard to find relevant experiment
- ⚠️ **Specific to Week 14-15 timeframe**

**Recommendation**:
- Archive entire directory to `docs/experiments/archive/`
- Create `docs/experiments/README.md` summary
- Extract key learnings into lessons-learned (e.g., iOS rendering bugs → lesson)

### 7. docs/core-architecture/ (7 files)

- `DATA-MODEL.md` - Storage architecture ✅
- `CHARACTER-STATS-REFERENCE.md` - Stats system ✅
- `IMPLEMENTATION-ROADMAP.md` - Development plan ✅
- `PATTERN-CATALOG.md` - TypeScript→GDScript patterns ✅
- `PERKS-ARCHITECTURE.md` - Perks system ✅
- `monetization-architecture.md` - Tier system ✅
- `ui-design-system.md` - Design tokens ✅

**Assessment**: ✅ Excellent, well-organized, all active

### 8. docs/game-design/systems/ (29 files)

Game system specifications (COMBAT-SYSTEM.md, SHOP-SYSTEM.md, etc.)

**Assessment**: ✅ Comprehensive, all active

### 9. docs/competitive-analysis/ (1 file)

- `BROTATO-COMPARISON.md` ✅

**Assessment**: ✅ Good

### 10. docs/ui-standards/ (2 files)

- `mobile-dialog-standards.md` ✅
- `mobile-ui-spec.md` ✅

**Assessment**: ✅ Good, focused

### 11. docs/tier-experiences/ (3 files)

- `free-tier.md`, `premium-tier.md`, `subscription-tier.md` ✅

**Assessment**: ✅ Excellent

### 12. docs/setup/ (2 files)

- `MACBOOK-SETUP.md`, `MACBOOK-SETUP-ULTIMATE.md` ✅

**Assessment**: ✅ Good

### 13. docs/reviews/ (1 file)

- `phase-2-5b-expert-review.md` ✅

**Assessment**: ✅ Good

### 14. docs/expert-consultations/ (1 file)

- `device-compatibility-matrix-consultation.md` ✅

**Assessment**: ✅ Good

### 15. docs/future-work/ (1 file)

- `character-roster-visual-overhaul.md` ✅

**Assessment**: ✅ Good

### 16. qa/ Directory (3 files + logs/)

- `AI_RESEARCH_CAMERA_JUMP.md` - Research doc ✅
- `ios-tween-fixes-qa-guide.md` - Testing guide ✅
- `week16-phase2-phase3-qa-plan.md` - QA plan ✅
- `logs/README.md` + subdirectories ✅

**Assessment**: ✅ Well-organized

### 17. Root Markdown Files (10 files)

- `README.md` - Project overview ✅
- `READY_FOR_QA.md` - QA checklist ✅
- `SETUP-COMPLETE.md` - Setup verification ✅
- `ENFORCEMENT-SYSTEM.md` - Quality gates ✅
- `GUT-MIGRATION.md` - Testing migration ✅
- `WEEK9-CODEBASE-AUDIT.md` - Code health ✅
- `brainstorm.md` - Ideation (⚠️ current?)
- `brotato-video-analysis-prompt.md` - Analysis prompt (⚠️)
- `controller-research.md` - Controller support research ✅

**Assessment**: Mostly good, some may be historical

---

## Issues Identified

### 1. **Redundancy**

#### Testing Documentation Overlap (12 files)

**Core Issue**: Multiple files cover testing best practices with overlap

**Files**:
1. `TESTING-INDEX.md` - Index (good ✅)
2. `godot-testing-research.md` (2097 lines) - Comprehensive
3. `test-file-template.md` - Template
4. `test-quality-enforcement.md` - Enforcement
5. `RUNNING-TESTS-IN-GODOT.md` - How to run
6. `RUNNING-RESOURCE-TESTS.md` - Resource tests
7. `RESOURCE-TESTS-GUIDE.md` - Resource guide
8. `gut-migration-phase3-status.md` - Migration status
9. `godot-gut-framework-validation.md` - Framework validation
10. `ENFORCEMENT-SYSTEM.md` (root) - Quality gates
11. `GUT-MIGRATION.md` (root) - Migration doc
12. `BRAINSTORM-COVERAGE-ANALYSIS.md` - Coverage analysis

**Recommendation**:
- **Keep**: TESTING-INDEX.md, godot-testing-research.md, test-file-template.md, RUNNING-TESTS-IN-GODOT.md
- **Archive**: gut-migration-phase3-status.md, godot-gut-framework-validation.md, BRAINSTORM-COVERAGE-ANALYSIS.md (historical)
- **Consolidate**: RESOURCE-TESTS-GUIDE.md + RUNNING-RESOURCE-TESTS.md → single doc
- **Move**: ENFORCEMENT-SYSTEM.md, GUT-MIGRATION.md → `docs/testing/`

#### Mobile UX Documentation Overlap (15+ files)

**Core Issue**: Multiple large files covering mobile UI standards

**Files**:
1. `mobile-ui-specification.md` (1841 lines)
2. `claude-mobile-game-ui-design-system.md` (2395 lines)
3. `MOBILE-TOUCH-CONTROLS-PLAN.md`
4. `MOBILE-UX-OPTIMIZATION-PLAN.md`
5. `MOBILE-UX-QA-FIXES.md`
6. `MOBILE-UX-QA-ROUND-3-PLAN.md`
7. `MOBILE-UX-QA-ROUND-4-PLAN.md`
8. `perplexity-brotato-ui-mobile-research.md`
9. `gemini-mobile-ui-research.md`
10. Plus ui-standards/ subdirectory (2 files)

**Recommendation**:
- **Keep**: `mobile-ui-specification.md` (canonical), `ui-standards/` (2 files)
- **Archive**: QA round docs (historical), research docs (consolidate learnings)
- **Consolidate**: Design system content into ui-specification or ui-standards

#### iOS-Specific Documentation (10+ files)

**Files**:
1. `godot-ios-sigkill-research.md` - **CRITICAL** ✅
2. `godot-ios-audio-research.md`
3. `godot-ios-canvasitem-ghost.md`
4. `godot-ios-metal-canvas.md`
5. `godot-ios-metal-flush.md`
6. `godot-ios-settings-privacy.md`
7. `godot-ios-temp-ui.md`
8. `godot-label-pooling-ios.md`
9. `IOS-DEVICE-TESTING-CHECKLIST.md`
10. `IOS-PRIVACY-PERMISSIONS-FIX.md`

**Recommendation**:
- **Create**: `docs/ios/` subdirectory
- **Keep Active**: sigkill-research.md, DEVICE-TESTING-CHECKLIST.md
- **Move**: All iOS files to `docs/ios/`
- **Create**: `docs/ios/README.md` index

### 2. **Poor Organization**

#### docs/ Root Directory Overload

**Issue**: 75+ files in single directory

**Impact**:
- Hard to find specific documents
- Unclear what's current vs historical
- No logical grouping visible

**Recommendation**: Create subdirectories
- `docs/testing/` - All testing docs
- `docs/ios/` - All iOS-specific docs
- `docs/mobile-ux/` - Mobile UX docs
- `docs/research/godot/` - Godot research
- `docs/status/week16/` - Week-specific status
- `docs/camera/` - Camera-specific docs

#### Lessons-Learned Flat Structure

**Issue**: 44 files, no categorization, duplicate numbers

**Impact**:
- Hard to find relevant lesson
- AI agents must scan all 44 files
- Duplicate numbering confusing

**Recommendation**:
- Create `lessons-learned/00-INDEX.md` with categories
- Fix duplicate numbering (renumber sequentially)
- Consider subcategories: git/, testing/, godot/, ai-protocols/

#### Migration Directory Mixed Historical/Current

**Issue**: 32 historical completion logs mixed with 8 active files

**Impact**:
- Unclear what's relevant
- Directory bloat
- Hard to find current planning

**Recommendation**:
- Move week2-week15 logs to `migration/archive/`
- Keep only: SUMMARY, TIMELINE, week16-week17, VALIDATION-REPORT
- Create `migration/README.md` explaining structure

### 3. **Outdated Content**

#### Experiments Directory (19 files, all Nov 14-15)

**Issue**: All experiments are resolved bugs from 1 week

**Impact**:
- Historical clutter
- No indication bugs are resolved
- Hard to find if similar bug occurs

**Recommendation**:
- Archive all to `experiments/archive/2025-11-week14-15/`
- Create `experiments/README.md` summary
- Extract learnings to lessons-learned

#### Migration Week Logs (32 files)

**Issue**: Day-by-day logs from completed migration weeks

**Impact**:
- Migration is complete, logs are historical
- Takes up namespace
- Adds to file count

**Recommendation**:
- Archive to `migration/archive/` by week
- Keep summaries only

#### Godot Weekly Action Items (73K file)

**Issue**: Large file, potentially historical checklists

**Impact**:
- If historical, adds bulk
- Unclear if actively maintained

**Recommendation**:
- Review file - if pre-Week 10, archive
- If still active, keep

### 4. **Missing Indexes**

#### No Lessons-Learned Index

**Issue**: 44 lessons, no categorization or search

**Impact**:
- AI must read all 44 to find relevant lesson
- Humans can't quickly find topic
- No indication of which are CRITICAL

**Recommendation**:
- Create `00-INDEX.md` with:
  - Categories (Git, Testing, Godot, AI Protocols, etc.)
  - Criticality levels (MANDATORY, High, Medium, Low)
  - Quick reference for common scenarios
  - Search tags/keywords

#### No Research Hierarchy

**Issue**: Research docs scattered across multiple directories

**Impact**:
- Can't distinguish strategic vs tactical research
- No central index
- Hard to find relevant research

**Recommendation**:
- Implement Lesson 43 recommendations
- Create `docs/research/README.md` index
- Separate strategic (evergreen) vs tactical (sprint-specific)

#### No Documentation Map

**Issue**: No top-level guide showing doc hierarchy

**Impact**:
- New contributors lost
- AI agents don't know optimal reading order
- Unclear what's authoritative

**Recommendation**:
- Enhance `docs/README.md` with:
  - Visual hierarchy diagram
  - "Start here" paths for different roles
  - Authority order (CLAUDE_RULES.md > lessons-learned > plans)

### 5. **Hard-to-Find Critical Information**

#### Parent-First Protocol Discovery

**Issue**: Critical iOS crash prevention in 3 places

**Locations**:
1. `.system/CLAUDE_RULES.md` (lines 641-757)
2. `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md`
3. `docs/godot/ui-development-best-practices.md`

**Good**: Cross-referenced ✅
**Missing**: No quick reference in CLAUDE_RULES.md summary

**Recommendation**:
- Add "Critical Godot 4 Rules" section to CLAUDE_RULES.md top
- Quick checklist for common violations

#### iOS SIGKILL Research

**Issue**: Forensic analysis is excellent but buried in docs/

**Location**: `docs/godot-ios-sigkill-research.md`

**Recommendation**:
- Move to `docs/ios/sigkill-research.md`
- Reference from CLAUDE_RULES.md
- Add to lessons-learned index as CRITICAL

---

## CLAUDE_RULES.md Enhancement Recommendations

### Current State

**Strengths**:
- ✅ Comprehensive blocking protocol
- ✅ Evidence-based engineering checklist
- ✅ Component integration protocol
- ✅ Mobile-native development standards
- ✅ Parent-First protocol (Godot 4)
- ✅ Scene layout compatibility rules
- ✅ Definition of "Complete"
- ✅ QA investigation protocol

**Gaps**:
- ❌ No quick reference to lessons-learned
- ❌ No index of critical documentation
- ⚠️ Very long (761 lines) - could use TOC

### Recommended Additions

#### 1. Add Table of Contents (Top of File)

```markdown
## Table of Contents

1. [BLOCKING PROTOCOL](#blocking-protocol-active)
2. [NEVER Rules](#never-rules-zero-tolerance)
3. [Evidence-Based Engineering](#evidence-based-engineering-checklist)
4. [Commit Message Format](#commit-message-format)
5. [Investigation Protocol](#investigation-protocol-before-attempting-fixes)
6. [Component Integration](#component-integration--scene-validation-protocol)
7. [Mobile-Native Development](#mobile-native-development-standards)
8. [Scene Layout Compatibility](#scene-layout-compatibility-rules)
9. [Godot 4 Dynamic UI (Parent-First)](#godot-4-dynamic-ui-development-critical)
10. [Definition of Complete](#definition-of-complete)
11. [QA Investigation Protocol](#qa--investigation-protocol)
12. [Running Tests and Validators](#running-tests-and-validators)
13. [Critical Documentation Index](#critical-documentation-index-new)
14. [Lessons Learned Quick Reference](#lessons-learned-quick-reference-new)
```

#### 2. Add Critical Documentation Index

```markdown
## Critical Documentation Index (NEW)

**Before working on specific topics, read these files:**

### Godot 4 Development
- **Parent-First Protocol**: `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md`
- **UI Best Practices**: `docs/godot/ui-development-best-practices.md`
- **iOS SIGKILL Research**: `docs/ios/sigkill-research.md`

### Mobile Development
- **Mobile UI Spec**: `docs/mobile-ux/mobile-ui-specification.md`
- **iOS HIG Compliance**: See Mobile-Native Development section above

### Testing
- **Testing Index**: `docs/TESTING-INDEX.md` (start here)
- **GUT Best Practices**: `docs/testing/godot-testing-research.md`
- **Test Template**: `docs/testing/test-file-template.md`

### Architecture
- **Data Model**: `docs/core-architecture/DATA-MODEL.md`
- **Service Patterns**: `docs/godot/services-guide.md`
- **Pattern Catalog**: `docs/core-architecture/PATTERN-CATALOG.md`

### Game Design
- **Complete Design**: `docs/GAME-DESIGN.md` (start here)
- **System Specs**: `docs/game-design/systems/` (29 files)

### AI Session Management
- **Session Protocol**: Read `.system/NEXT_SESSION.md` at start of EVERY session
- **Lessons Learned**: `docs/lessons-learned/00-INDEX.md` (categorized)
```

#### 3. Add Lessons Learned Quick Reference

```markdown
## Lessons Learned Quick Reference (NEW)

**Most frequently needed lessons by scenario:**

### When committing to git:
→ Lesson 01: Git operations (approval protocol)
→ Lesson 30: Commit guidelines (every commit)

### When writing tests:
→ Lesson 02: Testing conventions
→ Lesson 17: Check test patterns before coding
→ TESTING-INDEX.md

### When investigating bugs:
→ Lesson 19: Evidence-based debugging, not tool thrashing
→ Lesson 40: Systematic debugging (skill trigger discipline)
→ QA Investigation Protocol (section above)

### When working with Godot 4 UI:
→ Lesson 44: Parent-First protocol (MANDATORY)
→ Godot 4 Dynamic UI section (above)
→ `docs/godot/ui-development-best-practices.md`

### When making architectural decisions:
→ Lesson 43: Research discovery (tiered system)
→ Lesson 10: Established patterns
→ `docs/core-architecture/PATTERN-CATALOG.md`

### When planning sessions:
→ Lesson 23: Session self-assessment protocol
→ Lesson 06: Session management
→ `.system/NEXT_SESSION.md`

### Full Index:
→ `docs/lessons-learned/00-INDEX.md` (all 44 lessons categorized)
```

#### 4. Add "When to Read Which Documentation" Guide

```markdown
## When to Read Which Documentation

**At start of EVERY session:**
1. `.system/NEXT_SESSION.md` (current work context)
2. This file (CLAUDE_RULES.md)
3. Relevant week plan if continuing migration

**Before writing code:**
- Service layer: `docs/godot/services-guide.md`
- UI components: `docs/godot/ui-development-best-practices.md`
- Mobile features: `docs/mobile-ux/mobile-ui-specification.md`

**Before writing tests:**
- `docs/TESTING-INDEX.md` (start here)
- `docs/testing/test-file-template.md`

**Before working on specific systems:**
- Check `docs/game-design/systems/[SYSTEM]-SYSTEM.md`
- Check `docs/core-architecture/DATA-MODEL.md` if data-related

**Before making git commits:**
- Lesson 01: Git operations
- Lesson 30: Commit guidelines

**When stuck on a bug:**
- Lesson 19: Evidence-based debugging
- Spawn investigation agent (QA Investigation Protocol above)
```

### Reference vs Embed

**Embed in CLAUDE_RULES.md** (critical, blocking):
- ✅ Parent-First protocol (already embedded)
- ✅ Blocking protocol
- ✅ Commit message format
- ✅ Mobile-native standards
- ✅ Definition of Complete
- ✅ QA investigation protocol

**Reference from CLAUDE_RULES.md** (detailed guidance):
- → Lessons-learned index (too many to embed)
- → Testing documentation (too detailed)
- → Architecture docs (reference material)
- → Game design specs (reference material)
- → Research docs (context-dependent)

---

## Deprecation Strategy

### Tier 1: Archive Immediately (Low Risk, High Value)

#### 1. Migration Week Logs (32 files)

**What**: Day-by-day completion logs from weeks 2-15

**Why Deprecate**:
- Migration phases are complete
- Purely historical record
- Not referenced by active work

**How to Preserve**:
```
docs/migration/archive/
├── week-02/
│   ├── day1-summary.md
│   ├── day2-validation.md
│   ...
├── week-03/
├── week-04/
...
├── week-15/
└── README.md (explains archive structure)
```

**Keep Active**:
- `GODOT-MIGRATION-SUMMARY.md`
- `GODOT-MIGRATION-TIMELINE-UPDATED.md`
- `week16-implementation-plan.md`
- `week17-tentative.md`
- `VALIDATION-REPORT.md`
- `REACT-NATIVE-MIGRATION-PLAN.md` (reference)

**Impact**: Removes 32 files from active namespace, preserves history

#### 2. Experiments Directory (19 files)

**What**: Bug investigation journals from Nov 14-15 (Week 14-15)

**Why Deprecate**:
- All bugs resolved or superseded
- Specific to 1-week timeframe
- Learnings extracted to lessons-learned

**How to Preserve**:
```
docs/experiments/
├── archive/
│   └── 2025-11-week14-15/
│       ├── bug-11-enemy-persistence-fix.md
│       ├── ios-ghost-rendering-*.md
│       ├── ios-tween-*.md
│       └── ...
└── README.md (summary + index)
```

**Create Summary**: `docs/experiments/README.md`
```markdown
# Experiments Archive

Historical debugging investigations. Key learnings extracted to lessons-learned.

## Active Investigations
(none currently)

## Resolved (Archived)
- **Week 14-15 (2025-11)**: iOS rendering bugs, enemy persistence
  - See `archive/2025-11-week14-15/`
  - Key Lessons: 44-parent-first-protocol, iOS SIGKILL research
```

**Impact**: Cleans up 19 files, preserves forensic records

### Tier 2: Consolidate (Moderate Effort, High Value)

#### 3. Testing Documentation (12 files → 6 files)

**Current**: 12 files with overlap

**Proposed Structure**:
```
docs/testing/
├── README.md (index, replaces TESTING-INDEX.md)
├── godot-testing-research.md (keep)
├── test-file-template.md (keep)
├── test-quality-enforcement.md (keep)
├── running-tests.md (consolidate RUNNING-TESTS-IN-GODOT + RUNNING-RESOURCE-TESTS)
├── resource-tests-guide.md (consolidate RESOURCE-TESTS-GUIDE)
└── archive/
    ├── gut-migration-phase3-status.md (historical)
    ├── godot-gut-framework-validation.md (historical)
    └── BRAINSTORM-COVERAGE-ANALYSIS.md (historical)
```

**Move to root → docs/testing/**:
- `ENFORCEMENT-SYSTEM.md` → `testing/enforcement-system.md`
- `GUT-MIGRATION.md` → `testing/archive/gut-migration.md`

**Impact**: 12 files → 6 active + 4 archived

#### 4. Mobile UX Documentation (15+ files → 5 files)

**Current**: 15+ files with significant overlap

**Proposed Structure**:
```
docs/mobile-ux/
├── README.md (index)
├── mobile-ui-specification.md (canonical, keep)
├── ui-standards/
│   ├── mobile-dialog-standards.md
│   └── mobile-ui-spec.md
├── research/
│   ├── brotato-mobile-ux.md (consolidate brotato + perplexity research)
│   └── haptic-feedback.md (gemini-haptic-research)
└── archive/
    ├── qa-round-3-plan.md (historical)
    ├── qa-round-4-plan.md (historical)
    ├── touch-controls-plan.md (learnings → ui-specification)
    └── ux-optimization-plan.md (learnings → ui-specification)
```

**Consolidate**:
- `claude-mobile-game-ui-design-system.md` content → `mobile-ui-specification.md` or `ui-standards/`
- Research files → `mobile-ux/research/` (2 consolidated files)
- QA plans → archive (completed work)

**Impact**: 15+ files → 5 active + 4 archived

#### 5. iOS Documentation (10+ files → Organized Subdirectory)

**Current**: 10+ files scattered in docs/ root

**Proposed Structure**:
```
docs/ios/
├── README.md (index + quick start)
├── sigkill-research.md (CRITICAL, keep)
├── device-testing-checklist.md (keep)
├── privacy-permissions-fix.md (keep)
├── technical/
│   ├── audio-research.md
│   ├── canvasitem-ghost.md
│   ├── metal-canvas.md
│   ├── metal-flush.md
│   ├── label-pooling.md
│   └── temp-ui-notes.md
└── guides/
    ├── export-guide.md (quick-ios-export-guide)
    └── simulator-setup.md (consolidate simulator guides)
```

**Impact**: Better organization, easier discovery

### Tier 3: Archive After Review (Requires Judgment)

#### 6. Godot Weekly Action Items (73K file)

**File**: `docs/godot/godot-weekly-action-items.md`

**Question**: Is this historical or actively maintained?

**If Historical** (pre-Week 10):
- Archive to `docs/godot/archive/weekly-action-items-week1-9.md`

**If Active**:
- Keep, but consider splitting by phase if too large

**Action**: User to review

#### 7. Root Brainstorm Files

**Files**:
- `brainstorm.md`
- `brotato-video-analysis-prompt.md`
- `controller-research.md`

**Question**: Are these current or completed?

**If Completed**:
- Archive to `docs/archive/ideation/`

**If Active**:
- Move to appropriate subdirectory

**Action**: User to review

### Tier 4: Delete Entirely (Very Low Risk)

**Candidates**: None identified

**Rationale**: All documentation has historical value. Archive instead of delete.

---

## Reorganization Recommendations

### Proposed Directory Structure

```
docs/
├── README.md (enhanced with hierarchy map)
├── GAME-DESIGN.md (keep in root - primary reference)
├── DEVELOPMENT-RULES.md (keep in root - critical)
│
├── core-architecture/ (keep as-is) ✅
│   ├── DATA-MODEL.md
│   ├── PATTERN-CATALOG.md
│   └── ...
│
├── game-design/ (keep as-is) ✅
│   └── systems/
│       ├── COMBAT-SYSTEM.md
│       └── ...
│
├── lessons-learned/ (enhanced)
│   ├── 00-INDEX.md (NEW - categorized index)
│   ├── 01-git-operations.md
│   ├── 02-testing-conventions.md
│   └── ... (renumber to fix duplicates)
│
├── migration/
│   ├── README.md (NEW - explains structure)
│   ├── GODOT-MIGRATION-SUMMARY.md
│   ├── GODOT-MIGRATION-TIMELINE-UPDATED.md
│   ├── week16-implementation-plan.md
│   ├── week17-tentative.md
│   ├── VALIDATION-REPORT.md
│   └── archive/ (NEW)
│       ├── week-02/ (5 files)
│       ├── week-03/ (5 files)
│       └── ... (week-15/)
│
├── godot/ (keep as-is, review 1 file) ✅
│   ├── architecture-decisions.md
│   ├── ui-development-best-practices.md
│   └── ...
│
├── testing/ (NEW - consolidation)
│   ├── README.md (replaces TESTING-INDEX.md)
│   ├── godot-testing-research.md
│   ├── test-file-template.md
│   ├── test-quality-enforcement.md
│   ├── running-tests.md (consolidated)
│   ├── resource-tests-guide.md (consolidated)
│   ├── enforcement-system.md (moved from root)
│   └── archive/
│       ├── gut-migration-phase3-status.md
│       └── ...
│
├── mobile-ux/ (NEW - consolidation)
│   ├── README.md
│   ├── mobile-ui-specification.md (canonical)
│   ├── ui-standards/
│   │   ├── mobile-dialog-standards.md
│   │   └── mobile-ui-spec.md
│   ├── research/
│   │   ├── brotato-mobile-ux.md (consolidated)
│   │   └── haptic-feedback.md
│   └── archive/ (QA plans, etc.)
│
├── ios/ (NEW - organization)
│   ├── README.md (quick start guide)
│   ├── sigkill-research.md (CRITICAL)
│   ├── device-testing-checklist.md
│   ├── privacy-permissions-fix.md
│   ├── technical/ (7 files)
│   └── guides/ (2 files)
│
├── camera/ (NEW - organization)
│   ├── boundary-fix-plan.md
│   ├── camera-research-2025-11-16.md
│   ├── camera2d-boundaries.md
│   └── camera2d-movement.md
│
├── research/ (NEW - organization)
│   ├── README.md (strategic vs tactical index)
│   └── godot/
│       ├── service-architecture.md
│       ├── asset-import-research.md
│       ├── asset-optimization.md
│       ├── performance-patterns.md
│       ├── community-research.md
│       └── ...
│
├── reference/ (NEW - quick reference docs)
│   ├── godot-reference.md
│   ├── coordinates-reference.md
│   ├── rect2-reference.md
│   ├── performance-monitors-reference.md
│   └── ...
│
├── status/ (NEW - week/phase status)
│   └── week16/
│       ├── phase1-summary.md
│       ├── phase3.5-completion-summary.md
│       ├── phase3.5-validation-guide.md
│       ├── phase3.5-validation-report.md
│       ├── phase4-completion-summary.md
│       └── phase4-dialog-audit.md
│
├── experiments/ (reorganized)
│   ├── README.md (summary + index)
│   └── archive/
│       └── 2025-11-week14-15/ (19 files)
│
├── setup/ (keep as-is) ✅
├── ui-standards/ (move to mobile-ux/) →
├── tier-experiences/ (keep as-is) ✅
├── competitive-analysis/ (keep as-is) ✅
├── reviews/ (keep as-is) ✅
├── expert-consultations/ (keep as-is) ✅
├── future-work/ (keep as-is) ✅
└── archive/ (NEW - miscellaneous)
    └── ideation/ (brainstorm files if historical)
```

### Migration Impact Matrix

| Change | Files Affected | Risk | Value | Effort |
|--------|----------------|------|-------|--------|
| Archive migration week logs | 32 | Low | High | 1 hour |
| Archive experiments | 19 | Low | High | 30 min |
| Create lessons-learned index | 1 new + 44 review | Low | High | 2 hours |
| Consolidate testing docs | 12 | Medium | High | 2 hours |
| Consolidate mobile UX docs | 15+ | Medium | High | 2 hours |
| Organize iOS docs | 10+ | Low | Medium | 1 hour |
| Create subdirectories | Multiple | Low | High | Scripted |
| Enhance CLAUDE_RULES.md | 1 | Low | High | 1 hour |

**Total Estimated Effort**: 6-8 hours

### Index Creation

#### 1. Lessons-Learned Index (`docs/lessons-learned/00-INDEX.md`)

```markdown
# Lessons Learned Index

**44 lessons organized by category**

## Table of Contents

- [Critical Lessons (MANDATORY)](#critical-lessons-mandatory)
- [Git Operations](#git-operations)
- [Testing Discipline](#testing-discipline)
- [AI Session Management](#ai-session-management)
- [Evidence-Based Engineering](#evidence-based-engineering)
- [Godot-Specific](#godot-specific)
- [Quality Gates](#quality-gates)
- [Architecture](#architecture)
- [Database & Backend](#database--backend)
- [Migration Philosophy](#migration-philosophy)
- [Quick Reference by Scenario](#quick-reference-by-scenario)

---

## Critical Lessons (MANDATORY)

These lessons prevent **CRITICAL** bugs and failures:

1. **Lesson 44: Godot 4 Parent-First UI Protocol** 🔴 **MANDATORY**
   - **What**: Parent nodes before configuring (iOS SIGKILL prevention)
   - **When**: EVERY dynamic UI node creation in Godot 4
   - **Impact**: iOS app crashes if violated

2. **Lesson 01: Git Operations** 🔴 **MANDATORY**
   - **What**: Always get approval before git operations affecting history
   - **When**: EVERY merge, rebase, amend, push --force
   - **Impact**: Data loss prevention

3. **Lesson 19: Evidence-Based Debugging** 🟡 **High Priority**
   - **What**: Stop and investigate after 1 failure, don't trial-and-error
   - **When**: ANY QA failure or unclear bug
   - **Impact**: Time savings, root cause fixes

... (continue categorization)

---

## Quick Reference by Scenario

**Working on Godot 4 UI?**
→ Lesson 44 (Parent-First), Lesson 10 (Established Patterns)

**Committing code?**
→ Lesson 01 (Git Operations), Lesson 30 (Commit Guidelines)

**Writing tests?**
→ Lesson 02 (Testing Conventions), Lesson 17 (Check Patterns First)

**Investigating bugs?**
→ Lesson 19 (Evidence-Based), Lesson 40 (Systematic Debugging)

... (continue scenarios)
```

#### 2. Research Index (`docs/research/README.md`)

Implement Lesson 43 recommendations:
- Strategic research (evergreen)
- Tactical research (sprint-specific)
- When to reference guide

#### 3. Migration Index (`docs/migration/README.md`)

```markdown
# Migration Documentation

## Active Planning
- [Migration Summary](GODOT-MIGRATION-SUMMARY.md) - Executive overview
- [Migration Timeline](GODOT-MIGRATION-TIMELINE-UPDATED.md) - Updated schedule
- [Week 16 Plan](week16-implementation-plan.md) - Current work
- [Week 17 Plan](week17-tentative.md) - Next week

## Historical Records
See `archive/` subdirectory for completed week logs (week 2-15)

## Archive Structure
- `archive/week-02/` - Week 2 completion logs (5 files)
- `archive/week-03/` - Week 3 completion logs (5 files)
- ... (week-15)
```

---

## Implementation Plan

### Phase 1: Low-Risk Quick Wins (2 hours)

**Archiving historical content**

1. **Archive migration week logs** (30 min)
   ```bash
   cd docs/migration
   mkdir -p archive/{week-02,week-03,week-04,week-06,week-07,week-08,week-09,week-10,week-11,week-12,week-13,week-14,week-15}
   mv week2-*.md archive/week-02/
   mv week3-*.md archive/week-03/
   # ... (continue for all weeks)
   ```

2. **Archive experiments** (30 min)
   ```bash
   cd docs/experiments
   mkdir -p archive/2025-11-week14-15
   mv *.md archive/2025-11-week14-15/
   # Create README.md summary
   ```

3. **Create migration README** (15 min)
   - Write `docs/migration/README.md`
   - Explain archive structure

4. **Create experiments README** (15 min)
   - Write `docs/experiments/README.md`
   - Summary of resolved investigations

5. **Archive .system/docs pre-Week 8** (15 min)
   - Review and archive if appropriate

6. **Git commit** (15 min)
   - Commit archiving changes
   - Single commit: "docs: archive completed migration logs and experiments"

### Phase 2: Index Creation (2 hours)

**Creating discovery aids**

1. **Lessons-Learned Index** (1 hour)
   - Create `docs/lessons-learned/00-INDEX.md`
   - Categorize all 44 lessons
   - Add criticality levels (MANDATORY, High, Medium, Low)
   - Add quick reference by scenario
   - Fix duplicate numbering (renumber files)

2. **Research Index** (30 min)
   - Create `docs/research/README.md`
   - Implement Lesson 43 structure
   - Strategic vs tactical separation

3. **iOS Index** (15 min)
   - Create `docs/ios/README.md` (if organizing iOS docs)
   - Quick start guide + file index

4. **Git commit** (15 min)
   - Commit index files
   - "docs: add categorized indexes for discoverability"

### Phase 3: Consolidation (2 hours)

**Reducing redundancy**

1. **Testing Documentation** (1 hour)
   - Create `docs/testing/` subdirectory
   - Move relevant files from root
   - Consolidate RUNNING-TESTS-* files
   - Update TESTING-INDEX.md → README.md
   - Archive historical migration docs

2. **Mobile UX Documentation** (45 min)
   - Create `docs/mobile-ux/` subdirectory
   - Move relevant files
   - Consolidate research files
   - Archive completed QA plans

3. **Git commit** (15 min)
   - Commit consolidation
   - "docs: consolidate testing and mobile UX documentation"

### Phase 4: Organization (1.5 hours)

**Creating logical structure**

1. **Create subdirectories** (30 min)
   - `docs/ios/` - iOS-specific docs
   - `docs/camera/` - Camera docs
   - `docs/research/godot/` - Godot research
   - `docs/reference/` - Quick reference docs
   - `docs/status/week16/` - Week status docs

2. **Move files to subdirectories** (45 min)
   - Move iOS files
   - Move camera files
   - Move research files
   - Move reference files
   - Move status files

3. **Update internal links** (15 min)
   - Fix broken relative paths
   - Update cross-references

4. **Git commit** (15 min)
   - "docs: organize into logical subdirectories"

### Phase 5: CLAUDE_RULES.md Enhancement (1 hour)

**Improving AI effectiveness**

1. **Add TOC** (10 min)
   - Create table of contents at top

2. **Add Critical Documentation Index** (20 min)
   - Section linking to key docs by topic

3. **Add Lessons Learned Quick Reference** (20 min)
   - Common scenarios → relevant lessons

4. **Add "When to Read Which Documentation"** (10 min)
   - Session start protocol
   - Topic-specific guidance

5. **Git commit** (10 min)
   - "docs: enhance CLAUDE_RULES.md with navigation aids"

### Phase 6: Validation & Review (30 min)

1. **Test link integrity** (15 min)
   - Check all cross-references work
   - Verify archive structure

2. **AI agent test** (15 min)
   - Load CLAUDE_RULES.md
   - Can AI easily find:
     - Parent-First protocol? ✅
     - Testing best practices? ✅
     - Mobile UI standards? ✅
     - Relevant lessons-learned? ✅

### Total Estimated Time: 6-8 hours

**Breakdown**:
- Phase 1: 2 hours (archiving)
- Phase 2: 2 hours (indexing)
- Phase 3: 2 hours (consolidation)
- Phase 4: 1.5 hours (organization)
- Phase 5: 1 hour (CLAUDE_RULES.md)
- Phase 6: 0.5 hours (validation)

**Risk Level**: Low (mostly moving files, creating indexes)

**Value**: High (improved discoverability, reduced clutter)

---

## Maintenance Strategy Going Forward

### 1. Documentation Lifecycle

**Creation Phase**:
- All new docs created in appropriate subdirectory
- No docs directly in root unless strategic (GAME-DESIGN.md level)
- New lessons-learned must update 00-INDEX.md

**Active Phase**:
- Regular reviews (monthly)
- Update indexes when adding files
- Cross-link related documents

**Deprecation Phase**:
- After work completes, move to `archive/` within 1 week
- Create summary extracting key learnings
- Update relevant indexes to point to summary

### 2. Weekly/Phase Completion Protocol

**When completing a week/phase**:

1. **Extract learnings** to lessons-learned
2. **Archive detailed logs** to appropriate archive subdirectory
3. **Update indexes** (remove old, add new)
4. **Create summary document** if phase was significant
5. **Update NEXT_SESSION.md** (automatic)

### 3. Periodic Audits

**Monthly** (15 min):
- Review docs/ root - anything that should be in subdirectory?
- Check for new duplicate numbering in lessons-learned
- Verify indexes are up-to-date

**Quarterly** (1 hour):
- Full documentation audit (like this one)
- Archive strategy review
- Check for new redundancies
- Update CLAUDE_RULES.md if needed

### 4. New Document Checklist

**Before creating a new markdown file**:

```markdown
□ Is this strategic (root-level) or tactical (subdirectory)?
□ Does similar documentation already exist?
□ If yes, should I update existing vs create new?
□ What's the appropriate subdirectory?
□ Will this need to be archived later? (If yes, plan for it)
□ Should this be referenced in an index?
□ Should this be mentioned in CLAUDE_RULES.md?
```

### 5. Archive Naming Convention

**Format**: `archive/{timeframe-or-phase}/`

**Examples**:
- `migration/archive/week-02/` - Time-based
- `migration/archive/phase-1-config/` - Phase-based
- `experiments/archive/2025-11-week14-15/` - Time-based
- `lessons-learned/archive/react-phaser-era/` - Era-based

### 6. Index Update Protocol

**When to update indexes**:
- ✅ New lesson-learned added → Update 00-INDEX.md
- ✅ New testing doc → Update testing/README.md
- ✅ New research doc → Update research/README.md
- ✅ New iOS doc → Update ios/README.md
- ✅ Archive files → Update relevant index to show archive location

**Automated Check** (Future Enhancement):
- Git pre-commit hook checks if new .md in lessons-learned/ but no update to 00-INDEX.md
- Warns (doesn't block) to remind updating index

### 7. Deprecation Criteria

**Archive immediately if**:
- ✅ Work is 100% complete and not referenced
- ✅ Bug is resolved and learnings extracted
- ✅ Phase/week is finished
- ✅ Content is superseded by newer doc

**Keep active if**:
- ❌ Referenced by current work
- ❌ Contains strategic guidance
- ❌ Part of ongoing investigation
- ❌ Frequently consulted reference

---

## Success Metrics

### Quantitative Metrics

**Before Audit**:
- 200+ markdown files total
- 75+ files in docs/ root
- 44 lessons-learned (no index)
- 40+ migration files (32 historical)
- 19 experiments files (all historical)
- 12+ testing files (redundancy)
- 15+ mobile UX files (redundancy)

**After Implementation** (Target):
- 200+ markdown files total (preserved)
- ~30 files in docs/ root (strategic only)
- 44 lessons-learned + 00-INDEX.md
- ~8 active migration files (32 archived)
- 1 experiments README (19 archived)
- ~6 active testing files (6 archived)
- ~5 active mobile UX files (10 archived)

**Improvement**:
- 45 fewer files in active directories (23% reduction)
- 100% of lessons-learned indexed
- 80% of historical content archived
- 50% reduction in redundant documentation

### Qualitative Metrics

**Discoverability**:
- ✅ AI can find Parent-First protocol in <5 seconds
- ✅ AI can find relevant lesson-learned by scenario
- ✅ New contributors can navigate docs easily
- ✅ Strategic vs tactical docs clearly separated

**Maintenance**:
- ✅ Archive protocol established
- ✅ Index update protocol documented
- ✅ Monthly/quarterly audit schedule
- ✅ New document checklist

**AI Effectiveness**:
- ✅ CLAUDE_RULES.md has navigation aids
- ✅ Quick reference sections added
- ✅ Context loading optimized (load what's needed)
- ✅ Clear authority hierarchy (what to read first)

### Validation Checklist

**After implementation, verify**:

```markdown
□ Can find Parent-First protocol in 3 clicks or less?
□ Lessons-learned 00-INDEX.md categorizes all 44 lessons?
□ Migration archive has 32 historical files?
□ Experiments archive has 19 files + README summary?
□ Testing consolidation leaves 6 active + 6 archived?
□ Mobile UX consolidation leaves 5 active + 10 archived?
□ CLAUDE_RULES.md has TOC, index, quick reference?
□ All internal links still work after reorganization?
□ Git history preserved (files moved, not deleted)?
□ Archive README files explain what's preserved?
```

---

## Appendix A: File Counts by Directory

**Current State** (2025-11-22):

```
Total markdown files: 200+

.system/                    6 files
  ├── docs/                 8 files
  └── archive/              1 file

docs/                      75+ files (root)
  ├── lessons-learned/     44 files
  ├── migration/           40 files
  ├── godot/               11 files
  ├── core-architecture/    7 files
  ├── game-design/systems/ 29 files
  ├── experiments/         19 files
  ├── ui-standards/         2 files
  ├── tier-experiences/     3 files
  ├── setup/                2 files
  ├── competitive-analysis/ 1 file
  ├── reviews/              1 file
  ├── expert-consultations/ 1 file
  └── future-work/          1 file

qa/                         3 files
  └── logs/                 2+ files

Root markdown files        10 files
```

## Appendix B: Duplicate Numbering in Lessons-Learned

**Found duplicates**:
- 30: `30-commit-guidelines-every-commit.md`, `30-supabase-migration-timestamp-discipline.md`
- 38: `38-git-reset-disaster-approval-protocol.md`, `38-protectedsupabase-wrapper-timeout-tier-persistence.md`
- 39: `39-directory-awareness-protocol.md`, `39-quality-gate-engineering-lesson.md`
- 40: `40-realistic-session-planning-lesson.md`, `40-systematic-debugging-skill-trigger-discipline.md`
- 42: `42-continuation-prompt-stability.md`, `42-optimize-for-quality-not-speed.md`

**Recommendation**: Renumber sequentially 01-49

## Appendix C: Large Files (>1000 lines)

**Docs root**:
1. `claude-mobile-game-ui-design-system.md` - 2395 lines
2. `CAMERA-BOUNDARY-FIX-PLAN.md` - 2325 lines
3. `godot-testing-research.md` - 2097 lines
4. `godot-service-architecture.md` - 2068 lines
5. `mobile-ui-specification.md` - 1841 lines
6. `GAME-DESIGN.md` - 1523 lines
7. `godot-performance-patterns.md` - 1410 lines

**Migration**:
1. `week16-implementation-plan.md` - 124K (very large)
2. `week12-implementation-plan.md` - 98K
3. `week15-implementation-plan.md` - 93K
4. `week14-implementation-plan.md` - 90K

**Recommendation**: These are appropriate sizes for comprehensive planning/reference docs

## Appendix D: Authority Hierarchy

**For AI agents and humans, when conflicts arise, trust in this order:**

1. **`.system/CLAUDE_RULES.md`** - Mandatory protocols (highest authority)
2. **`docs/lessons-learned/`** - Institutional memory (proven patterns)
3. **`docs/DEVELOPMENT-RULES.md`** - Core development rules
4. **`docs/core-architecture/DATA-MODEL.md`** - Storage architecture
5. **`docs/GAME-DESIGN.md`** - Game design authority
6. **Week/phase plans** - Current work guidance
7. **Research docs** - Background information
8. **Experiment logs** - Historical debugging

**Rationale**: Mandatory > Proven > Design > Current > Historical

---

**End of Documentation Audit Proposal**

**Next Steps**: User review and approval for implementation

**Questions for User**:
1. Approve Phase 1 (archiving migration/experiments)? Low risk, high value.
2. Approve lessons-learned index creation with renumbering?
3. Should `godot-weekly-action-items.md` (73K) be reviewed for archiving?
4. Approve testing/mobile-ux consolidation?
5. Proceed with full 6-8 hour implementation or prioritize specific phases?

**Recommendation**: Start with Phase 1-2 (4 hours, low risk, immediate value)
