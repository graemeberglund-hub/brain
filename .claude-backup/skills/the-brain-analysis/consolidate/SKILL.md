---
name: consolidate
description: Scan all subgraphs for cross-domain patterns, promote to cross-cutting layer. Run weekly/biweekly.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(wc *), Agent
argument-hint: "[optional: 'dry-run' to preview without writing]"
dashterm: true
timeout: 180
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

(At start of execution, use Read and Glob to check: knowledge/graph-index.yml contents, whether knowledge/graph-cross-cutting.yml exists, and entity counts in knowledge/graph-dev.yml, knowledge/graph-projects.yml, knowledge/graph-epistemic.yml, and knowledge/graph-emergent.yml by reading each and counting top-level entities.)

# /consolidate — Cross-Domain Pattern Synthesis

Scan all knowledge subgraphs for patterns appearing in 2+ domains and promote them to the cross-cutting layer. This is synthesis, not cleanup.

## Central Design Principle

> Cross-cutting entities are PROMOTED during consolidation, not written directly. A pattern must appear in 2+ domains with concrete evidence before earning a cross-cutting entity.

## Phase 0: Load all subgraphs

Read the full contents of:
1. `knowledge/graph-dev.yml` — solutions, patterns, dead-ends, tools
2. `knowledge/graph-projects.yml` — project state snapshots
3. `knowledge/graph-epistemic.yml` — belief-states, question-states, thesis-layer-states
4. `knowledge/graph-emergent.yml` — drift-stage themes, blindspots, bridges, and recurring signals
5. `knowledge/graph-cross-cutting.yml` — existing cross-cutting entities (if any)

Use `graph-emergent.yml` as a candidate shortlist and naming aid, not as independent proof. Cross-cutting promotion still requires concrete evidence from the canonical domain subgraphs (`dev`, `projects`, `epistemic`).

## Phase 1: Pattern detection (agent-mediated)

Spawn an agent (subagent_type: general-purpose) with the domain subgraphs loaded, plus the emergent layer as shortlist context. The agent's task:

> "Analyze the domain subgraphs for patterns, principles, preferences, or anti-patterns that appear in 2+ domains. A 'domain' means dev, projects, or epistemic.
>
> The emergent layer is available as a shortlist of candidate themes and bridges. It may help with naming or prioritization, but it does NOT count as an additional domain and it is not sufficient evidence on its own.
>
> For each candidate pattern, provide:
> - `id`: kebab-case identifier
> - `type`: taste | principle | anti-pattern
> - `appears_in`: list of domains where this appears (minimum 2)
> - `evidence`: specific entity IDs or position slugs from each domain that demonstrate the pattern
> - `summary`: one sentence capturing the pattern
>
> Rules:
> - Require CONCRETE evidence from 2+ domains — not just thematic similarity
> - A dev solution and an epistemic position discussing the same principle counts
> - A project state and a dev dead-end revealing the same anti-pattern counts
> - If the emergent layer suggests a strong candidate, still verify it against the canonical subgraphs before returning it
> - Do NOT invent connections — the evidence must be explicit in the subgraph data
> - Maximum 7 candidates — quality over quantity
> - Prefer patterns that would genuinely help with future decision-making"

## Phase 2: Filter and deduplicate

From the agent's candidates:
1. Verify each candidate has genuine 2+ domain evidence (re-read the cited entities if needed)
2. Check against existing `graph-cross-cutting.yml` — skip any that duplicate existing entities
3. Use `graph-emergent.yml` to collapse duplicate candidate names before promotion when appropriate
4. Cap at 3-5 new entities per run (consolidation should be incremental, not exhaustive)
5. If `$ARGUMENTS` is "dry-run", report candidates and stop here

## Phase 3: Write cross-cutting entities

Create or update `knowledge/graph-cross-cutting.yml`:

```yaml
# Knowledge Graph — Cross-Cutting Subgraph
# Domain-transcendent patterns promoted during consolidation.
# Written by /consolidate. Read by /drift, /connect, /trace.
# Each entity must cite evidence from 2+ domain subgraphs.

entities:
  {entity-id}:
    type: {taste|principle|anti-pattern}
    appears_in: [{domain1}, {domain2}]
    evidence:
      - subgraph: {dev|projects|epistemic}
        entity: "{entity-id or position-slug}"
        detail: "One line explaining how this entity demonstrates the pattern"
      - subgraph: {other-domain}
        entity: "{entity-id or position-slug}"
        detail: "One line explaining the cross-domain connection"
    promoted_date: "{today}"
    summary: "One sentence capturing the pattern and why it matters."
```

If the file already exists, append new entities. Don't modify existing ones (they were validated in prior runs).

## Phase 4: Update graph-index.yml

Update the cross-cutting section in `knowledge/graph-index.yml`:
- Set `file:` to `graph-cross-cutting.yml`
- Update `count:` to reflect total entities

## Phase 5: Report

```
Consolidation for {date}:

Subgraphs scanned:
  - dev: {N} entities
  - projects: {N} entities
  - epistemic: {N} entities

Candidates identified: {N}
After filtering: {N}
New cross-cutting entities promoted: {N}

Promoted:
  - {entity-id} ({type}): {summary}
    Evidence: {domain1}/{entity} + {domain2}/{entity}

  ...

Cross-cutting total: {N} entities
```

## Design Constraints

- **Run cadence:** Weekly or biweekly. Not after every digest.
- **Incremental:** 3-5 new entities per run max. The cross-cutting layer grows slowly.
- **Evidence-required:** No speculative patterns. If you can't point to specific entities in 2+ subgraphs, it doesn't qualify.
- **Synthesis, not cleanup:** Don't reorganize or rename existing entities in other subgraphs. Consolidation reads, then writes only to cross-cutting.
- **Budgets:** Cross-cutting subgraph budget is 50 entities. If approaching limit, prioritize patterns with more domain coverage.
