# Phase Breakdown Example: Safe Area Implementation

**Purpose**: Demonstrate the difference between monolithic phases (WRONG) and incremental sub-phases with QA gates (RIGHT).

**Context**: Week 16 Phase 6 originally planned as a single 1.5h phase to add ScreenContainer safe area handling to 3 scenes. This approach led to rushed implementation, bulk commits, and QA failures.

---

## ❌ WRONG: Monolithic Phase (What We Did Initially)

```markdown
## Phase 6: Safe Area Implementation (1.5h)

**Objectives:**
- Create ScreenContainer component for safe area handling
- Apply to character_creation.tscn
- Apply to character_roster.tscn
- Apply to scrapyard.tscn
- Test on device

**Tasks:**
1. Read spec for ScreenContainer pattern
2. Create component scene
3. Modify 3 scene files
4. Commit all changes
5. Deploy and test

**Expected Outcome**: All 3 scenes properly handle safe areas
```

### What Actually Happened

**Execution Pattern:**
1. ⚠️ Skipped reading spec (assumed understanding)
2. ⚠️ Manual .tscn editing (faster than Godot editor)
3. ⚠️ Modified all 3 scenes at once (bulk work)
4. ⚠️ Committed all 3 scenes in single commit
5. ⚠️ Deployed to device for testing

**Results:**
- 🐛 2 out of 3 scenes had architectural violations
- 🐛 Hierarchy incorrect (missing VBoxContainer wrapper)
- 🐛 Layout mode conflicts (Mode 1 vs Mode 2)
- ⏱️ 5+ QA passes required to fix
- ⏱️ 3x estimated time spent (4.5h instead of 1.5h)

### Why It Failed

**Time Pressure:**
- "Need to finish in 1.5h" → cut corners
- "Do all 3 scenes quickly" → bulk commit
- "Manual edit is faster" → violated protocol

**No Incremental Validation:**
- All 3 scenes broken → can't isolate which change caused issue
- Must fix all 3 → can't proceed with partial success
- Bulk rollback required → lose all work

**No QA Gates:**
- No checkpoint after scene 1
- Errors propagate to scenes 2 and 3
- User discovers all failures at once

---

## ✅ RIGHT: Incremental Sub-Phases with QA Gates

```markdown
## Phase 6: Safe Area Implementation

**Total Estimated Time**: 1.5h (broken into 4 sub-phases)

### Phase 6.0: Pre-Implementation Spec Checkpoint (0.25h)

**Tasks:**
1. Read week16-implementation-plan.md lines 2934-2975
2. Quote key requirements:
   - "ScreenContainer → VBoxContainer → child controls"
   - "ScreenContainer handles safe area margins"
   - "Child uses size_flags_vertical = EXPAND_FILL"
3. Identify pattern from spec diagram
4. WAIT for user "yes" on understanding

**QA Gate**: User confirms spec understanding is correct

**GO/NO-GO**: NO-GO if spec understanding incorrect → re-read and clarify

---

### Phase 6.1: Create ScreenContainer Component (0.25h)

**Tasks:**
1. Use Godot editor to create scenes/ui/components/screen_container.tscn
2. Add VBoxContainer child
3. Create scripts/ui/components/screen_container.gd
4. Implement safe area margin logic
5. Write unit tests for component in isolation
6. Run automated tests
7. Commit component only

**Commit Message**:
```
feat(ui): add ScreenContainer component for safe area handling

- Created screen_container.tscn with VBoxContainer child
- Implemented safe area margin calculation
- Added unit tests for margin logic
- Component ready for integration

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**QA Gate**:
- ✅ Component scene instantiates correctly
- ✅ Unit tests pass
- ✅ Automated test suite passes (520/520)

**GO/NO-GO**: NO-GO if component tests fail → fix component before proceeding

---

### Phase 6.2: Apply to character_creation.tscn (0.25h)

**Tasks:**
1. Read current character_creation.tscn hierarchy
2. Use Godot editor (NOT manual edit) to:
   - Add ScreenContainer as root
   - Add VBoxContainer child
   - Move existing controls into VBoxContainer
   - Set layout_mode = 2 on all children
3. Open scene in Godot editor to validate
4. Run scene instantiation validator
5. Commit this scene only

**Commit Message**:
```
feat(ui): add safe area support to character creation

- Wrapped character_creation.tscn with ScreenContainer
- Added VBoxContainer layout wrapper
- Set proper layout modes for container children
- Scene validated in Godot editor

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**QA Gate**:
- ✅ Scene opens in Godot editor without errors
- ✅ Scene instantiation validator passes
- ✅ Deploy to iOS device → test character creation screen
- ✅ No layout issues, safe area margins correct

**GO/NO-GO**:
- GO if character creation works correctly → proceed to Phase 6.3
- NO-GO if issues found → fix this scene before touching roster

---

### Phase 6.3: Apply to character_roster.tscn (0.25h)

**Tasks:**
1. Apply SAME PATTERN as 6.2 (proven to work)
2. Use Godot editor to add ScreenContainer wrapper
3. Add VBoxContainer child
4. Move existing controls into VBoxContainer
5. Set layout_mode = 2 on children
6. Validate in Godot editor
7. Run scene instantiation validator
8. Commit this scene only

**Commit Message**:
```
feat(ui): add safe area support to character roster

- Applied ScreenContainer pattern from character_creation
- Wrapped roster with ScreenContainer + VBoxContainer
- Set proper layout modes for container children
- Scene validated in Godot editor

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**QA Gate**:
- ✅ Scene opens in Godot editor without errors
- ✅ Scene instantiation validator passes
- ✅ Deploy to iOS device → test roster screen
- ✅ No layout issues, safe area margins correct

