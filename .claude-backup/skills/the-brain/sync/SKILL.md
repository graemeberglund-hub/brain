---
name: sync
description: Sync git commits from registered repos into today's daily note with synthesis and knowledge graph. Use when user wants git commits reflected in daily notes.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git -C *), Bash(date *), Bash(python3 *)
argument-hint: "[optional date YYYY-MM-DD to backfill]"
dashterm: true
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

(At start of execution, use Glob to check: registered repos by listing repos/*.yml files.)

# /sync — Synthesized Git Commits → Daily Note + Knowledge Graph

Transform a day's git commits into meaningful knowledge. This is NOT a mechanical transcript — it's a synthesis layer that distills commits into what was learned, decided, solved, and where things stand.

## 1. Determine target date

If `input` contains a date (YYYY-MM-DD), use that. Otherwise use today.

## 2. Discover repos

Read all manifests in `repos/*.yml` to get repo names and paths. Also include the brain repo itself (`Brain` at `$BRAIN_VAULT_PATH`). Skip any repos whose path doesn't exist.

## 3. Two-pass commit reading

### Pass 1: Scan messages and file lists

For each repo:
```bash
git -C {repo_path} log --no-merges --format="%H|%s" --after="{target_date}T00:00:00" --before="{next_date}T00:00:00" --all
```

Also get changed files:
```bash
git -C {repo_path} log --no-merges --format="%H" --name-only --after="{target_date}T00:00:00" --before="{next_date}T00:00:00" --all
```

Collect each commit's full hash, short hash (7 chars), message, changed files, and repo name.

**Exclude sync's own commits** — drop any Brain repo commit whose message starts with one of these prefixes: `[brain-sync]`, `feat: sync`, `fix: sync`, `chore: sync`. Do NOT use substring matching on "sync" — a legitimate commit like "add database sync feature" must not be excluded. The `/sync` skill itself should use the `[brain-sync]` prefix when creating its own commit.

### Pass 2: Selective diff reading

Review the commit messages and identify commits where reading the actual diff would reveal substantive learning. Pull diffs for commits that:
- Fix bugs (the diff shows what was wrong and how it was fixed)
- Implement new approaches (the diff shows architectural decisions)
- Revert or change direction (the diff shows what didn't work)
- Touch core logic files (not config, formatting, or boilerplate)

Skip diffs for:
- Routine file additions, renames, or moves
- Formatting/linting/comment-only changes
- Simple config or dependency updates
- Commits where the message already tells the full story

For selected commits:
```bash
git -C {repo_path} diff {hash}^..{hash} --stat
git -C {repo_path} diff {hash}^..{hash} -- {specific_files}
```

Be selective — read 3-8 diffs max, not all of them. Prioritize learning density.

## 4. Group into logical work units

DO NOT list commits individually. Group related commits into logical work units — the conceptual chunks of work that happened. Examples:
- 12 commits on an age-band bug → one work unit: "Fixed age-band boundary condition"
- 5 commits adding a new component → one work unit: "Built the mortality explorer chart component"
- 3 commits trying something, then reverting → one work unit that captures the attempt AND the revert reason

Each work unit gets:
- A clear description of what was accomplished (or attempted)
- The project it belongs to (from `activity/config.yml` clusters and `notes/projects/`)
- Classification: `feature` | `fix` | `refactor` | `exploration` | `infrastructure` | `content`
- Optional: what was learned, what was decided, what didn't work

## 5. Attribute to projects

Read `activity/config.yml` for the canonical project list and cluster mapping. Skim relevant project notes in `notes/projects/` for context. Attribute each work unit to the right project.

**The config.yml list is a starting point, not a constraint.** New workstreams emerge constantly. Rules:
- If work clearly belongs to an existing project, use that canonical name
- If it's a genuinely new workstream, name it descriptively and let it stand — this is how new projects get discovered
- Name headings after **the thing being worked on** (e.g., "Work Activity System"), not the action taken (e.g., "Project Tracking Migration")
- If genuinely ambiguous, prefix with `[?Project Name]`
- Only use `General / {RepoName}` as a last resort

## 6. Ensure daily note exists

Path: `notes/daily/{target_date}.md`. If it doesn't exist, create it:

```yaml
---
title: "{target_date}"
type: daily
tags: []
created: {target_date}
---

## Work


## Decisions


## Captured


## Notes
```

## 7. Check idempotency

Read the daily note and collect any existing sync markers of the form `<!-- sync:{target_date}:{short_hash} -->`. A work unit is "already synced" if ALL of its constituent commit hashes appear in existing markers. Skip fully-synced work units.

For partially-synced work units (some commits already present), use this algorithm:
1. Match new commits to an existing work unit by checking if any of their hashes appear in that unit's sync marker
2. Read the existing narrative and the new commits together
3. Rewrite the narrative to incorporate the additional work (don't just append a sentence)
4. Replace the sync marker with one that includes ALL hashes (old + new): `<!-- sync:{target_date}:{all_hashes} -->`
5. If new commits don't match any existing marker but clearly belong to the same project/effort as an existing work unit (same project, related files), merge them into that unit using the same rewrite approach

## 8. Write synthesized entries to daily note

For each NEW work unit, write under `## Work`:

```markdown
### {Project Name}

{Synthesized description of what was accomplished, 2-5 sentences. Include what was learned or decided if applicable. Mention dead ends if they occurred.}

<!-- sync:{target_date}:{hash1},{hash2},{hash3} -->
```

If multiple projects had work, each gets its own `###` subsection. Append after existing `## Work` content, before `## Decisions`. Preserve all existing content.

**Writing quality guidelines:**
- **Hard limit: 2-5 sentences per work unit.** If you've written more, you're listing changes instead of synthesizing. Compress.
- Write in past tense, active voice: "Fixed the boundary condition" not "The boundary condition was fixed"
- Lead with the 1-2 biggest moves, then fold everything else into context. 17 commits about a landing page is NOT 17 things to mention — it's 2-3 themes (e.g., "migrated scroll engine", "restructured content", "fixed reverse-scroll bug") with details only where they teach something.
- Do NOT enumerate iterative refinements. "Iterated on headline layout and background imagery" is better than listing each swap.
- No editorializing ("massive overhaul", "extensive refinement"). State what happened; the scope speaks for itself.
- If a bug was fixed: state the symptom, root cause, and fix
- If something was tried and reverted: state what was tried, why it didn't work, and what replaced it
- If this was exploratory: state what was learned even if nothing was shipped
- Keep it concise — a reader should understand the day's work in 30 seconds

## 9. Write to knowledge graph

The knowledge graph is split into subgraphs. Read `knowledge/graph-index.yml` first for routing, then write to the appropriate subgraph:
- **Solutions, dead-ends, tools, patterns** → `knowledge/graph-dev.yml`
- **Project states** → `knowledge/graph-projects.yml`
- **Investigation entities** → `knowledge/graph-dev.yml` (until rla-investigation gets its own file)
- **Cross-subgraph structural relations** → `knowledge/graph-index.yml` under `relations:`

For each work unit, determine if it produced knowledge worth persisting. Not every work unit needs a graph entry — routine feature work or content additions usually don't. Write entities for:

### Solutions (type: solution)
When a bug was fixed or a non-obvious problem was solved. Add to `entities:` in `knowledge/graph-dev.yml`:
```yaml
  {slug}:
    type: solution
    domain: development
    title: "{Descriptive problem name}"
    project: "{project name}"
    date: "{target_date}"
    daily_note: "[[{target_date}]]"
    problem: "{what was broken/wrong}"
    root_cause: "{why it was broken}"
    fix: "{what solved it}"
```

### Dead ends (type: dead-end)
When an approach was tried and abandoned. **Actively look for these** — they are among the most valuable graph entries because they prevent re-treading failed paths. Scan the commit sequence for these patterns:
- A commit adds X, a later commit removes or replaces X (e.g., "add parade ground bg" → "swap parade for road")
- A commit sets a value/count, a later commit reverts it (e.g., "10 Figma exports" → "revert to 3 per scene")
- A commit implements a feature, a later commit simplifies it (e.g., "two-stroke X" → "single diagonal strikethrough")
- The narrative mentions "tried X then pivoted to Y" or "started with X then switched to Y"

Each of these is a dead-end entity. Walk the commit list chronologically and check for superseded work — don't just rely on the narrative you wrote. If in doubt, write the dead-end; false positives are cheaper than lost knowledge.
```yaml
  {slug}:
    type: dead-end
    domain: development
    title: "{What was tried}"
    project: "{project name}"
    date: "{target_date}"
    daily_note: "[[{target_date}]]"
    tried: "{the approach}"
    failed_because: "{why it didn't work}"
    replaced_by: "{what worked instead, if known}"
```

### Project states (type: project-state)
For each project that had meaningful work. If a project-state already exists in `knowledge/graph-projects.yml` AND the target date is newer than its `last_worked` date, UPDATE it in place (Edit the existing entry). If the existing state has a newer `last_worked` date (backfill scenario), do NOT overwrite it — the newer state is more current. If no state exists, create it in `knowledge/graph-projects.yml`:
```yaml
  state-{project-slug}:
    type: project-state
    domain: projects
    project: "{Project Name}"
    last_worked: "{target_date}"
    status: "{1-2 sentence summary of where things stand}"
    next_step: "{what would naturally come next}"
    context_to_restore: "{key details needed to resume efficiently}"
```

After adding entities, update the relevant count in `knowledge/graph-index.yml`. **Compute the count** by counting actual entity keys under `entities:` in each subgraph file — do not increment mentally. For development, count entities in `graph-dev.yml`. For projects, count entities in `graph-projects.yml`. Get it right the first time.

### Structural relations (write to `knowledge/graph-index.yml`)
After writing or updating entities, refresh `relations:` in `knowledge/graph-index.yml` opportunistically:

- Every entity with a `project` field and a matching `state-{project-slug}` entity gets a `belongs-to` relation
- Dead-ends whose replacement clearly maps to another tracked entity get a `replaced-by` relation
- Entities created on the same `project` + `date` get `same-session` relations
- Project-state -> tool dependencies get `uses` relations when a tracked tool clearly belongs to that project

Rules:
- Relations are directional: `from` -> `to` with one of the fixed verbs in `relation_verbs:`
- `from` and `to` must be entity slugs that actually exist in the split graph
- Deduplicate on `from + verb + to`
- Missing relations are acceptable; invented relations are not
- Keep the relations section lean and readable

### Investigation entities (rla-investigation domain)
When commits in rla-story-dev or rla-story-dev-clean touch entity dossiers, media ingestion, or evidence analysis, consider writing `person`, `organization`, or `timeline-event` entities. These capture investigation context that helps future sessions understand the evidentiary landscape:
```yaml
  {slug}:
    type: person | organization | timeline-event
    domain: rla-investigation
    title: "{Name or event description}"
    date: "{target_date}"
    daily_note: "[[{target_date}]]"
    summary: "{what was learned or added}"
    sources: ["{batch or dossier reference}"]
```

Only write these when the commit adds substantive intelligence (new connections, timeline events, cross-referenced sources) — not for routine registry updates or OCR processing alone.

### When NOT to write to the graph
- Routine content additions (adding a report, updating docs)
- Simple config or dependency changes
- Work where the commit message is the full story and there's no deeper learning
- Anything that wouldn't help future-you solve a problem or restore context

## 10. Feature tracking (L0)

After grouping work units and writing them to the daily note + knowledge graph, persist them as feature records. This is the levels system's ground truth — every commit attributed to a feature within a project.

### 10a. Load existing feature records

For each repo that had commits:
1. Check if `activity/features/{repo-slug}/` exists. If not, create the directory.
2. Read all existing `.yml` feature records in that directory (glob `activity/features/{repo-slug}/*.yml`).
3. Read `activity/features/{repo-slug}/_index.yml` if it exists.

The repo slug is the manifest filename (e.g., `rla-story-dev-clean` from `repos/rla-story-dev-clean.yml`). For the brain repo itself, use `brain`.

### 10b. Map work units to features

For each work unit from step 4:

**Explicit tags take priority:** If any commit message contains `[feature-name]` (square bracket tag), use that as the feature slug. Set `inference_confidence: 1.0`.

**Otherwise, semantic inference:** With all existing feature records and today's commit messages + diffs loaded, reason about attribution:
- Does this work unit extend an existing feature? (Same project, related files, related functionality)
- Is this a new feature? (New functionality, new component, new initiative)
- Could two work units actually be the same feature? (Same underlying component, different commits)

**Granularity rule — prefer splitting over lumping.** A feature should be a single shippable component, not an umbrella for an entire initiative. Apply these decomposition tests:
- **Different files test:** If commits touch different primary files (different skill definitions, different agents, different UI components), they are likely different features even if they share a theme.
- **Independent shipping test:** Could this component be marked "shipped" independently of the others? If yes, it's its own feature.
- **Initiative vs feature test:** If the grouping would contain 5+ commits touching 3+ distinct subsystems, it's probably an initiative containing multiple features, not a single feature. Use the `initiative:` field to group them — don't collapse into one record.

Bad: "Levels System Implementation" (13 commits, 30 files, 11 distinct subsystems → this is an initiative, not a feature)
Good: "Adversarial Tribunal" (1 commit, 3 related files, one shippable component)
Good: "Dashterm Levels Views" (1 commit, 2 files, one UI addition)

Generate a feature slug: lowercase, hyphenated, descriptive (e.g., `dashterm-notes-tab`, `mortality-explorer-chart`, `career-landing-page`). Set `inference_confidence` between 0.5 and 0.95 based on how clear the attribution is.

### 10c. Write feature records

For each feature (new or updated):

**New feature — create `activity/features/{repo-slug}/{feature-slug}.yml`:**
```yaml
feature: {feature-slug}
project: {repo-slug}
display_name: "{Human-readable Feature Name}"
status: wip
created: {target_date}
updated: {target_date}
initiative: {initiative-slug or null}
inference_confidence: {0.5-1.0}
commits:
  - hash: {short_hash}
    date: {target_date}
    message: "{commit message}"
    files_touched: {n}
    classification: {feature|fix|refactor|exploration|infrastructure|content}
learnings: []
related_positions: []
applied_taste_positions: []
cross_repo: []
tags: [{relevant, tags}]
```

**Existing feature — update with Edit:**
- Append new commits to the `commits:` array
- Update `updated:` date
- Update `status:` if still `wip`
- Do NOT overwrite `learnings`, `related_positions`, `applied_taste_positions`, `cross_repo` — those are populated by other skills

### 10d. APPLIED detection (semantic)

Load position notes eligible for APPLIED detection:
1. All positions with `classification: taste` AND `stage: operationalized` (taste positions — highest priority)
2. All positions with `stage: held` AND `confidence: high` or `confidence: convicted`

If no eligible positions exist, skip this step.

For group (1) — operationalized taste positions:
1. Read its `## Thesis` section (the full thesis text)
2. For each feature that had commits today, read the feature's commit diffs (already loaded from step 3)
3. Make a semantic judgment: "Does this feature's work embody this taste position?"
4. If yes, write an APPLIED event to `knowledge/operational-ledger.jsonl`. **Use the Edit tool** to append the JSON line after the last line of the file:

```json
{"timestamp":"{ISO8601}","verb":"APPLIED","source":"activity/features/{repo}/{feature}.yml","target":"notes/positions/{taste-position}.md","target_type":"position","reasoning":"{how the work embodies the taste position}","confidence":{0.6-0.9},"inference_mode":"sync-applied-detection"}
```

For group (2) — held positions with high/convicted confidence:
1. Read its `## Thesis` section
2. For each feature that had commits today, read the feature's commit diffs
3. Make a semantic judgment: "Does this feature's work clearly reflect acting on this belief?"
4. If yes, write an APPLIED event with confidence floor at 0.65 (slightly higher than operationalized — held positions have more ambiguity). **Use the Edit tool** to append the JSON line after the last line of `knowledge/operational-ledger.jsonl`:

```json
{"timestamp":"{ISO8601}","verb":"APPLIED","source":"activity/features/{repo}/{feature}.yml","target":"notes/positions/{position}.md","target_type":"position","reasoning":"{how the work reflects this belief}","confidence":{0.65-0.9},"inference_mode":"sync-applied-held-high"}
```

Also append to the feature record's `applied_taste_positions:` array:
```yaml
applied_taste_positions:
  - position: "{taste-position-slug}"
    date: {target_date}
    reasoning: "{brief}"
```

### 10e. Write _index.yml

After processing all features for a repo, write or update `activity/features/{repo-slug}/_index.yml`:

```yaml
repo: {repo-slug}
last_synced: {target_date}
features:
  - slug: {feature-slug}
    display_name: "{Feature Name}"
    status: {status}
    initiative: {initiative or null}
    commit_count: {total commits across all time}
    date_range: [{earliest_date}, {latest_date}]
    inference_confidence: {confidence}
initiatives:
  - slug: {initiative-slug}
    display_name: "{Initiative Name}"
    feature_count: {n}
    status: active
```

Compute all values from the actual feature records — don't guess.

### 10f. Cross-repo reconciliation

After ALL repos have been processed, if 2+ repos had commits:
1. Load all `_index.yml` files simultaneously
2. Use semantic matching to find features that span repos (e.g., a brain skill change and a downstream repo using it)
3. If found, add `cross_repo: [{repo: other-repo, feature: feature-slug}]` to both feature records
4. This is rare — only flag genuine cross-repo features, not coincidental same-day work

## 10g. Cross-repo signal detection

After cross-repo reconciliation and before the report, detect brain-relevant signals from seeded repos. This step uses `brainlib/repo_signals.py`.

For each repo that had commits (excluding brain itself):

1. **Structural detection** — run the Python module from the brain repo root. Construct a JSON array of commits (each with `hash` and `message` keys) and pass it to the detection function:

```bash
python3 -c "
import json, sys, yaml
sys.path.insert(0, '.')
from brainlib.repo_signals import detect_structural_signals, evaluate_propagation_policy, append_to_ledger, validate_signal

with open('.claude/control-plane.yml') as f:
    policy = yaml.safe_load(f).get('repo-signals', {}).get('propagation_policy', {})

commits = $COMMITS_JSON
signals = detect_structural_signals('$REPO_SLUG', commits, repo_path='$REPO_PATH')
for sig in signals:
    sig['propagation_status'] = evaluate_propagation_policy(sig, policy)
    ok, err = validate_signal(sig)
    if ok:
        append_to_ledger(sig)
        print(json.dumps(sig))
    else:
        print(f'SKIP: {err}', file=sys.stderr)
"
```

   Where `$COMMITS_JSON` is the actual JSON array you construct from step 3 data (e.g., `[{"hash":"abc1234","message":"feat: add new API"}]`), `$REPO_SLUG` is the repo manifest filename, and `$REPO_PATH` is the absolute path to the repo. **Run this from the brain repo root** (`$BRAIN_VAULT_PATH`).

2. **Semantic detection** — after structural, review the work units yourself for dependency shifts and architecture changes:
   - `dependency-shift`: new major dependency, framework migration, or tool change (confidence > 0.7)
   - `architecture-shift`: significant structural change, new directory layer, module split (confidence > 0.7)
   - For each semantic signal found, **use the Edit tool** to append a JSON line to `knowledge/repo-signals.jsonl`:
   ```json
   {"timestamp":"{ISO8601}","repo":"{repo_slug}","category":"dependency-shift","source_commits":["{hash1}"],"summary":"{what changed}","detail":"{why it matters to brain}","confidence":{0.7-0.9},"propagation_status":"pending","detected_by":"sync"}
   ```

3. **Policy note** — structural signals are auto-acknowledged by the Python module via control-plane.yml. Semantic signals default to `"pending"` (require human review).

**Graceful failure:** If the Python call fails, log the error in the report and continue. Signal detection is additive — never blocking.

**Brain exclusion:** Brain's own commits NEVER produce signals. Skip `repo == "brain"`.

## 11. Report

```
Sync for {target_date}:
- Repos scanned: {n} ({list})
- Commits found: {n} total
- Diffs read: {n} (of {total} — selective)
- Work units synthesized: {n}
  - {Project Name}: {brief description}
- Knowledge graph:
  - Solutions written: {n}
  - Dead ends recorded: {n}
  - Project states updated: {n}
- Feature tracking:
  - Features created: {n}
  - Features updated: {n}
  - APPLIED events: {n}
  - Cross-repo links: {n}
- Repo signals detected: {n}
  - {category}: {summary} (confidence: {conf}, status: {status})
- Daily note: notes/daily/{target_date}.md
```

If no commits found: `Sync for {target_date}: no commits found across {n} repos.`

## 12. Update active-context memory

After writing the daily note and knowledge graph, update the session memory file at `~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/active-context.md`:

1. Read the current file
2. Update the **Active threads** section — replace entries for repos that had commits today with their current state (what was worked on, what's next). Remove threads that are clearly done.
3. Update the **Recent transitions** section — note any significant state changes (strategic shifts, phase changes, new decisions)
4. Update the **Last updated** date to the target date
5. Leave **Parked** and **Known debt** sections unchanged (those are manually managed)
