---
name: question
description: Create or update an open question note. Use when user poses a question they want to track, investigate, or resolve over time.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *)
argument-hint: "[question to track]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /question — Open Question Tracking

Create or update a question note that tracks an open inquiry the user wants to investigate over time. Questions are co-primary with positions in the epistemic metabolism — `/digest` evaluates intake against both.

## Phase 1: Parse input

Extract the core question from `input`. Ensure it's phrased as a clear, specific question (not a statement). If the user gave a statement, convert to question form.

Identify:
- Key terms for vault search
- Relevant tags
- Related positions (existing positions this question might test, challenge, or refine)
- Suggested tests (concrete ways to investigate — experiments, data to check, people to ask)

## Phase 2: Search for existing questions

Grep `notes/positions/` for key terms (questions now live in `notes/positions/`). Check if a matching or very similar question already exists.

If a match is found:
- Show the existing question to the user
- Ask if they want to update it (add evidence, change status, etc.) or create a new distinct question
- If updating: add to Evidence So Far, adjust status if warranted
- Stop here after updating

If no match, continue to Phase 3.

## Phase 3: Search vault for related notes

Grep `notes/` broadly for key terms. Find related:
- Positions this question could test or challenge
- References with relevant evidence
- Inbox notes with partial answers
- Concepts or projects that relate

## Phase 4: Create question note

Generate a slug from the question (lowercase, hyphenated, max 6 words). Create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "{question phrased clearly}"
type: position
classification: question
testable: true
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
stage: forming
confidence: low
---

## Context

{Why this question matters, what prompted it. 2-3 sentences.}

## Evidence So Far

- {Any existing vault notes with relevant evidence, as wikilinks with context}

## Resolution

(empty until status -> resolved)
```

Include related positions and suggested tests in the body sections, not in frontmatter.

## Phase 5: Update daily note

Ensure today's daily note exists (create if missing — standard template). Append under `## Captured`:
```
- HH:MM — [question] [[{slug}]]: {question statement}
```

## Phase 6: Confirm

Report:
- Position note path (classification: question)
- Stage and confidence
- Related positions found
- Suggested tests
- Daily note updated
