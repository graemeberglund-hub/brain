---
name: skill-test
description: "Validate a skill runs correctly — check frontmatter, dry-run with fixture args, verify output shape. Use when testing skills before deployment or after edits."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(find *), Bash(test *), Bash(wc *), Bash(mkdir *), Agent
argument-hint: "skill-name [--all] [--family family-name] [--verbose]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Skill count: !`find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' '`

# /skill-test — Skill Validation

You are testing skills for correctness without executing them against the real vault. This is the quality gate before packaging or deployment.

## Parse Arguments

- **skill-name** — test a specific skill
- **--all** — test every skill found on disk
- **--family name** — test all skills in a family
- **--verbose** — show detailed output per check

## Test Levels

### Level 1: Static Analysis (always runs)

For each skill, read its SKILL.md and verify:

1. **Frontmatter validity**
   - `name:` exists and matches directory name
   - `description:` exists and contains "Use when"
   - `allowed-tools:` exists and lists valid tool names
   - `argument-hint:` exists

2. **Body structure**
   - Has at least one `## ` heading
   - Has a confirmation/report step (grep for "Confirm", "Report", "Output", or "Summary")
   - References `$ARGUMENTS` if `argument-hint` is non-empty
   - Dynamic context lines use correct `!` backtick syntax
   - No broken markdown (unclosed code blocks, mismatched headers)

3. **Path references**
   - Any hardcoded vault paths (e.g., `$BRAIN_VAULT_PATH/`) are valid
   - References to other skills or files exist on disk

4. **Tool permissions**
   - `allowed-tools:` doesn't include tools the skill body never uses
   - Bash patterns in `allowed-tools:` cover the bash commands used in dynamic context lines

### Level 2: Dry-run Validation (if skill declares test fixtures)

Check if the SKILL.md frontmatter includes a `test:` block:

```yaml
test:
  args: "example arguments"
  expects:
    files_created: ["path/pattern"]
    stdout_contains: ["string"]
    no_errors: true
```

If a `test:` block exists:
- Parse expected args
- Note: actual execution requires a sandbox — for now, validate that the expected output paths are plausible (parent directories exist or would be created)

If no `test:` block:
- Report `SKIP: no test fixtures declared`
- Suggest adding a `test:` block (this is an INFO, not a failure)

### Level 3: Cross-reference Checks

- **Index coverage**: Is this skill listed in `.claude/skill-index.yml`?
- **Router coverage**: Does this skill have a trigger in `CLAUDE.md`?
- **Symlink status**: For portable skills, does `~/.claude/skills/{name}` exist and point correctly?

## Output

```
=== Skill Test: {name} ===

Level 1 — Static Analysis:
  Frontmatter:     {PASS|FAIL: reason}
  Body structure:  {PASS|FAIL: reason}
  Path references: {PASS|FAIL: reason}
  Tool permissions: {PASS|WARN: reason}

Level 2 — Dry-run:
  {PASS|SKIP|FAIL: reason}

Level 3 — Cross-reference:
  Index:   {PASS|FAIL}
  Router:  {PASS|WARN}
  Symlink: {PASS|N/A|FAIL}

Result: {PASS|WARN|FAIL}
```

### Batch mode (--all or --family):

```
=== Skill Test Suite — {date} ===

Tested: {N} skills
Passed: {count}
Warnings: {count}
Failed: {count}

Failures:
- {skill}: {reason}

Warnings:
- {skill}: {reason}
```

Write batch results to `activity/reports/skill-tests/{date}.md` if any failures or warnings exist.
