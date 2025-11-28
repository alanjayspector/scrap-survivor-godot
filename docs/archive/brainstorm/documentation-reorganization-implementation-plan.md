# Documentation Reorganization Implementation Plan

**Date**: 2025-11-22
**Prepared by**: Claude Code
**Estimated Time**: 6-8 hours
**Risk Level**: Low (with master backup in place)

---

## ⚠️ IMPORTANT: Master Backup First

Before starting ANY reorganization work, create a master backup. This gives you THREE recovery options:
1. Revert individual git commits (fine-grained)
2. Restore from master archive (nuclear option)
3. Abandon git branch (if we hate everything)

---

## Phase 0: Master Backup & Safety (30 min)

### Step 0.1: Commit Current State (5 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

# Check current status
git status

# Add and commit any uncommitted changes
git add .
git commit -m "docs: snapshot before documentation reorganization"

# Verify clean state
git status  # Should show "nothing to commit, working tree clean"
```

### Step 0.2: Create Master Archive (10 min)

```bash
# Create timestamped master backup
mkdir -p .system/archive
cp -r docs/ .system/archive/docs-backup-2025-11-22/

# Verify backup
ls -la .system/archive/docs-backup-2025-11-22/
# Should show full docs/ structure

# Create recovery instructions
cat > .system/archive/docs-backup-2025-11-22/README.md << 'EOF'
# Documentation Backup - 2025-11-22

This is a complete snapshot of the docs/ directory before the documentation reorganization.

## Recovery Instructions

**If you need to restore everything:**

```bash
# From project root
rm -rf docs/
cp -r .system/archive/docs-backup-2025-11-22/ docs/
git add docs/
git commit -m "docs: restore from master backup"
```

**Backup Date**: 2025-11-22
**Backup Trigger**: Pre-documentation reorganization
**Total Files**: 200+
EOF
```

### Step 0.3: Create Git Branch (5 min)

```bash
# Create branch for reorganization work
git checkout -b docs-reorganization

# Verify on branch
git branch  # Should show * docs-reorganization
```

### Step 0.4: Commit Master Backup (10 min)

```bash
# Add master backup to git
git add .system/archive/docs-backup-2025-11-22/
git commit -m "docs: create master backup before reorganization"

# Push branch (optional but recommended)
git push -u origin docs-reorganization
```

**✅ Checkpoint**: You now have:
- Clean working directory
- Full master backup in `.system/archive/docs-backup-2025-11-22/`
- Working on `docs-reorganization` branch
- Can abandon branch or restore from backup if needed

---

## Phase 1: Archive Historical Content (2 hours)

### Step 1.1: Archive Migration Week Logs (45 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/migration

# Create archive structure
mkdir -p archive/{week-02,week-03,week-04,week-06,week-07,week-08,week-09,week-10,week-11,week-12,week-13,week-14,week-15}

# Move week 2 logs
mv week2-day1-summary.md archive/week-02/
mv week2-day2-validation.md archive/week-02/
mv week2-day3-validation.md archive/week-02/
mv week2-day4-validation.md archive/week-02/
mv week2-day5-completion.md archive/week-02/

# Move week 3 logs
mv week3-day1-completion.md archive/week-03/
mv week3-day2-completion.md archive/week-03/
mv week3-day3-completion.md archive/week-03/
mv week3-day4-completion.md archive/week-03/
mv week3-day5-completion.md archive/week-03/

# Move week 4 logs
mv week4-day1-completion.md archive/week-04/
mv week4-day2-completion.md archive/week-04/
mv week4-day3-completion.md archive/week-04/
mv week4-day4-completion.md archive/week-04/
mv week4-completion.md archive/week-04/

# Move week 6 logs
mv week6-days1-3-completion.md archive/week-06/

# Move week 7-15 implementation plans
mv week7-implementation-plan.md archive/week-07/
mv week8-implementation-plan.md archive/week-08/
mv week9-implementation-plan.md archive/week-09/
mv week10-implementation-plan.md archive/week-10/
mv week11-implementation-plan.md archive/week-11/
mv week12-implementation-plan.md archive/week-12/
mv week13-implementation-plan.md archive/week-13/

# Move week 13-14 handoff docs
mv week13-phase3.5-handoff.md archive/week-13/
mv WEEK14_HANDOFF.md archive/week-14/
mv WEEK14_NEXT_SESSION.md archive/week-14/
mv week14-implementation-plan.md archive/week-14/
mv week15-implementation-plan.md archive/week-15/

# Verify structure
ls -la archive/week-*/
```

### Step 1.2: Create Migration Archive README (15 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/migration

cat > README.md << 'EOF'
# Migration Documentation

## Active Planning

**Primary Documents:**
- [Migration Summary](GODOT-MIGRATION-SUMMARY.md) - Executive overview
- [Migration Timeline](GODOT-MIGRATION-TIMELINE-UPDATED.md) - Updated schedule
- [Week 16 Plan](week16-implementation-plan.md) - Current work
- [Week 17 Plan](week17-tentative.md) - Next week planning
- [Validation Report](VALIDATION-REPORT.md) - Quality assessment

**Reference:**
- [React Native Plan](REACT-NATIVE-MIGRATION-PLAN.md) - Original migration context
- [Phase 1 Inventory](PHASE-1-COMPONENT-INVENTORY.md) - Component catalog

## Historical Records

**Location**: `archive/` subdirectory

The archive contains week-by-week completion logs from the migration execution (Weeks 2-15).

### Archive Structure

- `archive/week-02/` - Week 2 daily completion logs (5 files)
- `archive/week-03/` - Week 3 daily completion logs (5 files)
- `archive/week-04/` - Week 4 completion logs (5 files)
- `archive/week-06/` - Week 6 partial logs (1 file)
- `archive/week-07/` - Week 7 implementation plan
- `archive/week-08/` - Week 8 implementation plan
- `archive/week-09/` - Week 9 implementation plan
- `archive/week-10/` - Week 10 implementation plan
- `archive/week-11/` - Week 11 implementation plan
- `archive/week-12/` - Week 12 implementation plan
- `archive/week-13/` - Week 13 plan and handoff docs
- `archive/week-14/` - Week 14 plan and handoff docs
- `archive/week-15/` - Week 15 implementation plan

**Total Archived**: 32 files

### When to Reference Archive

- Understanding historical context for a decision
- Reviewing how a specific week was executed
- Comparing original plan vs. actual execution
- Debugging issues introduced during a specific week

### Current Migration Status

**Migration Phase**: Week 16 (Deployment & Polish)
**Status**: In Progress
**Primary Document**: [week16-implementation-plan.md](week16-implementation-plan.md)
EOF
```

### Step 1.3: Archive Experiments (30 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/experiments

# Create archive structure
mkdir -p archive/2025-11-week14-15

# Move all experiment files
mv bug-11-enemy-persistence-fix.md archive/2025-11-week14-15/
mv bug-11-enemy-persistence-investigation.md archive/2025-11-week14-15/
mv bug-11-enemy-persistence-strategic-fix.md archive/2025-11-week14-15/
mv enhanced-diagnostics-experiment.md archive/2025-11-week14-15/
mv enhanced-diagnostics-v2-experiment.md archive/2025-11-week14-15/
mv hud-regression-debugging.md archive/2025-11-week14-15/
mv ios-cleanup-iteration-1.md archive/2025-11-week14-15/
mv ios-cleanup-iteration-2.md archive/2025-11-week14-15/
mv ios-cleanup-iteration-3.md archive/2025-11-week14-15/
mv ios-ghost-rendering-experiment.md archive/2025-11-week14-15/
mv ios-ghost-rendering-fix.md archive/2025-11-week14-15/
mv ios-ghost-rendering-hypothesis.md archive/2025-11-week14-15/
mv ios-screen-flash-experiment.md archive/2025-11-week14-15/
mv ios-tween-failure-fix-v2.md archive/2025-11-week14-15/
mv ios-tween-failure-fix.md archive/2025-11-week14-15/
mv ios-tween-failure-hypothesis.md archive/2025-11-week14-15/
mv validator-warnings-cleanup.md archive/2025-11-week14-15/
mv wave-end-stats-panel-fix.md archive/2025-11-week14-15/
mv wave-end-timing-fix.md archive/2025-11-week14-15/

# Verify all moved
ls *.md 2>/dev/null  # Should return nothing (no files left)
ls archive/2025-11-week14-15/  # Should show 19 files
```

