---
name: youtube
description: Extract knowledge from a YouTube video transcript — claims, positions, and reference note. Use when user shares a YouTube video for deep analysis. Add "comments" before the URL to extract comments instead of transcript.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(*/tools/yt-transcript.sh *), Bash(*/yt-dlp *), Bash(python3 *), Bash(node *), Bash(mkdir *), Bash(cp *), Bash(test *), AskUserQuestion, mcp__youtube-enhanced__get_transcript, mcp__youtube-enhanced__search_video_transcript
argument-hint: "[comments] [YouTube URL or path to transcript file]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

(At start of execution, use Glob to check: existing positions in notes/positions/ for matching during claim extraction.)

# /youtube — YouTube Knowledge Extraction Pipeline

**Mode detection**: If `$ARGUMENTS` starts with `comments` (e.g., `/youtube comments https://...`), jump to **COMMENTS MODE** below. Otherwise, run the standard transcript extraction pipeline.

Extract claims from a YouTube transcript, match them to vault positions, and create a reference note.

---

## Phase 1: Acquire transcript

**Dedup check first**: Grep `sources/youtube/` and `notes/references/` for the URL. If already extracted, report "Already extracted: {path}" and ask whether to re-extract or skip.

Detect input type:
- **YouTube URL** (contains `youtube.com` or `youtu.be`) → acquire transcript using the cascade below
- **File path** → read the file. Look for a URL on the first line for metadata.
- **Neither** → tell the user you need a YouTube URL or transcript file path

### Transcript acquisition cascade (for URLs)

1. **Primary — yt-dlp**: Run `tools/yt-transcript.sh "{url}"` via Bash. Output is a JSON metadata line followed by clean transcript text. Parse the first line as JSON for title, channel, duration.
2. **Fallback — MCP**: If yt-dlp fails (no subs, network error), try `mcp__youtube-enhanced__get_transcript`.
3. **Last resort**: Tell the user neither method worked and suggest pasting the transcript directly.

## Phase 2: Store raw transcript

Write to `sources/youtube/YYYY-MM-DD-{title-slug}.md`:

```yaml
---
title: "YYYY-MM-DD {video title}"
channel: "{channel name}"
url: "{youtube URL}"
duration: "{duration or 'unknown'}"
fetched: YYYY-MM-DD
---

{full transcript text}
```

Title slug: lowercase, hyphenated, max 6 words from the video title.

**Chapter markers**: If the transcript contains chapter/section headers (capitalized lines, `[timestamp] Title` patterns, or obvious topic shifts), preserve them as `## ` markdown headers in the stored transcript.

**Input file cleanup**: If the input was a file path outside `sources/youtube/`, inform the user: "Original file at {path} can be deleted — canonical copy is now in sources/youtube/{filename}."

## Phase 3: Signal assessment

Scan the transcript and classify density:
- **high** — dense with claims, data, frameworks, or novel insights (educational, analytical, interview with expert)
- **medium** — mix of substance and filler (typical podcast, panel discussion)
- **low** — mostly entertainment, self-promotion, or common knowledge

Report to user: "Signal: {level} — {one-line reasoning}"

If signal is **low**, run a lightweight path: store transcript, write a brief summary reference note, update daily note. Skip claim extraction and position matching — not worth the token cost.

## Phase 4: Extract claims

Analyze the full transcript. Extract 3-15 claims depending on density.

For each claim, determine:
- `type`: factual_claim | causal_claim | prediction | technique | assessment | framework | definition
- `claim`: one clear sentence stating the claim
- `quote`: supporting quote from transcript (keep short)
- `significance`: high | medium | low
- `novel`: true | false (is this commonly known or genuinely insightful?)

**Filter out**: common knowledge, self-promotion, repetitions, pure context-setting, vague statements.

Prioritize: specific data points, causal arguments, predictions with timeframes, named frameworks, contrarian takes.

## Phase 5: Match claims to vault positions

For each significant claim (high or medium significance):

1. Extract 2-3 key terms
2. Grep `notes/positions/` for those terms
3. Grep `notes/` broadly for related notes

