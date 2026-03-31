---
name: decision
description: Log a structured decision. Use when user states a decision, choice, or trade-off they've made.
allowed-tools: Read, Write, Edit, Glob, Bash(date *)
argument-hint: "[decision topic and context]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /decision — Structured Decision Log

Create a decision note and link it from today's daily note.

## 1. Create the decision note

Generate a slug from the decision topic (lowercase, hyphenated, max 5 words). Create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {decision topic}"
type: position
classification: decided
testable: true
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
project: "[[{project-slug}]]"
stage: acted-on
confidence: high
---

## Context

{What situation requires this decision?}

## Options

{Options mentioned in input, or numbered placeholders}

## Decision

{Decision stated in input, or blank for user to fill}

## Consequences

{Inferred consequences, or placeholder bullets}

## Related

- {Wikilinks detected in input}
```

## 2. Link to project and set status

Read the input and understand which project it relates to — you have the project notes in `notes/projects/` for context. Set the `project:` field accordingly. If no project fits, leave it empty and mention that.

Assess the decision stage from the input: a clear choice is `acted-on` (confidence: high), weighing options is `exploring` (confidence: medium), questioning a past decision is `exploring` (confidence: low).

## 3. Update today's daily note

Ensure today's daily note exists (create if not — see dynamic context above for status). Append under `## Decisions`:
```
- HH:MM — [[{slug}]]: {one-line summary}
```

## 4. Confirm

Report:
- Position note path (classification: decided)
- Stage and confidence assigned
- Project linked (if any)
- Daily note updated
