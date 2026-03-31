---
name: position
description: Create or update a position/thesis note. Use when user states a belief, thesis, or position they hold or want to track.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls notes/daily/*)
argument-hint: "[thesis statement or belief to track]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /position — Thesis/Position Tracking

Create or update a position note that tracks a belief, thesis, or claim the user holds.

## Phase 1: Parse input

Extract the core thesis statement from `input`. Distill it to one clear, assertive sentence if needed.

Identify:
- Key terms for vault search
- Relevant tags
- Optional area link (if the thesis clearly belongs to an area in `notes/areas/`)
- Optional parent position (broader thesis this falls under)
- Optional linked repos (if the thesis is connected to a registered repo in `repos/*.yml`)

## Phase 2: Search for existing positions (Stage 1 dedup)

Grep `notes/positions/` for 2-3 key terms from the thesis.

**Overlap threshold rule**: After finding hits, apply these checks:
- **Title overlap**: Count how many significant words in the shorter title appear in the found note's title. If ≥70% overlap, flag as a probable duplicate.
- **Tag overlap**: If ≥3 proposed tags match an existing note's tags, flag as a secondary signal.

If flagged:
- Show the existing position to the user
- Ask: "Similar position exists: [[{existing-slug}]]. Update it, or create a new distinct position?"
  - "update" → add an Evolution entry with today's date and what changed, adjust status/confidence if warranted. Stop here.
  - "new" → proceed with Phase 2b

If no flags, continue directly to Phase 2b.

## Phase 2b: Thesis contradiction check (Stage 2)

**Only runs when Phase 2 found no flagged match (i.e., creating a new position).**

1. Extract the core claim from the thesis statement
2. Generate 3-5 opposition terms — negations or contraries of the key claims (e.g., if thesis is "X causes Y", opposition terms include "X does not cause Y", "Y independent of X", "Y caused by Z")
3. Grep `notes/positions/` for those opposition terms
4. If genuine tension found, surface it informally:
   > "Potential contradiction with [[{slug}]]: {one-line tension}. Proceed?"
   - This is informational only — the user proceeds regardless.
   - If proceeding: note the tension in the new note's Evolution section: `- **YYYY-MM-DD** — Created with known tension against [[{conflicting-slug}]].`
5. If no hits, continue silently.

**Skip Phase 2b when**: Phase 2 resulted in "update" (no new note being created), or grep returns no hits.

## Phase 3: Search vault for related notes

Grep `notes/` broadly for key terms. Find related:
- References that serve as evidence
- Decisions that connect
- Other positions that could be parent/child
- Concepts or projects that relate

## Phase 4: Create position note

Generate a slug from the thesis (lowercase, hyphenated, max 6 words). Create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

Accept an optional `classification` parameter from the user. Default to `belief` if not specified. Valid values: `belief`, `taste`, `question`, `decided`, `goal`.

```yaml
---
title: "YYYY-MM-DD {thesis statement}"
type: position
classification: {belief | taste | question | decided | goal}
testable: {true | false}
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
stage: forming
confidence: low
area: "[[{area-slug}]]"
parent: "[[{parent-position-slug}]]"
repos: [{repo-name}]
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Thesis

{One paragraph stating the position clearly. Expand on the user's input if needed.}

## Evidence For

- {Any wikilinks to existing vault notes that support this, with one-line context}

## Evidence Against

- (none yet)

## Evolution

- **YYYY-MM-DD** — Position formed from {source/context}. Starting at forming/low.
```

Omit `area:`, `parent:`, and `repos:` fields entirely if not applicable (don't include them as empty). Populate `repos:` with repo names from `repos/*.yml` when the position is clearly connected to a registered repo (e.g., user mentions the repo, or the thesis is about work happening in that repo).

## Phase 5: Update daily note

Ensure today's daily note exists (create if missing — standard template). Append under `## Captured`:
```
- HH:MM — [position] [[{slug}]]: {thesis statement}
```

## Phase 6: Confirm

Report:
- Position note path
- Stage and confidence
- Related notes found
- Daily note updated
