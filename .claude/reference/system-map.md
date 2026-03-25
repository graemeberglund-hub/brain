# Brain Vault — Complete System Map

> Last verified: 2026-03-13. Covers architecture, data model, skills, agents, hooks, conventions, and current inventory.

---

## 1. High-Level Goals

The brain vault is a **second brain for interconnected knowledge, project tracking, and cross-repo awareness**. It serves one user. It is the interface through which the user engages claude code. It bridges the gap between model reasoning and persistent knowledge by providing a structured, typed, and interconnected system for capturing, processing, and analyzing data and coding user's ideas, preferences, and positions. By being agent driven we attempt to keep the cognitive load of using the system or even understanding it's architecure minimal, while surfacing the benefits to the user. 

It works by:

1. **Capture** — Ingest thoughts, references, positions (beliefs, tastes, goals, questions, decisions), conversations, and LLM outputs into structured markdown notes with typed frontmatter
2. **Metabolize** — Process new intake against existing beliefs and open questions via an epistemic metabolism system (retrieval → inference → ledger events → belief state updates)
3. **Synthesize** — Transform raw git commits into meaningful work narratives; distill cross-domain patterns into a knowledge graph
4. **Analyze** — Trace idea evolution, find connections between topics, detect unnamed themes and blind spots
5. **Track** — Maintain project states, weekly activity logs, and thesis health across three abstraction layers

