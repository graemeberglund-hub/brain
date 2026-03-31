---
name: reference
description: Capture an external reference (article, video, tool, paper). Use when user shares a URL, article, video, tool, or paper.
allowed-tools: Read, Write, Edit, Glob, Bash(date *), WebFetch
argument-hint: "[URL and/or description of the reference]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /reference — External Reference Capture

Create a reference note and link it from today's daily note.

## 1. Understand the source

If a URL is present, understand what kind of source it is from the URL and any context provided. Set `source_type` to: `article`, `video`, `tool`, `paper`, or `case-study`.

If no URL, determine the source type from the description.

## Step 1b: Pre-write dedup check

Before creating the reference note:
1. Extract 2-3 key words from the reference title or URL domain/path
2. Grep `notes/references/` for those key words
3. If hits found: check title overlap — if ≥70% of significant words in the shorter title appear in a found note's title, flag it. Also flag if the URL exactly matches an existing note's `source:` field.
4. Secondary signal: if ≥3 tags match an existing note, flag it.
5. If flagged: surface the existing note(s) and ask:
   > "Similar reference exists: [[{existing-slug}]]. Update it, or create new?"
   - "update" → open existing note, update Summary/Why It Matters, skip creation
   - "new" → proceed with creation

**Skip this check if** user has said "create all", "skip dedup", or "force create" earlier in the conversation.

## 2. Create the reference note

Generate a slug from the reference title/topic (lowercase, hyphenated, max 5 words). Create `notes/references/YYYY-MM-DD-ref-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {reference title or topic}"
type: reference
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: "{URL if provided, otherwise empty string}"
source_type: {detected type}
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
concepts_mentioned: [{concept-1}, {concept-2}]
---

## Summary

{Brief description based on input context}

## Why It Matters

{Inferred relevance, or placeholder}

## Related

- {Wikilinks detected in input}
```

## 3. Fetch content if URL provided

If a URL was provided, use WebFetch to get the page title and a brief summary. Use the fetched title as the note title if it's better than what was provided. Add key points to the Summary section.

## 4. Update today's daily note

Ensure today's daily note exists (create if not — see dynamic context above for status). Append under `## Captured`:
```
- HH:MM — [{source_type}] [[{slug}]]: {one-line summary}
```

## 5. Confirm

Report:
- Reference note path
- Source type detected
- URL captured (if any)
- Daily note updated

## 6. Log absorption

Append one JSONL line to `knowledge/absorption-log.jsonl`:

```json
{"timestamp": "{ISO 8601 now}", "type": "{source_type}", "intent": "evaluative", "source": "notes/references/{slug}.md", "source_author": "{author if determinable}", "domain_tags": [{tags}], "claims_extracted": 0, "techniques_extracted": 0, "positions_seeded": 0, "positions_reinforced": 0, "claims_created": [], "positions_affected": [], "absorption_state": "seen", "absorption_history": [{"state": "seen", "date": "{ISO now}", "trigger": "reference"}]}
```

Intent is usually `evaluative` (default). For applied references (tutorials, how-tos), use `intent: "applied"` and add a `## Techniques` section to the reference note body. This is a lightweight entry — /reference doesn't extract claims. The `seen` state tracks consumption volume for `/drift` pattern detection.
