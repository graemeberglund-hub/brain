---
name: digest
description: Run epistemic metabolism — process new intake against existing positions and questions, emit events to the ledger. Use when user wants to digest recent captures, or periodically to keep the knowledge system current.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(wc *), Bash(git diff*), Bash(git log*), Bash(python tools/retrieval*), Agent, AskUserQuestion
argument-hint: "[optional: specific note path or 'all']"
dashterm: true
timeout: 180
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

Positions (all): !`ls notes/positions/ 2>/dev/null | head -30`
Questions (classification: question): !`grep -l "classification: question" notes/positions/*.md 2>/dev/null | xargs -I{} basename {} | head -30`
Recent intake (last 5 commits): !`git diff --name-only HEAD~5 -- notes/inbox/ notes/references/ notes/conversations/ notes/concepts/ 2>/dev/null | grep '\.md$' | head -30`
Ledger size: !`wc -l < knowledge/epistemic-ledger.jsonl 2>/dev/null || echo 0`
Last digest candidates: !`tail -5 knowledge/event-candidates.jsonl 2>/dev/null || echo "(empty)"`

# /digest — Epistemic Metabolism Orchestrator

You are running a digest cycle for the brain vault's epistemic metabolism system. This processes new intake against existing positions and open questions, identifying epistemic events (supports, contradicts, challenges, extends, advances, etc.).

## Phase Mode Routing

Check `input` for `--phase` argument. If present, skip directly to that phase:

- `--phase prosecution` → Read `knowledge/digest-pairs.json` for candidate pairs and `knowledge/digest-run-id.txt` for run_id. Skip to **Phase 3** (prosecution only). Do NOT run defense or judge. Exit after writing candidates.
- `--phase defense` → Read `knowledge/digest-run-id.txt` for run_id. Skip to **Phase 3b** (defense only). Read prosecution events from `knowledge/event-candidates.jsonl`. Exit after writing defense assessments.
- `--phase judge` → Read `knowledge/digest-run-id.txt` for run_id. Skip to **Phase 4** (judge deliberation → promote → update notes → crystallize → DECAYS sweep). This is the full resolution phase.

**When running in phase mode:**
- Do NOT generate a new run_id — read from `knowledge/digest-run-id.txt`
- Do NOT clear `event-candidates.jsonl` — each phase appends to it
- Do NOT run phases outside your scope
- Report only on the phase you ran

**When running WITHOUT `--phase`** (interactive `/digest` or `/digest all`):
- Run the full pipeline below (Phase 0 through Phase 7) as before

---

## Phase 0: Generate run_id and clear staging

Generate a UUID for this digest run. This `run_id` will be included in every event emitted during this cycle for traceability. Use a simple approach:

```
run_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
```

**Clear `knowledge/event-candidates.jsonl`** before starting — write an empty file. This prevents stale candidates from a crashed prior run from contaminating this cycle. The clear happens here (not Phase 4) so that a mid-run crash leaves a clean staging area.

Pass this `run_id` to the inference engine in Phase 3.

## Pre-check: Triage before digest

If `notes/inbox/` has pending notes, warn the user:
> "Inbox has {N} notes. Run /triage first — digesting inbox notes that will be moved later breaks ledger references."

This is a warning, not a blocker. If the user says to proceed anyway, continue.

## Phase 1: Identify intake

Determine which notes to process:
- If the user provided a specific path in `$ARGUMENTS`, use just that note
- If `$ARGUMENTS` is "all", process all positions and questions against all intake
- Otherwise, use the "Recent intake" list from dynamic context above
- Filter out notes that are themselves positions (those are targets, not sources) — all epistemic notes (beliefs, questions, decisions, tastes) live in `notes/positions/` with `type: position` and a `classification` field

