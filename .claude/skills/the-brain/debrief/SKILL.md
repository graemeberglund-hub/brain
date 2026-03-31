---
name: debrief
description: Extract process insights, agent patterns, and learnings from a day's commits. Deeper than sync — reads full diffs and analyzes the shape of work. Use when user wants to reflect on how work happened, not just what.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git -C *), Bash(date *), Bash(ls *), Bash(cat *), Bash(wc *)
argument-hint: "[optional repo-name] [optional date YYYY-MM-DD]"
context: fork
dashterm: true
effort: medium
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Registered repos: !`ls repos/*.yml 2>/dev/null | xargs -I{} basename {} .yml || echo "none"`

# /debrief — Process Insight Extraction from Git Commits

You are analyzing HOW work happened, not WHAT was accomplished. `/sync` already captures the what. This skill reads the full commit sequence as a process artifact — understanding routes taken, agent collaboration patterns, reversals, churn, and learnings.

## 1. Parse arguments

- If `input` contains a repo name (matching a manifest in `repos/` or "brain"), scope to that single repo
- If `input` contains a date (YYYY-MM-DD), use that date
- If no repo specified, run for ALL repos that had commits on the target date
- If no date specified, use today

## 2. Discover repos

Read manifests in `repos/*.yml` for paths. Include brain itself (`$BRAIN_VAULT_PATH`). Skip repos whose path doesn't exist.

## 3. For each target repo: Full commit read

```bash
git -C {repo_path} log --no-merges --format="%H|%ai|%s" --after="{target_date}T00:00:00" --before="{next_date}T00:00:00" --all
```

If no commits, skip this repo.

**Read ALL diffs** (not selective like sync):
```bash
git -C {repo_path} diff {hash}^..{hash} --stat
git -C {repo_path} diff {hash}^..{hash}
```

For very large diffs (1000+ lines), read `--stat` first and focus on the most structurally interesting files. Skip generated/output files (minified JS, compiled HTML in output dirs, lock files).

Also get the commit sequence with timestamps to understand pacing:
```bash
git -C {repo_path} log --no-merges --format="%h|%ai|%s" --after="{target_date}T00:00:00" --before="{next_date}T00:00:00" --all --reverse
```

The `--reverse` flag gives chronological order, which is essential for understanding the route.

## 4. Read recent debriefs for cross-session context

Check for the last 3-5 debriefs for this repo:
```bash
ls knowledge/debriefs/*-{repo_slug}.md 2>/dev/null | tail -5
```

Read them if they exist. This enables cross-session pattern detection:
- Files that churn across multiple sessions
- Recurring dead ends or approach oscillation
- Evolving agent collaboration style
- Scope drift patterns over time

## 4b. Check existing patterns

Before analyzing this session, read `knowledge/graph-dev.yml` and filter for `type: pattern` entities whose `project:` field matches the repo being debriefed (or whose domain overlaps).

If relevant patterns exist, keep them in mind. During the analysis phases (Steps 5-7), actively check:
- Did this session **follow** a known pattern? (Note it — the pattern is validated)
- Did it **violate** a known pattern? (Note why — either the pattern was wrong or the context was different)
- Did it **discover a variant** of a known pattern? (Update the existing pattern in Step 8 instead of creating a new one)

This creates a feedback loop: past learnings inform future analysis.

## 5. Analyze the commit sequence

Read the diffs carefully and think about these dimensions:

### Route Analysis
- Was the path from start to finish direct or winding?
- How many pivots or direction changes?
- Could the end state have been reached in fewer steps? What would that shorter path have looked like?
- Were there commits that undid previous commits?
- Classify: `clean` (direct path), `winding` (some pivots but progressive), `exploratory` (many direction changes, outcome uncertain at start)

### Agent Collaboration Patterns
- What does the commit granularity suggest about the human-AI working mode?
  - Large commits with many files = agent ran with autonomy
  - Small sequential commits = tight feedback loop
  - Pattern of big commit → several fix-up commits = agent got the broad strokes but missed details