### Step 1.4: Create Experiments README (20 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/experiments

cat > README.md << 'EOF'
# Experiments Archive

This directory contains debugging investigations and experimental fixes for specific bugs.

## Purpose

Experiments are **forensic debugging journals** created during bug investigations. They document:
- Hypothesis formation
- Evidence gathering
- Attempted fixes
- Root cause analysis
- Final resolution

## Archive Structure

### 2025-11 Week 14-15 (Archived)

**Location**: `archive/2025-11-week14-15/` (19 files)

**Summary**: iOS rendering and persistence bugs

**Key Investigations**:
1. **Bug 11: Enemy Persistence** (3 files)
   - Root cause: Race condition in sync system
   - Resolution: Strategic refactor of sync pause mechanism
   - Learnings: Extracted to lessons-learned

2. **iOS Ghost Rendering** (3 files)
   - Root cause: CanvasItem lifecycle + iOS Metal rendering
   - Resolution: Parent-First protocol enforcement
   - Learnings: Documented in `docs/godot-ios-sigkill-research.md`

3. **iOS Cleanup Iterations** (3 files)
   - Multiple iOS-specific rendering issues
   - Resolution: Systematic cleanup of node lifecycle
   - Learnings: iOS-specific patterns documented

4. **iOS Tween Failures** (3 files)
   - Root cause: Tweens on orphaned nodes
   - Resolution: Tween ownership management
   - Learnings: Node lifecycle patterns

5. **Enhanced Diagnostics** (2 files)
   - Diagnostic tooling experiments
   - Resolution: Better logging infrastructure

6. **Misc Fixes** (5 files)
   - HUD regression, screen flash, wave-end timing, validators
   - Various iOS and UX polish issues

**Status**: All bugs resolved, learnings extracted

**Key Lessons Extracted**:
- Lesson 44: Godot 4 Parent-First UI Protocol (CRITICAL)
- iOS SIGKILL research documented
- Node lifecycle patterns established

**When to Reference**:
- Similar iOS rendering bugs
- Node lifecycle debugging
- Understanding parent-first protocol origins

## Active Investigations

(None currently)

## Creating New Experiments

**When to create an experiment:**
- Bug has unclear root cause
- Need systematic hypothesis testing
- Multiple attempted fixes
- Forensic evidence gathering required

**Naming Convention**: `{bug-description}-{investigation|hypothesis|fix|experiment}.md`

**After Resolution**:
1. Extract learnings to `docs/lessons-learned/`
2. Move experiment to `archive/{date-range}/`
3. Update this README with summary
EOF
```

### Step 1.5: Archive Godot Weekly Action Items (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/migration

# Move the original planning document
mv ../godot/godot-weekly-action-items.md archive/original-16-week-plan.md

# Verify
ls archive/original-16-week-plan.md
wc -l archive/original-16-week-plan.md  # Should show 3020 lines
```

### Step 1.6: Git Commit Phase 1 (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/migration/
git add docs/experiments/
git add docs/godot/  # (weekly action items removed)
git commit -m "docs: archive completed migration logs and experiments

- Archive 32 migration week logs (weeks 2-15) to migration/archive/
- Archive 19 experiments from Week 14-15 to experiments/archive/
- Archive original 16-week plan to migration/archive/
- Create README files explaining archive structure
- Preserves all history, improves active directory clarity"
```

**✅ Checkpoint**: Archived 51 historical files, created READMEs

---

## Phase 2: Reorganize Lessons-Learned (2 hours)

### Step 2.1: Create Category Subdirectories (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/lessons-learned

# Create category directories
mkdir -p git testing ai-protocols godot architecture database quality-gates migration
```

### Step 2.2: Move Lessons to Categories (45 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/lessons-learned

# Git category
mv 01-git-operations.md git/approval-protocol.md
mv 30-commit-guidelines-every-commit.md git/commit-guidelines.md
mv 38-git-reset-disaster-approval-protocol.md git/reset-disaster-protocol.md

# Testing category
mv 02-testing-conventions.md testing/conventions.md
mv 17-check-test-patterns-before-coding.md testing/check-patterns-first.md
mv 29-fireevent-for-tests-with-fake-timers.md testing/fireevent-fake-timers.md

# AI Protocols category
mv 06-session-management.md ai-protocols/session-management.md
mv 23-session-self-assessment-protocol.md ai-protocols/self-assessment.md
mv 04-context-gathering.md ai-protocols/context-gathering.md
mv 07-context-window-rollovers.md ai-protocols/context-rollovers.md
mv 24-context-rollover-resilience.md ai-protocols/rollover-resilience.md
mv 09-ai-execution-protocol.md ai-protocols/execution-protocol.md
mv 12-notebooklm-skill-usage.md ai-protocols/notebooklm-usage.md
mv 22-notebooklm-documentation-queries.md ai-protocols/notebooklm-queries.md
mv 25-ai-following-problem-forcing-function.md ai-protocols/following-forcing-function.md
mv 39-directory-awareness-protocol.md ai-protocols/directory-awareness.md
mv 40-realistic-session-planning-lesson.md ai-protocols/realistic-planning.md
mv 42-continuation-prompt-stability.md ai-protocols/prompt-stability.md

# Godot category
mv 44-godot4-parent-first-ui-protocol.md godot/parent-first-protocol.md
mv 10-established-patterns.md godot/established-patterns.md
mv 14-established-patterns-documentation.md godot/patterns-documentation.md
mv 16-following-conventions-not-memory.md godot/follow-conventions.md

# Architecture category
mv 43-research-discovery-tiered-system.md architecture/research-tiered-system.md
mv 27-task-specific-checklist-forcing-function.md architecture/task-checklists.md
mv 37-react-phaser-modal-architecture-gap.md architecture/modal-architecture-gap.md

# Database category
mv 13-database-triggers-rls.md database/triggers-rls.md
mv 21-supabase-auth-usage-patterns.md database/auth-patterns.md
mv 30-supabase-migration-timestamp-discipline.md database/migration-timestamps.md
mv 32-rls-explicit-vs-generic-policies.md database/rls-policies.md
mv 33-protectedsupabaseclient-return-unwrapped.md database/protected-client-unwrapped.md
mv 38-protectedsupabase-wrapper-timeout-tier-persistence.md database/wrapper-timeout.md
mv 26-direct-reads-vs-api-queries.md database/direct-reads-vs-api.md

# Quality Gates category
mv 19-evidence-based-debugging-not-tool-thrashing.md quality-gates/evidence-based-debugging.md
mv 40-systematic-debugging-skill-trigger-discipline.md quality-gates/systematic-debugging.md
mv 15-evidence-based-database-work.md quality-gates/evidence-based-database.md
mv 36-debug-logging-evidence-based-troubleshooting.md quality-gates/debug-logging.md
mv 39-quality-gate-engineering-lesson.md quality-gates/engineering-discipline.md

# Migration category
mv 41-migration-philosophy-not-quick-fixes.md migration/philosophy-not-quick-fixes.md
mv 42-optimize-for-quality-not-speed.md migration/optimize-quality.md

