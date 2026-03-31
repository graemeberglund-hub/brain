---
name: health-check
description: "Fast operational health scan — inbox depth, stale positions, broken links, scheduler status, skill integrity. Use when checking if the vault is working."
allowed-tools: Read, Glob, Grep, Bash(ls *), Bash(date *), Bash(find *), Bash(test *), Bash(readlink *), Bash(wc *), Bash(launchctl *), Bash(stat *), Write, Edit
argument-hint: "[--verbose]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob and Grep to gather: inbox count from notes/inbox/, position count from notes/positions/, and question count by grepping notes/positions/ for classification: question.)

# /health-check — Vault Operational Health

You are running a fast, non-interactive health scan of the brain vault. This answers "is my vault working?" — different from `/audit` which is deep epistemic analysis.

## Parse Arguments

- `--verbose` — show per-item details, not just counts
- No args → summary mode (counts + top-level status)

## Run All Checks

Track each check as `OK`, `WARN`, or `FAIL` with a one-line reason.

### 1. Inbox Depth

- Read inbox count from dynamic context above
- **OK**: 0-5 items
- **WARN**: 6-15 items ("inbox building up")
- **FAIL**: 16+ items ("inbox overflowing — triage needed")
- If `--verbose`: list inbox note titles

### 2. Stale Positions

Scan `notes/positions/` for files where `updated:` is more than 30 days before today's date.

- **OK**: 0 stale positions
- **WARN**: 1-3 stale ("some positions haven't been revisited")
- **FAIL**: 4+ stale ("multiple positions going stale")
- If `--verbose`: list stale position titles with last updated date

### 3. Unresolved Questions

Scan `notes/positions/` for files where `classification: question` and (`stage: open` or `stage: active`) and `created:` is more than 30 days ago.

- **OK**: All questions recent or resolved
- **WARN**: 1-3 aging open questions
- **FAIL**: 4+ aging questions ("open questions accumulating without progress")
- If `--verbose`: list question titles with age

### 4. Daily Note Freshness

Check if today's daily note exists at `notes/daily/{today}.md`.

- **OK**: Today's note exists
- **WARN**: Missing (but yesterday's exists)
- **FAIL**: Neither today nor yesterday exist

### 5. Skill Symlink Integrity

Check `~/.claude/skills/` for broken symlinks:

```bash
find ~/.claude/skills -maxdepth 1 -type l ! -exec test -e {} \; -print
```

- **OK**: No broken symlinks
- **WARN**: 1-2 broken
- **FAIL**: 3+ broken

### 6. Scheduler Status

Check if brain launchd jobs are loaded:

```bash
launchctl list 2>/dev/null | grep "com.brain" || echo "none"
```

- **OK**: Jobs found and loaded
- **WARN**: No brain jobs found (scheduler not set up)
- **INFO**: Jobs present (report which ones)

### 7. Knowledge Graph Freshness

Check modification dates of graph files:
- `knowledge/graph-dev.yml`
- `knowledge/graph-projects.yml`
- `knowledge/graph-epistemic.yml`
- `knowledge/graph-emergent.yml`

- **OK**: All updated within 7 days
- **WARN**: Any graph older than 7 days
- **FAIL**: Any graph older than 30 days or missing

### 8. Epistemic Ledger Health

Check `knowledge/epistemic-ledger.jsonl`:
- Does it exist?
- How many events total?
- When was the last event?

- **OK**: Exists with recent events (within 7 days)
- **WARN**: Exists but last event > 7 days ago
- **FAIL**: Missing or empty

## Output

Print a compact dashboard to stdout:

```
=== Vault Health — {date} ===

  Inbox depth:     {count} items          {OK|WARN|FAIL}
  Stale positions: {count}/{total}        {OK|WARN|FAIL}
  Aging questions: {count}/{total}        {OK|WARN|FAIL}
  Daily note:      {exists|missing}       {OK|WARN|FAIL}
  Skill symlinks:  {broken}/{total}       {OK|WARN|FAIL}
  Scheduler:       {status}               {OK|WARN|INFO}
  Graph freshness: {oldest age}           {OK|WARN|FAIL}
  Epistemic ledger:{event count}, last {age} {OK|WARN|FAIL}

  Overall: {HEALTHY|NEEDS ATTENTION|DEGRADED}
  {one-line recommendation if not HEALTHY}
```

Overall logic:
- **HEALTHY**: 0 FAILs, ≤2 WARNs
- **NEEDS ATTENTION**: 0 FAILs, 3+ WARNs
- **DEGRADED**: Any FAILs

If `--verbose`, expand each section with item-level detail below the dashboard.

Do NOT write a report file — this is stdout-only for fast operational checks. The user can pipe to a file if they want persistence.