Categorize each claim's relationship to existing positions:
- **REINFORCES** — supports an existing position's thesis
- **CHALLENGES** — contradicts or weakens an existing position
- **SEEDS** — no matching position exists, but the claim is strong enough to warrant a new position
- **INFORMS** — relevant to vault knowledge but doesn't map to a position (useful context)

If `notes/positions/` is empty (cold start), all significant claims become SEEDS candidates. Use judgment — not every claim deserves a position. Look for claims that are:
- Thesis-like (asserting something debatable)
- Relevant to the user's interests (check existing tags, areas, projects)
- Specific enough to track over time

## Phase 6: Update/create positions

### REINFORCES
- Read the matching position note
- Add a bullet to `## Evidence For`:
  ```
  - [[{reference-slug}]] — {claim with context} (YYYY-MM-DD)
  ```
- If the evidence is particularly strong, add an Evolution entry:
  ```
  - **YYYY-MM-DD** — Reinforced by {video title}: {brief context}
  ```

### CHALLENGES
- Read the matching position note
- Add a bullet to `## Evidence Against`:
  ```
  - [[{reference-slug}]] — {claim with context} (YYYY-MM-DD)
  ```
- Add Evolution entry:
  ```
  - **YYYY-MM-DD** — Challenged by {video title}: {brief context}
  ```
- If the challenge is strong and position was `held`, consider changing status to `challenged`

### SEEDS
- Before creating, run Stage 1 dedup: grep `notes/positions/` for 2-3 key terms from the proposed title. Apply the ≥70% title-overlap threshold. If flagged, surface the existing note and ask: "Similar position exists: [[{slug}]]. Update it, or create new?" If "update", add Evidence For instead. If "new", proceed.
- Create a new position note in `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {thesis derived from claim}"
type: position
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: exploring
confidence: exploring
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Thesis

{One paragraph expanding the claim into a trackable position.}

## Evidence For

- [[{reference-slug}]] — {original claim} (YYYY-MM-DD)

## Evidence Against

- (none yet)

## Evolution

- **YYYY-MM-DD** — Seeded from "{video title}" ({channel}). Starting at exploring/exploring.
```

Use judgment on how many positions to seed. 1-5 is typical. Don't create positions for every claim.

### INFORMS
- Skip unless the claim is highly actionable, in which case create an inbox note.

## Phase 7: Create reference note

**Pre-write dedup check**: Before creating, grep `notes/references/` for 2-3 key words from the video title. If hits found, apply ≥70% title-overlap threshold. Also check if the YouTube URL already appears in any reference note's `source:` field. If flagged, surface the existing note and ask: "Similar reference exists: [[{slug}]]. Update it, or create new?" If "update", add to the existing note's Key Claims section. If "new", proceed.

Generate a slug from the video title. Create `notes/references/YYYY-MM-DD-ref-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {video title}"
type: reference
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: "{youtube URL}"
source_type: video
channel: "{channel name}"
duration: "{duration}"
transcript: "sources/youtube/{transcript-filename}"
signal: {high|medium|low}
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Summary

{2-4 sentence summary of the video's main argument/content.}

## Key Claims

### High Significance
- {claim} — {type}. {→ [[position-slug]] if matched}

### Medium Significance
- {claim} — {type}. {→ [[position-slug]] if matched}

## Positions Affected

- [[position-slug]] — {REINFORCED|CHALLENGED|SEEDED}
- ...

## Related

- {Wikilinks to related vault notes found during search}
```

## Phase 8: Update daily note

Ensure today's daily note exists (create if missing — standard template). Append under `## Captured`:
```
- HH:MM — [video] [[{reference-slug}]]: {title} ({channel}). {n} claims, {m} positions updated/created. Signal: {level}.
```

## Phase 9: Report

Summarize what was done:

```
YouTube extraction complete:
- Video: {title} by {channel} ({duration})
- Signal: {level}
- Transcript: sources/youtube/{filename}
- Reference: notes/references/{slug}.md
- Claims extracted: {n} ({breakdown by significance})
  - {n} high, {n} medium, {n} low
- Positions:
  - Reinforced: {list or "none"}
  - Challenged: {list or "none"}
  - Seeded: {list with paths or "none"}
  - Informed (no position match): {count}
- Daily note updated
```

