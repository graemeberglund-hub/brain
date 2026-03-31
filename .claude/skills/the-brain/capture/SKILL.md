---
name: capture
description: Capture a note, idea, or reference into the daily note and optionally inbox. Use when user shares a thought, idea, or observation worth remembering.
allowed-tools: Read, Write, Edit, Glob, Bash(date *)
argument-hint: "[content to capture]"
effort: low
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /capture — Daily Note + Inbox Pipeline

You are appending a capture to today's daily note and optionally creating an inbox note.

## Steps

### 1. Ensure today's daily note exists

- Path: `notes/daily/YYYY-MM-DD.md` (use today's date from dynamic context above)
- If the daily note status above says "missing", create it:

```yaml
---
title: "YYYY-MM-DD"
type: daily
tags: []
created: YYYY-MM-DD
---

## Work


## Decisions


## Captured


## Notes
```

### 2. Append to the daily note

- Add a timestamped bullet under `## Captured`:
  ```
  - HH:MM — {input content}
  ```
- Use the current time from dynamic context above (24h format)
- Preserve any `[[wikilinks]]` in the input as-is
- Extract any `#tags` from the input and keep them inline

### 3. Decide if inbox note is needed

Create an inbox note if ANY of these are true:
- Input is substantial (more than ~20 words)
- Input contains a `?` (question worth exploring)
- Input contains a URL
- Input explicitly asks to "save" or "note" something

If creating an inbox note:
- Generate a slug from the key words (lowercase, hyphenated, max 5 words)
- Extract lightweight concept tags from the content (key topics, frameworks, or domain terms mentioned)

### Step 2b: Pre-write dedup check

**Run this check only when an inbox note would be created AND** at least one of these conditions applies:
- Input is ≥20 words, OR
- Input contains a URL, OR
- Input contains a `?`

(Skip dedup for short captures that don't meet the above — they are appended to the daily note but don't create inbox notes anyway.)

**Also skip if** the user has said "create all", "skip dedup", or "force create" earlier in the conversation.

If the check runs:
1. Extract 2-3 key words from the proposed title/slug
2. Grep `notes/inbox/` for those key words
3. If hits found: check title overlap — if ≥70% of significant words in the shorter title appear in a found note's title, flag it
4. Secondary signal: if ≥3 tags match an existing note, flag it
5. If flagged: surface the existing note(s) and ask:
   > "Similar note exists: [[{existing-slug}]]. Update it, or create new?"
   - "update" → open existing note, append to its body, skip creation
   - "new" → proceed with creation

- Create `notes/inbox/YYYY-MM-DD-in-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {summary of the input}"
type: inbox
tags: [{extracted tags}]
created: YYYY-MM-DD
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
concepts_mentioned: [{concept-1}, {concept-2}]
---

{full input content, preserving wikilinks}
```

The `concepts_mentioned` field enables idea provenance tracking — the system can later trace how concepts move across intake surfaces over time. Extract 1-5 key concepts, using existing concept slugs from `notes/concepts/` when they match.

- Add a pointer in the daily note's `## Captured` entry: append ` -> [[{slug}]]`

### 4. Confirm

Report:
- What was added to the daily note
- Whether an inbox note was created (and its path)
- Any wikilinks or tags that were detected