# Other lessons (review these)
mv 03-user-preferences.md architecture/user-preferences.md
mv 05-data-model-assumptions.md architecture/data-model-assumptions.md
mv 08-dry-principle.md architecture/dry-principle.md
mv 11-defensive-development.md architecture/defensive-development.md
mv 18-follow-established-query-patterns.md database/query-patterns.md
mv 20-user-documentation-tells-truth.md architecture/documentation-truth.md
mv 28-storybook-interactive-stories-with-hooks.md architecture/storybook-patterns.md
mv 34-game-store-reactivity-updatecharacter.md godot/store-reactivity.md
mv 35-sync-race-condition-runwithsyncpaused.md godot/sync-race-conditions.md

# Verify no files left in root
ls *.md 2>/dev/null  # Should return nothing

# Verify category structure
ls -la */
```

### Step 2.3: Create Lessons-Learned Index (60 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/lessons-learned

cat > 00-INDEX.md << 'EOF'
# Lessons Learned Index

**44 lessons organized by category**

This index provides quick navigation to institutional knowledge learned throughout the project. Lessons are categorized by topic and tagged with priority levels.

## Priority Levels

- 🔴 **MANDATORY** - Violating this causes critical bugs or data loss
- 🟡 **High** - Violating this causes significant problems
- 🟢 **Medium** - Best practices, improves quality
- ⚪ **Low** - Nice-to-know, context

---

## Table of Contents

1. [Critical Lessons (MANDATORY)](#critical-lessons-mandatory)
2. [Git Operations](#git-operations)
3. [Godot Development](#godot-development)
4. [Testing Discipline](#testing-discipline)
5. [AI Session Management](#ai-session-management)
6. [Quality Gates & Evidence-Based Engineering](#quality-gates--evidence-based-engineering)
7. [Architecture & Design](#architecture--design)
8. [Database & Backend](#database--backend)
9. [Migration Philosophy](#migration-philosophy)
10. [Quick Reference by Scenario](#quick-reference-by-scenario)

---

## Critical Lessons (MANDATORY)

These lessons prevent **CRITICAL** bugs and failures. Violating these can cause iOS crashes, data loss, or project disasters.

### 🔴 Godot 4 Parent-First UI Protocol

**File**: [godot/parent-first-protocol.md](godot/parent-first-protocol.md)

**What**: Always parent dynamic Control nodes BEFORE configuring properties

**When**: EVERY dynamic UI node creation in Godot 4 (`.new()` calls)

**Why**: iOS crashes with SIGKILL if violated (configure-then-parent creates layout conflicts)

**Impact**: App disappears with no error message on iOS

**Code Pattern**:
```gdscript
# ✅ CORRECT
var node = VBoxContainer.new()
parent.add_child(node)      # 1. Parent FIRST
node.layout_mode = 2        # 2. Set mode
node.name = "MyNode"        # 3. Configure AFTER

# ❌ WRONG
var node = VBoxContainer.new()
node.name = "MyNode"        # ❌ Configure first
parent.add_child(node)      # ❌ Parent last → iOS SIGKILL
```

**See Also**: `.system/CLAUDE_RULES.md` (Godot 4 Dynamic UI section)

---

### 🔴 Git Approval Protocol

**File**: [git/approval-protocol.md](git/approval-protocol.md)

**What**: Always get user approval before destructive git operations

**When**: ANY merge, rebase, amend, push --force, reset

**Why**: Prevents data loss and collaboration disasters

**Impact**: Losing hours/days of work

**Required Actions**:
1. Announce operation
2. Show what will change
3. Wait for explicit "yes"
4. Never use `--no-verify` or `--force` without approval

**See Also**: `.system/CLAUDE_RULES.md` (Blocking Protocol)

---

## Git Operations

**Category**: `git/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Git Approval Protocol | [approval-protocol.md](git/approval-protocol.md) | 🔴 Mandatory | Always get approval for destructive git operations |
| Commit Guidelines | [commit-guidelines.md](git/commit-guidelines.md) | 🟡 High | Follow conventional commits format every time |
| Reset Disaster Protocol | [reset-disaster-protocol.md](git/reset-disaster-protocol.md) | 🔴 Mandatory | Never use git reset --hard without approval |

---

## Godot Development

**Category**: `godot/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Parent-First Protocol | [parent-first-protocol.md](godot/parent-first-protocol.md) | 🔴 Mandatory | Parent nodes before configuring (iOS SIGKILL prevention) |
| Established Patterns | [established-patterns.md](godot/established-patterns.md) | 🟡 High | Follow project patterns, don't invent new approaches |
| Patterns Documentation | [patterns-documentation.md](godot/patterns-documentation.md) | 🟢 Medium | Document patterns for consistency |
| Follow Conventions | [follow-conventions.md](godot/follow-conventions.md) | 🟡 High | Use conventions from codebase, not memory |
| Store Reactivity | [store-reactivity.md](godot/store-reactivity.md) | 🟢 Medium | Update character triggers store reactivity |
| Sync Race Conditions | [sync-race-conditions.md](godot/sync-race-conditions.md) | 🟡 High | Use run_with_sync_paused for atomic operations |

---

## Testing Discipline

**Category**: `testing/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Testing Conventions | [conventions.md](testing/conventions.md) | 🟡 High | Follow established test patterns and naming |
| Check Patterns First | [check-patterns-first.md](testing/check-patterns-first.md) | 🟡 High | Read existing tests before writing new ones |
| FireEvent Fake Timers | [fireevent-fake-timers.md](testing/fireevent-fake-timers.md) | 🟢 Medium | Use FireEvent for tests with fake timers |

---

## AI Session Management

**Category**: `ai-protocols/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Session Management | [session-management.md](ai-protocols/session-management.md) | 🟡 High | Use NEXT_SESSION.md for continuity |
| Self-Assessment | [self-assessment.md](ai-protocols/self-assessment.md) | 🟡 High | Regular quality checkpoints during sessions |
| Context Gathering | [context-gathering.md](ai-protocols/context-gathering.md) | 🟢 Medium | Gather context before making changes |
| Context Rollovers | [context-rollovers.md](ai-protocols/context-rollovers.md) | 🟢 Medium | Handle context window limits gracefully |
| Rollover Resilience | [rollover-resilience.md](ai-protocols/rollover-resilience.md) | 🟢 Medium | Maintain quality across context boundaries |
| Execution Protocol | [execution-protocol.md](ai-protocols/execution-protocol.md) | 🟡 High | Follow systematic execution process |
| NotebookLM Usage | [notebooklm-usage.md](ai-protocols/notebooklm-usage.md) | ⚪ Low | When to use NotebookLM skill |
| NotebookLM Queries | [notebooklm-queries.md](ai-protocols/notebooklm-queries.md) | ⚪ Low | Effective NotebookLM query patterns |
| Following Forcing Function | [following-forcing-function.md](ai-protocols/following-forcing-function.md) | 🟡 High | Use checklists to force compliance |
| Directory Awareness | [directory-awareness.md](ai-protocols/directory-awareness.md) | 🟢 Medium | Verify directory context before operations |
| Realistic Planning | [realistic-planning.md](ai-protocols/realistic-planning.md) | 🟡 High | Plan sessions realistically, not optimistically |
| Prompt Stability | [prompt-stability.md](ai-protocols/prompt-stability.md) | 🟢 Medium | Use stable continuation prompts |

---

## Quality Gates & Evidence-Based Engineering

**Category**: `quality-gates/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Evidence-Based Debugging | [evidence-based-debugging.md](quality-gates/evidence-based-debugging.md) | 🔴 Mandatory | Stop and investigate after 1 failure, no tool thrashing |
| Systematic Debugging | [systematic-debugging.md](quality-gates/systematic-debugging.md) | 🔴 Mandatory | Spawn investigation agent after unclear QA failure |
| Evidence-Based Database | [evidence-based-database.md](quality-gates/evidence-based-database.md) | 🟡 High | Prove database changes with evidence |
| Debug Logging | [debug-logging.md](quality-gates/debug-logging.md) | 🟢 Medium | Strategic debug logging for troubleshooting |
| Engineering Discipline | [engineering-discipline.md](quality-gates/engineering-discipline.md) | 🟡 High | Quality gates are engineering tools, not obstacles |