## Phase 9b: Log absorption

Append one JSONL line to `knowledge/absorption-log.jsonl`:

```json
{"timestamp": "{ISO 8601 now}", "type": "youtube", "source": "notes/references/{slug}.md", "source_author": "{channel name}", "domain_tags": [{tags from reference note}], "claims_extracted": {n}, "positions_seeded": {count of SEEDS}, "positions_reinforced": {count of REINFORCES}, "absorption_state": "{committed if any positions seeded/reinforced, otherwise seen}"}
```

Skip this step for COMMENTS MODE — comments extraction is not content absorption.

---

# COMMENTS MODE

Triggered when input starts with `comments`. Extract all comments + replies from a YouTube video as structured markdown, with optional visual screenshot capture.

Usage:
- `/youtube comments <url>` — extract comments to markdown
- `/youtube comments <url> --screenshots` — also capture visual screenshots via Puppeteer

## Comments Phase 1: Extract via yt-dlp

**Dedup check**: Look for existing `sources/youtube/*-comments.md` files matching this video ID. If found, report and ask whether to re-extract.

Extract the video ID from the URL. Run:

```bash
/opt/homebrew/Caskroom/miniconda/base/bin/yt-dlp \
  --write-comments --write-info-json --skip-download \
  -o "%(id)s" \
  -P sources/youtube/ \
  "{url}"
```

This creates `sources/youtube/{videoId}.info.json` with all comments in the `comments` array.

## Comments Phase 2: Parse to markdown

Run the parser:

```bash
python3 tools/yt-comments-to-md.py \
  sources/youtube/{videoId}.info.json \
  sources/youtube/{date}-{title-slug}-comments.md
```

Title slug: lowercase, hyphenated, max 6 words from the video title.

## Comments Phase 3: Screenshots (only if `--screenshots` flag present)

Check if the Puppeteer screenshotter is installed:

```bash
test -f /Users/ritual/Projects/Development/rla-story-dev-clean/SYSTEM/tools/youtube/comment-screenshotter/capture-comments.js && echo "installed" || echo "missing"
```

If installed, run it:

```bash
cd /Users/ritual/Projects/Development/rla-story-dev-clean/SYSTEM/tools/youtube/comment-screenshotter && \
node capture-comments.js "{url}" ~/Downloads/youtube-comment-archive/{videoId}/
```

**Important**: This launches a headed browser. It runs in the background. Monitor with TaskOutput. The script:
1. Opens Chrome with persisted session (no login needed after first run)
2. Scrolls to load all comments
3. Expands all reply threads
4. Captures scroll-and-stitch screenshots as numbered PNG chunks

## Comments Phase 4: Copy to registered repo (if applicable)

Check if the current working directory or the video's context maps to a registered repo. For RLA content, copy outputs to:

```
rla-story-dev-clean/collections/social_media/youtube/{date}-{slug}-comments.md
rla-story-dev-clean/collections/social_media/youtube/screenshots/  (if screenshots were captured)
```

For other repos or general use, outputs stay in `sources/youtube/`.

## Comments Phase 5: Update daily note

Append under `## Captured`:
```
- HH:MM — [comments] {video title}: {n} comments ({m} top-level, {r} replies) extracted. {screenshots note if applicable}
```

## Comments Phase 6: Report

```
YouTube comments extracted:
- Video: {title}
- Comments: {total} ({top-level} top-level, {replies} replies)
- Markdown: sources/youtube/{filename}
- Screenshots: {path or "skipped (use --screenshots to capture)"}
- Repo copy: {path or "n/a"}
- Daily note updated
```

## Comments Phase 7: Cleanup

The `{videoId}.info.json` file can be large (contains full video metadata + comments). Inform the user:
"Raw JSON at sources/youtube/{videoId}.info.json ({size}). Keep for re-processing or delete to save space."

Also clean up the thumbnail if one was downloaded:
```bash
rm -f sources/youtube/{videoId}.webp 2>/dev/null
```