**Exception — explicit position input:** If the user explicitly passes position note paths as `$ARGUMENTS`, do NOT silently skip them. Instead:
1. Warn: "Input files are position notes (targets, not sources). Running in cross-position linkage mode."
2. Proceed with the positions as sources — treat them as intake that generates events on OTHER positions/questions
3. Use the position slug as the `independence_group` for all events (not the original source of the position's thesis)
4. Note in the Phase 7 report: "Cross-position linkage mode — all events share the same independence group. These are structural connections, not independent corroboration."

This mode is valid for: newly created positions that haven't been cross-linked yet, or when the user wants to explicitly map how a set of positions relates to the rest of the vault.

### Absorption-aware intake identification

After building the intake list, check `knowledge/absorption-log.jsonl` for any intake sources that have absorption metadata. For each intake note that matches an absorption-log entry:
- Note the `absorption_state` (`seen`, `shaping`, `committed`)
- If `committed` — this source already has position links. Prioritize it for cross-referencing (it may strengthen existing positions further).
- If `seen` — this source was consumed but the user hasn't expressed a view. Weight it normally but note the absorption state in the Phase 7 report.
- If `shaping` — this source is actively influencing thinking. Flag candidate pairs involving this source as higher priority.

This enrichment is informational — it does NOT change which notes are processed, only how they're prioritized in Phase 2 retrieval.

Read each intake note to confirm it has real content worth evaluating.

## Phase 2: Retrieval — code-based candidate pair finding

Retrieval is performed by the deterministic code engine (`tools/retrieval.py`), not inline LLM reasoning. This runs in <1 second, produces candidate pairs at ~88% precision (validated via autoresearch optimization — see `brain-skills-dev/autoresearch/`).

Run the retrieval script based on the mode determined in Phase 1:

```bash
# For "all" mode:
python tools/retrieval.py --all --json > /tmp/digest_pairs.json

# For recent intake (default):
python tools/retrieval.py --json > /tmp/digest_pairs.json

# For specific source:
python tools/retrieval.py --source "notes/references/some-note.md" --json > /tmp/digest_pairs.json
```

The script outputs a JSON array of candidate pairs:
```json
[
  {
    "source": "notes/references/some-note.md",
    "target": "notes/positions/some-position.md",
    "target_type": "position",
    "target_layer": "wedge",
    "score": 1.25,
    "relevance": "high",
    "retrieval_method": "code"
  }
]
```

Read the output JSON to get the candidate pairs for Phase 3.

**After code retrieval**, read the ledger (`knowledge/epistemic-ledger.jsonl`) to check for existing events on these pairs. Skip pairs that already have a recent event (same source + target within the last 7 days) to avoid duplicate processing.

**Note:** The code engine handles symbolic (tags, wikilinks, area), semantic (TF-IDF), and interaction effects. It does NOT do emergent-theme matching or LLM reasoning — those happen in prosecution (Phase 3). ~12% of code-retrieved pairs are superficial connections that prosecution should skip after reading both notes. This is by design — cheaper to over-retrieve and let prosecution filter than to under-retrieve and miss connections.

## Phase 3: Prosecution — inference engine evaluates pairs

**In `--phase prosecution` mode:** Read candidate pairs from `knowledge/digest-pairs.json` and run_id from `knowledge/digest-run-id.txt`. Do NOT run retrieval — pairs are already prepared by daily-cycle.

**In full mode:** Use the candidate pairs from Phase 2.

Spawn the **inference-engine** agent (prosecution) with:
1. The candidate pairs JSON (from file or Phase 2)
2. The `run_id` (from file or Phase 0)
3. Instructions to evaluate each pair, characterize the epistemic relationship, determine provenance, and write event candidates to `knowledge/event-candidates.jsonl`

The prosecution agent no longer does adversarial analysis — that's the defense's job. It focuses on finding genuine relationships and characterizing them accurately with provenance tracking.

**In `--phase prosecution` mode:** After writing candidates, report the count and exit. Do not proceed to defense.

## Phase 3b: Defense — devil's advocate attacks and hunts

**In `--phase defense` mode:** Read run_id from `knowledge/digest-run-id.txt`. Prosecution events are already in `knowledge/event-candidates.jsonl`.

**In `--phase defense` mode:** After writing assessments and hunt discoveries, report the tally and exit. Do not proceed to judge.

Spawn the **devil-advocate** agent (defense) with:
1. The `run_id` (from file or Phase 0)
2. Instructions to:
   - **Attack**: Read all prosecution events from `knowledge/event-candidates.jsonl`, assess each as CONFIRMED/OVERSTATED/REVERSED/IRRELEVANT, check citation accuracy and evidence independence
   - **Hunt**: Read each target position's thesis, search the vault for counter-evidence prosecution missed

The defense writes its assessments and hunt discoveries to `knowledge/event-candidates.jsonl` with `inference_mode: "devil-advocate"`.

This phase is **mandatory** and runs every cycle.

## Phase 4: Judge deliberation — weigh prosecution and defense

You (the orchestrator) are the judge. Read all events from `knowledge/event-candidates.jsonl` for this run_id. Separate prosecution events from defense assessments and hunt discoveries.

### 4a. Deliberation per prosecution event

For each prosecution event, find the matching defense assessment (if any):

| Prosecution | Defense Assessment | Judge Action |
|-------------|-------------------|--------------|
| SUPPORTS | CONFIRMED | Promote at stated confidence |
| SUPPORTS | OVERSTATED | Promote at confidence - 0.15 |
| SUPPORTS | REVERSED | Read both arguments carefully, decide. May promote as CHALLENGES instead. |
| SUPPORTS | IRRELEVANT | Do not promote |
| Any | No assessment | Promote at stated confidence (defense didn't reach it) |

For defense hunt discoveries (events with `hunt_discovery: true`):
- Read the source and target notes
- If the counter-evidence is genuine, promote as CHALLENGES or CONTRADICTS
- If it's a stretch, skip it

### 4b. Cascade checking

For any CONTRADICTS event being promoted:
1. Read the target position note — does it have a `parent:` field?
2. Check all other positions for `parent:` pointing to this position
3. If children exist, emit CASCADE_PRESSURE events to `knowledge/operational-ledger.jsonl`. **Use the Edit tool** — read the file first, then append each JSON line after the last line:
   ```json
   {"timestamp":"{ISO8601}","verb":"CASCADE_PRESSURE","source":"notes/positions/parent.md","target":"notes/positions/child.md","target_type":"position","reasoning":"Parent position received CONTRADICTS event. Child may be affected.","confidence":0.7,"inference_mode":"cascade-check"}
   ```

### 4c. Evidence independence scoring

After deliberation, compute per-target independence metrics:
- Count distinct `independence_group` values across promoted events for each target
- Flag positions where `independent_sources / total_events < 0.3` (heavy echo chamber)

### 4d. Promote validated events

**Intent verification checkpoint** — before promoting, check each event:

**Trigger condition:** The event touches a position that the user has modified in the last 7 days (check `updated:` frontmatter), OR the event would add the FIRST-EVER entry to a position's `## Evidence Against` section (check if section currently contains only "(none yet)").

When triggered in **interactive mode**, use AskUserQuestion:
```
Digest found: {source_slug} {VERB} {target_slug}.
Reasoning: {one-line reasoning}. Should I add this to the position's evidence and ledger?
```

Response handling:
- **"Yes"** → promote and update as normal
- **"No, skip it"** → do not promote, do not update position note
- **"Yes but different verb"** → ask for the correct verb, then promote with that verb

When triggered inside **daily-cycle (batch mode)**: collect all intent-check events and present as a single summary at the end of Phase C, not one-by-one. If running **unattended**, promote with `"needs_intent_verification": true` flag on the event JSON.

**Events that do NOT trigger the checkpoint:** Events targeting positions unmodified for 7+ days with existing Evidence Against entries. These promote silently.

For each event passing deliberation (and intent verification if applicable):
1. Validate source and target files exist
2. Append to `knowledge/epistemic-ledger.jsonl` (hook validates)
3. Include provenance in the promoted event
4. If `needs_intent_verification` was set, include it in the ledger entry

### 4e. Defense effectiveness metrics

Compute and report:
```yaml
defense_metrics:
  attack_assessment_distribution:
    CONFIRMED: {n}
    OVERSTATED: {n}
    REVERSED: {n}
    IRRELEVANT: {n}
  hunt_results:
    counter_evidence_found: {n}
    counter_evidence_promoted: {n}
  prosecution_accuracy: {CONFIRMED / total assessments}
  defense_discovery_rate: {counter_evidence_promoted / total prosecution events}
```

If defense rated 100% CONFIRMED and found 0 hunt discoveries, flag:
> "⚠ Defense agent may not be functioning effectively — all prosecution events confirmed, no counter-evidence discovered."

## Phase 5: Update affected notes

For each promoted event:
1. **Position targets**: Append to the position's `## Evolution` section:
   ```
   - **YYYY-MM-DD** — {VERB} by [[source-slug]]: {one-line reasoning} (via /digest)
   ```
   **Also update Evidence For / Evidence Against sections:**
   - SUPPORTS or EXTENDS → add to `## Evidence For` (replace "(none yet)" if present)
   - CONTRADICTS or CHALLENGES → add to `## Evidence Against` (replace "(none yet)" if present)
   - Format: `- [[source-slug]] — {one-line reasoning} (YYYY-MM-DD)`

2. **Question targets** (positions with `classification: question`): Append to the question's `## Evidence So Far` section:
   ```
   - [[source-slug]] — {reasoning} (YYYY-MM-DD, via /digest)
   ```

## Phase 5b: Crystallize epistemic state into knowledge graph

After updating notes, read the **full** `knowledge/epistemic-ledger.jsonl` and aggregate events per target. Then update `knowledge/graph-epistemic.yml` with compressed belief-state and question-state entities.

### For each position with ledger events:

Count events by verb (SUPPORTS, CONTRADICTS, CHALLENGES, EXTENDS, REFINES, CONVERGES, DECAYS, SUPERSEDES). Read the position note to get current `stage:` and `confidence:`. Compute derived fields:

**Trajectory:**
- `strengthening` — supports > 2× (contradicts + challenges), recent events mostly positive
- `stable` — low event count or balanced mix
- `weakening` — contradicts > supports
- `contested` — both supports AND (contradicts or challenges) present

**Pressure:**
- `none` — 0 contradicts + challenges
- `low` — 1 contradict or challenge
- `high` — 2+ contradicts + challenges

Write or update entity in `knowledge/graph-epistemic.yml`:
```yaml
position-slug:
  type: belief-state
  domain: epistemic
  position: "[[position-slug]]"
  stage: held
  confidence: medium
  supports: 5
  contradicts: 1
  challenges: 2
  extends: 1
  total_events: 9
  independent_sources: 3
  evidence_diversity: 0.33
  effective_evidence: 4.2
  trajectory: contested
  pressure: high
  last_event: "2026-03-07"
  summary: "One-line compressed state"
```

**Evidence independence fields:**
- `independent_sources`: Count of distinct `independence_group` values across all events for this position
- `evidence_diversity`: `independent_sources / total_events` (1.0 = fully independent, 0.1 = heavy echo)
- `effective_evidence`: Weighted count that discounts echoed evidence. Events from groups with N members each count as 1/N. Sum across all events.

### For each question (position with `classification: question`) with ledger events:

Count ADVANCES, COMPLICATES, SPAWNS. Read the position note for `stage:`. Compute:

**Trajectory:**
- `advancing` — advances > complicates
- `stalled` — no recent events
- `complicated` — complicates >= advances

**Resolution proximity:**
- `far` — 0-1 advances
- `approaching` — 2-3 advances
- `ready` — 4+ advances (flag for user: consider resolving into a position)

Write or update entity:
```yaml
question-slug:
  type: question-state
  domain: epistemic
  question: "[[question-slug]]"
  stage: active
  advances: 4
  complicates: 1
  total_events: 5
  trajectory: advancing
  resolution_proximity: approaching
  last_event: "2026-03-07"
  summary: "One-line compressed state"
```

### Per-layer aggregation (thesis-layer-state entities)

After computing per-position belief-states, also compute per-layer aggregates:

1. Read all position notes with `thesis_layer:` frontmatter and group by layer (`architectural`, `competitive`, `wedge`)
2. For each layer, sum `supports`, `contradicts`, `challenges` across all belief-state entities for positions in that layer
3. Compute layer trajectory:
   - `strengthening` — supports > 2× (contradicts + challenges)
   - `stable` — low event count or balanced mix
   - `weakening` — contradicts > supports
   - `contested` — both supports AND (contradicts or challenges) present
4. Compute layer health:
   - `healthy` — supports > 2× (contradicts + challenges), no unaddressed challenges
   - `stressed` — challenges exist but supports still dominate, OR some positions contested
   - `critical` — contradicts + challenges ≥ supports, OR a high-confidence position in this layer has trajectory `weakening`
5. Write/update three `thesis-layer-state` entities in `knowledge/graph-epistemic.yml` (one per layer), listing the position slugs in each layer, the aggregate counts, trajectory, health, and a one-sentence summary
6. Positions without `thesis_layer:` are excluded from layer aggregation (they still get individual belief-states as normal)

### Update the index

After writing entities, update the `epistemic.count` in `knowledge/graph-index.yml` to reflect the total number of belief-state + question-state + thesis-layer-state entities.

### Rules
- **Overwrite, don't accumulate.** Each entity is the *current* compressed state. If the entity already exists, replace it entirely with the new computation.
- **Summary is the compression.** Write one sentence that captures what a cold-start Claude needs to know about this position or question. Not the evidence — the *verdict*.
- **Skip positions with 0 ledger events.** Don't create empty entities. (Both belief-state and question-state entities come from `notes/positions/` — filter by `classification` field.)

## Phase 5b.1: Absorption state advancement

After crystallizing epistemic state, advance absorption-log entries based on digest outcomes.

Read `knowledge/absorption-log.jsonl`. For each entry:

1. **Match entries to digest sources:** Compare each absorption-log entry's `source` (URL, path, or title) against the intake notes processed in this digest run. Match by:
   - Source path overlap (absorption entry's `type` + metadata → intake note path)
   - Timestamp proximity (absorption entry near intake note's `created:` date)

2. **Advance state based on promoted events:**
   For each matched absorption-log entry:
   - If the corresponding intake note produced **promoted events** (SUPPORTS, EXTENDS, CHALLENGES, CONTRADICTS) in this run → advance to `committed`
   - If the corresponding intake note was **processed but produced no promoted events** (pairs found but all filtered or rejected) → advance to `shaping` (the system considered it, just didn't find strong connections yet)
   - If the entry is already `committed` → leave as-is

3. **Update counts:** For entries advancing to `committed`, update `positions_seeded` and `positions_reinforced` counts based on the promoted events:
   - Count events where the intake note is the source and verb is SUPPORTS/EXTENDS → `positions_reinforced`
   - Count events where the intake note seeded a NEW position → `positions_seeded`

4. **Write back:** Rewrite `knowledge/absorption-log.jsonl` with updated entries. Preserve all fields; only modify `absorption_state`, `positions_seeded`, `positions_reinforced`. **Concurrency note:** This is a full-file rewrite. Safe inside /daily-cycle (single session owns all writes). If running standalone /digest, no other intake skills (/youtube, /reference, /llm, /transcribe) should be active concurrently.

5. **Report:** In Phase 7, add line: `- Absorption advanced: {N} seen→shaping, {M} seen→committed, {K} shaping→committed`

Rules:
- Only advance forward (seen → shaping → committed). Never regress.
- If no absorption-log entries match this run's intake, skip silently.
- If `knowledge/absorption-log.jsonl` doesn't exist, skip silently.

## Phase 5c: DECAYS sweep (periodic)

Run this sweep every 3rd digest cycle. To count cycles correctly:

Read `knowledge/digest-cycle-count.json` (create if missing with `{"digest_cycle_count": 0, "last_run_id": null}`).
Increment `digest_cycle_count` by 1. Update `last_run_id` to the current run_id. Write back.

If the updated count is divisible by 3, run the sweep. Otherwise skip to Phase 6.

### Rule 1: Time-bound evidence staleness (30+ days)

Scan the ledger for SUPPORTS and EXTENDS events older than 30 days. For each:
1. Read the source note
2. Check if the evidence is time-bound (e.g., "as of Q1 2026", "current price", "recent data shows", specific market conditions)
3. If the evidence has a clear temporal dependency that may no longer hold, emit a DECAYS event:
   ```json
   {
     "timestamp": "...",
     "verb": "DECAYS",
     "source": "notes/positions/the-position.md",
     "target": "notes/positions/the-position.md",
     "target_type": "position",
     "reasoning": "Original SUPPORTS from [source] cited [time-bound claim] which is now 30+ days old and may no longer reflect current conditions.",
     "confidence": 0.6,
     "inference_mode": "decay-sweep",
     "source_tier": "T1-primary",
     "run_id": "{run_id}"
   }
   ```

### Rule 2: Evidence staleness (6+ months)

For any position where ALL SUPPORTS events cite sources older than 6 months AND no new SUPPORTS has been added in 3 months → emit DECAYS. The evidence base has gone cold even if individual claims aren't time-bound.

### Rule 3: Position neglect (6+ months)

For any position note unmodified for 6 months (check file mtime or frontmatter `updated:`) with zero events of any kind in the last 6 months → emit DECAYS. A position that generates no epistemic activity for 6 months is effectively abandoned.

### Rule 4: Reference expiry (12+ months)

For any reference note (`type: reference`) older than 12 months that has not been cited in any ledger event since creation → flag for review in the report (do NOT auto-emit DECAYS — references may be archival). List these in the Phase 6 report as "stale references."

### Rule 5: Bridge-triggered decay escalation (future)

If a position has `UNTESTED_IN_ACTION` events from 2+ distinct bridge runs (check ledger for `inference_mode: rule`, `verb: UNTESTED_IN_ACTION`, same target), escalate to DECAYS consideration. Review the position and its evidence — if the evidence is also aging AND the position is untested, emit DECAYS. This rule only activates once `/bridge` has run multiple cycles.

**Window-aware discounting:** Bridge events carry an `observation_window` field (days). When counting bridge runs for escalation, **ignore events where `observation_window < 7`** — these are preliminary signals from young repos/positions and should not contribute to decay escalation. Only full-window bridge events (observation_window >= 7) count toward the 2-run threshold.

**Shared rules for all decay emissions:**
- DECAYS source and target are both the position — it's the position's evidence base decaying, not a new source challenging it
- Don't decay evergreen evidence (theoretical arguments, structural analyses, historical facts)
- Only decay claims that depend on specific current conditions
- This is a lightweight check, not a deep re-evaluation — if unsure, skip
- Update the position's Evolution section and graph entity accordingly

## Phase 6: Daily note summary

Append a digest summary to today's daily note under `## Work`:
```
- HH:MM — /digest: processed {N} intake notes, {M} candidate pairs, {K} events promoted. {brief highlights}
```

## Phase 7: Report

Tell the user:
- How many intake notes were processed
- How many candidate pairs were found (inline retrieval)
- **Tribunal results:**
  - Prosecution events: {N}
  - Defense assessments: CONFIRMED {n}, OVERSTATED {n}, REVERSED {n}, IRRELEVANT {n}
  - Defense hunt discoveries: {n} found, {n} promoted
  - Prosecution accuracy: {percentage}
  - Defense discovery rate: {percentage}
- Events promoted to ledger: {N}
- **Evidence independence:** {N} distinct independence groups across {M} events
- **Layer health summary** (read the three `thesis-layer-state` entities from `knowledge/graph-epistemic.yml`):
  ```
  Layer health:
    - architectural: {health} ({N} supports, {M} challenges)
    - competitive: {health} ({N} supports, {M} challenges — {brief context})
    - wedge: {health} ({N} supports, {M} challenges — {brief context})
  ```
- Cascade events emitted: {N} (if any CONTRADICTS triggered cascades)
- A brief summary of the most interesting findings
- Any positions or questions that accumulated multiple events (worth reviewing)