---

## Architecture & Design

**Category**: `architecture/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Research Tiered System | [research-tiered-system.md](architecture/research-tiered-system.md) | 🟡 High | Strategic vs tactical research separation |
| Task Checklists | [task-checklists.md](architecture/task-checklists.md) | 🟢 Medium | Use checklists as forcing functions |
| Modal Architecture Gap | [modal-architecture-gap.md](architecture/modal-architecture-gap.md) | 🟢 Medium | React-Phaser modal issues (historical) |
| User Preferences | [user-preferences.md](architecture/user-preferences.md) | 🟢 Medium | User preference patterns |
| Data Model Assumptions | [data-model-assumptions.md](architecture/data-model-assumptions.md) | 🟡 High | Don't assume, verify data model |
| DRY Principle | [dry-principle.md](architecture/dry-principle.md) | 🟢 Medium | Don't Repeat Yourself appropriately |
| Defensive Development | [defensive-development.md](architecture/defensive-development.md) | 🟢 Medium | Build defensively, expect edge cases |
| Documentation Truth | [documentation-truth.md](architecture/documentation-truth.md) | 🟡 High | User docs must reflect reality |
| Storybook Patterns | [storybook-patterns.md](architecture/storybook-patterns.md) | ⚪ Low | Storybook interactive stories (React era) |

---

## Database & Backend

**Category**: `database/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Triggers & RLS | [triggers-rls.md](database/triggers-rls.md) | 🟡 High | Database triggers work with RLS |
| Auth Patterns | [auth-patterns.md](database/auth-patterns.md) | 🟡 High | Supabase auth usage patterns |
| Migration Timestamps | [migration-timestamps.md](database/migration-timestamps.md) | 🟢 Medium | Proper timestamp discipline in migrations |
| RLS Policies | [rls-policies.md](database/rls-policies.md) | 🟡 High | Explicit vs generic RLS policies |
| Protected Client Unwrapped | [protected-client-unwrapped.md](database/protected-client-unwrapped.md) | 🟡 High | ProtectedSupabaseClient returns unwrapped |
| Wrapper Timeout | [wrapper-timeout.md](database/wrapper-timeout.md) | 🟢 Medium | Timeout handling in Supabase wrapper |
| Direct Reads vs API | [direct-reads-vs-api.md](database/direct-reads-vs-api.md) | 🟢 Medium | When to use direct reads vs API queries |
| Query Patterns | [query-patterns.md](database/query-patterns.md) | 🟡 High | Follow established query patterns |

---

## Migration Philosophy

**Category**: `migration/`

| Lesson | File | Priority | Summary |
|--------|------|----------|---------|
| Philosophy Not Quick Fixes | [philosophy-not-quick-fixes.md](migration/philosophy-not-quick-fixes.md) | 🟡 High | Migration requires philosophy, not hacks |
| Optimize Quality | [optimize-quality.md](migration/optimize-quality.md) | 🟡 High | Optimize for quality, not speed |

---

## Quick Reference by Scenario

### 🎮 When working on Godot 4 UI:
→ 🔴 [godot/parent-first-protocol.md](godot/parent-first-protocol.md) (MANDATORY)
→ 🟡 [godot/established-patterns.md](godot/established-patterns.md)
→ 🟡 [godot/follow-conventions.md](godot/follow-conventions.md)
→ See also: `.system/CLAUDE_RULES.md` (Godot 4 Dynamic UI section)

### 🔨 When committing to git:
→ 🔴 [git/approval-protocol.md](git/approval-protocol.md) (MANDATORY)
→ 🟡 [git/commit-guidelines.md](git/commit-guidelines.md)
→ See also: `.system/CLAUDE_RULES.md` (Commit Message Format)

### 🧪 When writing tests:
→ 🟡 [testing/conventions.md](testing/conventions.md)
→ 🟡 [testing/check-patterns-first.md](testing/check-patterns-first.md)
→ See also: `docs/TESTING-INDEX.md`

### 🐛 When investigating bugs:
→ 🔴 [quality-gates/evidence-based-debugging.md](quality-gates/evidence-based-debugging.md) (MANDATORY)
→ 🔴 [quality-gates/systematic-debugging.md](quality-gates/systematic-debugging.md) (MANDATORY)
→ See also: `.system/CLAUDE_RULES.md` (QA Investigation Protocol)

### 🏗️ When making architectural decisions:
→ 🟡 [architecture/research-tiered-system.md](architecture/research-tiered-system.md)
→ 🟡 [godot/established-patterns.md](godot/established-patterns.md)
→ See also: `docs/core-architecture/PATTERN-CATALOG.md`

### 🤖 When planning AI sessions:
→ 🟡 [ai-protocols/session-management.md](ai-protocols/session-management.md)
→ 🟡 [ai-protocols/self-assessment.md](ai-protocols/self-assessment.md)
→ 🟡 [ai-protocols/realistic-planning.md](ai-protocols/realistic-planning.md)
→ See also: `.system/NEXT_SESSION.md`

### 🗄️ When working with database:
→ 🟡 [database/triggers-rls.md](database/triggers-rls.md)
→ 🟡 [database/auth-patterns.md](database/auth-patterns.md)
→ 🟡 [database/query-patterns.md](database/query-patterns.md)
→ See also: `docs/core-architecture/DATA-MODEL.md`

### 📱 When debugging iOS issues:
→ 🔴 [godot/parent-first-protocol.md](godot/parent-first-protocol.md) (MANDATORY)
→ See also: `docs/godot-ios-sigkill-research.md`

### 🚀 When working on migration:
→ 🟡 [migration/philosophy-not-quick-fixes.md](migration/philosophy-not-quick-fixes.md)
→ 🟡 [migration/optimize-quality.md](migration/optimize-quality.md)

---

## Statistics

- **Total Lessons**: 44
- **MANDATORY (🔴)**: 4 lessons
- **High Priority (🟡)**: 25 lessons
- **Medium Priority (🟢)**: 13 lessons
- **Low Priority (⚪)**: 2 lessons

## How to Use This Index

1. **Before starting work**: Check relevant scenario in Quick Reference
2. **During work**: Reference specific lessons for patterns and gotchas
3. **When stuck**: Check Quality Gates section for debugging discipline
4. **For planning**: Review AI Protocols section

## Maintenance

**When adding new lessons**:
1. Place in appropriate category subdirectory
2. Add to this index in relevant table
3. Add to Quick Reference if scenario-specific
4. Update statistics

**Last Updated**: 2025-11-22 (reorganization from numbered to categorized)
EOF
```

### Step 2.4: Git Commit Phase 2 (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/lessons-learned/
git commit -m "docs: reorganize lessons-learned into categories

- Drop numeric prefixes (01-44) to prevent numbering drift
- Organize into 9 categories: git, godot, testing, ai-protocols, quality-gates, architecture, database, migration
- Create comprehensive 00-INDEX.md with categorization, priority levels, and quick reference
- All 44 lessons preserved with semantic filenames
- Improves discoverability and prevents maintenance burden of renumbering"
```

**✅ Checkpoint**: Lessons-learned reorganized into logical categories, index created

---

## Phase 3: Consolidate Testing Documentation (1.5 hours)

### Step 3.1: Create Testing Subdirectory (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Create structure
mkdir -p testing/archive

