# Claude Code Rules & Blocking Protocol

**Version**: 1.0
**Effective**: 2025-01-10
**Enforcement**: MANDATORY - Violations stop work immediately

## BLOCKING PROTOCOL (Active)

### High-Risk Actions Requiring User Approval

Before executing these actions, I MUST:
1. Announce: "**APPROVAL REQUIRED**: [action description]"
2. Show completed evidence checklist
3. Show exact command to be executed
4. **WAIT for user "yes" before proceeding**

**High-Risk Actions:**
- ✓ Any `git commit` (even if validation passes)
- ✓ Any `git push`
- ✓ Modifying validator files in `.system/validators/`
- ✓ Changing quality gate expectations or test assertions
- ✓ Using flags: `--no-verify`, `--force`, `--amend`, `--skip-ci`
- ✓ Modifying pre-commit hooks or validation configuration

## NEVER Rules (Zero Tolerance)

**NEVER do these under any circumstances:**

1. ❌ **NEVER use `--no-verify`** on git commits
2. ❌ **NEVER bypass quality gates** (validators, linters, formatters, tests)
3. ❌ **NEVER modify validators without evidence** (docs, line numbers, examples)
4. ❌ **NEVER assume validation is wrong** - investigate first, prove with evidence
5. ❌ **NEVER take shortcuts when frustrated** - stop and investigate systematically

## Evidence-Based Engineering Checklist

Before modifying validators or bypassing any gate:

```
□ Have I read the validation code? [file:line reference]
□ Have I found 3+ correct examples? [list examples]
□ Can I cite documentation/SDK proving correctness? [citations]
□ Have I asked user if unclear? [yes/no]
```

**If ANY checkbox is unchecked → STOP and ask user**

## Commit Message Format

**Validation**: `.git/hooks/commit-msg:7`

**Valid format**: `<type>: <description 1-100 chars>`

**Valid types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style (formatting, no logic change)
- `refactor` - Code restructuring (no behavior change)
- `perf` - Performance improvement
- `test` - Test additions/changes
- `chore` - Build, tooling, dependencies
- `build` - Build system changes
- `ci` - CI/CD changes
- `revert` - Revert previous commit

**Optional scope**: `<type>(scope): <description>`

**Examples:**
- ✅ `feat: add enemy spawning`
- ✅ `fix: correct drop_system zero-amount bug`
- ✅ `docs: update migration timeline`
- ❌ `debug: add logging` (invalid type)
- ❌ `feat:add enemy` (missing space)
- ❌ `add enemy spawning` (missing type)

**Multi-line commits allowed after first line**

## Investigation Protocol (Before Attempting Fixes)

### When validation fails:

**After 2 failed attempts → STOP and investigate:**

1. Read validation configuration:
   - Commits: `.git/hooks/commit-msg`
   - Linting: `.gdlintrc`
   - Formatting: `.editorconfig`
   - Tests: Look at failing test file
   - Validators: Read the `.system/validators/[name].py` file

2. Find correct examples:
   - Commits: `git log --oneline -10`
   - Code: Search codebase for working examples
   - Validators: Read referenced documentation

3. Match pattern exactly before retrying

4. If still unclear → **ASK USER**

## Component Integration & Scene Validation Protocol

**CRITICAL**: Scene files and component integration require special validation.

### Scene File Creation Rules

**NEVER manually edit .tscn files without validation.**

1. ✅ **ALWAYS create scenes via Godot editor** (File → New Scene)
2. ❌ **NEVER hand-edit .tscn files** without opening in editor after
3. ✅ **IF manual edit required** → Open in Godot editor immediately to validate

### Scene File Validation Checklist

Before committing any .tscn file:
```
□ Scene opens in Godot editor without errors
□ All child nodes have parent="..." specification (check .tscn file)
□ Scene instantiates successfully (automated validator checks this)
□ Scene hierarchy displays correctly in editor
□ No orphan nodes (all children specify parent)
```

**If scene won't load**: Check that all child nodes specify `parent="..."` attribute

**Example - Correct scene structure**:
```
[node name="Root" type="PanelContainer"]

[node name="Child" type="HBoxContainer" parent="."]

[node name="GrandChild" type="Label" parent="Child"]
```

