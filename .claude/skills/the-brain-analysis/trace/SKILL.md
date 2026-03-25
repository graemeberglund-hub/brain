---
name: trace
description: Trace the evolution timeline of a topic across the vault. Use when user asks about history or evolution of a topic.
context: fork
agent: vault-reader
allowed-tools: Read, Grep, Glob
argument-hint: "[topic to trace, e.g. 'mortality', 'deduplication']"
---

input = $ARGUMENTS

# /trace — Idea Evolution Timeline

Trace the evolution and structural position of a topic across the brain vault. This is a **read-only** command — never create or modify notes.

## 1. Search the vault

Search for the topic across all note types:

- `knowledge/graph-index.yml` — first, for routing and cross-subgraph relations
- Project notes (`notes/projects/rla/*.md`, `notes/projects/brain/*.md`) — frontmatter and body
- Position notes (`notes/positions/*.md` — includes all classifications: belief, question, decided, taste, goal)
- Concept notes (`notes/concepts/*.md`)
- Reference notes (`notes/references/*.md`)
- Daily notes (`notes/daily/*.md`)
- Inbox notes (`notes/inbox/*.md`)
- Weekly activity (`activity/weeks/*.yml`)

## 2. Build the structural picture

Before following note-level chains, inspect `knowledge/graph-index.yml` for any entity or project-state whose slug/title matches the topic. Use `relations:` to map structural position:

- `belongs-to` — what project-state a dev/tool/pattern entity rolls up into
- `replaced-by` — dead-end -> replacement sequences
- `same-session` — adjacent work from the same project session
- `uses` — project-state -> tool dependencies
- If no graph relation matches exist, say so and continue with the note/project scan

From matched project notes, trace relationships:

- **Upstream**: Follow `spawned_by` links to find origins
- **Downstream**: Follow `enables` links to find what this unlocked
- **Cluster membership**: Which clusters contain matched projects? (check `activity/config.yml`)
- **Arc types**: What arcs do matched projects have?
- **Decision links**: Which decisions reference matched projects?

## 3. Map the activity timeline

From `activity/weeks/*.yml`, find weeks with activity related to the topic. Note the first appearance, peak activity, and most recent mention.

## 4. Generate the report

```
## /trace: {input}

### Timeline
{Chronological list of all appearances, sorted by date:}
YYYY-MM-DD  [type]  description

### Structural Position
- **Cluster(s):** {cluster names}
- **Arc type(s):** {arc values}
- **Upstream (spawned_by chain):** {chain or "root-level"}
- **Downstream (enables chain):** {chain or "terminal"}
- **Graph relations:** {key relation chains from `knowledge/graph-index.yml`, or "None found"}

### Decisions Made
{Decision notes with status and one-line summary, or "None found"}

### Activity Profile
- **First activity:** {date}
- **Peak week:** {date} ({N} items)
- **Most recent:** {date}
- **Total weeks active:** {count}

### Connected Concepts
{Concept or reference notes that matched, with their tags}

### Value Produced
{value_note fields from matched project notes, or "No value_note recorded"}
```

If very few matches are found, say so — the topic may be nascent or not yet tracked.
