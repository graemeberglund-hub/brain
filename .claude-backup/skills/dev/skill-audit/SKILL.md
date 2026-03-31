---
name: skill-audit
description: "Scan all skills for health issues — stale triggers, missing frontmatter, broken symlinks, orphaned skills. Use when validating skill infrastructure."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls *), Bash(date *), Bash(find *), Bash(test *), Bash(readlink *), Bash(wc *), Bash(mkdir *), Agent
argument-hint: "[--fix] [--family family-name]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

(At start of execution, use Glob to check: skill count by listing .claude/skills/*/SKILL.md and .claude/skills/*/*/SKILL.md files, symlinks in ~/.claude/skills/ directory, and whether .claude/skill-index.yml exists.)

# /skill-audit — Skill Infrastructure Health Check

You are scanning all skills across the vault and personal scope for health issues. This is an automated quality gate — not a deep epistemic audit.

## Parse Arguments

- `--fix` — auto-fix trivial issues (missing fields, broken symlinks with obvious targets)
- `--family {name}` — scope audit to one family only
- No args → full audit

## Audit Checks

Run ALL of the following checks. Track findings as `{severity}: {description}` where severity is `ERROR`, `WARN`, or `INFO`.

### Check 1: Filesystem vs Index

Compare skills found on disk (`.claude/skills/` — all `SKILL.md` files) against entries in `.claude/skill-index.yml`.

- **ERROR**: Skill on disk but not in index (orphaned)
- **ERROR**: Skill in index but not on disk (ghost entry)
- **WARN**: Index meta counts don't match actual counts

### Check 2: Frontmatter Completeness

For each SKILL.md, verify required frontmatter fields:
- `name:` — must exist, must match directory name
- `description:` — must exist, should contain "Use when" clause
- `allowed-tools:` — must exist
- `argument-hint:` — should exist (WARN if missing)

Findings:
- **ERROR**: Missing `name:` or `description:`
- **WARN**: Missing `argument-hint:`
- **WARN**: `description:` doesn't contain "Use when"
- **WARN**: `name:` doesn't match directory name

### Check 3: Symlink Integrity

For each symlink in `~/.claude/skills/`:
- Resolve the target — does it exist?
- Does it point back into `.claude/skills/` in a known vault path?
- Is there a matching skill on disk?

For each portable skill on disk (families: `dev`, `writing`, `research`, `seo`, `integrations`, `media`, `google`, `google-recipes`, `personas`):
- Does a symlink exist in `~/.claude/skills/`?

Findings:
- **ERROR**: Broken symlink (target doesn't exist)
- **WARN**: Portable skill without symlink to `~/.claude/skills/`
- **INFO**: Symlink points to unexpected location

### Check 4: Router Coverage

Read the CLAUDE.md agent router section. For each vault skill in the index, check if there's a matching trigger pattern.

- **WARN**: Skill exists but has no router entry (users can't discover it via natural language)
- **INFO**: Router entry exists but skill name doesn't match exactly

### Check 5: Body Quality (lightweight)

For each SKILL.md body:
- Does it have at least one `## ` section?
- Does it reference `$ARGUMENTS` if `argument-hint:` is set?
- Does it have a confirmation/report step?
- Are there dynamic context lines (`!` backtick)?

Findings:
- **WARN**: No sections in body (empty skill)
- **WARN**: Has argument-hint but body never references `$ARGUMENTS`
- **INFO**: No confirmation step found
- **INFO**: No dynamic context lines

## Output Report

### To stdout (always)

```
=== Skill Audit — {date} ===

Scanned: {N} skills across {M} families
Symlinks checked: {K}

ERRORS ({count}):
- {error descriptions}

WARNINGS ({count}):
- {warning descriptions}

INFO ({count}):
- {info descriptions}

Health: {PASS if 0 errors, WARN if errors exist}
```

### To file (if errors or warnings exist)

Write to `activity/reports/skill-audit/{date}.md`:

```yaml
---
title: "Skill Audit {date}"
type: report
created: {date}
errors: {count}
warnings: {count}
info: {count}
health: PASS|WARN|FAIL
---
```

Followed by the full findings detail, organized by check.

Create the directory if it doesn't exist.

## Auto-fix (if --fix)

If `--fix` was passed, attempt to fix:
- Missing `argument-hint:` → add `argument-hint: ""` placeholder
- Missing "Use when" in description → append ". Use when invoked directly."
- Broken symlink with obvious target (skill exists on disk, symlink just needs re-pointing) → relink
- Index count mismatch → update counts

Report what was fixed vs. what needs manual attention.