**Example - WRONG (missing parent)**:
```
[node name="Root" type="PanelContainer"]

[node name="Child" type="HBoxContainer"]  # ❌ Missing parent="."
```

### Component Integration Protocol

**Creating a component ≠ Using a component**

When refactoring to use reusable components:

**Integration Checklist**:
```
□ Component scene created via Godot editor
□ Component script implemented
□ Component preloaded in parent script (const SCENE = preload(...))
□ Parent code instantiates component (SCENE.instantiate())
□ Parent code calls component.setup() or initialization
□ Parent code connects component signals
□ Integration tested (instantiation succeeds, no null errors)
□ Manual QA validation on device
□ Old manual UI code REMOVED (if refactor)
```

### Before Marking Work "COMPLETE"

- ❌ **NOT ENOUGH**: Component files exist
- ❌ **NOT ENOUGH**: Tests pass
- ✅ **REQUIRED**: Component actually used in parent code
- ✅ **REQUIRED**: Integration manually validated on device
- ✅ **REQUIRED**: Old code removed (if claiming refactor)

### Red Flags

- 🚩 Component scene exists but no `preload()` references in codebase
- 🚩 Parent still has old manual UI generation code
- 🚩 "80 lines → 14 lines" refactor claim but file still has 80 lines
- 🚩 Plan says "refactored to use Component" but Grep shows no references

### Verification Commands

**Before claiming "refactored to use component":**

```bash
# Check component is actually used
grep "COMPONENT_SCENE" scripts/path/to/parent.gd
# Should show: preload() and instantiate() calls

# Check old code is removed
wc -l scripts/path/to/parent.gd
# Line count should match "after" claim, not "before"

# Check function was actually refactored
grep -A 20 "func _create_item" scripts/path/to/parent.gd
# Function should be ≤20 lines if using component
```

**If old manual UI code still present** → Refactor NOT complete

### Scene Instantiation Testing

**When creating PackedScene components**, verify instantiation:

```gdscript
# Test that scene loads
const SCENE = preload("res://path/to/component.tscn")

func test_instantiation():
    var instance = SCENE.instantiate()
    assert(instance != null, "Scene instantiation failed - check parent nodes")
    assert(instance.has_method("setup"), "Component missing setup method")
```

**If instantiate() returns null** → Scene file corrupted, check parent specifications

### Automated Validators

The following validators enforce these rules:

- **scene_structure_validator.py** - Validates .tscn parent specifications (BLOCKING)
- **scene_instantiation_validator.py** - Tests scenes can instantiate (BLOCKING)
- **component_usage_validator.py** - Verifies components are used (BLOCKING if preloaded but unused)
- **refactor_verification_validator.py** - Validates refactor claims (BLOCKING on refactor commits)

**These run automatically in pre-commit hooks.**

---

## Files to Read Before Certain Actions

| Action | Required Reading |
|--------|-----------------|
| Git commit | `.git/hooks/commit-msg` |
| Modifying validator | The validator file + docs it references |
| Fixing test failure | The test file + implementation file |
| Changing quality gate | Configuration files + ask user |
| Creating .tscn scene | ALWAYS use Godot editor (not manual) |
| Refactoring to components | Component Integration Protocol above |

## Running Tests and Validators

**IMPORTANT**: NEVER try to find `godot` command in PATH. Always use the validator scripts.

### Test Runner

**Run automated tests:**
```bash
python3 .system/validators/godot_test_runner.py
```

This script:
- Handles Godot executable location automatically
- Runs all 520 GUT tests in headless mode
- Creates class cache for custom classes
- Outputs JUnit XML results to `test_results.xml`

### Available Validators

All validators are in `.system/validators/` directory:

