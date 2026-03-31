---
name: bridge
description: Check belief-action alignment — compare positions against operational activity (git commits, project state) to detect misalignment.
context: fork
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(wc *), Bash(git -C*), Bash(git log*), Agent, AskUserQuestion
argument-hint: "[optional: specific position slug]"
dashterm: true
timeout: 0
effort: high
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Positions: !`ls notes/positions/ 2>/dev/null | head -50`
Repos: !`ls repos/*.yml 2>/dev/null`
Graph projects: !`head -5 knowledge/graph-projects.yml 2>/dev/null`
Ledger size: !`wc -l < knowledge/epistemic-ledger.jsonl 2>/dev/null || echo 0`

# /bridge — Belief-Action Alignment Engine

Deterministic, rule-based engine that compares held positions against operational activity in linked projects. Detects when beliefs and actions diverge.

## Central Design Principle

> Bridge events are rule-based, not LLM-interpreted. The rules are explicit and deterministic — no judgment calls, no subjective classification. If the rule fires, the event emits.

## Phase 0: Load context

1. Read `knowledge/graph-index.yml` to understand subgraph layout
2. Read `knowledge/graph-projects.yml` for `last_worked` dates and project states
3. Read all `repos/*.yml` manifests for repo paths
4. Read `knowledge/project-activity-index.yml` for historical project activity baselines
5. Generate a `run_id`: `bridge-{today's date}`

## Phase 1: Build position-project map

For each position file in `notes/positions/`:
1. Read frontmatter only (fast scan)
2. Extract `created:` date (position age matters for rule evaluation)
3. Extract linkable project references from:
   - `area:` field → look for matching area note → check its `## Active Projects`
   - Direct `[[project-slug]]` wikilinks in body
   - `derived_predictions:` → `repo:` field → match to `repos/*.yml`
4. For each linked project, resolve the repo manifest name and repo path via `repos/*.yml` → `path:` field
5. Skip positions with no project links (most career/personal positions — this is expected)
6. **Claim grounding check:** For each position, scan its `## Evidence For` and `## Evidence Against` sections for claim references (`[[*-clm-*]]`). If found, read those claim notes and tally:
   - `endorsed_claims`: count of linked claims with `endorsed: yes`
   - `unendorsed_claims`: count of linked claims with `endorsed: null` or `partial`
   - `challenged_claims`: count of linked claims with `endorsed: challenged`

If `$ARGUMENTS` specifies a position slug, process only that position.

**Output:** A map of `{position_file → [{project_name, repo_name, repo_path, position_status, position_confidence, position_created, endorsed_claims, unendorsed_claims, challenged_claims}]}`

## Phase 2: Measure activity

For each (position, project) pair:

### 2a. Pre-compute commit counts per repo (once)

For each unique repo path discovered in Phase 1 (primary repos + evidence repos):
1. Check accessibility: `test -d {repo_path}`
   - If not mounted/accessible → log warning, mark as inaccessible
2. Determine **repo age** (days since first commit):
   ```bash
   git -C {repo_path} log --reverse --format="%ai" -1 2>/dev/null
   ```
3. Count 14-day commits:
   ```bash
   git -C {repo_path} log --oneline --after="{14_days_ago}T00:00:00" 2>/dev/null | wc -l
   ```
4. Count 30-day commits:
   ```bash
   git -C {repo_path} log --oneline --after="{30_days_ago}T00:00:00" 2>/dev/null | wc -l
   ```

Store as: `repo_counts = {repo_path: {age_days, commits_14d, commits_30d}}`

This runs 3 git commands per unique repo (not per position-repo pair). At 15 repos = 45 git calls, regardless of position count.

### 2a-bis. Evidence repo aggregation (from pre-computed counts)

