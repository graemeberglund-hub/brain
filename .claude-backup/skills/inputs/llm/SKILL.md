---
name: llm
description: Extract knowledge from LLM conversation outputs (GPT, Claude, Gemini). Creates timestamped position, decision, and inbox notes. Use when user has an LLM conversation or model output to ingest.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mv *), AskUserQuestion
argument-hint: "[path to markdown file]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`

(At start of execution, use Glob to check: existing positions in notes/positions/ for dedup and linking.)

# /llm — LLM Conversation Knowledge Extraction

Extract knowledge from LLM conversation outputs and create timestamped vault notes.

---

## Phase 1: Acquire source

Read the file at the provided path. If the file doesn't exist, tell the user and stop.

Detect the content type:
- **Single model output** — one continuous document (like a context handoff, analysis, or essay)
- **Back-and-forth conversation** — alternating user/assistant messages
- **Multiple outputs** — several model responses concatenated in one doc

Note the type for the reference note frontmatter.

## Phase 2: Identify source model

Scan for clues about which model produced this:
- Explicit mentions ("GPT-4", "Claude", "Gemini", "o1", etc.)
- Formatting patterns (GPT tends to use bold headers + bullet lists, Claude uses longer paragraphs)
- If unclear, **you MUST ask the user** — do not guess or default to a generic name

Record: `model` (specific version, e.g. "GPT-4o", "Claude 3.5 Sonnet"), `app` (ChatGPT, Claude, Gemini, etc.)

## Phase 3: Store raw source

Generate a slug from the content's main topic (lowercase, hyphenated, max 6 words).

Move (not copy) the original file to: `sources/llm/YYYY-MM-DD-{slug}.md`

Add frontmatter to the top of the stored file:

```yaml
---
title: "YYYY-MM-DD {descriptive title from content}"
model: "{model name, e.g. GPT-4o, Claude 3.5 Sonnet}"
app: "{ChatGPT | Claude | Gemini | other}"
content_type: "{single-output | conversation | multi-output}"
source_file: "{original filename}"
ingested: YYYY-MM-DD
---

{original content unchanged}
```

Create `sources/llm/` directory if it doesn't exist.

Inform the user: "Source moved to sources/llm/{filename}"

## Phase 4: Signal assessment

Classify the content density:
- **high** — dense with hypotheses, frameworks, architecture decisions, novel insights
- **medium** — mix of substance and exploration/brainstorming
- **low** — mostly generic advice, common knowledge, or thin exploration

Report: "Signal: {level} — {one-line reasoning}"

If **low**: store source, write a brief summary reference note, update daily note. Skip detailed extraction.

## Phase 5: Extract knowledge

Analyze the full content. Categorize extractable knowledge into buckets:

### Hypotheses (→ position notes)
Statements that assert something debatable, testable, or trackable. Look for:
- Explicit hypotheses or theses
- Strong claims about how things work
- Predictions about outcomes
- Beliefs worth tracking over time

For each: `hypothesis`, `confidence_expressed` (if any), `supporting_reasoning`

### Decisions (→ decision notes)
Choices or trade-offs made during the conversation. Look for:
- "We decided to...", "Going with X over Y"
- Architecture choices, tool selections, strategic pivots
- Explicit trade-off reasoning

For each: `decision`, `alternatives_considered`, `reasoning`

### Open questions (→ inbox notes)
Unresolved questions that need future work. Look for:
- Explicit "unanswered questions" sections
- "We need to figure out..."
- Questions asked but not resolved

Consolidate related questions into a single inbox note with sub-questions rather than creating one note per question. Group by theme.

For each (or each group): `question`, `context`

### Concepts (→ inbox notes, user promotes)
Frameworks, mental models, or design principles worth naming. Look for:
- Named patterns or principles
- Architecture patterns
- Reusable frameworks

For each: `concept`, `description`

### Product/project ideas (→ inbox notes, user promotes)
Concrete product concepts, project scopes, or MVP definitions. Look for:
- Product descriptions with target users
- MVP definitions
- Feature specs

For each: `idea`, `description`

**Filter out**: filler, repetition, common knowledge, pure context-setting, generic LLM advice.

## Phase 6: Scan vault for related notes + Stage 1 dedup

For each extracted hypothesis and decision:
1. Extract 2-3 key terms
2. Grep `notes/positions/` for those terms
3. Grep `notes/projects/` and `notes/positions/` (filter `classification: decided`) for those terms
4. Grep `notes/concepts/` for those terms

Cast a wide net — use multiple search terms per item (synonyms, abbreviations). Report what exists with brief relevance notes. These become `related:` wikilinks and `area:` links in the created notes.

**Dedup threshold rule (for position and decision notes)**: After grepping, check each hit for title overlap:
- **Title overlap**: If ≥70% of significant words in the shorter title appear in an existing note's title, flag it as a probable duplicate.
- **Tag overlap**: If ≥3 proposed tags match an existing note's tags, flag as a secondary signal.

**Conflict surfacing**: Before writing ANY notes, collect all flagged conflicts across hypotheses and decisions. Then ask the user ONCE:
> "Found potential duplicates before creating notes:
> - Hypothesis '{title}' may duplicate [[{existing-slug}]]
> - Decision '{title}' may duplicate [[{existing-slug}]]
> For each: update existing, create new, or skip?"

Collect the user's answers and apply them batch-wise — do not ask per note. If the user says "create all" or "skip dedup", proceed without asking.

**Naming**: If a slug already exists for today's date (not a duplicate, just a naming collision), add a `-2` suffix.