**Python Validators:**
- `godot_test_runner.py` - Run automated tests (520 tests)
- `test_method_validator.py` - Validate test method calls against service APIs
- `test_naming_validator.py` - Check test naming conventions
- `test_patterns_validator.py` - Check for test quality issues (non-blocking)
- `test_quality_validator.py` - Check assertion quality (non-blocking)
- `integration_test_checker.py` - Verify integration tests exist
- `godot_antipatterns_validator.py` - Check for Godot anti-patterns (non-blocking)
- `godot_performance_validator.py` - Check for performance issues (non-blocking)
- `godot_config_validator.py` - Validate Godot project configuration
- `scene_node_path_validator.py` - Validate scene node paths
- `data_model_consistency_validator.py` - Check data model usage (non-blocking)
- `service_architecture_validator.py` - Validate service architecture
- Other validators: `native_class_checker.py`, `resource_validator.py`, etc.

**Shell Script Validators:**
- `check-imports.sh` - Validate asset import settings (non-blocking)
- `check-patterns.sh` - Validate GDScript patterns (non-blocking)
- `check-audio-assets.sh` - Check audio asset configuration

**Non-Blocking vs Blocking:**
- **Blocking**: Tests, test method validator, config validator - MUST pass for commit
- **Non-blocking**: Test patterns, antipatterns, performance - warnings only, good to fix but won't block commit

## Mobile-Native Development Standards

**Effective**: 2025-11-22 (Week 16 learnings)

### Definition of "Mobile-Native"

**Mobile-native DOES NOT mean:**
- ❌ Gaming UI patterns (two-tap confirmations, button state machines)
- ❌ Hybrid workarounds (desktop + mobile mixed)
- ❌ "Works on mobile" (just responsive to screen size)

**Mobile-native MEANS:**
- ✅ **iOS HIG compliance** - Follow Apple Human Interface Guidelines exactly
- ✅ **Platform patterns** - Use ModalFactory.show_confirmation(), not button states
- ✅ **Native controls** - Use ALERT, SHEET, FULLSCREEN modals
- ✅ **Cite guidelines** - Reference specific HIG sections when claiming compliance

### Before Claiming "iOS HIG Compliant"

**Evidence Checklist:**
```
□ Can cite specific iOS HIG guideline(s)? [URL or section]
□ Uses platform-native patterns? (modals, not button state machines)
□ Tested on actual iOS device? (not just simulator/desktop)
□ Uses ModalFactory or approved mobile components?
```

**If ANY checkbox unchecked → NOT iOS HIG compliant**

### Mobile Pattern Examples

**✅ CORRECT - iOS HIG Pattern:**
```gdscript
# Destructive confirmation using native modal
ModalFactory.show_destructive_confirmation(
    self,
    "Delete Character?",
    "This cannot be undone.",
    func(): _delete_character()
)
```

**❌ INCORRECT - Gaming UI Hack:**
```gdscript
# Two-tap button state machine (NOT iOS HIG)
if delete_state == 0:
    button.text = "Tap Again to Confirm"
    delete_state = 1
elif delete_state == 1:
    _delete_character()
```

### Mobile-First Validation

Before marking mobile work "COMPLETE":
```
□ Follows iOS HIG (not gaming UI patterns)
□ Uses approved mobile components (MobileModal, ModalFactory)
□ Tested on physical iOS device
□ No desktop patterns mixed in
□ Can defend every UI choice with HIG citation
```

---

## Scene Layout Compatibility Rules

**Effective**: 2025-11-22 (After iOS layout mode crash)

### The Problem

iOS strictly validates layout constraints. Incompatible layout modes crash with SIGKILL (no error message).

**Common Conflict:**
- Node with `anchors_preset` (standalone positioning)
- Added to `VBoxContainer` or `HBoxContainer` (container layout)
- **Result**: iOS detects unsolvable constraint → SIGKILL

### Before Modifying .tscn Files

**Layout Compatibility Checklist:**
```
□ Is this node going into a container (VBox/HBox)?
□ Does it have anchors_preset set?
□ Does it have layout_mode = 2 and size_flags?
□ Will it work in BOTH contexts (standalone AND container)?
```

### Container-Compatible Node Requirements

**If adding Control node to VBoxContainer/HBoxContainer:**

**MUST have:**
- `layout_mode = 2` (container layout mode)
- `size_flags_horizontal` and/or `size_flags_vertical`
- Optional: `custom_minimum_size`

