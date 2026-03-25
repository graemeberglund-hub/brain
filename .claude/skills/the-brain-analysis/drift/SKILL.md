---
name: drift
description: Detect unnamed themes and conceptual gaps across the vault, persist them to the emergent layer, and archive the run.
context: fork
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(wc *), Agent
argument-hint: "[optional focus area, e.g. 'mortality', 'infrastructure']"
dashterm: true
timeout: 0
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Emergent entity count: !`grep -c "^  [a-z]" knowledge/graph-emergent.yml 2>/dev/null || echo 0`

# /drift — Emergent Layer Synthesizer

Detect themes, patterns, conceptual gaps, bridges, and pressure signals across the vault. Unlike `/trace` and `/connect`, `/drift` **does persist its output**:

1. Immutable run artifact in `knowledge/drift-runs/`
2. Deduped current-state cards in `knowledge/graph-emergent.yml`

## Central Design Principle

> Capture first in the emergent layer. Do not auto-promote to concept, decision, question, or cross-cutting principle unless the user explicitly asks.

This keeps `/drift` from becoming a second `/consolidate`, a second `/weekly-review`, or a competing epistemic ledger.

## Phase 0: Load current state

Read:

1. `knowledge/graph-index.yml`
2. `knowledge/graph-emergent.yml`
3. `knowledge/graph-epistemic.yml`
4. `knowledge/graph-cross-cutting.yml`
5. `activity/config.yml`
6. `knowledge/absorption-log.jsonl` (if it exists — may be empty or have only comment headers)

## Phase 1: Analyze via `vault-reader`

Spawn the `vault-reader` agent to perform the full read-only scan. Give it the optional focus area from `input` if present.

Ask it to return a report with these sections:

```
## /drift{input ? ": " + input : ""}

### Unnamed Themes
1. **{theme}**
   - Summary: {one-sentence pattern}
   - Evidence: {where it appears and why it stands out}
   - Clusters touched: {list}
   - Claim holders: {who voiced/holds it, if inferable}
   - Origin modes: {self-question | self-grapple | llm-suggestion | external-position | derived-pattern}
   - Suggestion: {optional promotion target}

### Ghost Links
- `[[target]]` — referenced by {N} notes: {list}

### Cluster Blindspots
- **{cluster}**
  - Summary: {what is missing}
  - Evidence: {why this is a structural gap}
  - Suggested next artifact: {concept/question/reference if obvious}

### Cross-Cluster Bridges
- **{bridge}**
  - Summary: {what connects}
  - Clusters touched: {list}
  - Evidence: {shared examples}
  - Claim holders: {if inferable}
  - Origin modes: {list}

### Structural Graph Signals
- **Isolated entities** — tracked entities with zero `relations:` in `knowledge/graph-index.yml`
- **Same-session clusters** — repeated pairings or chains that reveal work patterns
- **Replacement chains** — `replaced-by` sequences that show evolution from false start to working move
- **Tool dependencies** — `uses` relations that reveal hidden project coupling

### Epistemic Weather

**Layer health:** (read `thesis-layer-state` entities from `knowledge/graph-epistemic.yml`)
- **Architectural** ({health}): {one-sentence summary}
- **Competitive** ({health}): {one-sentence summary}
- **Wedge** ({health}): {one-sentence summary}

**Positions under pressure (by layer):**
- *{Layer}*: {position-slug} — {N} CHALLENGE(S), {M} CONTRADICT(S) ({brief reasoning})

**Strengthened**: {positions with recent SUPPORTS events}
**Advancing questions**: {questions with ADVANCES events}
**Echo chamber risk**: {positions with only SUPPORTS and no challenges — if any}

### Consumption Clusters

Scan `knowledge/absorption-log.jsonl` for consumption patterns:

**By domain:** Group entries by overlapping `domain_tags`. If 3+ entries share the same tag and NO corresponding position exists in `notes/positions/` with that tag:
- **{domain_tag}**: {N} items consumed, no position formed
  - Sources: {list source_author values}
  - Suggested action: "form position?"

**By author:** Group by `source_author`. If 3+ entries from the same author:
- **{author}**: {N} items consumed
  - Absorption states: {count by state}
  - Domains: {list domain_tags}

If absorption-log.jsonl is empty or missing, output: "No consumption data yet — absorption tracking starts with next /youtube, /reference, /llm, or /transcribe run."
```

