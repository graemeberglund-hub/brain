---
name: repo-health
description: "Multi-phase repo health workstream — naming conventions, CLAUDE.md accuracy, manifest integrity, frontmatter, link integrity, graph staleness, git hygiene. Run periodically to catch drift across all registered repos."
allowed-tools: Read, Glob, Grep, Bash(ls *), Bash(find *), Bash(git *), Bash(date *), Bash(wc *), Bash(basename *), Bash(readlink *), Bash(test *), Bash(stat *), Write, Edit
argument-hint: "[repo-slug | --all] [--fix] [--phase N]"
dashterm: true
timeout: 0
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Registered repos: !`ls $BRAIN_VAULT_PATH/repos/*.yml | xargs -I{} basename {} .yml | tr '\n' ', '`

# /repo-health — Repo Health Workstream

Multi-phase health check across registered repos. Each phase scans for a category of drift, reports findings, and optionally fixes. Audit gates between phases catch cascading issues.

## Parse Arguments

- `repo-slug` — target a single repo (matches `repos/*.yml`). Use `brain` for the vault itself.
- `--all` — scan all registered repos + brain
- `--fix` — auto-fix violations where safe (uses git mv for renames, edits for references). Without this flag, dry-run only.
- `--phase N` — run only phase N (1-6). Useful for targeted checks.
- No args → brain only, all phases, dry-run mode

## Resolve Targets

For each target repo:
1. Read `repos/{slug}.yml` to get the path
2. Verify the path exists (`test -d`)
3. Skip repos whose path doesn't exist (report as `UNREACHABLE`)

For brain itself, path is the vault root.

---

## Phase 1: Naming Convention v2

Reference: `notes/concepts/2026-03-19-con-filename-convention-v2.md`

### Required pattern

```
YYYY-MM-DD-{type_tag}-{slug}.md
```

**Valid type tags:** pos, con, ref, conv, in, journal, trace, project, prp, prompt, output, spec, paper, opp

### Scan rules

Find all `.md` files recursively in the repo. For each file:

**Skip if:**
- Path contains: `.git/`, `.claude/`, `.obsidian/`, `.venv/`, `node_modules/`, `__pycache__/`, `.agents/`, `dist/`, `build/`
- Basename is: `CLAUDE.md`, `README.md`, `STATUS.md`, `DELIVERABLES.md`, `LICENSE*`, `CHANGELOG*`, `CONTRIBUTING*`
- Non-note extensions: `*.yml`, `*.yaml`, `*.json`, `*.jsonl`, `*.py`, `*.sh`, `*.html`, `*.css`, `*.js`, `*.ts`, `*.pdf`, `*.txt`
- In `notes/areas/` with no date prefix (area-style, exempt)
- In `people/` with no date prefix (profile-style, exempt)
- Daily note matching `YYYY-MM-DD.md` exactly

**Detect violations:**

| Code | Violation | Pattern |
|------|-----------|---------|
| `SEQ` | Bare sequential number | `^[0-9]{2,3}-` |
| `NODATE` | No date prefix | doesn't match `^[0-9]{4}-[0-9]{2}-[0-9]{2}-` |
| `NOTAG` | Date but no type tag | has date, next segment not in valid tags list |

**Exception:** Workstream outputs (`YYYY-MM-DD-{workstream}-{segment}-{slug}.md`) where segment is a number (`01`, `02`) or letter code (`sx`, `q`) are valid — don't flag as NOTAG.

### Fix logic (if --fix)

1. Recover date: `git log --diff-filter=A --format=%cs -- "{file}" | tail -1` (fallback: today)
2. Infer type tag from directory or frontmatter `type:` field (see inference table at bottom)
3. `git mv` the file
4. Search repo for old basename references, update them

### Phase 1 audit gate

Report: `Phase 1 Naming: {N} violations across {M} repos ({n1} SEQ, {n2} NODATE, {n3} NOTAG)`

If `--fix`: also `{K} fixed, {J} need manual review`

**Gate rule:** If SEQ violations > 0 and --fix was NOT used, WARN: "Sequential-numbered files found. These lose sort order and provenance. Consider --fix."

---

## Phase 2: CLAUDE.md Accuracy

For each repo that has `claude_md: true` in its manifest (or is brain):

### Checks

1. **Directory references**: Extract directory paths mentioned in CLAUDE.md (look for paths in backticks, tables, yaml blocks). Verify each exists relative to repo root.
   - Flag: `DEADDIR` — referenced directory doesn't exist