- Where did the agent likely help vs. where did the human likely intervene?
- Were there signs of the agent going off-track (reverts, simplifications after complexity)?
- What instructions might have produced a more direct route?

### Reversals & Dead Ends
- Identify any approach that was tried and then abandoned or replaced
- For each: what was tried, what replaced it, and what signal indicated the switch was needed
- Were any dead ends predictable in hindsight?
- Cross-reference with previous debriefs: is this a recurring pattern?

### File Churn
- Which files were modified in multiple commits?
- Is the churn structural (the file is a natural convergence point) or a signal (the abstraction is wrong, or the approach kept changing)?
- Cross-reference with previous debriefs: files that churn across sessions may need architectural attention

### Learnings
- Technical patterns discovered or confirmed
- Library/tool insights (things that work well, things that don't)
- Architectural decisions that emerged from the work (not pre-planned)
- Process insights: what worked about the approach, what would you do differently

### Scope Trace
- What appears to have been the intended scope at session start?
- What actually got done?
- Was the drift productive (natural expansion) or wasteful (lost focus)?

## 6. Check idempotency

Check if a debrief already exists for this repo + date:
```
knowledge/debriefs/{target_date}-{repo_slug}.md
```

If it exists, read it and check whether new commits have appeared since it was written. If no new commits, report "Debrief already exists for {repo} on {date}" and skip. If new commits exist, regenerate the full debrief (overwrite).

## 7. Write debrief file

Write to `knowledge/debriefs/{target_date}-{repo_slug}.md`:

```yaml
---
title: "Debrief: {Repo Name} — {target_date}"
type: debrief
repo: {repo_slug}
date: {target_date}
commits: {count}
route: clean | winding | exploratory
files_touched: {unique file count}
top_churn: ["{file1} ({n} commits)", "{file2} ({n} commits)"]
---

## Route Analysis

{2-4 paragraphs on how the session unfolded. Be specific — reference actual commits
and files. Describe the shape of the work: was it a straight line, a spiral, a tree
with branches? Where were the pivots?}

## Agent Collaboration

{2-3 paragraphs on the human-AI working pattern. What does the commit sequence reveal
about how the agent was used? Where did it excel, where did it struggle? What
instructions or approach might have been more efficient?}

## Reversals & Dead Ends

{Bullet list of specific reversals. If none, say "None detected — clean path."
For each: what was tried → what replaced it → the signal that triggered the switch.}

## File Churn

{Table or list of files touched in 2+ commits, with context on whether the churn
is structural or signals something. Cross-reference with previous debriefs if available.}

## Learnings

{Bullet list of durable insights. These should be things worth carrying forward —
not session-specific details. Each should be actionable or reference-worthy.
Mark any that are strong enough for graph persistence with [graph].}

## Scope Trace

{1-2 paragraphs. What was the apparent starting intent? What actually happened?
Was the drift productive?}
```

**Writing guidelines:**
- Be honest and specific. This is a private process document, not a status report.
- Reference actual commits, files, and code when making claims.
- Don't editorialize ("amazing progress") — describe what happened and what it means.
- If a shorter route existed, describe it concretely ("could have started from X instead of building Y first").
- Cross-session patterns are the highest-value insights. Surface them explicitly.

## 8. Link learnings to feature records (L1↔L0)

Before writing to the knowledge graph, link each learning to its parent feature:

1. **Generate learning IDs** for each learning in the debrief. Format: `L-{target_date}-{NNN}` (e.g., `L-2026-03-14-001`).
2. **Find the parent feature** by matching commits — the feature record in `activity/features/{repo-slug}/` whose `commits:` array contains the same hashes that produced this learning. Glob the directory and read feature records to match.
3. **Write back to feature records** — for each matched feature, append the learning ID to its `learnings:` array:
   ```yaml
   learnings:
     - id: L-2026-03-14-001
       date: 2026-03-14
       insight: "Two-pane editors need independent scroll containers"
       type: technical
       source_commits: [c1ae50c]
       persisted_to_graph: false
   ```
4. If no feature record exists for the commits (e.g., sync hasn't run yet), note this in the report but still generate the learning ID. The learning will be orphaned until `/sync` creates the feature record.

## 9. Write durable learnings to knowledge graph

For any learning marked `[graph]` in the debrief, write to `knowledge/graph-dev.yml` as a pattern entity. Update the learning's `persisted_to_graph: true` in the feature record.

**Recurrence check (do this first):** Before writing a new pattern, search `knowledge/graph-dev.yml` for existing patterns with the same project or similar insight text. If a substantially similar pattern already exists:

1. **Update the existing entity** instead of creating a duplicate:
   - Add or increment `recurrence_count`
   - Update `last_recurrence: "{target_date}"`
   - Append to `recurrence_dates: [...]`
   - Append the new learning ID to `supporting_learnings: [...]`
2. In the debrief report, note: "Recurring pattern: {title} (seen {N} times)"
3. If `recurrence_count` >= 3:
   - Add: "[consolidation candidate] — recurred enough to consider promotion to cross-cutting via `/consolidate`"
   - **Check `feeds_positions`**: If the pattern has linked positions, emit a REINFORCED event to `knowledge/operational-ledger.jsonl`. **Use the Edit tool** — read the file first, then append the JSON line after the last line:
     ```json
     {"timestamp":"{ISO8601}","verb":"REINFORCED","source":"knowledge/graph-dev.yml","target":"notes/positions/{position}.md","target_type":"position","reasoning":"Pattern '{title}' recurred {N} times, reinforcing linked position.","confidence":0.7,"inference_mode":"debrief-reinforced"}
     ```

**For genuinely new patterns**, write:

```yaml
  {slug}:
    type: pattern
    domain: development
    title: "{Descriptive pattern name}"
    project: "{project name}"
    date: "{target_date}"
    daily_note: "[[{target_date}]]"
    debrief: "knowledge/debriefs/{target_date}-{repo_slug}.md"
    insight: "{the pattern or learning, 1-3 sentences}"
    applies_when: "{when this is relevant}"
    supporting_learnings:
      - L-{target_date}-{NNN}
    feeds_positions: []
```

**Position linking:** After writing a new pattern, check if its insight relates to any existing position (read `notes/positions/` titles and theses). If a clear connection exists, add the position slug to `feeds_positions:` and add the pattern to the position note's `## Evidence For` section.

Update the entity count in `knowledge/graph-index.yml` after adding. Count actual entities in the file — don't increment mentally.

## 9b. Cross-repo implication flagging

After writing durable learnings to the graph (Step 9) and before the report:

For each learning marked `[graph]` in the debrief:

1. **Check cross-repo relevance** — does the learning's insight apply to other registered repos?
   - Read repo manifests in `repos/*.yml` for domain context (`key_directories`, `description`)
   - Check if any repo has `watches.receive` categories that match this insight type
   - Consider: would knowing this insight change how work is done in the other repo?

2. **Emit `pattern-discovered` signals** — for each cross-repo implication found, **use the Edit tool** to append a JSON line after the last line of `knowledge/repo-signals.jsonl`:
   ```json
   {"timestamp":"{ISO8601}","repo":"{source_repo}","category":"pattern-discovered","source_commits":["{hash1}"],"summary":"{learning title}","detail":"{insight} — may apply to: {target_repos}","confidence":{0.7-0.9},"propagation_status":"pending","detected_by":"debrief"}
   ```

3. **Be conservative** — only emit signals for insights with clear cross-repo applicability. If the learning is repo-specific (e.g., "this API endpoint needs rate limiting"), don't force a connection.

**Graceful failure:** If signal detection fails, skip and continue to report.

## 10. Report

```
Debrief for {target_date}:
- {repo_name}: {n} commits, route={route}
  - Reversals: {n}
  - Learnings: {n} ({m} persisted to graph, {k} linked to features)
  - REINFORCED events: {n}
  - Cross-repo implications: {n}
  - Top churn: {file} ({n} commits)
  [repeat per repo if multiple]
- Files written: {list of debrief paths}
```

If no commits found across any repo: `Debrief for {target_date}: no commits found.`
