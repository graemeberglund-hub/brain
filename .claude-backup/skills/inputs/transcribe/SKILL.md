---
name: transcribe
description: Transcribe a conversation from audio, extract threads, and connect to the vault.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(uv *), Bash(python *), Bash(date *), Bash(ls *), Bash(mv *), Bash(cp *), AskUserQuestion
argument-hint: "[path to audio file] [optional: speaker names]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

# /transcribe — Conversation Transcription + Thread Extraction Pipeline

You are processing a conversation recording (or existing transcript) into the vault: transcribe, name speakers, extract threads, and connect everything.

## Phase 1: Detect input type and normalize audio path

Parse `input` for:
- An audio file path (`.m4a`, `.mp3`, `.wav`, `.mp4`, `.aac`, `.flac`) → full pipeline (Phase 2+)
- An existing JSON transcript path → skip to Phase 3 (speaker naming)
- An existing markdown conversation note → skip to Phase 6 (thread extraction)

If no file path found, ask the user what they want to transcribe.

### Audio file handling

If the input is an audio file, move it to `sources/conversations/` with the canonical name format:

```
YYYY-MM-DD-speaker1-firstname-speaker2-firstname.ext
```

Example: `2026-03-06-peter-jarett.m4a`

Use today's date unless a date is clearly embedded in the original filename. Extract speaker names from either the filename or the `input` arguments. If speaker names aren't determinable yet, use a temporary name and rename after Phase 3.

Move the file:
```bash
mv "{original_path}" $BRAIN_VAULT_PATH/sources/conversations/{canonical_name}
```

Use this new path for all subsequent steps.

## Phase 2: Transcribe

Build the transcription command:

```bash
uv run --with assemblyai --with python-dotenv python $BRAIN_VAULT_PATH/tools/transcribe.py "{audio_path}" --output-dir $BRAIN_VAULT_PATH/sources/conversations/
```

Add flags as needed:
- If speaker names were provided: `--speakers "Name1,Name2"`
- **Always add `--vocabulary`** with relevant proper nouns — participant names, project names, place names, or any domain terms you can infer from context. Example: `--vocabulary "Jarett,Merrick,RLA"`

Parse the JSON summary line from stdout to get `json_path`, `md_path`, `duration_human`, `speakers`, `utterance_count`.

This step takes a few minutes. Let the user know it's running.

## Phase 3: Name speakers

Read the JSON transcript. Show the user the first 10-15 utterances with speaker labels.

Format the preview like:
```
Speaker A: "First utterance text here..."
Speaker B: "Response text here..."
Speaker A: "Next thing they said..."
...
```

**If speaker names were already provided** and diarization shows the expected number of speakers, skip confirmation — just proceed. Only ask if something looks wrong (unexpected speaker count, etc.).

**If speaker names were NOT provided**, ask: "Who are these speakers? (e.g., A=Peter, B=Jarett)"

Once names are known, update both the JSON and MD files in `sources/conversations/` with the correct speaker names. Also rename the audio file to the canonical format if it was temporarily named.

## Phase 4: Clean transcript

Read the full markdown transcript from `sources/conversations/{stem}.md`. Clean it up in a single pass, writing the result back to the same file:

### What to clean

- **Filler words**: Remove "um", "uh", "like" (when filler, not comparative), "you know", "I mean" (when filler), "sort of", "kind of" (when filler), "right?" (when rhetorical filler)
- **False starts and stutters**: "I was- I was going to" → "I was going to"
- **Repeated words**: "the the" → "the", "I I think" → "I think"
- **Trailing fragments**: Remove abandoned sentence fragments that add no meaning
- **Merge micro-utterances**: If the same speaker has multiple consecutive utterances of <5 words that form one thought, merge them into a single utterance
- **Punctuation and capitalization**: Fix missing periods, capitalize sentence starts, clean up run-on sentences into proper sentence boundaries

### What to preserve

- **Meaning and tone**: Never change what someone said, only how it reads
- **Natural speech patterns**: Keep colloquialisms, slang, contractions — this is conversation, not an essay
- **Speaker voice**: Each person should still sound like themselves
- **Emphasis and emotion**: Keep exclamations, rhetorical questions, emphatic repetition ("no no no, that's wrong")
- **Technical terms and proper nouns**: Don't "correct" domain language
- **Paragraph breaks between speakers**: Maintain the existing speaker label format