# Move files from root to testing/
mv TESTING-INDEX.md testing/README.md
mv godot-testing-research.md testing/
mv test-file-template.md testing/
mv test-quality-enforcement.md testing/
mv RUNNING-TESTS-IN-GODOT.md testing/running-tests.md
mv RUNNING-RESOURCE-TESTS.md testing/resource-tests.md
mv RESOURCE-TESTS-GUIDE.md testing/resource-tests-guide.md

# Archive historical files
mv gut-migration-phase3-status.md testing/archive/
mv godot-gut-framework-validation.md testing/archive/
mv BRAINSTORM-COVERAGE-ANALYSIS.md testing/archive/

# Move from root
mv ../ENFORCEMENT-SYSTEM.md testing/enforcement-system.md
mv ../GUT-MIGRATION.md testing/archive/gut-migration.md
```

### Step 3.2: Consolidate Resource Test Docs (20 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/testing

# Read both files to consolidate
# (Manual step: merge content of resource-tests.md and resource-tests-guide.md)
# Keep one canonical guide

# For now, let's keep both but mark in README which is authoritative
```

### Step 3.3: Update Testing README (30 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/testing

# Update README (formerly TESTING-INDEX.md)
cat > README.md << 'EOF'
# Testing Documentation

Comprehensive testing guide for the Scrap Survivor Godot project.

## Quick Start

1. **New to testing?** Start here: [godot-testing-research.md](godot-testing-research.md) (comprehensive guide)
2. **Writing a test?** Use: [test-file-template.md](test-file-template.md)
3. **Running tests?** See: [running-tests.md](running-tests.md)

## Core Documentation

### Testing Fundamentals

**[godot-testing-research.md](godot-testing-research.md)** (2097 lines)
- Comprehensive GUT framework guide
- Test patterns and best practices
- Examples for all test types
- **Start here for deep dive**

**[test-file-template.md](test-file-template.md)**
- Standard template for new test files
- Naming conventions
- Structure requirements
- Copy-paste starting point

**[test-quality-enforcement.md](test-quality-enforcement.md)**
- Quality gates for tests
- Validator integration
- What tests must pass to commit

### Running Tests

**[running-tests.md](running-tests.md)** (formerly RUNNING-TESTS-IN-GODOT.md)
- How to run full test suite
- How to run specific tests
- CI/CD integration
- Troubleshooting test failures

**[resource-tests.md](resource-tests.md)** (formerly RUNNING-RESOURCE-TESTS.md)
- Running resource-specific tests
- Resource test patterns

**[resource-tests-guide.md](resource-tests-guide.md)** (formerly RESOURCE-TESTS-GUIDE.md)
- Detailed guide for testing custom resources
- Resource instantiation patterns
- **Authoritative resource test guide**

### Quality Enforcement

**[enforcement-system.md](enforcement-system.md)** (formerly root ENFORCEMENT-SYSTEM.md)
- Quality gate system overview
- Pre-commit hooks
- Validators
- How enforcement works

## Historical Documentation

**Location**: `archive/` subdirectory

- `gut-migration-phase3-status.md` - GUT migration status (completed)
- `godot-gut-framework-validation.md` - Framework validation (completed)
- `BRAINSTORM-COVERAGE-ANALYSIS.md` - Coverage analysis (completed)
- `gut-migration.md` - GUT migration documentation (completed)

## Test Statistics

**Current Status** (as of Week 16):
- **Total Tests**: 520 automated tests
- **Passing**: 100%
- **Framework**: GUT (Godot Unit Test)
- **Coverage**: High (core systems well-tested)

## Quick Reference

### Running All Tests
```bash
python3 .system/validators/godot_test_runner.py
```

### Running Specific Test
```bash
# Via Godot editor
# Select test in FileSystem, right-click → "Run GUT Test"
```

### Creating New Test
1. Copy [test-file-template.md](test-file-template.md)
2. Follow naming convention: `test_{class_under_test}.gd`
3. Place in `tests/` directory
4. Run to verify

### Common Patterns
- **Service tests**: Mock dependencies, test in isolation
- **Integration tests**: Test service interactions
- **Resource tests**: Use `ResourceLoader.load()`, test properties
- **Performance tests**: Use `TimingService`, assert thresholds

## See Also

- `.system/CLAUDE_RULES.md` - Testing validation rules
- `docs/lessons-learned/testing/` - Testing lessons learned
- `docs/core-architecture/PATTERN-CATALOG.md` - Testing patterns

## Maintenance

When adding testing documentation:
1. Determine if it's core, running, quality, or historical
2. Place in appropriate location
3. Update this README
4. Link from relevant sections

**Last Updated**: 2025-11-22 (consolidation from root directory)
EOF
```

### Step 3.4: Git Commit Phase 3 (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/testing/
git add docs/TESTING-INDEX.md  # (removed)
git add docs/godot-testing-research.md  # (removed)
# ... (all moved files)
git commit -m "docs: consolidate testing documentation into testing/ subdirectory

- Create docs/testing/ subdirectory
- Move 12 testing files from root and other locations
- Archive 4 historical migration docs
- Update README (formerly TESTING-INDEX.md) with clear navigation
- Reduces docs/ root clutter, improves testing doc discoverability"
```

**✅ Checkpoint**: Testing docs consolidated (12 → 7 active + 4 archived)

---

## Phase 4: Consolidate Mobile UX Documentation (1.5 hours)

### Step 4.1: Create Mobile UX Subdirectory (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Create structure
mkdir -p mobile-ux/research mobile-ux/archive

