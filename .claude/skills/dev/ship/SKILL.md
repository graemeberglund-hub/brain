---
name: ship
description: "Gated shipping pipeline — review, security, tests, coverage, changelog, version bump, push, PR. Use when user says 'ship', 'ship it', 'ready to ship', or wants to push code."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion
argument-hint: "[optional: --skip-review | --skip-security | --skip-tests | --dry-run]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current branch: !`git branch --show-current`
Repo root: !`git rev-parse --show-toplevel`
Repo name: !`basename $(git rev-parse --show-toplevel)`
Default branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main`
HEAD sha: !`git rev-parse --short HEAD`
Ship config: !`cat .claude/ship-config.yml 2>/dev/null || echo "(no config — using defaults)"`
Last review: !`tail -1 knowledge/review-log.jsonl 2>/dev/null || echo "(no reviews)"`
Last security: !`ls -t knowledge/security-reports/*.json 2>/dev/null | head -1 || echo "(no reports)"`

# /ship — Gated Shipping Pipeline

8-gate pipeline. Each gate either passes, asks, or blocks. Skips available via flags or per-repo config.

## Per-repo config

Read `.claude/ship-config.yml` from repo root (dynamic context above). Defaults if missing:
```yaml
gates:
  review: recommended
  security: recommended
  coverage_minimum: 0
  bridge_check: false
test_command: auto-detect
```

## Gate 1: Review Readiness

Read `knowledge/review-log.jsonl` — find the most recent entry for this repo + branch.

- If found and `status: "CLEAR"` and `commit_sha` matches HEAD → PASS
- If found but commit_sha doesn't match HEAD → STALE: "Review was run at {sha} but HEAD is now {HEAD}. Re-run /review?"
- If not found → MISSING: "No review on record. Run /review first?"

If config says `review: required` and missing/stale → BLOCK.
If config says `review: recommended` → WARN and ask.
If config says `review: skip` → PASS silently.

## Gate 2: Security Check

Read `knowledge/security-reports/` — find the most recent report for this repo.

- If found within last 24h and zero critical findings → PASS
- If found but has critical findings → BLOCK: "Security audit found {N} critical issues."
- If not found or older than 24h → MISSING

Same required/recommended/skip logic as Gate 1.

## Gate 3: Test Detection + Bootstrap

Detect test framework:
1. Check for test commands in package.json scripts, Makefile, pyproject.toml
2. Look for test directories: `test/`, `tests/`, `__tests__/`, `spec/`
3. Check for test runner configs: jest.config, vitest.config, pytest.ini, .rspec

If test command found (from config or detection):
- Run it
- Parse results: passed, failed, skipped
- If failures: triage as pre-existing (fail on default branch too?) vs in-branch (must fix)
- In-branch failures → BLOCK

If no test framework detected → WARN: "No tests found. Shipping without test coverage."

## Gate 4: Coverage Audit

If `coverage_minimum > 0` in config:
- Get list of changed files: `git diff {default_branch}...HEAD --name-only`
- Check if coverage data exists for changed files
- If below minimum → BLOCK with file-level breakdown
- Override available via `--skip-tests` flag

If `coverage_minimum: 0` → PASS silently.

## Gate 4b: Bridge Check (epistemic integration)

Only runs if `bridge_check: true` in config (default: false). Unique to repos registered in the brain vault.

1. Get changed files: `git diff {default_branch}...HEAD --name-only`
2. Read `knowledge/graph-epistemic.yml` — find positions linked to changed code areas
3. For each linked position, check:
   - Has the position's trajectory changed to `weakening` or `contested` recently?
   - Has it received CONTRADICTS events in the last 14 days?
   - Has its confidence dropped?

4. If a weakened position is linked to shipped code → WARN:
   ```
   Bridge check: You're shipping code that implements [[position-slug]]
   but that position weakened on {date} based on evidence from [[claim-slug]].
   Continue? (The position's evidence base may no longer support this approach.)
   ```

5. Use AskUserQuestion following `.claude/reference/ask-format.md`. User can:
   - **Continue** — ship anyway, log the override
   - **Investigate** — pause ship, review the position
   - **Abort** — cancel ship

If no positions are linked to changed files, or all linked positions are stable → PASS silently.

## Gate 5: Changelog

Auto-generate from ALL commits on branch (not just recent):
```
git log {default_branch}..HEAD --pretty=format:"%s" --reverse
```

Categorize each commit:
- **Added**: new features, new files, new capabilities
- **Changed**: modifications to existing behavior
- **Fixed**: bug fixes
- **Removed**: deleted features or code
- **Security**: security-related changes

Write in user-facing voice: what can you DO now that you couldn't before.

Present changelog for user approval. Allow edits.

## Gate 6: Version Bump

Detect versioning system:
- `package.json` → npm version
- `pyproject.toml` → Python version
- `Cargo.toml` → Rust version
- `VERSION` file

Auto-pick PATCH for bug-fix-only branches. Ask for MINOR/MAJOR if new features present.

If no versioning system → skip silently.

## Gate 7: Commit + Push + PR

1. Stage any remaining changes (changelog, version bump)
2. Create commit with changelog summary
3. Push with upstream tracking: `git push -u origin {branch}`
4. Create PR with summary including:
   - Changelog
   - Test results (pass/fail/skip counts)
   - Review status
   - Security status

If `--dry-run` flag → show what would happen, don't execute.

## Gate 8: Post-Ship

1. Write to `knowledge/ship-log.jsonl`:
```jsonl
{"timestamp": "ISO8601", "repo": "repo-name", "branch": "branch", "commit_sha": "abc123", "gates_passed": ["review", "security", "tests"], "gates_skipped": ["coverage"], "changelog_categories": {"added": 2, "fixed": 1}, "pr_url": "..."}
```

2. If in brain vault context: trigger `/sync` awareness (note the ship event for daily note).

## Report

```
SHIP — {repo}:{branch}

Gates:
  Review:   {PASS|STALE|MISSING|BLOCKED}
  Security: {PASS|MISSING|BLOCKED}
  Tests:    {PASS|FAIL|NO_TESTS}
  Coverage: {PASS|BELOW_MIN|SKIP}

Changelog:
{formatted changelog}

{if all gates pass: "Shipped. PR: {url}"}
{if blocked: "Blocked by: {gate}. Fix and re-run."}
```