**GO/NO-GO**:
- GO if roster works correctly → proceed to Phase 6.4
- NO-GO if issues found → fix this scene before touching scrapyard

---

### Phase 6.4: Apply to scrapyard.tscn (0.25h)

**Tasks:**
1. Apply SAME PATTERN as 6.2 and 6.3 (proven to work)
2. Use Godot editor to add ScreenContainer wrapper
3. Add VBoxContainer child
4. Move existing controls into VBoxContainer
5. Set layout_mode = 2 on children
6. Validate in Godot editor
7. Run scene instantiation validator
8. Commit this scene only

**Commit Message**:
```
feat(ui): add safe area support to scrapyard scene

- Applied ScreenContainer pattern from previous scenes
- Wrapped scrapyard with ScreenContainer + VBoxContainer
- Set proper layout modes for container children
- Scene validated in Godot editor

Phase 6 Complete: All 3 scenes have safe area support

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**QA Gate**:
- ✅ Scene opens in Godot editor without errors
- ✅ Scene instantiation validator passes
- ✅ Deploy to iOS device → test scrapyard screen
- ✅ No layout issues, safe area margins correct

**GO/NO-GO**:
- GO if scrapyard works correctly → Phase 6 COMPLETE
- NO-GO if issues found → fix before marking complete

---

### Phase 6 Summary

**Total Time**: 1.5h (4 × 0.25h sub-phases + 0.25h spec checkpoint)

**Commits**: 4 incremental commits (component, scene 1, scene 2, scene 3)

**QA Passes**: 4 incremental QA gates (1 per sub-phase)

**Success Criteria**:
- ✅ All sub-phases completed
- ✅ All QA gates passed (GO)
- ✅ No architectural violations
- ✅ Proper tool usage (Godot editor, not manual)
- ✅ Spec followed exactly
```

---

## Key Differences: WRONG vs RIGHT

| Aspect | WRONG (Monolithic) | RIGHT (Incremental) |
|--------|-------------------|---------------------|
| **Phase Size** | 1 phase, 1.5h | 4 sub-phases, 0.25h each |
| **Spec Reading** | Skipped (assumed) | Mandatory checkpoint |
| **Tool Usage** | Manual .tscn edit | Godot editor required |
| **Scope** | All 3 scenes at once | One scene at a time |
| **Commits** | 1 bulk commit | 4 incremental commits |
| **QA Gates** | 1 final test | 4 incremental tests |
| **Failure Isolation** | All 3 scenes broken | Isolated to 1 scene |
| **Time Pressure** | "Must finish in 1.5h" | "Each piece is 15 min" |
| **User Experience** | Wait for all 3 + fixes | See progress incrementally |
| **Actual Time** | 4.5h (3x estimate) | 1.5h (meets estimate) |
| **QA Failure Rate** | 99% (5+ passes) | 0% (one-shot success) |

---

## Lessons Learned

### Why Incremental Works

**Psychological:**
- 0.25h feels achievable → no time pressure → no rushing
- One scene = small scope → methodical approach
- QA gate after each piece → built-in quality checkpoint

**Technical:**
- Failures isolated to single scene → easy to debug
- Pattern proven in scene 1 → confidently apply to scenes 2-3
- Incremental commits → can bisect issues if needed

**Process:**
- Spec checkpoint prevents "I think I know" mistakes
- Godot editor requirement prevents architectural violations
- QA gates prevent "let me do all 3 and test later" bulk work

### Why Monolithic Fails

**Time Pressure:**
- 1.5h for 3 scenes → "need to hurry" → cut corners
- Bulk work feels faster → actually creates 3x more rework

**No Safety Net:**
- No incremental validation → errors propagate
- All 3 scenes broken → can't isolate root cause
- Must fix everything before making progress

**Encourages Violations:**
- "Manual edit is faster" → architectural violations
- "Skip spec, I know the pattern" → misunderstand requirements
- "Do all at once" → bulk commits without QA

---

## Planning Template

Use this template for all future phases:

```markdown
## Phase [N]: [Feature Name]

**Total Estimated Time**: [X]h

**Breakdown:**

### Phase [N].0: Pre-Implementation Spec Checkpoint ([0.25]h)
- Read spec section [file:lines]
- Quote 2-3 key requirements
- Identify pattern/example
- WAIT for user "yes"
- **QA Gate**: User confirms understanding

### Phase [N].1: [First Increment] ([0.25-0.5]h)
- [Specific tasks]
- Commit: [what to commit]
- **QA Gate**: [specific validation]
- **GO/NO-GO**: Fix before proceeding if NO-GO

### Phase [N].2: [Second Increment] ([0.25-0.5]h)
- Apply same pattern as [N].1
- Commit: [what to commit]
- **QA Gate**: [specific validation]
- **GO/NO-GO**: Fix before proceeding if NO-GO

[...continue for each increment...]

**Each sub-phase includes:**
- Spec reading checkpoint (Phase N.0)
- Implementation (using correct tools)
- Local testing (validators, automated tests)
- Incremental commit (one piece at a time)
- Device QA gate (GO/NO-GO decision)
```

---

**Created**: 2025-11-23
**Purpose**: Reference example for process improvement initiative
**Source**: Week 16 Phase 6 post-mortem analysis
**Application**: Use this pattern for all future week plans starting Week 17+