## Phase 2: Write immutable run artifact

Write the full report to:

`knowledge/drift-runs/{Today's date}-{Current time with ":" removed}.md`

Rules:

- One run = one file
- Never edit prior run artifacts in place
- Preserve the full report, even if only a subset becomes emergent cards

## Phase 3: Update `knowledge/graph-emergent.yml`

For each finding in these sections:

- `Unnamed Themes` -> `type: unnamed-theme`
- `Cluster Blindspots` -> `type: cluster-blindspot`
- `Cross-Cluster Bridges` -> `type: cross-cluster-bridge`
- `Structural Graph Signals` -> only promote when the signal is durable enough to matter beyond a single run
- `Ghost Links` -> `type: ghost-link`
- `Epistemic Weather` -> only create `type: weather-signal` entries for durable, repeated alerts or notable shifts. Do NOT write every routine weather line as an entity.

### Deduplication rule

Deduplicate conservatively.

- Merge only within the same `type`
- Merge only when summary, clusters, and evidence overlap strongly
- False duplicates are cheaper than false merges
- If two findings are adjacent but not clearly identical, keep them separate and record aliases only when confident

### Common fields

Every entity should have:

```yaml
  {entity-id}:
    type: unnamed-theme | cluster-blindspot | cross-cluster-bridge | ghost-link | weather-signal
    status: emerging | strengthening | stable | promoted | addressed | stale
    summary: "One sentence"
    aliases: []
    clusters: [list]
    claim_holders: [list]
    origin_modes: [list]
    first_seen: "YYYY-MM-DD"
    last_seen: "YYYY-MM-DD"
    recurrence: 1
    surfaced_by:
      - "knowledge/drift-runs/YYYY-MM-DD-HHMM.md"
    evidence:
      - ref: "[[note-or-file-ref]]"
        detail: "One line"
```

### Type-specific hints

```yaml
  {theme-id}:
    type: unnamed-theme
    promotion_target: "notes/concepts/{slug}.md"

  {blindspot-id}:
    type: cluster-blindspot
    cluster: "{cluster-name}"
    suggested_artifact: "notes/concepts/{slug}.md"

  {bridge-id}:
    type: cross-cluster-bridge
    bridge_between: [cluster-a, cluster-b, cluster-c]
    promotion_target: "notes/concepts/{slug}.md"

  {ghost-link-id}:
    type: ghost-link
    missing_target: "[[target]]"
    referenced_by: [list]

  {weather-id}:
    type: weather-signal
    signal_kind: "pressure | strengthening | echo-chamber-risk | layer-shift"

  {consumption-cluster-id}:
    type: unnamed-theme
    origin_modes: [consumption-cluster]
    suggested_action: "form position?"
    consumption_count: {N}
    consumption_sources: [list of source_author values]
```

If an entity already exists:

- append new aliases only if genuinely alternate labels
- merge any new clusters, claim holders, and origin modes
- append the current run artifact path to `surfaced_by` if missing
- update `last_seen`
- increment `recurrence`
- tighten the summary if the new run is clearer
- update `status` when appropriate (`emerging` -> `strengthening` -> `stable`; `cluster-blindspot` can become `addressed`)

## Phase 4: Report

Tell the user:

- run artifact path
- emergent entities created vs updated
- any findings deliberately left as run-only (especially weather lines)
- top cards now in the emergent layer

## Non-goals

- Do NOT auto-create concept notes
- Do NOT promote directly into `graph-cross-cutting.yml`
- Do NOT write weekly artifacts
- Do NOT create a second epistemic ledger