**MUST NOT have:**
- `anchors_preset` (incompatible with containers)
- `anchor_left`, `anchor_right`, `anchor_top`, `anchor_bottom`
- `grow_horizontal`, `grow_vertical` (unless using anchors)

### Validation Before Commit

**After modifying any .tscn file:**

1. **Read the scene file** - Check layout_mode and anchors
2. **Test instantiation** - Run scene_instantiation_validator.py
3. **Test on iOS device** - Desktop may not show the issue
4. **Check parent context** - Where is this scene being used?

### Red Flags

- 🚩 Scene has `anchors_preset = 8` (CENTER) but is used in VBoxContainer
- 🚩 Scene works on desktop but crashes on iOS (layout conflict)
- 🚩 Modified .tscn without testing in actual usage context
- 🚩 "It instantiates fine" but haven't tested where it's actually used

---

## Definition of "Complete"

**Effective**: 2025-11-22 (After premature completion claims)

### What "Complete" Actually Means

**Code Complete ≠ Work Complete**

**NOT ENOUGH to mark work "COMPLETE":**
- ❌ Code written and committed
- ❌ Automated tests pass (647/671 passing)
- ❌ Validators pass
- ❌ "It works on desktop"
- ❌ Documentation written

**REQUIRED to mark work "COMPLETE":**
- ✅ Code written and committed
- ✅ Automated tests pass
- ✅ Validators pass
- ✅ **Manual QA pass on target device** (iPhone for mobile work)
- ✅ **All acceptance criteria met** (not just coded)
- ✅ **No known bugs** in the feature
- ✅ **Integration tested** (not just unit tested)

### Phase Completion Checklist

Before marking Phase X "COMPLETE":
```
□ All objectives coded and committed?
□ All automated tests passing?
□ Manual QA pass on device (not simulator)?
□ Success criteria from plan ALL met?
□ No known bugs or workarounds?
□ User approved the work?
□ Documentation updated?
```

**If ANY checkbox unchecked → Phase NOT complete**

### Honest Status Reporting

**Use these statuses accurately:**
- ✅ **COMPLETE** - All criteria met, QA passed on device, zero known issues
- 🔨 **CODE COMPLETE** - Coded but not QA tested yet
- 🧪 **IN QA** - Coded, in testing, may have bugs
- 🐛 **BROKEN** - Coded but has critical bugs
- ⏭️ **PENDING** - Not started yet

**NEVER report "COMPLETE" before device QA**

---

## QA & Investigation Protocol

**Effective**: 2025-11-22 (After 5 QA passes doing trial-and-error)

### When QA Fails: Investigation Tiers

**Tier 1: Quick Fix (1 attempt)**
- Obvious typo, syntax error, missing file
- Fix immediately, retest

**Tier 2: Stop and Investigate (After 1 failed QA pass)**
- Read diagnostic logs
- Check recent changes
- Review code for obvious issues
- **If unclear → Tier 3**

**Tier 3: Systematic Investigation (Spawn Expert Agent)**
- Use Task tool with subagent_type="general-purpose"
- Evidence-based investigation
- Root cause analysis
- Technical debt identification

### NEVER Do This

❌ **Trial-and-error for 3+ QA passes**
- Wastes user's time (rebuild, redeploy, retest)
- Misses root cause
- Creates technical debt

✅ **Instead: Spawn investigation agent after Pass 1 failure**
- Systematic analysis
- Evidence-based fixes
- One proper fix vs. five guesses

### Investigation Agent Trigger

**Spawn investigation agent if:**
- QA pass 1 fails with unclear root cause
- Error message doesn't make sense
- "It should work but doesn't"
- No error logs or crash with no message
- iOS-specific issue (works on desktop, fails on device)

**Agent Prompt Template:**
```
You are investigating [ISSUE].

Evidence:
- QA log: [path]
- Error: [description or "no error, just killed"]
- Platform: iOS/Desktop
- Recent changes: [commits]

Tasks:
1. Read relevant code files
2. Identify root cause with file:line evidence
3. Explain why it fails (technical reason)
4. Provide correct fix (not workaround)
5. Identify why this wasn't caught earlier

Return: Root cause analysis + correct fix + prevention recommendations
```

### Investigation > Guessing