### Process

1. Read the current MD transcript
2. Clean it section by section (use Edit tool, not full rewrite, to preserve structure)
3. Also update the JSON transcript with the same cleaned text so both files stay in sync

This phase is about readability, not summarization. The transcript should still be complete — just pleasant to read.

## Phase 5: Get context

Use AskUserQuestion to ask the user for a brief context line:
"One-line context for this conversation? (when/where/why — e.g., 'Coffee catch-up at Boxcar, talking about AI and garden projects')"

## Phase 6: Write conversation note

Generate a slug from the date + participants (e.g., `2026-03-06-peter-jarett`). This should match the audio filename stem.

Create `notes/conversations/YYYY-MM-DD-conv-{slug}.md` (where slug is participant names, e.g. `jarett-peter`):

```yaml
---
title: "YYYY-MM-DD {context-derived title}"
type: conversation
tags: [{extracted tags}]
created: {today's date}
participants: [{speaker names}]
duration: "{duration_human}"
audio_source: "sources/conversations/{audio_filename}"
transcript_source: "sources/conversations/{json_filename}"
---

## Context
{user's context line}

## Threads
{filled in Phase 8}
```

The conversation note does NOT contain the transcript. The transcript lives in `sources/conversations/` as the raw MD and JSON files. The note links to them via frontmatter.

## Phase 7: Extract threads

Read the full transcript (from `sources/conversations/{stem}.md` or the JSON). Identify 3-10 discrete topics/threads discussed. For each thread:
- Short descriptive name (2-5 words)
- 1-3 sentence summary of what was discussed
- Key terms for vault search

For each thread, use Grep to search existing vault notes (`notes/` directory) for potential wikilink matches. Search for key terms, names, concepts mentioned in that thread.

## Phase 8: Connect to vault

### 8a. Ensure daily note exists

Path: `notes/daily/{today}.md`. If daily note status says "missing", create it with the standard template:

```yaml
---
title: "{today}"
type: daily
tags: []
created: {today}
---

## Work


## Decisions


## Captured


## Notes
```

### 8b. Daily note capture

Add a **single** consolidated bullet under `## Captured` (NOT one per thread):
```
- HH:MM — Transcribed call w/ {participants} ({duration}): {comma-separated thread names}. {n} threads extracted, {n} inbox notes. -> [[{conversation-note-slug}]]
```

### 8c. Inbox notes for substantial threads

For threads that are substantial enough to warrant follow-up (new ideas, actionable items, research topics), create an inbox note:

`notes/inbox/YYYY-MM-DD-in-{thread-slug}.md`:
```yaml
---
title: "YYYY-MM-DD {thread summary}"
type: inbox
tags: [{relevant tags}]
created: {today}
source_conversation: "[[{conversation-note-slug}]]"
---

{2-3 sentence expansion of the thread, including any action items or questions raised}

Discussed with {participants} on {today}.
```

Not every thread needs an inbox note — only ones with follow-up potential.

### 8d. Fill Threads section

Go back to the conversation note and fill in `## Threads`:
```markdown
- **{Thread name}** — {1-3 sentence summary}. See [[existing-note]] / -> [[inbox-note-slug]]
```

Include wikilinks to both existing vault notes (if grep found matches) and any new inbox notes created.

## Phase 9: Report

Summarize what was done:

```
Transcription complete:
- Audio: sources/conversations/{filename} ({duration})
- Speakers: {names}
- Raw transcript: sources/conversations/{json + md files}
- Conversation note: notes/conversations/{slug}.md
- Threads extracted: {n}
  - {thread name} [-> inbox note if created]
  - ...
- Daily note updated: notes/daily/{date}.md
- Inbox notes created: {n}
```

## Phase 9b: Log absorption

Append one JSONL line to `knowledge/absorption-log.jsonl`:

```json
{"timestamp": "{ISO 8601 now}", "type": "conversation", "source": "notes/conversations/{slug}.md", "source_author": "{comma-separated participant names}", "domain_tags": [{tags from conversation note}], "claims_extracted": {count of threads extracted}, "positions_seeded": 0, "positions_reinforced": 0, "absorption_state": "seen"}
```
