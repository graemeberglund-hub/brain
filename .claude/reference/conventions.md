# Conventions — Internal Reference

Read by skills on demand. NOT loaded into every session.

## Filenames
Convention v2 — `YYYY-MM-DD-{type_tag}-{slug}.md`. Type tags: pos, con, clm, ref, conv, in, journal, trace, project, prp. LLM artifacts: prompt, output, spec. Exceptions: daily notes (`YYYY-MM-DD.md`), area notes (`slug.md`). Never use bare sequential numbers. All epistemic notes (beliefs, tastes, goals, questions, decisions) use the `pos` tag — classification lives in frontmatter, not the filename.

## Title Scoping
Position titles must be scoped to their evidence, not their aspiration. Titles propagate through wikilinks, graph entities, and agent retrieval — an over-scoped title inflates downstream. Scope the claim to what was actually observed or tested.
- BAD: "Institutional abuse operates through total environment control" (universal claim, RLA-specific evidence)
- GOOD: "RLA's abuse was architected through total environment control" (scoped to evidence)
When evidence later supports the broader claim, the title can be widened. Start narrow.

## Knowledge Graph
Split into purpose-built subgraphs routed by `knowledge/graph-index.yml`:
- `graph-dev.yml` — solutions, dead-ends, tools, patterns (written by `/sync`)
- `graph-projects.yml` — project state snapshots (written by `/sync`)
- `graph-epistemic.yml` — position states by classification (belief, taste, goal, question, decided), thesis-layer-states (written by `/digest`, `/resolve-feedback`)
- `graph-emergent.yml` — drift-stage themes, blindspots, bridges (written by `/drift`)
- Cross-subgraph relations in `graph-index.yml` under `relations:`
- Relation verbs: `belongs-to`, `evolved-into`, `replaced-by`, `same-session`, `caused-by`, `uses`, `spawned`

## Absorption Log
`knowledge/absorption-log.jsonl` — tracks content consumption through the intake pipeline. Two paths:
- **Evaluative** (`intent: evaluative`): `seen → shaping → committed`. Claims extracted at intake. `positions_seeded` increments only at `/digest` endorsement, never at intake.
- **Applied** (`intent: applied`): `seen → applied`. Techniques extracted at intake. No claims pipeline. The act of applying IS the endorsement.
Schema: `{timestamp, type, intent, source, source_author, domain_tags, claims_extracted, techniques_extracted, positions_seeded, positions_reinforced, claims_created, positions_affected, absorption_state, absorption_history}`.
Written by intake skills + `/digest` (endorsement updates). Read by `/drift`, `/boot`, `/briefing`.

## Intake Intent
All intake skills detect intent before extraction:
- `intent: applied` — user seeks practical knowledge to use (tutorials, techniques, how-tos, "can we improve our system with this"). No claims extracted. Produces: reference note with techniques inline + inbox items for actionable patterns.
- `intent: evaluative` — user assesses someone's thesis or encounters claims about the world. Produces: claim notes with author attribution, endorsement-gated.
Default: evaluative (conservative — ensures claims get proper attribution).
Detection: implicit from user's framing or explicit flag (e.g., `/youtube applied <url>`).

## Epistemic Ledger
`knowledge/epistemic-ledger.jsonl` — canonical validated events (SUPPORTS, CONTRADICTS, ADVANCES, etc.). Written by `/digest`. Events may carry `needs_intent_verification: true`. Pre-tribunal triage (Phase 2b in `/digest`) serves as the quality gate — claims are auto-classified, flagged for tribunal, or auto-rejected before prosecution.

## Engines
`.claude/agents/retrieval-engine.md` and `.claude/agents/inference-engine.md` — subagents spawned by `/digest`.

## Artifacts
- `studio/readable/` — styled HTML renderings via `/readable`
- `studio/briefing/` — daily editorial briefings ("The Mirror") via `/briefing`
- `knowledge/debriefs/` — per-repo process analysis via `/debrief`

## Workstreams
`.claude/workstreams/{name}/` — manifest.yml + runner.sh + phases/*.md. Phases execute via dashterm API or claude CLI. Communication between phases is through filesystem artifacts only. See [[2026-03-19-con-automated-workstream-architecture]].

## prompts/ vs PRPs/

| Directory | Purpose | Output |
|-----------|---------|--------|
| `prompts/` | Research pipeline — questions → models → knowledge | Notes |
| `PRPs/` | Execution specs — instructions → artifacts | Code, HTML, docs |

### prompts/ hierarchy (sprint-first)
- `sprints/{NN}/strategy/` — prompts for this sprint
- `sprints/{NN}/outputs/` — model responses from this sprint
- `context/` — reusable profiles, fact bases (not sprint-bound)
- `analysis/` — one-off audit/analysis prompts
- `strategy/` — standalone strategy prompts (not part of a numbered sprint)
- `exploration/` — discovery/schema prompts

## Metabolism
Two-layer architecture. Layer 1 (`tools/metabolism_daemon.py`) runs every 90 min via launchd — zero tokens, deterministic rules. Layer 2 (workstream phases) runs only when Layer 1 detects real work. State: `knowledge/metabolism-state.json`, `metabolism-calibration.json`, `metabolism-last-run.json`, `absorption-advances.jsonl`.