## Phase 6b: Thesis contradiction check (positions only)

After Phase 6 dedup, for each hypothesis that will become a NEW position note (not updating an existing one):
1. Extract the core claim
2. Generate 3-5 opposition terms (negations of key claims)
3. Grep `notes/positions/` for those opposition terms
4. If genuine tension found: surface it informally before writing:
   > "Potential contradiction with [[{slug}]]: {one-line tension}. Proceed?"
   - Informational only — user proceeds regardless.
   - If proceeding: note the tension in the new note's Evolution section.

Group all contradiction alerts and surface them once, not per-hypothesis. Skip for hypotheses where Phase 6 resulted in "update".

## Phase 7: Create notes

### Position notes (from hypotheses)

For each hypothesis worth tracking, create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {thesis statement}"
type: position
classification: belief
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
stage: exploring
confidence: low
area: "[[{area-slug}]]"              # optional — link to relevant area note if one exists
parent: "[[{parent-position-slug}]]" # optional — broader thesis this falls under
source: "[[{reference-slug}]]"
independence_group: "{source-slug}"  # same for all positions from this session — enables retrieval dedup
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Thesis

{One paragraph expanding the hypothesis into a trackable position.}

## Evidence For

- [[{reference-slug}]] — {supporting reasoning from the conversation} (YYYY-MM-DD)

## Evidence Against

- (none yet)

## Related

- [[{sibling-position-slug}]] — {how related}
- [[{existing-vault-note}]] — {connection}

## Evolution

- **YYYY-MM-DD** — Seeded from LLM session ({model}, {app}). Starting at exploring/exploring.
```

Use judgment — not every hypothesis deserves a position. 1-5 is typical.

**Cross-link sibling positions**: When multiple positions come from the same session, add `## Related` wikilinks between them. Positions from the same conversation are likely part of the same thesis hierarchy — consider using `parent:` to express this.

**Independence group**: All positions from the same session share the same `independence_group` value (the source slug). This field is used by the retrieval engine to detect echo-chamber evidence — positions from the same session should not be treated as independent corroboration of each other. Set this to the source slug (the slug assigned to the LLM file in Phase 3), not a UUID.

### Decision notes (from decisions)

For each decision, create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {decision statement}"
type: position
classification: decided
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
stage: acted-on
confidence: high
project: "[[{project-slug}]]"        # optional — link to project note if applicable
source: "[[{reference-slug}]]"
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Thesis

{What was decided, framed as a position.}

## Alternatives Considered

- {Alternative 1} — {why rejected}
- {Alternative 2} — {why rejected}

## Evidence For

- [[{reference-slug}]] — {reasoning from the conversation} (YYYY-MM-DD)

## Evidence Against

- (none yet)

## Evolution

- **YYYY-MM-DD** — Decision captured from LLM session ({model}, {app}).
```

### Inbox notes (from open questions, concepts, project ideas)

For each, create `notes/inbox/YYYY-MM-DD-in-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {title}"
type: inbox
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: "[[{reference-slug}]]"
inbox_type: "{question | concept | project-idea}"
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

{Content — the question, concept description, or project idea.}
```

Keep inbox notes short. They're prompts for future action, not full documents.

## Phase 8: Create reference note

This is the index note for the entire ingestion. Create `notes/references/YYYY-MM-DD-ref-{slug}.md`:

```yaml
---
title: "YYYY-MM-DD {descriptive title}"
type: reference
tags: [{relevant tags}]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: "sources/llm/{source-filename}"
source_type: llm-conversation
model: "{model}"
app: "{app}"
content_type: "{single-output | conversation | multi-output}"
signal: "{high | medium | low}"
ai_generated: "YYYY-MM-DD"
ai_model: "{your model ID, e.g. claude-opus-4-6, claude-sonnet-4-6}"
---

## Summary

{2-4 sentence summary of what this conversation/output explored.}

## Extracted

### Positions
- [[{position-slug}]] — {thesis one-liner}
- ...

### Decisions
- [[{decision-slug}]] — {decision one-liner}
- ...

### Open Questions (inbox)
- [[{inbox-slug}]] — {question}
- ...

### Concepts (inbox)
- [[{inbox-slug}]] — {concept}
- ...

### Project Ideas (inbox)
- [[{inbox-slug}]] — {idea}
- ...

## Related

- {Wikilinks to related vault notes found during search}
```

## Phase 9: Update daily note

Ensure today's daily note exists (create if missing — standard template). Append under `## Captured`:
```
- HH:MM — [llm] [[{reference-slug}]]: {title} ({model}). {n} positions, {m} decisions, {k} inbox items. Signal: {level}.
```

## Phase 10: Report

```
LLM ingestion complete:
- Source: {original filename} → sources/llm/{new filename}
- Model: {model} ({app})
- Content type: {single-output | conversation | multi-output}
- Signal: {level}
- Reference: notes/references/{slug}.md
- Extracted:
  - Positions: {list with paths, or "none"}
  - Decisions: {list with paths, or "none"}
  - Inbox: {list with paths, or "none"}
- Daily note updated
```

## Phase 10b: Log absorption

Append one JSONL line to `knowledge/absorption-log.jsonl`:

```json
{"timestamp": "{ISO 8601 now}", "type": "llm", "source": "notes/references/{slug}.md", "source_author": "{model} via {app}", "domain_tags": [{tags from reference note}], "claims_extracted": {count of hypotheses + decisions + questions extracted}, "positions_seeded": {count of new position notes}, "positions_reinforced": 0, "absorption_state": "{committed if any positions created, otherwise seen}"}
```
