---
name: review
description: "Structured code review with two-pass severity model and fix-first heuristic. Use when user wants a code review, says 'review', 'review this', or before shipping."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git diff*), Bash(git log*), Bash(git show*), Bash(wc *), Agent, AskUserQuestion
argument-hint: "[optional: file paths, branch name, or 'staged']"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current branch: !`git branch --show-current`
Repo root: !`git rev-parse --show-toplevel`
Staged files: !`git diff --cached --name-only 2>/dev/null | head -20`
Recent commits (5): !`git log --oneline -5 2>/dev/null`

# /review — Structured Code Review

Two-pass severity model with fix-first heuristic. Finds real issues, auto-fixes mechanical ones, asks about risk-bearing ones.

## Step 0: Determine scope

Based on `input`:
- If specific file paths → review those files
- If branch name → `git diff main...{branch} --name-only` to get changed files
- If "staged" → review staged files from dynamic context above
- If empty → review unstaged + staged changes (`git diff --name-only` + `git diff --cached --name-only`)
- If a PR number → `git diff main...HEAD --name-only`

Read each file in scope. If scope exceeds 30 files, warn and ask whether to proceed or narrow.

## Step 1: Pass 1 — CRITICAL findings

Scan all files in scope for critical issues. These are **STOP and ASK** findings:

| Category | Examples |
|----------|----------|
| Security | SQL injection, command injection, XSS, path traversal, hardcoded secrets, insecure deserialization |
| Data loss | Unguarded DELETE/DROP, missing transaction boundaries, race conditions on shared state |
| Correctness | Off-by-one in boundary conditions, null/undefined dereference, enum switch missing cases, type coercion bugs |
| LLM trust boundary | LLM output written directly to DB, query, or rendered in UI without sanitization |

If CRITICAL findings exist:
1. List them with file:line references
2. Use AskUserQuestion (one per independent decision) following `.claude/reference/ask-format.md`
3. Wait for user response before proceeding

If no CRITICAL findings: proceed to Pass 2.

## Step 2: Pass 2 — INFO findings with fix-first heuristic

Scan for informational issues. Apply fix-first classification:

### AUTO-FIX (apply without asking)
- Dead code (unreachable branches, unused functions with no external callers)
- Stale comments that describe code that no longer exists
- Unused imports
- Obvious N+1 queries (when fix is mechanical)
- Version mismatches in lockfiles vs package.json
- Trailing console.log/print statements in non-test code

For each auto-fix: apply the fix using Edit, note what was changed.

### NOTE (report but don't fix)
- Missing test coverage for new code paths
- Magic numbers without named constants
- Functions exceeding ~50 lines (suggest split point)
- Duplicated logic across files (suggest extraction point)
- TODO/FIXME/HACK comments older than 30 days

### NEVER FLAG (suppression list)
- Test file naming conventions
- Import ordering preferences
- Trailing whitespace in markdown
- Comment style (// vs /* */)
- Variable naming in test fixtures
- Blank line count between functions

## Step 2b: Specialized Checks

Run these targeted checks after the general Pass 2 scan:

### Enum completeness tracing
When a diff adds a new enum value (or union type member):
1. Find all switch/match/case statements that consume this enum
2. Check each consumer for exhaustive handling of the new value
3. If any consumer lacks handling → CRITICAL (correctness bug, not style)

### LLM trust boundary validation
When a diff writes LLM output to persistent storage, query construction, or UI rendering:
1. Check for sanitization/escaping between LLM output and the sink
2. Flag direct writes without validation as CRITICAL
3. Acceptable patterns: schema validation, HTML escaping, parameterized queries

### Bundle impact assessment
When a diff adds npm/pip/cargo dependencies:
1. Check added package size: `npm info {pkg} dist.unpackedSize 2>/dev/null`
2. Flag packages >50KB gzipped as INFO with size note
3. Flag lockfile growth >10% as INFO
4. Flag packages with post-install scripts as INFO (supply chain concern)

## Step 3: Scope drift detection

Compare the set of changed files against the stated intent:
1. Read the most recent commit messages in scope
2. If a PR description exists, read it
3. Flag files that appear unrelated to the stated intent

Format: "Possible scope drift: {file} doesn't appear related to '{intent}'. Intentional?"

Only flag if confidence is high — a utils file touched alongside a feature is normal.

## Step 4: Convergence guard

If running iteratively (re-review after fixes), load `.claude/reference/convergence-protocol.md`.
After each review pass, hash findings and compare against previous pass.
Log to `knowledge/review-convergence.jsonl`.
If >50% match → stop, report convergence.

## Step 5: Write review log

Append to `knowledge/review-log.jsonl`:
```jsonl
{"skill": "review", "repo": "{repo_name}", "branch": "{branch}", "timestamp": "{ISO8601}", "status": "CLEAR|FINDINGS", "critical": {N}, "informational": {N}, "auto_fixed": {N}, "commit_sha": "{HEAD_SHA}"}
```

Create the file if it doesn't exist.

## Step 6: Report

```
REVIEW — {repo}:{branch} at {timestamp}

CRITICAL: {N} (0 = clear to ship)
{list if any}

INFO: {N} found, {M} auto-fixed, {K} noted
Auto-fixed:
- {file}:{line} — {what was fixed}

Notes:
- {file}:{line} — {observation}

Scope drift: {none | list}

Review logged to knowledge/review-log.jsonl
```

Keep the report concise. The user reads code — they don't need it quoted back.