2. **Phase/status freshness**: If CLAUDE.md has a "Current Phase" or "Current Status" section, compare against `graph-projects.yml` state entry's `status` field. Flag if they seem to describe different states.
   - Flag: `STALE_PHASE` — CLAUDE.md phase description may be outdated

3. **Skill references**: If CLAUDE.md references skill paths (`~/.claude/skills/` or `.claude/skills/`), verify the symlinks or directories exist.
   - Flag: `DEAD_SKILL` — referenced skill doesn't exist

### Fix logic

- `DEADDIR`: Report only (may be intentional removal)
- `STALE_PHASE`: Report both values so user can decide
- `DEAD_SKILL`: Report only

### Phase 2 audit gate

Report: `Phase 2 CLAUDE.md: {N} issues ({n1} DEADDIR, {n2} STALE_PHASE, {n3} DEAD_SKILL)`

**Gate rule:** If DEADDIR > 3 in a single repo, WARN: "Multiple dead directories — repo may have been restructured without updating CLAUDE.md."

---

## Phase 3: Manifest Accuracy

For each repo, read `repos/{slug}.yml` in brain:

### Checks

1. **key_directories exist**: For each entry, verify the directory exists in the repo.
   - Flag: `DEAD_KEYDIR`

2. **Deliverable repos exist**: For each deliverable entry, check the repo path exists.
   - Flag: `MISSING_DELIVERABLE`

3. **claude_md field**: If `claude_md: true`, verify CLAUDE.md file exists.
   - Flag: `CLAUDE_MD_MISSING`

4. **Path validity**: Verify the manifest `path:` points to an existing directory.
   - Flag: `BAD_PATH`

### Fix logic

- `DEAD_KEYDIR` with `--fix`: Remove the entry from the manifest
- Others: Report only

### Phase 3 audit gate

Report: `Phase 3 Manifest: {N} issues ({n1} DEAD_KEYDIR, {n2} MISSING_DELIVERABLE, ...)`

**Gate rule:** If BAD_PATH on any repo, FAIL: "Repo path doesn't exist — may have moved or been deleted. Fix manifest before continuing."

---

## Phase 4: Frontmatter Completeness

For each `.md` note file (same skip rules as Phase 1):

### Checks

1. **Has frontmatter**: File starts with `---` and has a closing `---`
   - Flag: `NO_FM`

2. **Required fields**: `title`, `type`, `tags`, `created` must all be present
   - Flag: `MISSING:{field}` (e.g., `MISSING:type`)

3. **Type validity**: `type:` value is a recognized note type
   - Flag: `INVALID_TYPE`

4. **Date format**: `created:` matches `YYYY-MM-DD`
   - Flag: `BAD_DATE`

### Fix logic (if --fix)

- `MISSING:created`: Recover from `git log --diff-filter=A`, insert into frontmatter
- `MISSING:type`: Infer from directory (same table as Phase 1), insert
- `MISSING:tags`: Insert `tags: []`
- Others: Report only

### Phase 4 audit gate

Report: `Phase 4 Frontmatter: {N} issues ({n1} NO_FM, {n2} MISSING, {n3} INVALID_TYPE, {n4} BAD_DATE)`

**Gate rule:** If NO_FM > 0, WARN: "Files without frontmatter won't be indexed by Obsidian or vault skills."

---

## Phase 5: Link Integrity

### Checks