For each (position, project) pair:
1. Look up the primary repo's pre-computed counts from `repo_counts`
2. Set `primary_14d = repo_counts[repo_path].commits_14d`
3. Set `primary_30d = repo_counts[repo_path].commits_30d`
4. Look up the repo manifest (from `repos/{repo_name}.yml`)
5. Check the manifest for `bridges_all_domains: true`
   - If the field is absent or not `true` → do **not** aggregate anything; the effective commit counts remain the primary repo counts
   - If `bridges_all_domains: true` is present → treat this repo as a bridge hub and aggregate across its declared `evidence_repos`
6. When aggregation is active:
   a. For each evidence repo, look up its pre-computed counts (already in `repo_counts` if accessible)
   b. Sum evidence contributions from the lookup (no new git calls)
7. Sum the counts deterministically:
    - `evidence_contribution_14d = sum(evidence_repo_14d counts)`
    - `evidence_contribution_30d = sum(evidence_repo_30d counts)`
    - `effective_14d = primary_14d + evidence_contribution_14d`
    - `effective_30d = primary_30d + evidence_contribution_30d`
8. Store a transparent breakdown for the report:
    - primary repo count
    - per-evidence-repo counts
    - total evidence-only contribution
    - effective totals used for indirect / false-negative handling
9. **Critical:** Keep both `primary_*` and `effective_*` as first-class values. Use `primary_*` for direct `ALIGNS_WITH_ACTION`. Use `effective_*` only to suppress false negatives and to emit operational-only indirect classes.
10. **Critical:** Keep the existing effective window calculation tied to the **primary repo age** from step 2a. Do not use evidence repo ages to lengthen or shorten the window.

### 2b. Historical activity lookup
14. Look up the **repo short name** (from `repos/*.yml` filename, e.g. `career`, `predictive-history`)
15. Search `project-activity-index.yml` for all projects whose `repos:` list includes matching repo names (story-dev, story-dev-clean, brain, etc.)
16. For matched projects, calculate:
   - **Total historical items** in the last 30 days of indexed activity (by checking `weekly_activity` entries)
   - **Last active week** from the index
   - This provides pre-vault-era context for repos that are young or recently split off

### 2c. Cross-repo predecessor check
17. If the linked repo is **younger than 30 days** (from step 2), also check the activity index for projects in **predecessor repos**. The predecessor mapping is:
   - `career` → check `story-dev`, `story-dev-clean` (career work may have lived there)
   - `predictive-history` → check `story-dev` (PH was extracted from story-dev)
   - `apollo` → no predecessor (new domain)
   - `aron-heroux-legal` → check `story-dev` (legal work originated there)
   - Other repos → no predecessor assumed
18. For predecessor matches, note the related project names and their last active dates — this is **context for the report only**, not used to change rule firing.

### 2d. Standard checks
19. Check `graph-projects.yml` for `last_worked` date on matching project entity
20. Check if project note has `parked_reason:` set (indicates intentionally paused)

## Phase 3: Apply rules

Three deterministic rules. Each fires independently per (position, project) pair.

**Critical: effective window calculation.** For rules that use time windows (14 days, 30 days), the **effective window** is the minimum of:
- The rule's standard window (14 or 30 days)
- The repo age (days since first commit)
- The position age (days since `created:` date)

This prevents misleading signals like "1 commit in 30 days" when the repo or position is 3 days old. The reasoning template must report the effective window, not the standard window.

For rule evaluation, keep both views visible:
- `primary_14d` / `primary_30d`: the primary repo count for the effective window
- `effective_14d` / `effective_30d`: the primary repo count plus accessible `evidence_repos` when `bridges_all_domains: true`, otherwise equal to the primary count
- `aggregation_active`: whether evidence-repo aggregation is active for this pair
- `evidence_contribution_14d` / `evidence_contribution_30d`: how much of the effective count came from other repos