# Move ui-standards/ subdirectory content
mv ui-standards/* mobile-ux/
rmdir ui-standards

# Move primary specification
mv mobile-ui-specification.md mobile-ux/

# Move design system (to be consolidated into specification)
mv claude-mobile-game-ui-design-system.md mobile-ux/archive/

# Move plans to archive
mv MOBILE-TOUCH-CONTROLS-PLAN.md mobile-ux/archive/
mv MOBILE-UX-OPTIMIZATION-PLAN.md mobile-ux/archive/
mv MOBILE-UX-QA-FIXES.md mobile-ux/archive/
mv MOBILE-UX-QA-ROUND-3-PLAN.md mobile-ux/archive/
mv MOBILE-UX-QA-ROUND-4-PLAN.md mobile-ux/archive/

# Move research files
mv perplexity-brotato-ui-mobile-research.md mobile-ux/research/brotato-mobile-ux.md
mv gemini-mobile-ui-research.md mobile-ux/research/
mv gemini-haptic-research.md mobile-ux/research/haptic-feedback.md
```

### Step 4.2: Create Mobile UX README (30 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs/mobile-ux

cat > README.md << 'EOF'
# Mobile UX Documentation

Mobile user experience standards, specifications, and research for iOS and Android.

## Quick Start

**Primary Reference**: [mobile-ui-specification.md](mobile-ui-specification.md) (1841 lines)

This is the **authoritative mobile UX specification** covering:
- Touch controls
- Screen layouts
- Button sizing
- Gesture patterns
- Accessibility
- iOS HIG compliance

## Core Documentation

### UI Specifications

**[mobile-ui-specification.md](mobile-ui-specification.md)** ⭐ **AUTHORITATIVE**
- Complete mobile UI specification
- Touch-optimized controls
- Screen size adaptations
- Platform-specific patterns (iOS HIG, Material Design)

**Standards** (subdirectory)
- [mobile-dialog-standards.md](mobile-dialog-standards.md) - Modal dialog patterns
- [mobile-ui-spec.md](mobile-ui-spec.md) - UI component specs

### Research

**Location**: `research/` subdirectory

**[brotato-mobile-ux.md](research/brotato-mobile-ux.md)**
- Competitor analysis (Brotato mobile UX)
- Consolidated from Perplexity research

**[gemini-mobile-ui-research.md](research/gemini-mobile-ui-research.md)**
- AI research on mobile UI patterns

**[haptic-feedback.md](research/haptic-feedback.md)**
- Haptic feedback research and patterns

## Historical Documentation

**Location**: `archive/` subdirectory

Completed plans and design iterations:
- `claude-mobile-game-ui-design-system.md` - Original design system (2395 lines, learnings → specification)
- `MOBILE-TOUCH-CONTROLS-PLAN.md` - Touch controls plan (completed)
- `MOBILE-UX-OPTIMIZATION-PLAN.md` - UX optimization plan (completed)
- `MOBILE-UX-QA-FIXES.md` - QA fixes (completed)
- `MOBILE-UX-QA-ROUND-3-PLAN.md` - QA round 3 (completed)
- `MOBILE-UX-QA-ROUND-4-PLAN.md` - QA round 4 (completed)

## iOS-Specific

**See also**: `docs/ios/` directory for iOS-specific technical documentation

## Key Principles

1. **Touch-First Design** - All controls optimized for finger input (44×44pt minimum)
2. **iOS HIG Compliance** - Follow Apple Human Interface Guidelines exactly
3. **Native Patterns** - Use platform modals, not custom button state machines
4. **One-Handed Play** - Primary controls in thumb-reach zone
5. **Clear Visual Hierarchy** - Contrast, spacing, typography

## Quick Reference

### Button Sizing
- **Minimum**: 44×44pt (iOS HIG requirement)
- **Recommended**: 48×48dp (comfortable for all users)
- **Large Actions**: 56×56pt (primary actions)

### Modal Types (iOS)
- **Alert** - Simple confirmation (1-2 buttons)
- **Action Sheet** - List of choices (destructive marked red)
- **Full Screen** - Complex UI (character select, shop)

### Touch Zones (Landscape Phone)
- **Primary Zone** - Bottom-right corner (right thumb)
- **Secondary Zone** - Bottom-left corner (left thumb)
- **Tertiary Zone** - Center (two-handed)

## See Also

- `.system/CLAUDE_RULES.md` - Mobile-Native Development Standards
- `docs/ios/` - iOS-specific technical documentation
- `docs/godot/ui-development-best-practices.md` - UI development patterns
- `docs/lessons-learned/godot/parent-first-protocol.md` - Critical iOS UI protocol

## Maintenance

When updating mobile UX:
1. Update primary specification first
2. Extract research learnings → specification
3. Archive completed plans
4. Update this README if structure changes

**Last Updated**: 2025-11-22 (consolidation from root directory)
EOF
```

### Step 4.3: Git Commit Phase 4 (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/mobile-ux/
git add docs/ui-standards/  # (removed)
# Add all moved files
git commit -m "docs: consolidate mobile UX documentation into mobile-ux/ subdirectory

- Create docs/mobile-ux/ subdirectory with research/ and archive/
- Move ui-standards/ content to mobile-ux/
- Archive 6 completed QA plans and design iterations
- Consolidate research files (brotato, haptic, gemini)
- mobile-ui-specification.md is authoritative reference
- Reduces docs/ root from 15+ mobile files to organized subdirectory"
```

**✅ Checkpoint**: Mobile UX docs consolidated (15+ → 5 active + 6 archived)

---

## Phase 5: Organize iOS, Camera, Research, Reference, Status (2 hours)

### Step 5.1: Create iOS Subdirectory (30 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Create structure
mkdir -p ios/technical ios/guides

# Move critical iOS docs
mv godot-ios-sigkill-research.md ios/sigkill-research.md
mv IOS-DEVICE-TESTING-CHECKLIST.md ios/device-testing-checklist.md
mv IOS-PRIVACY-PERMISSIONS-FIX.md ios/privacy-permissions-fix.md

# Move technical docs
mv godot-ios-audio-research.md ios/technical/
mv godot-ios-canvasitem-ghost.md ios/technical/
mv godot-ios-metal-canvas.md ios/technical/
mv godot-ios-metal-flush.md ios/technical/
mv godot-ios-settings-privacy.md ios/technical/
mv godot-ios-temp-ui.md ios/technical/
mv godot-label-pooling-ios.md ios/technical/

# Move guides
mv quick-ios-export-guide.md ios/guides/export-guide.md
mv simulator-first-time-guide.md ios/guides/simulator-first-time.md
mv iphone12mini-simulator-quick-guide.md ios/guides/iphone12mini-simulator.md

# Create iOS README
cat > ios/README.md << 'EOF'
# iOS Development Documentation

iOS-specific technical documentation, debugging guides, and device testing procedures.

## 🔴 CRITICAL

**[sigkill-research.md](sigkill-research.md)** - **READ FIRST IF iOS CRASHES**

Forensic analysis of iOS SIGKILL crashes (0x8badf00d watchdog).

**Root Cause**: Godot 4 Parent-First protocol violations
**Solution**: Parent dynamic nodes BEFORE configuring properties
**See Also**: `docs/lessons-learned/godot/parent-first-protocol.md`

## Quick Start

### Device Testing
**[device-testing-checklist.md](device-testing-checklist.md)**
- Pre-deployment checklist
- Required iOS device tests
- Performance validation
- Crash detection

### Privacy & Permissions
**[privacy-permissions-fix.md](privacy-permissions-fix.md)**
- iOS privacy settings
- Required permissions
- Info.plist configuration

## Technical Documentation

**Location**: `technical/` subdirectory

- `godot-ios-audio-research.md` - iOS audio implementation
- `godot-ios-canvasitem-ghost.md` - Ghost rendering debugging
- `godot-ios-metal-canvas.md` - Metal canvas rendering
- `godot-ios-metal-flush.md` - Metal flush behavior
- `godot-ios-settings-privacy.md` - Settings and privacy
- `godot-ios-temp-ui.md` - Temporary UI notes
- `godot-label-pooling-ios.md` - Label pooling for performance

## Export & Deployment Guides

**Location**: `guides/` subdirectory

- `export-guide.md` - Quick iOS export guide
- `simulator-first-time.md` - First-time simulator setup
- `iphone12mini-simulator.md` - iPhone 12 Mini specific guide

## Common iOS Issues

### App Crashes with SIGKILL (No Error)
→ Read [sigkill-research.md](sigkill-research.md)
→ Check for Parent-First violations
→ Review dynamic UI creation code

### Performance Issues on Device
→ Check label pooling: `technical/godot-label-pooling-ios.md`
→ Review Metal rendering: `technical/godot-ios-metal-canvas.md`

### Audio Not Working
→ Check: `technical/godot-ios-audio-research.md`

## See Also

- `.system/CLAUDE_RULES.md` - Godot 4 Parent-First Protocol (MANDATORY)
- `docs/godot/ui-development-best-practices.md` - UI best practices
- `docs/mobile-ux/` - Mobile UX standards
- `docs/lessons-learned/godot/parent-first-protocol.md` - Critical lesson

**Last Updated**: 2025-11-22 (organization from docs/ root)
EOF
```

### Step 5.2: Create Camera, Research, Reference, Status Subdirectories (40 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Camera
mkdir -p camera
mv CAMERA-BOUNDARY-FIX-PLAN.md camera/boundary-fix-plan.md
mv godot-camera-research-2025-11-16.md camera/camera-research-2025-11-16.md
mv godot-camera2d-boundaries.md camera/camera2d-boundaries.md
mv godot-camera2d-movement.md camera/camera2d-movement.md

cat > camera/README.md << 'EOF'
# Camera System Documentation

Camera implementation, boundaries, and performance optimization for Scrap Survivor.

## Core Documentation

- `boundary-fix-plan.md` (2325 lines) - Camera boundary system implementation
- `camera-research-2025-11-16.md` - Research on Godot Camera2D behavior
- `camera2d-boundaries.md` - Camera boundary patterns
- `camera2d-movement.md` - Camera movement implementation

## Quick Reference

**Primary Document**: `boundary-fix-plan.md` contains comprehensive camera system design.

**Last Updated**: 2025-11-22
EOF

# Research
mkdir -p research/godot
mv godot-service-architecture.md research/godot/service-architecture.md
mv godot-asset-import-research.md research/godot/asset-import.md
mv godot-asset-optimization.md research/godot/asset-optimization.md
mv godot-performance-patterns.md research/godot/performance-patterns.md
mv godot-community-research.md research/godot/community-research.md

cat > research/README.md << 'EOF'
# Research Documentation

Strategic and tactical research organized by topic.

## Structure

- `godot/` - Godot engine research and patterns

## Godot Research

- `service-architecture.md` (2068 lines) - Service layer architecture patterns
- `asset-import.md` - Asset import pipeline research
- `asset-optimization.md` - Asset optimization strategies
- `performance-patterns.md` (1410 lines) - Performance optimization patterns
- `community-research.md` - Godot community patterns and practices

## See Also

- `docs/lessons-learned/architecture/research-tiered-system.md` - Research organization methodology

**Last Updated**: 2025-11-22
EOF

# Reference
mkdir -p reference
mv godot-reference.md reference/
mv godot-coordinates-reference.md reference/coordinates-reference.md
mv godot-rect2-reference.md reference/rect2-reference.md
mv godot-performance-monitors-reference.md reference/performance-monitors-reference.md
mv godot-data-tree-null.md reference/data-tree-null.md

cat > reference/README.md << 'EOF'
# Quick Reference Documentation

Quick reference guides for Godot APIs and patterns.

## References

- `godot-reference.md` - General Godot API reference
- `coordinates-reference.md` - Coordinate system reference
- `rect2-reference.md` - Rect2 API reference
- `performance-monitors-reference.md` - Performance monitoring API
- `data-tree-null.md` - Data tree null handling

## Usage

These are quick-lookup references for common APIs. For comprehensive guides, see main documentation directories.

**Last Updated**: 2025-11-22
EOF

# Status
mkdir -p status/week16
mv week16-phase1-summary.md status/week16/phase1-summary.md
mv week16-phase3.5-completion-summary.md status/week16/phase3.5-completion-summary.md
mv week16-phase3.5-validation-guide.md status/week16/phase3.5-validation-guide.md
mv week16-phase3.5-validation-report.md status/week16/phase3.5-validation-report.md
mv week16-phase4-completion-summary.md status/week16/phase4-completion-summary.md
mv week16-phase4-dialog-audit.md status/week16/phase4-dialog-audit.md

cat > status/README.md << 'EOF'
# Status Documentation

Week-by-week and phase-by-phase status reports.

## Week 16

**Location**: `week16/` subdirectory

Phase completion summaries and validation reports for Week 16 work.

- `phase1-summary.md` - Phase 1 completion
- `phase3.5-completion-summary.md` - Phase 3.5 completion
- `phase3.5-validation-guide.md` - Phase 3.5 QA guide
- `phase3.5-validation-report.md` - Phase 3.5 QA results
- `phase4-completion-summary.md` - Phase 4 completion
- `phase4-dialog-audit.md` - Dialog audit results

## Future Weeks

Add subdirectories for future weeks: `week17/`, `week18/`, etc.

**Last Updated**: 2025-11-22
EOF
```

### Step 5.3: Git Commit Phase 5 (10 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/ios/
git add docs/camera/
git add docs/research/
git add docs/reference/
git add docs/status/
# Add all moved files
git commit -m "docs: organize iOS, camera, research, reference, and status into subdirectories

- Create docs/ios/ with technical/ and guides/ subdirectories (10+ files)
- Create docs/camera/ for camera system docs (4 files)
- Create docs/research/godot/ for research docs (5 files)
- Create docs/reference/ for quick reference docs (5 files)
- Create docs/status/week16/ for status reports (6 files)
- Each subdirectory has README for navigation
- Reduces docs/ root by 30+ files"
```

**✅ Checkpoint**: iOS, camera, research, reference, status organized

---

## Phase 6: Enhance CLAUDE_RULES.md (1 hour)

### Step 6.1: Add Table of Contents (15 min)

Edit `.system/CLAUDE_RULES.md` and add TOC at top (after version/effective/enforcement header):

```markdown
## Table of Contents

1. [BLOCKING PROTOCOL](#blocking-protocol-active)
2. [NEVER Rules](#never-rules-zero-tolerance)
3. [Evidence-Based Engineering Checklist](#evidence-based-engineering-checklist)
4. [Commit Message Format](#commit-message-format)
5. [Investigation Protocol](#investigation-protocol-before-attempting-fixes)
6. [Component Integration & Scene Validation](#component-integration--scene-validation-protocol)
7. [Mobile-Native Development Standards](#mobile-native-development-standards)
8. [Scene Layout Compatibility Rules](#scene-layout-compatibility-rules)
9. [Definition of "Complete"](#definition-of-complete)
10. [QA & Investigation Protocol](#qa--investigation-protocol)
11. [Godot 4 Dynamic UI Development (CRITICAL)](#godot-4-dynamic-ui-development-critical)
12. [Session Continuity Protocol](#session-continuity-protocol)
13. [Running Tests and Validators](#running-tests-and-validators)
14. [Files to Read Before Certain Actions](#files-to-read-before-certain-actions)
15. [Critical Documentation Index](#critical-documentation-index) ⭐ **NEW**
16. [Lessons Learned Quick Reference](#lessons-learned-quick-reference) ⭐ **NEW**
17. [When to Read Which Documentation](#when-to-read-which-documentation) ⭐ **NEW**

---
```

### Step 6.2: Add Critical Documentation Index (20 min)

Add new section after "Files to Read Before Certain Actions":

```markdown
---

## Critical Documentation Index

**Before working on specific topics, read these files:**

### Godot 4 Development
- **Parent-First Protocol**: `docs/lessons-learned/godot/parent-first-protocol.md` (🔴 MANDATORY)
- **UI Best Practices**: `docs/godot/ui-development-best-practices.md`
- **iOS SIGKILL Research**: `docs/ios/sigkill-research.md` (if iOS crashes)
- **Established Patterns**: `docs/lessons-learned/godot/established-patterns.md`

### Mobile Development
- **Mobile UI Spec**: `docs/mobile-ux/mobile-ui-specification.md` (authoritative)
- **iOS HIG Compliance**: See Mobile-Native Development section above
- **iOS Device Testing**: `docs/ios/device-testing-checklist.md`

### Testing
- **Testing Index**: `docs/testing/README.md` (start here)
- **GUT Best Practices**: `docs/testing/godot-testing-research.md` (comprehensive)
- **Test Template**: `docs/testing/test-file-template.md`
- **Running Tests**: `docs/testing/running-tests.md`

### Architecture
- **Data Model**: `docs/core-architecture/DATA-MODEL.md`
- **Service Patterns**: `docs/godot/services-guide.md`
- **Pattern Catalog**: `docs/core-architecture/PATTERN-CATALOG.md`

### Game Design
- **Complete Design**: `docs/GAME-DESIGN.md` (start here)
- **System Specs**: `docs/game-design/systems/` (29 system specs)

### AI Session Management
- **Session Protocol**: Read `.system/NEXT_SESSION.md` at start of EVERY session
- **Lessons Learned**: `docs/lessons-learned/00-INDEX.md` (categorized, 44 lessons)

---
```

### Step 6.3: Add Lessons Learned Quick Reference (20 min)

Add new section:

```markdown
## Lessons Learned Quick Reference

**Most frequently needed lessons by scenario:**

### When committing to git:
→ 🔴 `docs/lessons-learned/git/approval-protocol.md` (MANDATORY)
→ 🟡 `docs/lessons-learned/git/commit-guidelines.md`

### When writing tests:
→ 🟡 `docs/lessons-learned/testing/conventions.md`
→ 🟡 `docs/lessons-learned/testing/check-patterns-first.md`
→ See also: `docs/testing/README.md`

### When investigating bugs:
→ 🔴 `docs/lessons-learned/quality-gates/evidence-based-debugging.md` (MANDATORY)
→ 🔴 `docs/lessons-learned/quality-gates/systematic-debugging.md` (MANDATORY)
→ See also: QA Investigation Protocol (section above)

### When working with Godot 4 UI:
→ 🔴 `docs/lessons-learned/godot/parent-first-protocol.md` (MANDATORY)
→ See also: Godot 4 Dynamic UI section (above)
→ See also: `docs/godot/ui-development-best-practices.md`

### When making architectural decisions:
→ 🟡 `docs/lessons-learned/architecture/research-tiered-system.md`
→ 🟡 `docs/lessons-learned/godot/established-patterns.md`
→ See also: `docs/core-architecture/PATTERN-CATALOG.md`

### When planning AI sessions:
→ 🟡 `docs/lessons-learned/ai-protocols/session-management.md`
→ 🟡 `docs/lessons-learned/ai-protocols/self-assessment.md`
→ 🟡 `docs/lessons-learned/ai-protocols/realistic-planning.md`
→ See also: `.system/NEXT_SESSION.md`

### When working with database:
→ 🟡 `docs/lessons-learned/database/triggers-rls.md`
→ 🟡 `docs/lessons-learned/database/auth-patterns.md`
→ 🟡 `docs/lessons-learned/database/query-patterns.md`
→ See also: `docs/core-architecture/DATA-MODEL.md`

### When debugging iOS issues:
→ 🔴 `docs/lessons-learned/godot/parent-first-protocol.md` (MANDATORY)
→ `docs/ios/sigkill-research.md` (if app crashes)
→ `docs/ios/device-testing-checklist.md`

### Full Index:
→ `docs/lessons-learned/00-INDEX.md` (all 44 lessons categorized by priority)

---
```

### Step 6.4: Git Commit Phase 6 (5 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add .system/CLAUDE_RULES.md
git commit -m "docs: enhance CLAUDE_RULES.md with navigation aids

- Add table of contents for 761-line file
- Add Critical Documentation Index (where to find key topics)
- Add Lessons Learned Quick Reference (common scenarios → relevant lessons)
- Improves AI agent discoverability and effectiveness
- No protocol changes, only navigation improvements"
```

**✅ Checkpoint**: CLAUDE_RULES.md enhanced with navigation

---

## Phase 7: Validation & Final Commit (30 min)

### Step 7.1: Verify Documentation Structure (15 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Check new structure
ls -la

# Should see:
# - camera/
# - core-architecture/
# - competitive-analysis/
# - development-guide/
# - experiments/
# - expert-consultations/
# - future-work/
# - game-design/
# - godot/
# - ios/
# - lessons-learned/
# - migration/
# - mobile-ux/
# - proposals/
# - reference/
# - research/
# - reviews/
# - setup/
# - status/
# - testing/
# - tier-experiences/
# - GAME-DESIGN.md
# - README.md
# - (minimal other root files)

# Check lessons-learned structure
ls -la lessons-learned/
# Should see: 00-INDEX.md + category directories

# Check archive structure
ls -la migration/archive/
ls -la experiments/archive/

# Verify file counts
find . -name "*.md" -type f | wc -l  # Should still be ~200+
```

### Step 7.2: Test Link Integrity (optional, manual)

Manually spot-check a few cross-references:
- Open `lessons-learned/00-INDEX.md` and click a few links
- Open `testing/README.md` and verify links work
- Open `mobile-ux/README.md` and verify links work

### Step 7.3: Update docs/README.md (10 min)

Update the main docs README to reflect new structure:

```bash
cd /Users/alan/Developer/scrap-survivor-godot/docs

# Edit README.md to add directory guide
# (Manual edit or script)
```

### Step 7.4: Final Commit (5 min)

```bash
cd /Users/alan/Developer/scrap-survivor-godot

git add docs/README.md
git commit -m "docs: update main README with new structure"

# Create summary commit (optional)
git log --oneline docs-reorganization | head -20
```

---

## Phase 8: Merge to Main (15 min)

### Step 8.1: Review Changes

```bash
cd /Users/alan/Developer/scrap-survivor-godot

# Review all commits on branch
git log --oneline main..docs-reorganization

# Should show ~7 commits:
# 1. Master backup
# 2. Archive migration/experiments
# 3. Reorganize lessons-learned
# 4. Consolidate testing
# 5. Consolidate mobile-ux
# 6. Organize iOS/camera/research/reference/status
# 7. Enhance CLAUDE_RULES.md
# 8. Update docs README
```

### Step 8.2: Merge to Main

```bash
# Switch to main
git checkout main

# Merge (fast-forward or merge commit)
git merge docs-reorganization

# Push to remote
git push origin main

# Delete branch (optional)
git branch -d docs-reorganization
git push origin --delete docs-reorganization
```

---

## Recovery Procedures

### If Something Went Wrong During Reorganization

#### Option 1: Revert Specific Commits
```bash
# Find problematic commit
git log --oneline

# Revert it
git revert <commit-hash>
```

#### Option 2: Restore from Master Backup
```bash
# Nuclear option: restore entire docs/
rm -rf docs/
cp -r .system/archive/docs-backup-2025-11-22/ docs/
git add docs/
git commit -m "docs: restore from master backup"
```

#### Option 3: Abandon Branch
```bash
# If on docs-reorganization branch and want to start over
git checkout main
git branch -D docs-reorganization  # Force delete

# Master backup still exists in .system/archive/
```

---

## Post-Implementation Checklist

After completing all phases:

```markdown
✅ Master backup created in .system/archive/docs-backup-2025-11-22/
✅ All work done on docs-reorganization branch
✅ 51 historical files archived (migration + experiments + weekly-action-items)
✅ Lessons-learned reorganized into categories (no more numbering drift)
✅ Testing docs consolidated (12 → 7 active + 4 archived)
✅ Mobile UX docs consolidated (15+ → 5 active + 6 archived)
✅ iOS docs organized into ios/ subdirectory
✅ Camera, research, reference, status organized into subdirectories
✅ CLAUDE_RULES.md enhanced with TOC, index, quick reference
✅ All READMEs created for subdirectories
✅ Git history preserved (files moved, not deleted)
✅ Merged to main branch
✅ Master backup preserved for recovery
```

---

## Summary

**Total Time**: 6-8 hours
**Files Reorganized**: 200+
**Files Archived**: 51
**Subdirectories Created**: 10+
**Risk Level**: Low (master backup + git branch)
**Value**: High (improved discoverability, reduced clutter, better AI effectiveness)

**Key Improvements**:
1. ✅ Historical content archived (clear active vs. completed work)
2. ✅ Lessons-learned organized by category (no numbering drift)
3. ✅ Documentation consolidated (50% reduction in redundancy)
4. ✅ Logical subdirectory structure (docs/ root 75+ → ~30 files)
5. ✅ CLAUDE_RULES.md navigation aids (TOC, index, quick reference)
6. ✅ Every subdirectory has README (clear navigation)

**Next Steps**:
- Monthly audits (15 min) to maintain organization
- Quarterly reviews (1 hour) for deeper cleanup
- Follow new document checklist when creating files

---

**Implementation Plan Complete**

This plan is ready to execute. Work through phases sequentially, commit after each phase, and you'll have full recovery options at every step.

**Good luck!** 🚀
