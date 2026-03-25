---
name: connect
description: Find structural bridges between two topics in the vault. Use when user asks how two topics connect or relate.
context: fork
agent: vault-reader
allowed-tools: Read, Grep, Glob
argument-hint: "[two topics, e.g. 'mortality, evidence' or 'mortality and evidence']"
---

input = $ARGUMENTS

# /connect — Bridge Finder Between Two Topics

Find and explain connections between two topics across the brain vault. This is a **read-only** command — never create or modify notes.

## 1. Parse input

Split `input` on `,` or ` and ` to get the two topics. If parsing fails, ask the user for two topics.

## 2. Gather context

Read `knowledge/graph-index.yml` first. Use it both as:
- the routing layer for which subgraphs exist
- the structural graph via `relation_verbs:` and `relations:`

Read notes related to both topics:

- `knowledge/graph-index.yml`
- Project notes in `notes/projects/rla/*.md` and `notes/projects/brain/*.md`
- Position notes in `notes/positions/*.md` (includes all classifications: belief, question, decided, taste, goal)
- Concept notes in `notes/concepts/*.md`
- Reference notes in `notes/references/*.md`
- Daily notes in `notes/daily/*.md` and journal notes in `notes/journal/*.md`
- Inbox notes in `notes/inbox/*.md`
- Weekly activity in `activity/weeks/*.yml`
- Cluster structure in `activity/config.yml`

## 3. Find connections

Start with graph relations before doing the wider vault scan:

- **Graph connections** — if either topic matches an entity slug, entity title, or project name in the split knowledge graph, follow `relations:` in `knowledge/graph-index.yml` for 1-2 hops
- Use `belongs-to` to jump from dev/tool/pattern entities to project-state context
- Use `replaced-by` to surface dead-end -> replacement chains
- Use `same-session` to surface adjacent work from the same project day
- If no graph match exists, say so explicitly and continue with the broader vault scan

Understand how the two topics relate. Consider:

- **Direct bridges** — notes that mention both topics
- **Structural connections** — shared clusters, enables/spawned_by chains, wikilink paths between them
- **Thematic overlap** — shared tags, similar arc types, related concepts
- **Temporal co-occurrence** — weeks where both were actively worked on

## 4. Generate the report

```
## /connect: {topic_a} <-> {topic_b}

### Summary
{One sentence: deeply connected, loosely related, or independent?}

### Graph Connections
{Relation chains from `knowledge/graph-index.yml`, or "No graph relation path found"}

### Direct Bridges
{Notes that reference both topics — or "None found"}

### Structural Connections
{Cluster co-membership, enables/spawned_by chains, wikilink paths — or "None found"}

### Thematic Overlaps
{Shared tags, similar arcs — or "None found"}

### Temporal Co-occurrence
{Weeks where both were active — or "No co-occurring activity"}

### Interpretation
{2-3 sentences: what does this connection pattern suggest? Is there an unexplored link worth investigating?}
```

If no connections exist, say so — the topics may be genuinely independent in this vault.