### Rule 1: UNTESTED_IN_ACTION
**Condition:** Position confidence >= medium AND linked project has ≤2 **primary repo** commits in the effective 14-day window AND project is NOT parked
**Verb:** `UNTESTED_IN_ACTION`
**Short-window handling:** If effective window < 7 days, the event still fires but with `"observation_window"` field set to the effective window in days. Downstream consumers (recommendations, digest) should discount short-window events. The reasoning template must honestly report the effective window.
**Reasoning template:** "Position '{title}' at {confidence} confidence has minimal direct activity ({primary_14d} primary repo commits) in linked project '{project}' over {effective_window} days. Belief held but not tested through action."

### Rule 2: ALIGNS_WITH_ACTION
**Condition:** Position status = exploring AND `primary_14d >= 5`
**Verb:** `ALIGNS_WITH_ACTION`
**Emit only once per position.** Check the ledger for existing ALIGNS_WITH_ACTION events with the same target. If one already exists (from any prior bridge run), skip — the alignment is already recorded. This prevents repetitive noise each cycle.
**Reasoning template:** "Position '{title}' at exploring status shows direct investigation — {primary_14d} primary repo commits in linked project '{project}' over {effective_window} days."

### Rule 2b: INDIRECT_ALIGNS
**Condition:** Position status = exploring AND `primary_14d < 5` AND `effective_14d >= 5` AND the threshold is satisfied by evidence-repo contribution and/or a domain marked as indirectly fed in operator state
**Verb:** `INDIRECT_ALIGNS`
**Operational-only:** Include it in the bridge report and daily note, but do **not** write it to `knowledge/epistemic-ledger.jsonl`, and do **not** update position `## Evolution`.
**Reasoning template:** "Position '{title}' is being fed indirectly — {primary_14d} primary repo commits plus {evidence_contribution_14d} evidence-repo commits ({effective_14d} effective total) over {effective_window} days. Domain activity exists, but this exact thesis is not yet directly tested in the primary repo."

### Rule 3: MISALIGNED_WITH_ACTION
**Condition:** Position confidence >= high AND linked project has ≤2 **primary repo** commits in effective 30-day window OR project has `parked_reason:` set
**Verb:** `MISALIGNED_WITH_ACTION`
**Short-window handling:** If effective window < 14 days, the event still fires but with `"observation_window"` field set to the effective window in days. Downstream consumers should discount short-window events.
**Reasoning template:** "Position '{title}' held at {confidence} confidence but linked project '{project}' is stalled ({primary_30d} primary repo commits in {effective_window} days) or parked. High-conviction belief not reflected in operational priority."

**Edge cases:**
- Multiple positions on same project → process each independently
- Position links to multiple projects → evaluate each pair, fire rule if ANY project triggers
- Parked projects → only MISALIGNED fires (for high-confidence positions), UNTESTED skips parked
- Young repos/positions → events still fire but include `observation_window` field; downstream consumers discount short windows

## Phase 3.1: Intent Verification Checkpoint

Before emitting UNTESTED_IN_ACTION or MISALIGNED_WITH_ACTION events, check if intent verification is needed.

**Trigger condition:** The event fires AND the position's primary repo has ≤5 commits in the effective window AND the position has `confidence >= medium`.

**Skip condition (clear signals — no checkpoint needed):**
- `primary_14d >= 50` (overwhelming direct evidence)
- `parked_reason:` is set on the project (intentionally paused — MISALIGNED still fires but no ambiguity)
- Position confidence is `exploring` (not yet committed enough to verify)

**Interactive mode behavior:**

When trigger fires, use AskUserQuestion:

```
Position '{title}' shows {primary_14d} commits in {repo} over {effective_window} days.
Is this thesis being tested indirectly through other work, intentionally parked, or genuinely untested?
```