1. **Broken wikilinks**: Scan `.md` files for `[[target]]` patterns. For each, verify a file matching `*{target}*` exists somewhere in the repo (or in brain's `notes/` for cross-repo links).
   - Flag: `BROKEN_LINK`
   - Sample up to 50 files per repo to keep runtime reasonable

2. **Dead path references**: Scan for backtick-quoted paths (`` `path/to/file` ``). Verify the file exists relative to repo root.
   - Flag: `DEAD_PATH`
   - Sample up to 30 files per repo

### Fix logic

- Report only — broken links need human judgment
- If a wikilink target has an obvious renamed match (same slug, different prefix), suggest the fix

### Phase 5 audit gate

Report: `Phase 5 Links: {N} issues ({n1} BROKEN_LINK, {n2} DEAD_PATH)`

**Gate rule:** If BROKEN_LINK > 10 in a single repo, WARN: "Mass breakage — likely a bulk rename happened without reference updates. Consider targeted grep+sed."

---

## Phase 6: Graph & Git Hygiene

### Knowledge graph staleness (brain only)

For each `state-{slug}` entry in `knowledge/graph-projects.yml`:
1. Read `last_worked` date
2. If more than 14 days stale, check for newer commits: `git -C {repo_path} log --since="{last_worked}" --oneline | head -1`
3. If newer commits exist but graph wasn't updated:
   - Flag: `STALE_GRAPH`

### Git hygiene (all target repos)

1. **Uncommitted changes**: `git -C {path} status --porcelain | wc -l`
   - Flag: `DIRTY` if > 10 uncommitted changes

2. **Untracked notes**: `git -C {path} ls-files --others --exclude-standard '*.md' | wc -l`
   - Flag: `UNTRACKED` if > 5 untracked .md files

### Fix logic

- `STALE_GRAPH`: Report with dates. Don't auto-fix — `/sync` handles this.
- `DIRTY` / `UNTRACKED`: Report only.

### Phase 6 audit gate

Report: `Phase 6 Graph/Git: {N} issues ({n1} STALE_GRAPH, {n2} DIRTY, {n3} UNTRACKED)`

**Gate rule:** If STALE_GRAPH on 3+ repos, WARN: "Multiple repos out of sync — consider running /sync."

---

## Final Report

After all phases, produce a consolidated report:

```
# Repo Health Report — YYYY-MM-DD

## Summary

| Repo | P1 Naming | P2 CLAUDE | P3 Manifest | P4 Frontmatter | P5 Links | P6 Git | Total |
|------|-----------|-----------|-------------|----------------|----------|--------|-------|
| brain | 0 | 1 | 0 | 2 | 3 | 1 | 7 |
| jason-holt | 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| ... | ... | ... | ... | ... | ... | ... | ... |

**Total: {N} issues across {M} repos**
**Fixed: {K}** (if --fix)
**Manual review: {J}**

## Audit Gates

- P1: {PASS|WARN|FAIL} — {reason}
- P2: {PASS|WARN|FAIL} — {reason}
- P3: {PASS|WARN|FAIL} — {reason}
- P4: {PASS|WARN|FAIL} — {reason}
- P5: {PASS|WARN|FAIL} — {reason}
- P6: {PASS|WARN|FAIL} — {reason}

## Details

{Per-phase findings grouped by repo — only show repos with issues}
```

## Log to daily note

Append under `## Captured`:
```
- HH:MM — [repo-health] {M} repos scanned, {N} issues (P1:{n1} P2:{n2} P3:{n3} P4:{n4} P5:{n5} P6:{n6}). {K} fixed. Gates: {pass_count} PASS, {warn_count} WARN, {fail_count} FAIL.
```

---

## Type tag inference table

All epistemic notes (beliefs, questions, decisions, tastes, goals) live in `positions/` — differentiated by `classification:` field, not directory.

| Directory pattern | Tag |
|-------------------|-----|
| `positions/` | pos |
| `concepts/` | con |
| `references/` | ref |
| `conversations/` | conv |
| `inbox/` | in |
| `journal/` | journal |
| `traces/` | trace |
| `projects/` | project |
| `PRPs/` (not ai_docs/) | prp |
| `PRPs/ai_docs/` | spec |
| `prompts/` (not outputs/) | prompt |
| `prompts/outputs/` or `outputs/` | output |
| `opportunities/` | opp |
| `papers/` | paper |

If directory doesn't match, check frontmatter `type:` field. If still ambiguous, flag for manual review instead of auto-fixing.

## Modes

### Interactive (this skill)

`/repo-health` runs the 6-phase scan inline in the current session. Good for quick checks.

- `/repo-health` — brain only, dry-run
- `/repo-health --all` — all repos, dry-run
- `/repo-health jason-holt --fix` — single repo, auto-fix safe violations

### Workstream: Deep Alignment

For repos that need full structural alignment, use the multi-agent workstream:

```bash
.claude/workstreams/repo-health/runner.sh <repo-slug>
```

This runs 6 phases via dashterm (each a fresh Claude instance):
1. **Orient** — assess repo, produce gap analysis
2. **Plan** — create alignment PRP from gaps
3. **Review** (x2) — adversarial check of the PRP
4. **Execute** — run the PRP
5. **Verify** — check execution, create follow-up PRP if needed
6. **Finalize** — execute follow-up, commit, update docs

Requires dashterm running. Run from Terminal, not inside Claude Code.

### Workstream: Daily Check

Lightweight scan designed to run as part of the morning pipeline:

```bash
.claude/workstreams/repo-health/runner.sh --check
```

Scans all repos, auto-fixes safe violations (orphan renames, missing frontmatter fields), reports the rest. Recommends `/repo-health <slug>` align runs for repos with significant drift.

## Cadence

- **Daily**: `--check` as part of morning pipeline (catches drift)
- **Weekly**: `/repo-health --all` interactive for quick review
- **On-demand**: `runner.sh <slug>` for deep alignment of older repos
- **Per-session**: `/repo-health {slug}` after significant work
