# Claude Code Rules & Blocking Protocol

**Version**: 2.0
**Effective**: 2025-11-28
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

## Thinking Transparency at Decision Points

**At critical decision points, Claude MUST output thinking before acting:**

**Trigger**: Claude should proactively output thinking when:
- About to modify scene files
- About to commit multiple files
- Feeling time pressure
- About to skip a checklist step

**Example - Time Pressure Detection:**
```
🚨 TIME PRESSURE DETECTED 🚨
I'm thinking "need to apply this to all 3 scenes quickly to hit the 1.5h estimate."
Corrective action: Break into 3 sub-phases, one scene at a time with QA gates.
```

## Evidence-Based Engineering Checklist

Before modifying validators or bypassing any gate:

```
□ Have I read the validation code? [file:line reference]
□ Have I found 3+ correct examples? [list examples]
□ Can I cite documentation/SDK proving correctness? [citations]
□ Have I asked user if unclear? [yes/no]
```

**If ANY checkbox is unchecked → STOP and ask user**

## Service & Component Development Protocol

**MANDATORY**: Follow this workflow for ALL feature and component work.

### 1. Design Doc Requirement (BEFORE Coding)

**Rule**: Implementation cannot begin without reading and quoting the design doc.

**Pre-Implementation Checkpoint:**
```
📋 **DESIGN DOC CHECKPOINT**
Feature: [Feature Name]
Design Doc: docs/game-design/systems/[FILENAME].md

Key Design Decisions Found:
1. [Quote from doc - e.g., "Location: Hub → Shop"]
2. [Quote from doc - e.g., "Refresh: Every 4 hours"]

Hub/Combat Context:
- Is this a HUB service? [yes/no + evidence]
- Is this a COMBAT feature? [yes/no + evidence]

Does this match your understanding? (WAIT for 'yes')
```

**If no design doc exists**: STOP and ask user for requirements.

### 2. Spec & Scope Checkpoint

**Before writing code:**
```
□ Read relevant spec section (file:lines)?
□ Breaking work into smallest testable increment?
□ One scene/file at a time?
□ QA validation planned after this piece?
```

### 3. Scene Modification Protocol

**NEVER manually edit .tscn files without validation.**
- ✅ **ALWAYS create scenes via Godot editor**
- ❌ **NEVER hand-edit .tscn files** (unless minor property change)

**Before modifying .tscn files:**
```
⚠️ **SCENE MODIFICATION DETECTED**
About to modify: [filename]
Method: [Godot editor / Manual edit]
Checklist:
□ Read spec for hierarchy?
□ Using Godot editor?
□ Applying to ONE scene only?
□ Will test this scene before modifying next?
```

### 4. Component Integration Protocol

**Creating a component ≠ Using a component**

**Integration Checklist:**
```
□ Component scene created via Godot editor
□ Component preloaded in parent script (const SCENE = preload(...))
□ Parent code instantiates component (SCENE.instantiate())
□ Parent code connects component signals
□ Integration tested (instantiation succeeds)
□ Manual QA validation on device
□ Old manual UI code REMOVED (if refactor)
```

**Verification Commands:**
```bash
grep "COMPONENT_SCENE" scripts/path/to/parent.gd  # Check usage
wc -l scripts/path/to/parent.gd                   # Check line count reduction
```

## UI & Asset Standards

**Detailed standards are moved to specific documentation:**

| Topic | Reference |
|-------|-----------|
| **UI Implementation** | [`docs/ui/IMPLEMENTATION-GUIDE.md`](docs/ui/IMPLEMENTATION-GUIDE.md) |
| **Modal Patterns** | [`docs/ui/MODAL-PATTERNS.md`](docs/ui/MODAL-PATTERNS.md) |
| **Mobile-Native Rules** | [`docs/ui/IMPLEMENTATION-GUIDE.md`](docs/ui/IMPLEMENTATION-GUIDE.md) |
| **Asset Import Settings** | [`docs/ui/IMPLEMENTATION-GUIDE.md`](docs/ui/IMPLEMENTATION-GUIDE.md) |

**Key Rules Summary:**
1. **Parent-First Protocol**: Always `add_child()` BEFORE configuring dynamic controls.
2. **Modal Sizing**: Set `size` FIRST, then calculate position/offsets.
3. **Destructive UI**: Must be prominent (≥300px height) with large buttons.
4. **iOS Compliance**: Follow Apple HIG, use `ModalFactory`.

## Commit Message Format