Response handling:
- **"Tested indirectly"** → Reclassify to INDIRECT_ALIGNS (operational-only, not epistemic). Do NOT write to ledger or update Evolution. Apply this answer to all positions in the same area for the remainder of this bridge run (don't re-ask).
- **"Intentionally parked"** → Skip the event entirely. No emission.
- **"Genuinely untested"** → Emit UNTESTED_IN_ACTION (or MISALIGNED_WITH_ACTION) as normal.

**Automation/unattended mode behavior:**

If running inside `/daily-cycle` (unattended), skip the AskUserQuestion. Instead:
1. Emit the event as normal (UNTESTED or MISALIGNED)
2. Add `"needs_intent_verification": true` to the event JSON
3. These flagged events are surfaced during the next interactive `/boot` for user confirmation

**Answer propagation:** If the user answers "tested indirectly" for position A, apply that answer to all other positions in the same `area:` during this bridge run. Do not re-ask for each position individually.

## Phase 3.5: Operator-state filtering

1. Read `~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/operator-state.md` (if it exists)
2. If the file exists and contains a `## Domain–Activity Map` section:
   - For each UNTESTED_IN_ACTION or MISALIGNED_WITH_ACTION event about to emit:
     a. Identify the position's domain from its `area:` field or tags
     b. Look up that domain in the Domain–Activity Map
     c. If the map says the domain is "fed indirectly":
        - Reclassify MISALIGNED_WITH_ACTION → **INDIRECT** (informational, not alarming)
        - Reclassify UNTESTED_IN_ACTION → **INDIRECT_UNTESTED** (lower priority)
        - Include the feeding projects listed in the map in the event metadata
     d. If the map shows the domain has direct activity or is not mentioned:
        - Keep the original verb unchanged
   - For exploring positions with `primary_14d < 5` but `effective_14d >= 5`:
     a. If aggregation is active and/or the map says the domain is "fed indirectly":
        - Emit **INDIRECT_ALIGNS** instead of ALIGNS_WITH_ACTION
        - Include the feeding projects and evidence breakdown in the metadata
     b. If the primary repo alone clears the threshold:
        - Keep **ALIGNS_WITH_ACTION** as a direct event
3. If the file does not exist → keep direct verbs unchanged, but aggregated-only positive cases still remain operational-only `INDIRECT_ALIGNS`, not direct ledger events

**Critical:** INDIRECT, INDIRECT_UNTESTED, and INDIRECT_ALIGNS are bridge-operational only. They appear in the bridge report and daily note but are **NOT** written to `knowledge/epistemic-ledger.jsonl`. They do not update position `## Evolution` sections. This keeps the epistemic layer clean.

## Phase 4: Emit events

For each rule that fires:

1. Append direct epistemic verbs to `knowledge/epistemic-ledger.jsonl` (the validation hook will enforce schema and dedup):
   ```json
   {
     "timestamp": "ISO 8601 (now)",
     "verb": "{UNTESTED_IN_ACTION|ALIGNS_WITH_ACTION|MISALIGNED_WITH_ACTION}",
     "source": "notes/positions/{position-file}",
     "target": "notes/positions/{position-file}",
     "target_type": "position",
     "reasoning": "{from template above}",
     "confidence": 1.0,
     "inference_mode": "rule",
     "source_tier": "T1-primary",
     "run_id": "bridge-{today}",
     "observation_window": {effective_window_in_days}
   }
   ```
   Notes:
   - confidence is always 1.0 for rule-based events — the rule either fires or it doesn't.
   - `observation_window` is the effective window in days (min of standard window, repo age, position age). Downstream consumers should treat short windows (< 7 days for UNTESTED, < 14 days for MISALIGNED) as low-weight signals.

3. If validated, update position's `## Evolution` section — **only for UNTESTED_IN_ACTION and MISALIGNED_WITH_ACTION** (the actionable direct verbs). Do NOT update Evolution for ALIGNS_WITH_ACTION, INDIRECT, INDIRECT_UNTESTED, or INDIRECT_ALIGNS:
   ```
   - **{date}** — {VERB}: {one-line summary from reasoning} (via /bridge, rule-based)
   ```

## Phase 5: Check for sustained patterns (future escalation)

**Note:** This step only becomes meaningful after 2+ bridge cycles.

If a position has `UNTESTED_IN_ACTION` events from 2+ different bridge runs (check ledger for `inference_mode: rule` events with same target and verb), flag for DECAYS consideration in the report. Do NOT emit DECAYS automatically — flag it for the next `/digest` cycle to evaluate.

## Phase 6: Report

```
Bridge check for {date}:

Positions scanned: {N}
Positions with project links: {N}
Pairs evaluated: {N}
Repos inaccessible: {N} (list if any)
Short-window events: {N} (list — observation_window < standard threshold, downstream should discount)

Repo context:
  Standard repo:
    {repo_name}: {commit_count} commits, repo age {N} days
      Historical activity (from index): {list of related projects with last_active dates}

  Aggregated repo (only when `bridges_all_domains: true`):
    {repo_name}: {effective_commit_count} effective commits used for rules ({primary_commit_count} primary + {evidence_commit_count} across {M} evidence repos), repo age {N} days
      Evidence breakdown: {repo_a}: {n_a}, {repo_b}: {n_b}, ...
      Historical activity (from index): {list of related projects with last_active dates}

Events:
  {VERB} — {position title} ↔ {project name} (effective window: {N} days)
    {reasoning}

  INDIRECT (operational-only):
  {INDIRECT|INDIRECT_UNTESTED|INDIRECT_ALIGNS} — {position title} ↔ {project name} (fed by: {feeding projects})
    {reasoning}

  Summary:
    No direct rule-fired belief-action gaps among linked positions after evidence aggregation.
    Indirect/domain-fed activity may still be present and must be described as indirect, not as direct thesis testing.

Claim grounding:
  Positions with claim-backed evidence: {N}
    Fully endorsed: {N} (all linked claims endorsed)
    Partially grounded: {N} (mix of endorsed and unendorsed claims)
    Ungrounded: {N} (evidence cites only unendorsed claims)
  {For positions with unendorsed claim evidence at high confidence:}
  Warning: '{title}' at {confidence} confidence — evidence includes {N} unendorsed claims. Run /digest to triage.

Sustained flags: {list any positions with 2+ UNTESTED cycles, or "none yet"}
```

## Design Constraints

- **No LLM interpretation.** Rules are if/then. No "seems like" or "probably."
- **No transitive links.** Position must directly reference a project or repo. Don't chain through areas→projects→repos unless the area note explicitly lists projects.
- **Skip gracefully.** Most positions won't have project links. That's fine — report the count but don't treat it as a problem.
- **Idempotent within a day.** The run_id is `bridge-{date}`, so the dedup hook prevents firing twice on the same day for the same (source, target, verb).
- **Effective windows prevent misleading framing.** Never report a time window longer than the repo or position has existed. A 3-day-old position gets `"observation_window": 3`, not 30. Events still fire — they just carry honest metadata.
- **`observation_window` enables downstream discounting.** Short-window events are real signals but low-weight. Recommendations and digest should treat `observation_window < 7` as preliminary. The field is always present on bridge events.
- **Activity index is context, not override.** Historical activity from the index enriches the report but does not change rule firing. Rules use git commit counts only. The index helps the human interpret whether low activity is a new pattern or continuation of historical behavior.
- **Evidence repo aggregation is opt-in.** Only aggregate across `evidence_repos` when the primary repo manifest explicitly sets `bridges_all_domains: true`. Repos without that flag behave exactly as before.
- **Aggregation stays auditable.** When aggregation is active, the report must show the primary count, each contributing evidence repo count, skipped evidence repos (if any), and the aggregated totals actually used for rule evaluation.
- **INDIRECT verbs are bridge-operational only.** `INDIRECT`, `INDIRECT_UNTESTED`, and `INDIRECT_ALIGNS` are never written to `knowledge/epistemic-ledger.jsonl`. They appear only in the bridge report and daily note. This keeps the epistemic layer clean of operational assessments.
- **Operator-state filtering is additive.** If `operator-state.md` does not exist, bridge degrades to pre-operator behavior — no filtering, no INDIRECT verbs, identical to previous runs.
