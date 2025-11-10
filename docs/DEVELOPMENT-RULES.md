# Development Rules - CRITICAL

**Last Updated**: 2025-01-10
**Purpose**: Mandatory rules for all contributors (human and AI)

---

## 🚨 Git Commit Rules (CRITICAL)

### ❌ NEVER USE THESE FLAGS:

```bash
# FORBIDDEN - Do not use under any circumstances
git commit --no-verify
git commit --no-gpg-sign
git push --no-verify
git commit --no-post-rewrite

# Any flag that bypasses hooks is FORBIDDEN
```

### ✅ ALWAYS:

1. **Let pre-commit hooks run completely**
   - Hooks are mandatory protective layers
   - They catch bugs, enforce quality, run validators
   - They are part of the core development workflow

2. **Fix all linting/formatting errors properly**
   - Use `gdformat` to fix formatting issues
   - Use `gdlint` to check for linting errors
   - Read error messages carefully and address root causes

3. **If hooks fail, diagnose and fix the root cause**
   - Don't try to bypass validation
   - Fix the actual issue in the code
   - Re-run the commit after fixing

4. **If truly blocked, ask the user for guidance**
   - If stuck after 2 genuine attempts to fix errors
   - **NEVER** assume bypassing hooks is acceptable
   - Always ask the user before proceeding

### Why These Rules Exist

The pre-commit hooks are a **critical protective layer** that:

- ✅ Catch bugs before they're committed (parse errors, type errors)
- ✅ Enforce code quality standards (gdlint, gdformat)
- ✅ Run project validators (service API checks, test coverage)
- ✅ Ensure test consistency (GUT test execution)
- ✅ Validate resource files and project configuration
- ✅ Check for anti-patterns and performance issues

**Bypassing hooks defeats the entire purpose of having them.**

---

## 🔧 If Hooks Block You

### Step-by-Step Resolution Process

1. **Read the error message carefully**
   ```
   Example error:
   "Line 42: max-line-length (120 characters)"
   ```

2. **Identify the file and line number**
   ```
   scripts/ui/conversion_flow.gd:42
   ```

3. **Fix the actual issue**
   ```bash
   # For formatting issues
   gdformat scripts/ui/conversion_flow.gd

   # For linting issues - read output and fix manually
   gdlint scripts/ui/conversion_flow.gd
   ```

4. **Re-attempt the commit**
   ```bash
   git add scripts/ui/conversion_flow.gd
   git commit -m "fix: Address linting issues in conversion flow"
   ```

5. **If still blocked after 2 attempts, ASK THE USER**
   ```
   "I've attempted to fix the linting errors twice but am still blocked by:
   [error message]. Should I investigate further or do you have guidance?"
   ```

### Common Hook Failures & Solutions

| Error Type | Solution |
|------------|----------|
| `max-line-length` | Split long lines, use multiline strings |
| `duplicated-load` | Use `const` preload at class level |
| `function-name` or `undefined-variable` | Fix typos, check function exists |
| `Parse error` | Check GDScript syntax, missing colons, indentation |
| Test failures | Fix the actual test or code being tested |

---

## 📋 Exception Policy

**There are ZERO exceptions to this rule.**

- ❌ "The hook is wrong" - Fix the hook, don't bypass it
- ❌ "It's just a minor change" - Minor changes can break builds
- ❌ "I'll fix it later" - Fix it now, before committing
- ❌ "The linter is too strict" - Discuss with team, don't bypass
- ❌ "I'm in a hurry" - Rushing leads to bugs

**If you think you need --no-verify, you're wrong. Ask the user instead.**

---

## 🤖 For AI Assistants

If you are an AI assistant (Claude Code, Copilot, etc.) working on this codebase:

### Mandatory Rules

1. **Read this file at the start of EVERY session**
2. **NEVER use `--no-verify` or any bypass flags**
3. **Fix validation errors, don't bypass them**
4. **After 2 failed attempts to fix, ASK THE USER**
5. **Treat pre-commit hooks as sacred - they protect the codebase**

### Session Start Protocol

At the start of each session, you should:

```
1. Read docs/DEVELOPMENT-RULES.md
2. Review docs/godot-service-architecture.md (if working on services)
3. Check current week plan (docs/migration/)
4. Understand the test-driven workflow
```

### Commit Workflow for AI

```bash
# 1. Make changes to code
[edit files]

# 2. Run formatters
gdformat [files]

# 3. Stage changes
git add [files]

# 4. Commit (let hooks run)
git commit -m "descriptive message"

# 5. If hooks fail, read error and fix
# [fix the actual error]

# 6. Re-commit
git commit -m "descriptive message"

# 7. NEVER use --no-verify at any point
```

---

## 🛡️ Pre-Commit Hook Details

### What Runs During Pre-Commit

1. **GDScript Linting** (`gdlint`)
   - Checks for syntax errors
   - Enforces naming conventions
   - Detects undefined variables

2. **GDScript Formatting** (`gdformat`)
   - Ensures consistent code style
   - Checks line length (120 chars max)
   - Validates indentation

3. **Project Validators**
   - Native class name conflict checker
   - Service API consistency validator
   - Test method call validator
   - User story coverage checker

4. **Anti-Pattern Detectors**
   - Godot performance anti-patterns
   - Godot code smell detection
   - Service architecture issues
   - Test pattern violations

5. **GUT Test Execution** (headless mode)
   - Runs all non-resource tests
   - Ensures 313/313 tests pass
   - Validates test file structure

### Hook Execution Time

- **Typical**: 3-5 seconds
- **With test failures**: 10-15 seconds
- **Worth it**: YES - catches bugs before they're committed

---

## 📚 Related Documentation

- [godot-testing-research.md](./godot-testing-research.md) - Testing best practices
- [godot-service-architecture.md](./godot-service-architecture.md) - Service patterns
- [RUNNING-TESTS-IN-GODOT.md](./RUNNING-TESTS-IN-GODOT.md) - How to run tests in editor
- [test-file-template.md](./test-file-template.md) - Template for new tests

---

## ✅ Enforcement

This document is **mandatory** for all contributors. Violations will result in:

1. **First violation**: Warning + revert commit
2. **Second violation**: Review of development process
3. **Repeated violations**: Loss of commit access

For AI assistants: The user will correct you immediately. Learn from feedback.

---

## 🔄 Updates to This Document

If you believe a rule should be changed:

1. Discuss with the team
2. Get consensus
3. Update this document
4. Update related hooks/scripts
5. Communicate changes to all contributors

**Do not ignore rules because you disagree with them.**

---

**Document Version**: 1.0
**Last Updated**: 2025-01-10
**Next Review**: After Week 10 completion
**Maintained By**: Scrap Survivor Dev Team