**Validation**: `.git/hooks/commit-msg`
**Format**: `<type>: <description>`

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`, `revert`

**Examples**:
- ✅ `feat: add enemy spawning`
- ❌ `debug: add logging`

## Investigation Protocol

### When validation fails:
**After 2 failed attempts → STOP and investigate:**

1. **Read Config**: `.git/hooks/commit-msg`, `.gdlintrc`, `.editorconfig`
2. **Find Examples**: `git log`, search codebase
3. **Match Pattern**: Copy working examples exactly
4. **Ask User**: If still unclear

### When QA Fails:
**Tier 1**: Quick fix (1 attempt)
**Tier 2**: Stop and Investigate (Read logs, review code)
**Tier 3**: Spawn Expert Agent (Systematic analysis)

**NEVER** do trial-and-error for 3+ QA passes.

## Testing & Validators

**Run automated tests:**
```bash
python3 .system/validators/godot_test_runner.py
```

**Key Validators (.system/validators/):**
- `scene_structure_validator.py` - Validates .tscn parent specifications (BLOCKING)
- `scene_instantiation_validator.py` - Tests scenes can instantiate (BLOCKING)
- `component_usage_validator.py` - Verifies components are used (BLOCKING)
- `check-imports.sh` - Validates asset import settings (BLOCKING)

## Definition of "Complete"

**REQUIRED to mark work "COMPLETE":**
- ✅ Code written and committed
- ✅ Automated tests pass
- ✅ Validators pass
- ✅ **Manual QA pass on target device** (iPhone for mobile work)
- ✅ All acceptance criteria met
- ✅ No known bugs
- ✅ Integration tested

**Statuses:**
- ✅ **COMPLETE** (QA passed on device)
- 🔨 **CODE COMPLETE** (Coded, not QA tested)
- 🧪 **IN QA** (Testing in progress)
- 🐛 **BROKEN** (Critical bugs)
- ⏭️ **PENDING** (Not started)

## Session & Project Management

### Session Continuity
- **Start**: Read `.system/NEXT_SESSION.md` if it exists.
- **End**: Update `.system/NEXT_SESSION.md` with progress, next steps, and git status.
- **Archive**: Move to `.system/archive/` when milestones are reached.

### Week Plans
- **Immutable**: Plan content doesn't change after execution starts.
- **Living**: Status tracker and `NEXT_SESSION.md` track reality.

### Phase Breakdown
- Break large phases (>1.5h) into sub-phases (0.25-0.5h).
- Each sub-phase must have a QA gate.

## Art Asset Review Protocol

### Overview
Art assets are dropped in `art-docs/` and must be processed before use in-game.
See `docs/ART-PIPELINE.md` for full documentation.

### Reviewing New Art Assets

**NEVER read raw art files directly** (they're too large and will crash the session).

**Process:**
1. **Check for preview file**: Look for `art-docs/{name}-preview.jpg`
2. **If no preview exists**, ask user to run:
   ```bash
   ./scripts/tools/optimize-art-asset.sh art-docs/FILENAME.png
   ```
3. **Copy preview to Claude's computer** for viewing:
   ```
   Filesystem:copy_file_user_to_claude → /Users/alan/Developer/scrap-survivor-godot/art-docs/{name}-preview.jpg
   ```
4. **View with the `view` tool** on Claude's computer:
   ```
   view → /mnt/user-data/uploads/{name}-preview.jpg
   ```

### Expert Panel Review Criteria

When reviewing art assets, evaluate as the expert panel:

| Role | Focus |
|------|-------|
| **Sr UI/UX Designer** | Readability, contrast, UI overlay suitability |
| **Sr Mobile Game Designer** | Aesthetic fit, player experience, focal points |
| **Sr SQA** | Accessibility, edge cases, device compatibility |
| **Sr Godot Developer** | Technical fit, performance, import settings |

**For Backgrounds specifically:**
- Dark center (~70%) for UI overlay?
- Detail pushed to edges?
- No competing focal points?
- Muted color palette?
- Matches existing art style?

### Asset Locations

| Type | Source | Game-Ready |
|------|--------|------------|
| Backgrounds | `art-docs/*.png` | `assets/ui/backgrounds/*.jpg` (2048x2048) |
| Icons | `art-docs/*_icon.png` | `assets/ui/icons/*.png` (128x128) |
| Sprites | `art-docs/*_sprite.png` | `assets/sprites/*.png` |
| Previews | N/A | `art-docs/*-preview.jpg` (for Claude review) |

## QA Screenshot Review Protocol

### Overview
QA screenshots are dropped in `qa/` and processed for Claude review.

### Reviewing QA Screenshots

**Process:**
1. **Check for preview file**: Look for `qa/previews/{name}-preview.jpg`
2. **If no preview exists**, ask user to run:
   ```bash
   ./scripts/tools/process-qa-screenshot.sh --batch
   ```
3. **Copy preview to Claude's computer** for viewing:
   ```
   Filesystem:copy_file_user_to_claude → /Users/alan/Developer/scrap-survivor-godot/qa/previews/{name}-preview.jpg
   ```
4. **View with the `view` tool** on Claude's computer

### Directory Structure
```
qa/
├── *.png              # Drop screenshots here
├── previews/          # Claude-safe previews
└── archive/           # Timestamped originals
```

## Safety Protocols

### File Size Safety
**ALWAYS check file size with `get_file_info` before reading.**
- **> 5MB**: DO NOT READ (will crash session).
- **Images**: Never read raw content directly - use the Art Asset Review Protocol above.

### Time Pressure Detection
If thinking "need to do this quickly" or "just do all X at once":
1. **STOP**
2. **Output**: "🚨 TIME PRESSURE DETECTED"
3. **Action**: Slow down, break into smaller steps, follow process.

## Documentation Index

| Category | Document |
|----------|----------|
| **Game Design** | `docs/game-design/` |
| **Testing** | `docs/TESTING-INDEX.md` |
| **UI Standards** | `docs/ui/IMPLEMENTATION-GUIDE.md` |
| **Modal Patterns** | `docs/ui/MODAL-PATTERNS.md` |
| **Art Pipeline** | `docs/ART-PIPELINE.md` |
| **Godot Reference** | `docs/godot-reference.md` |
| **Lessons Learned** | `docs/lessons-learned/` |