**After 1 QA failure:**
- ✅ Read logs systematically
- ✅ Spawn expert investigation agent
- ✅ Find root cause with evidence
- ✅ Apply correct fix once

**Don't do:**
- ❌ "Let me try adding this log..."
- ❌ "Maybe it's this, let me change it..."
- ❌ "Let's rebuild and see if it works now..."
- ❌ 5 QA passes doing trial-and-error

---

## Enforcement Mechanism

**User's role**: Call me out when I violate these rules

**My commitment**:
1. Follow blocking protocol for high-risk actions
2. Show evidence checklist when investigating
3. Stop after 2 failed attempts and investigate
4. Never bypass gates or use `--no-verify`

**If I violate**: User stops me, I acknowledge, we review what went wrong

## Evidence-Based Engineering Examples

### ✅ CORRECT: Modifying test validator
```
"Test method validator blocking .new() calls. Before modifying:
□ Read .system/validators/test_method_validator.py ✓
□ Found docs/godot-reference.md:365 showing Sprite2D.new() ✓
□ Found docs/godot-testing-research.md with 30+ .new() examples ✓
□ Verified WaveManager is NOT autoload in project.godot ✓
□ Can cite evidence: Regular classes use .new(), autoloads don't ✓

Evidence complete. Modifying validator with documented reasoning."
```

### ❌ INCORRECT: Bypassing gates
```
"Commit failed 3 times with format errors.
Using --no-verify to bypass and move forward."
← VIOLATION: Should have read .git/hooks/commit-msg instead
```

---

## Session Continuity Protocol

**Purpose**: Maintain context across sessions for multi-phase projects

### At Session Start (AUTOMATIC)

**I MUST do this at the beginning of EVERY session:**

1. **Check for `.system/NEXT_SESSION.md`**
   - If file exists → Read it IMMEDIATELY (before user's first request)
   - If file doesn't exist → Proceed normally

2. **Acknowledge current state** (if file exists):
   - "I see we're currently working on [PHASE] - [STATUS]"
   - "Phase [X] is complete, Phase [Y] is in progress"
   - Show awareness of what was accomplished in previous session

3. **Use Quick Start Prompt** (if user says "continue"):
   - Use the prompt from `.system/NEXT_SESSION.md`
   - Load all referenced files
   - Present plan for current phase

### At Session End (AUTOMATIC)

**When wrapping up a session, I MUST:**

1. **Update `.system/NEXT_SESSION.md`** with:
   - Current date/time
   - Current phase and status (complete/in progress)
   - What we accomplished this session
   - Next phase objectives
   - Ready-to-paste Quick Start Prompt for next session
   - Any important decisions made
   - Current test status
   - Current git status (branch, last commit)

2. **Ask for approval to commit** (per Blocking Protocol):
   - "**APPROVAL REQUIRED**: Commit session handoff update"
   - Show what changed in `.system/NEXT_SESSION.md`
   - Wait for user "yes"

3. **Commit the update**:
   ```
   git add .system/NEXT_SESSION.md
   git commit -m "docs: update session handoff for [PHASE]"
   ```

### Session Continuity Triggers

**User says any of these → I read NEXT_SESSION.md automatically:**
- "continue"
- "continue from last session"
- "where did we leave off?"
- "what's next?"
- "resume"

**User starts with a new task → I don't use NEXT_SESSION.md:**
- User provides specific instructions unrelated to NEXT_SESSION.md content
- User explicitly says "ignore NEXT_SESSION.md"

### Staleness Check

**If `.system/NEXT_SESSION.md` is more than 7 days old:**
- Alert user: "⚠️ NEXT_SESSION.md is X days old - is this still current?"
- Wait for confirmation before using it

### Branch Mismatch Detection

**If current git branch ≠ branch in NEXT_SESSION.md:**
- Alert user: "⚠️ Branch mismatch: Currently on [BRANCH], NEXT_SESSION.md says [OTHER_BRANCH]"
- Ask which is correct

---

**Last Updated**: 2025-11-22 by Claude Code (Mobile-Native Standards, Scene Layout Rules, Definition of Complete, QA Investigation Protocol added)
**Next Review**: When violations occur or user requests update