The system is **file-based, git-tracked, Obsidian-compatible, and has zero external service dependencies** (no database, no MCP for storage). Claude Code skills read/write plain YAML, JSONL, and markdown files.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT ROUTER (CLAUDE.md)                 │
│  Natural language → skill dispatch (first match wins)           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CAPTURE LAYER          PROCESSING LAYER      ANALYSIS LAYER    │
│  ┌──────────────┐       ┌──────────────┐     ┌──────────────┐  │
│  │ /capture     │       │ /digest      │     │ /trace       │  │
│  │ /position    │──────▶│ /triage      │     │ /connect     │  │
│  │ /question    │       │ /sync        │     │ /drift       │  │
│  │ /decision    │       │ /weekly-rev  │     └──────┬───────┘  │
│  │ /reference   │       └──────┬───────┘            │          │
│  │ /youtube     │              │                    │          │
│  │ /llm         │              │              vault-reader     │
│  │ /transcribe  │              │              (read-only scan) │
│  │ /ingest      │              │                               │
│  └──────────────┘              │                               │
│                                ▼                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  KNOWLEDGE LAYER                         │   │
│  │                                                         │   │
│  │  knowledge/graph-index.yml    Routing layer             │   │
│  │  knowledge/graph-dev.yml      Solutions, dead-ends      │   │
│  │  knowledge/graph-projects.yml Project states            │   │
│  │  knowledge/graph-epistemic.yml Belief/question states   │   │
│  │  knowledge/graph-emergent.yml Drift-stage candidates    │   │
│  │                                                         │   │
│  │  knowledge/epistemic-         Temporal event log        │   │
│  │  ledger.jsonl                 (SUPPORTS, CONTRADICTS,   │   │
│  │                               CHALLENGES, EXTENDS...)   │   │
│  │                                                         │   │
│  │  knowledge/event-             Staging area              │   │
│  │  candidates.jsonl             (pre-validation)          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  NOTE LAYER                              │   │
│  │  notes/positions/  notes/concepts/   notes/areas/       │   │
│  │  notes/references/ notes/projects/   notes/journal/     │   │
│  │  notes/inbox/      notes/conversations/                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  ACTIVITY LAYER                           │   │
│  │  activity/weeks/*.yml    activity/reports/*.html         │   │
│  │  repos/*.yml             activity/generate_emergence.py   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  HOOKS: validate-note-schema, validate-ledger-event,           │
│         update-frontmatter-date, session-start-context,        │
│         session-end-cleanup, notify-desktop, pre-compact       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Note Types and Schema

All notes use YAML frontmatter + markdown body. `[[wikilinks]]` connect notes.

### Base Fields (all types)
```yaml
title: "Note Title"
type: project | area | concept | reference | journal | daily | inbox | conversation | position
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD   # auto-managed by hook; absent on type: daily
```

### type: project
Lives in `notes/projects/{rla|brain}/`. Additional fields:
- `name` — must match cluster project list
- `areas: [area-slug]` — which area(s) this belongs to
- `cluster` — cluster family (legacy, optional)
- `arc` — spike | organic | need-driven | infrastructure | exploratory | deliverable | meta
- `repo` — which repo this project lives in
- `origin` — one-liner trigger/reason
- `spawned_by` — parent project or external trigger
- `enables: []` — downstream projects this unblocks
- `value_note` — impact/outcome summary
- `parked_reason` — why resting/archived (if applicable)
- `repo_paths: [{path, label}]` — links to repo directories
- Sections: About, Key Artifacts

### type: area
Lives in `notes/areas/`. Long-lived, open-ended containers that never "finish." Manually maintained index pages.
- Sections: About, Active Projects (wikilinks), Learning, Key Concepts (wikilinks)
- Projects link to areas via `areas:` frontmatter

### type: position (unified epistemic type)
Lives in `notes/positions/`. All epistemic notes use this type with a `classification` field.
- `classification` — belief | taste | goal | question | decided
- `stage` — forming | exploring | held | acted-on | falsified | achieved | abandoned
- `confidence` — low | medium | high
- `area` — optional, single area link
- `parent` — optional, broader thesis (enables hierarchy)
- `thesis_layer` — optional: architectural | competitive | wedge
- Classification-specific fields:
  - **goal**: `weight` (high | medium | low), plus Weight Evidence and Progress Signals sections
  - **decided**: `project` (optional wikilink), frozen snapshot — new evidence spawns new note
  - **taste**: design/preference positions (no extra fields, `testable: false`)
  - **question**: investigation positions (`testable: true`, resolves into belief or decided)
- Sections: Thesis, Evidence For, Evidence Against, Evolution (chronological diary)
- Stage and confidence are orthogonal (can be `held` at `low` confidence)
- Filename tag: `pos-` for all classifications

### type: reference
Lives in `notes/references/`. Additional fields:
- `source` — URL or citation
- `source_type` — article | video | tool | paper | case-study

### type: conversation
Lives in `notes/conversations/`. Additional fields:
- `participants: []`
- `duration`
- `audio_source` — path to audio in `sources/conversations/`
- `transcript_source` — path to transcript in `sources/conversations/`
- Sections: Context, Threads (knowledge payload — NOT full transcript)

### type: daily
Lives in `notes/journal/`. NO `updated:` field.
- Sections: Work, Decisions, Captured, Notes
- Single-day artifact; uses calendar date (midnight rollover)

### type: concept
Lives in `notes/concepts/`. Standard base fields only.

### type: inbox
Lives in `notes/inbox/`. Temporary holding area before triage.

---

## 4. Knowledge Graph (split subgraphs)

Purpose-built subgraphs routed by `knowledge/graph-index.yml`. Git-tracked, no MCP dependency.

### Subgraph Files

| Subgraph | File | Entity Types | Count | Written By | Budget |
|----------|------|-------------|-------|------------|--------|
| `dev` | `graph-dev.yml` | solution, pattern, dead-end, tool | 29 | `/sync` | 250 |
| `projects` | `graph-projects.yml` | project-state | 15 | `/sync` | 200 |
| `epistemic` | `graph-epistemic.yml` | belief-state, question-state, thesis-layer-state | 52 | `/digest`, `/resolve-feedback` | 400 |
| `emergent` | `graph-emergent.yml` | unnamed-theme, cluster-blindspot, cross-cluster-bridge, ghost-link, weather-signal | 28 | `/drift` | 200 |
| `rla-investigation` | null (not yet populated) | person, organization, timeline-event | 0 | `/sync` | — |
| `cross-cutting` | `graph-cross-cutting.yml` | preference, principle, anti-pattern | 7 | `/consolidate` | 50 |
| **Total** | | | **131** | | |

### Index (`graph-index.yml`)
Routing layer — read this first, then pull the subgraph you need. It now contains:
- subgraph metadata: file path, entity types, who writes/reads, entity counts
- `relation_verbs:` — fixed vocabulary for structural graph links
- `relations:` — cross-subgraph links between entity slugs

### Entity Types

| Type | Domain | Purpose | Key Fields |
|------|--------|---------|------------|
| solution | development | How a problem was solved | symptom, root_cause, fix, project, date |
| dead-end | development | What didn't work and why | approach, why_failed, replaced_by, project, date |
| pattern | development | Recurring approach (2+ instances) | instances, description |
| tool | development | Tools, libraries, techniques | what, use_case, project |
| project-state | projects | Context restoration snapshot | status, key_state, last_worked, daily_note |
| belief-state | epistemic | Compressed position standing | supports/contradicts/challenges/extends counts, trajectory, pressure, status, confidence |
| question-state | epistemic | Compressed question progress | advances/complicates counts, trajectory, resolution_proximity |
| thesis-layer-state | epistemic | Per-layer aggregate | positions list, total event counts, trajectory, health, summary |
| unnamed-theme | emergent | Recurring theme not yet promoted | summary, clusters, evidence, recurrence |
| cluster-blindspot | emergent | Structural gap in a cluster | cluster, summary, suggested_artifact, status |
| cross-cluster-bridge | emergent | Recurrent bridge spanning clusters | bridge_between, summary, evidence, recurrence |
| ghost-link | emergent | Persistent broken or deferred wikilink | missing_target, referenced_by, recurrence |
| weather-signal | emergent | Repeated drift-level alert | signal_kind, summary, recurrence |

### Relations
Relations are now implemented in `knowledge/graph-index.yml` as the cross-subgraph structural layer. Current seeded verbs are:
- `belongs-to`
- `replaced-by`
- `same-session`
- `uses`
- Reserved but not yet seeded broadly: `caused-by`, `evolved-into`

Designed schema:
```yaml
relations:
  - from: "entity-slug"
    from_subgraph: "dev"
    to: "entity-slug"
    to_subgraph: "projects"
    verb: "belongs-to"    # belongs-to | replaced-by | same-session | caused-by | uses | evolved-into
    date: "YYYY-MM-DD"
```

### Current Entity Inventory
The volatile entity counts live in `knowledge/graph-index.yml` and the subgraph files themselves. Keep this document descriptive, not authoritative.

High-signal snapshot as of 2026-03-13:
- `graph-dev.yml`: 29 entities
- `graph-projects.yml`: 15 entities
- `graph-epistemic.yml`: 52 entities
- `graph-emergent.yml`: 28 entities
- `graph-cross-cutting.yml`: 7 entities
- `knowledge/graph-index.yml`: 73 validated structural relations

### Tiered Architecture
1. **Tier 1: Index** — routing layer (read first to understand what's available)
2. **Tier 2: Knowledge Entities** — domain-specific facts (solutions, dead-ends, tools, project-states)
3. **Tier 2b: Epistemic Layer** — derived from ledger by `/digest`, overwritten each cycle
4. **Tier 3: Cross-Cutting Layer** — promoted during consolidation

### Key Design Properties
- No MCP dependency — plain YAML read/written with standard tools
- No database — Claude extracts patterns without SQL
- Write-time synthesis — knowledge distilled when `/sync` runs
- Derived epistemic state — ledger is source of truth, graph is compressed cache
- Split subgraphs with per-file bloat budgets (dev: 250, projects: 200, epistemic: 400)

---

## 5. Epistemic Ledger (`knowledge/epistemic-ledger.jsonl`)

Append-only JSONL event log. Each line is one validated epistemic event.

### Event Schema
```json
{
  "timestamp": "ISO 8601",
  "verb": "SUPPORTS",
  "source": "notes/references/example.md",
  "target": "notes/positions/example.md",
  "target_type": "position",
  "reasoning": "One sentence explaining the epistemic relationship",
  "confidence": 0.85,
  "inference_mode": "llm",
  "run_id": "UUID",
  "source_tier": "T2"
}
```

### Verb Vocabulary

| Category | Verbs |
|----------|-------|
| Position (9) | SUPPORTS, CONTRADICTS, CHALLENGES, EXTENDS, REFINES, CONVERGES, DECAYS, SUPERSEDES, WITHDRAWS |
| Question (3) | ADVANCES, COMPLICATES, SPAWNS |
| Action (3, unused) | ALIGNS_WITH_ACTION, MISALIGNED_WITH_ACTION, UNTESTED_IN_ACTION |

### Source Tier Ceilings (confidence caps)

| Tier | Description | Max Confidence |
|------|-------------|---------------|
| T1 | Primary/empirical | 0.95 |
| T2 | Curated secondary | 0.90 |
| T3 | Community/editorial | 0.85 |
| T4 | Social/anecdotal | 0.70 |

### Current Ledger Statistics (32 events)

| Dimension | Breakdown |
|-----------|-----------|
| By verb | SUPPORTS: 16, EXTENDS: 7, ADVANCES: 5, CHALLENGES: 4 |
| By mode | llm: 30, devil-advocate: 2 |
| By target | position: 27, question: 5 |

### Event Candidates (`knowledge/event-candidates.jsonl`)
Staging area for LLM-proposed events. Cleared at start of each `/digest` run. Currently **empty**.

---

## 6. Thesis Layering System

Three abstraction layers for positions, with independent health tracking:

| Layer | Claim Type | Falsification Standard | Positions | Health |
|-------|-----------|----------------------|-----------|--------|
| `architectural` | How good decisions work in messy domains | Very hard (near-philosophical) | 6 | healthy |
| `competitive` | Why competitors can't replicate this | Medium (show barrier isn't real or already crossed) | 2 | stressed |
| `wedge` | Where to start and how to monetize | Testable (market data, user feedback) | 5 | stressed |

**Key properties:**
- Layer 1 survives Layer 3 failure (but Layer 1 failure kills everything)
- Fixed vocabulary (exactly three layers)
- Manual assignment via `thesis_layer:` frontmatter on positions
- Layer health is derived (computed from ledger events), never manually set
- Questions are cross-layer (can ADVANCES positions at any layer)
- `parent:` hierarchy is orthogonal to layers

**Health computation:**
- `healthy`: supports > 2× (contradicts + challenges), no unaddressed challenges
- `stressed`: challenges exist but supports dominate, or some positions contested
- `critical`: contradicts + challenges ≥ supports, or high-confidence position weakening

---

## 7. Skills (22 in vault)

### Capture Layer (10 skills)

| Skill | Purpose | Writes To |
|-------|---------|-----------|
| `/capture` | Append timestamped captures to daily note; optionally create inbox notes | `notes/journal/`, `notes/inbox/` |
| `/position` | Create/update tracked belief with evidence tracking | `notes/positions/`, daily note |
| `/question` | Create/track open inquiry (classification: question) | `notes/positions/`, daily note |
| `/decision` | Log structured decision (classification: decided) | `notes/positions/`, daily note |
| `/reference` | Create reference note from URL/article/video | `notes/references/`, daily note |
| `/youtube` | Extract claims from video transcript, match to positions | `sources/youtube/`, `notes/references/`, positions, daily note |
| `/llm` | Extract positions/inbox from LLM conversation output | `sources/llm/`, positions, inbox, references, daily note |
| `/transcribe` | Transcribe audio, extract conversation threads | `sources/conversations/`, `notes/conversations/`, inbox, daily note |
| `/ingest` | Thin dispatcher routing to youtube/llm/transcribe/reference | none (dispatcher) |
| `/seed` | Scaffold new tracked repo with CLAUDE.md, .claude/ infra, brain registration | new repo directory, `repos/*.yml`, brain CLAUDE.md |

### Processing Layer (5 skills)

| Skill | Purpose | Writes To |
|-------|---------|-----------|
| `/digest` | Epistemic metabolism: process intake against positions | event-candidates, ledger, positions, graph-epistemic, daily note |
| `/resolve-feedback` | Flow PH prediction resolutions back to Brain positions via staged interpretation | ledger, positions, graph-epistemic (via next digest) |
| `/triage` | Move inbox notes to canonical destinations | moves files, updates frontmatter and references |
| `/sync` | Transform git commits into work narratives + knowledge graph entities | daily note, graph-dev, graph-projects |
| `/weekly-review` | Generate canonical weekly YAML from daily notes | `activity/weeks/*.yml` |

### Analysis Layer (3 skills, mostly read-only)

| Skill | Purpose |
|-------|---------|
| `/trace` | Trace evolution timeline of a topic across vault |
| `/connect` | Find structural bridges between two topics |
| `/drift` | Detect unnamed themes, gaps, and blind spots; persist deduped candidates and run artifacts |

### Shared (4 skills — also deployed to personal scope)

| Skill | Purpose |
|-------|---------|
| `/style` | Apply named design system to frontend |
| `/create-prompt` | Create optimized XML-structured prompts |
| `/prp-create` | Generate production-grade PRP through deep research |
| `/prp-base-execute` | Execute PRP with phase gates and verification |

---

## 8. `/digest` — Detailed Phase Breakdown

The central orchestrator of epistemic metabolism.

| Phase | Name | What Happens |
|-------|------|-------------|
| 0 | Staging clear | Clear `event-candidates.jsonl`; warn if inbox has pending notes |
| 1 | Identify intake | Find new/updated notes since last digest (references, inbox, conversations, concepts) |
| 2 | Retrieval | Spawn `retrieval-engine` agent → candidate pairs (source intake × target positions/questions) |
| 3 | Inference | Spawn `inference-engine` agent → event candidates with verbs, confidence, reasoning |
| 3b | Devil's advocate | **Mandatory** counterevidence pass — attempt CONTRADICTS/CHALLENGES for every SUPPORTS |
| 4 | Validation | Run validate-ledger-event.sh hook; promote passing candidates to ledger |
| 5 | Crystallize | Update position/question Evolution sections and Evidence For/Against; update belief-state and question-state entities in graph |
| 5b | Layer aggregation | Group positions by `thesis_layer`; sum events per layer; compute trajectory and health; write thesis-layer-state entities |
| 5c | DECAYS sweep | Every 3rd cycle: scan for positions with no new evidence in 30+ days → emit DECAYS events |
| 6 | Daily note | Write digest summary to daily note |
| 7 | Report | Output to user: events promoted, positions updated, layer health summary |

---

## 9. Agents (3)

| Agent | Spawned By | Role | Output |
|-------|-----------|------|--------|
| `retrieval-engine` | `/digest` Phase 2 | Find candidate pairs between intake and positions/questions using symbolic, structural, and keyword strategies | JSON array of candidate pairs |
| `inference-engine` | `/digest` Phase 3 | Evaluate pairs, classify epistemic verbs, emit events with confidence caps by source tier | Appends to `event-candidates.jsonl` |
| `vault-reader` | `/trace`, `/connect`, `/drift` Phase 1 | Read-only vault scanner (no Write/Edit/Agent tools). Budget ~40 files, max 2 wikilink hops | Structured analysis sections |

---

## 10. Hooks (8)

| Hook | Event Type | Fires On | Purpose |
|------|-----------|----------|---------|
| `validate-note-schema.sh` | PreToolUse | Write to `notes/*.md` | Enforce required frontmatter (title, type, tags, created); validate type enum |
| `validate-note-schema-post.sh` | PostToolUse | Edit to `notes/*` | Lint/warn about optional field quality (non-blocking) |
| `validate-ledger-event.sh` | PreToolUse | Write/Edit to `epistemic-ledger.jsonl` | Validate JSON, required fields, ISO 8601, verb vocabulary, file existence, 7-day duplicate detection |
| `update-frontmatter-date.sh` | PostToolUse | Edit/Write to `notes/*.md` | Auto-update `updated:` field to today's date; skips type: daily |
| `session-start-context.sh` | SessionStart | Session init | Bootstrap daily context (daily note status, inbox count, recent notes) |
| `session-end-cleanup.sh` | Stop | Session end | Auto-commit vault changes and push to backup if available |
| `notify-desktop.sh` | Notification | After tool completion | Desktop notifications for long-running ops |
| `pre-compact-context.sh` | PreCompact | Before context compaction | Re-inject vault conventions into context |

---

## 11. Current Vault Inventory

### Notes by Type (167 total)

| Type | Directory | Count |
|------|-----------|-------|
| position (all classifications) | `notes/positions/` | 37 |
| concept | `notes/concepts/` | 25 (3 untracked) |
| area | `notes/areas/` | 21 |
| reference | `notes/references/` | 11 |
| conversation | `notes/conversations/` | 2 |
| daily/journal | `notes/journal/` | 9 |
| inbox | `notes/inbox/` | 0 |
| project (rla) | `notes/projects/rla/` | 57 |
| project (brain) | `notes/projects/brain/` | 5 |

### Position Layer Assignments (13 of 20 assigned)

**Architectural (6)**: moat-is-stateful-reasoning-not-llm, hard-code-metabolism-not-the-world, tensions-are-primary-self-awareness, llm-as-constrained-adjudicator, signal-filtering-over-prediction, edge-is-setup-discipline-not-more-feeds

**Competitive (2)**: integration-pain-as-competitive-barrier, cross-class-confirmation-strongest-signal

**Wedge (5)**: markets-misprice-structural-risks, structural-mispricing-valuable-to-traders, oil-shipping-geopolitical-strongest-wedge, prediction-markets-top-of-funnel, private-engine-over-enterprise-product

**Unassigned (7)**: historical-pattern-matching-as-edge, gold-silver-end-of-empire-hedge, regime-strategy-separation, llm-trading-arbitrage-window, llm-strongest-30m-24h-horizon, agent-feedback-improves-future-retrieval, session-vs-permanent-memory-distinction

### Supporting Files

| Category | Location | Count |
|----------|----------|-------|
| Weekly activity YAML | `activity/weeks/` | 29 |
| Repo manifests | `repos/` | 4 |
| PRPs completed | `PRPs/completed/` | 14 |
| PRPs in progress | `PRPs/in_progress/` | 7 |
| YouTube sources | `sources/youtube/` | 11 |
| LLM sources | `sources/llm/` | 9 |
| Conversation sources | `sources/conversations/` | 7 |

---

## 12. Personal Toolkit Architecture

Brain is the **workshop** — tools developed here, deployed to `~/.claude/skills/` for cross-repo use.

### Deployed to personal scope (14 skills)
prp-create, prp-base-execute, prp-planning-create, task-list-init, create-prompt, debug-RCA, update-docs, prime-core, onboarding, new-dev-branch, diagram, style, find-skills (symlink), remotion-best-practices (symlink)

### Vault-specific (18 skills — stay in brain)
capture, decision, reference, position, question, digest, resolve-feedback, youtube, llm, transcribe, ingest, triage, weekly-review, sync, trace, connect, drift, seed

### Shared (4 skills — in both brain and personal scope)
create-prompt, style, prp-create, prp-base-execute

**Workflow**: Edit source in brain → test → copy to `~/.claude/skills/` to deploy.

---

## 13. Conventions

- **Wikilinks**: `[[note-filename]]` (no extension)
- **Tags**: frontmatter `tags:` array, lowercase, hyphenated
- **Filenames**: lowercase, hyphenated slugs matching title
- **One note = one idea**: Atomic and interconnected
- **Obsidian-compatible**: Opens directly in Obsidian; `notes/obsidian-dashboard.md` is Dataview-powered landing page
- **Emergence view**: `activity/generate_emergence.py` is the editorial weekly view generator. It reads graph state, ledger motion, raw `sources/`, note outputs, and daily captures; renders via `activity/templates/emergence.html.j2`; and writes `activity/reports/vault_emergence.html`. Use this path for intake atlas / thinking map / conversation lens work, not the older project dashboard generator.
- **Daily notes**: Use calendar date (midnight rollover). `date +%Y-%m-%d` used in all hooks and skills
- **Updated field**: Auto-managed by hook; absent on `type: daily`
- **Idempotency**: `/sync` uses `<!-- sync:{date}:{hashes} -->` markers; `/digest` clears staging before each run
- **Append-only ledger**: JSONL format prevents merge conflicts
- **No GitHub remote**: Backup is local Git-to-Git to `/Volumes/RLA_MASTER_WORK/00_SYSTEMS/brain`
- **Bloat gate**: per-subgraph budgets (dev: 250, projects: 200, epistemic: 400)

---

## 14. Data Flow Summary

```
User input
    │
    ▼
Agent Router (CLAUDE.md) ──▶ Skill dispatch
    │
    ├── Capture skills ──▶ notes/inbox/ or notes/positions/ or notes/{type}/
    │                         │
    │                         ▼
    ├── /triage ──────▶ Move inbox → canonical locations
    │                         │
    │                         ▼
    ├── /digest ──────▶ retrieval-engine (agent)
    │                    │
    │                    ▼
    │                  inference-engine (agent)
    │                    │
    │                    ├──▶ event-candidates.jsonl (staging)
    │                    │         │
    │                    │         ▼ (validation hook)
    │                    │    epistemic-ledger.jsonl (promoted)
    │                    │         │
    │                    │         ▼
    │                    ├──▶ graph-epistemic.yml (belief-states, question-states, thesis-layer-states — all derived from positions)
    │                    └──▶ graph-emergent.yml (drift-stage themes, blindspots, bridges)
    │                              │
    ├── /resolve-feedback ▶ PH resolved predictions → interpretation → ledger events
    │                        (staged: detect → classify → verb select → emit)
    │
    ├── /sync ────────▶ git history → daily note + graph-dev.yml + graph-projects.yml
    │
    ├── /weekly-review ▶ daily notes + decisions + refs → activity/weeks/*.yml
    │
    └── /trace, /connect ──▶ vault-reader agent ──▶ read-only reports
    └── /drift ──▶ vault-reader phase ──▶ drift-runs/ + graph-emergent.yml
```

---

## 15. Known Gaps and Technical Debt

### Structural gaps
- `caused-by` and `evolved-into` exist in the relation vocabulary but are not yet seeded broadly
- rla-investigation domain has 0 entities (schema defined, not populated)
- Cross-subgraph relation seeding is heuristic and intentionally incomplete; `/sync` should keep enriching it opportunistically

### Underused verbs
- Position verbs never used: DECAYS, SUPERSEDES, WITHDRAWS, REFINES, CONVERGES
- Question verbs never used: COMPLICATES, SPAWNS
- Action verbs entirely unused: ALIGNS_WITH_ACTION, MISALIGNED_WITH_ACTION, UNTESTED_IN_ACTION

### Imbalances
- Devil's advocate pass: 2 events out of 32 total (6%) — low adversarial coverage
- 7 of 20 positions have no thesis_layer assigned
- 6 of 20 positions have no belief-state in the graph (the unassigned ones minus gold-silver)

### Untracked files (per git status at time of writing)
- `notes/concepts/contradiction-as-feedback-mechanism.md`
- `notes/concepts/integration-depth-as-moat.md`
- `notes/concepts/verbs-over-nouns-design-principle.md`
