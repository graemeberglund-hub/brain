---
name: triage
description: Triage inbox notes into their proper destinations. Use when user wants to clean up, organize, or process inbox notes.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(ls *), Bash(mv *), Bash(date *), Bash(sed *)
argument-hint: "[optional filter text]"
dashterm: true
---

filter = $ARGUMENTS

Inbox count: !`find notes/inbox -name "*.md" -not -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' '`

# /triage — Inbox Conveyor Belt

You are triaging notes from `notes/inbox/` into their proper canonical locations.

## Steps

### 0. WIP cap check

Inbox count: {INBOX_COUNT from dynamic context}

If inbox count > 15:
- Emit: "⚠ INBOX OVER CAP: {inbox_count} items (limit: 15). /capture is blocked until this drops below 15."
- Do NOT block triage — triage is the solution, not the problem
- Continue to Step 1 with this warning visible

### 1. Scan the inbox

- List all `.md` files in `notes/inbox/` (exclude `.gitkeep`)
- If a filter argument was provided, only show notes whose filename or title matches
- Read each note's frontmatter and content
- If inbox is empty, report "Inbox is clear" and stop

### 2. For each inbox note, propose a destination

Analyze the content and propose ONE of these actions:

| Destination | When | Target Path |
|-------------|------|-------------|
| `position (decided)` | Contains a choice, trade-off, or "should we" language | `notes/positions/YYYY-MM-DD-pos-{slug}.md` (with `classification: decided`) |
| `reference` | External source, URL, case study | `notes/references/YYYY-MM-DD-ref-{slug}.md` |
| `concept` | Pattern, framework, insight, mental model | `notes/concepts/YYYY-MM-DD-con-{slug}.md` |
| `project` | Relates to a specific project's scope | `notes/projects/rla/YYYY-MM-DD-project-{slug}.md` or `notes/projects/brain/YYYY-MM-DD-project-{slug}.md` |
| `journal` | Reflection, personal observation, life/personal captures, health, relationships, existential thoughts — anything not tied to a specific project | `notes/journal/YYYY-MM-DD-journal-{slug}.md` |
| `trace` | Chronological idea evolution from a conversation or event | `notes/traces/YYYY-MM-DD-trace-{slug}.md` |
| `delete` | Stale, duplicate, or already captured elsewhere | (remove file) |
| `keep` | Not ready to triage yet | (leave in inbox) |

Present each note with its destination and duplicate context (see Step 2b below):
```
{filename}
   Title: {title}
   Preview: {first 50 chars of body}
   -> Proposed: {destination} — {reason}
   -> Duplicate signals: none
```

Or, when duplicates are flagged:
```
{filename}
   Title: {title}
   Preview: {first 50 chars of body}
   -> Proposed: {destination} — {reason}
   -> Possible duplicates:
      - [[{existing-slug}]] — {why it matched: title overlap %, tags, exact URL}
```

### 2b. Destination-aware Stage 1 dedup (per-note, inside proposal loop)

For each note where the proposed destination is a move action (`decision`, `reference`, `concept`, `project`, `journal`), run a destination-specific duplicate scan **before presenting the proposal**. Skip dedup for `delete` and `keep` actions.

**Destination-to-directory mapping:**

| Destination | Search directories |
|-------------|-------------------|
| `position (decided)` | `notes/positions/` (filter `classification: decided`) |
| `reference` | `notes/references/` |
| `concept` | `notes/concepts/` |
| `project` | `notes/projects/brain/` and `notes/projects/rla/` |
| `journal` | exempt — see below |
| `delete` / `keep` | skip dedup |

**Journal exemption**: `journal` notes are dated personal reflections covering many topics. Keyword-based dedup produces too many false positives against grab-bag journal entries. Journal destinations skip semantic dedup entirely (like `delete`/`keep`). The existing exact-path collision check in Step 4 still applies.

**Search procedure (for non-exempt destinations):**

1. Extract 2-3 significant keywords from the inbox note title / proposed slug
2. Grep the mapped canonical directory/directories for those keywords
3. Evaluate duplicate signals:
   - **Primary signal**: ≥70% title overlap using the shorter title as the denominator (count significant words in shorter title that appear in longer title)
   - **Secondary signal**: ≥3 overlapping tags, when both notes have tags
   - **`reference`-only extra signal**: exact match on `source:` URL if the inbox note contains a URL or a `source` field
4. If no signals cross threshold → mark `Duplicate signals: none` in the proposal
5. If one or more candidates are flagged → list them in the proposal under `Possible duplicates`

**Skip dedup if** user has said "create all", "skip dedup", or "force create" earlier in the conversation.

### 2c. Duplicate resolution (for flagged notes only)

For any note with flagged duplicates, the confirmation step must offer these explicit resolution choices:

- **`update existing`** — append the inbox note's useful content into the selected canonical note, then delete the inbox note
- **`create new distinct note`** — keep the proposed destination and proceed with the normal move flow
- **`delete`** — remove the inbox note as redundant
- **`keep`** — leave it in the inbox for later

**Execution semantics for `update existing`:**

1. Treat the selected canonical note as the final destination path for downstream reference repair
2. Append the inbox note body under a `## Triage Updates` section with a dated subheading. If `## Triage Updates` already exists in the canonical note (from a previous triage merge), append the new dated subheading under the existing section rather than creating a duplicate heading:

```markdown
## Triage Updates

### YYYY-MM-DD {inbox note title}
{body excerpt or full body, preserving wikilinks}
```

3. Preserve the existing canonical note title/frontmatter
4. Delete the inbox note after the append succeeds

**Constraint**: Do not invent note-type-specific merge rewrites. A dated `## Triage Updates` append is the whole merge contract.

### 3. Ask for confirmation

Present ALL proposals at once and ask user to confirm, modify, or skip each one.
Use AskUserQuestion if there are 3 or fewer notes. For larger batches, present the list and ask the user to confirm or provide corrections.

### 4. Execute moves

**Order of checks**: Semantic dedup (Step 2b) → user resolution (Step 2c) → exact-path collision (below) → write/delete/update references. This preserves today's rename/skip/merge handling for same-slug collisions while adding the earlier guard for different-slug duplicates.

For each confirmed move (including `create new distinct note` resolutions):

1. Read the original note fully
2. Update frontmatter:
   - Change `type:` to match destination (position/reference/concept/project/journal/trace)
   - For `position (decided)`: set `type: position`, `classification: decided`, `stage: acted-on`
   - Preserve original `created:` date
   - Set `updated:` to today's date
   - Add `triage_auto_routed: false`
   - Add `triage_routed_by: user`
   - Add destination-specific fields:
     - **position (decided)**: add `project: ""`, `classification: decided`, `stage: acted-on`
     - **reference**: add `source: ""`, `source_type: article`
     - **project**: add project-specific fields (name, cluster, arc, repo, etc.)
3. Move file to destination directory (write to new path, delete old). **Convention v2 filenames**: All note types use `YYYY-MM-DD-{type_tag}-{slug}.md`. If the inbox file is `YYYY-MM-DD-in-{slug}.md`, the destination file should be `YYYY-MM-DD-{tag}-{slug}.md` where `{tag}` matches the destination type (pos, con, ref, conv, journal, trace, project). All epistemic types (beliefs, questions, decisions, tastes) use `pos` tag and go to `notes/positions/` with appropriate `classification` field. Preserve the original `created:` date in the filename.
   **Collision check**: Before moving, verify the target path doesn't already exist (`ls {target_path}`). If a file exists at the destination:
   - Tell the user: "Target `{target_path}` already exists."
   - Offer options: **rename** (append `-2` or similar suffix), **skip** (leave in inbox), or **merge** (append new content to existing note)
   - Wait for user input before proceeding
4. **Update downstream references** — after moving each file, fix any references that pointed to the old inbox path:
   - **Epistemic ledger**: Grep `knowledge/epistemic-ledger.jsonl` for the old path. If found, use the Edit tool (not sed) to replace old path with new path. This avoids regex special character issues and preserves the audit trail.
   - **Wikilinks in other notes**: Grep `notes/` for `[[old-slug]]` wikilinks (using the old filename without extension). If the slug changed (e.g., date prefix stripped), use the Edit tool with `replace_all: true` to update wikilinks.
   - **Event candidates**: Grep `knowledge/event-candidates.jsonl` for the old path. If found, use the Edit tool to replace with the new path.
   - **Knowledge graph**: Grep `knowledge/graph-dev.yml`, `knowledge/graph-projects.yml`, and `knowledge/graph-epistemic.yml` for the old path/slug. If found, use the Edit tool to replace with the new slug/path.
5. For `delete` action: remove the file

### 5. Report summary

```
Triage complete:
- {n} moved to positions/ (decided)
- {n} moved to references/
- {n} moved to concepts/
- {n} moved to projects/
- {n} moved to journal/
- {n} deleted
- {n} kept in inbox
- {n} remaining in inbox
```

## Post-triage cap status

Count remaining inbox items:
- If count >= 15: "⚠ Still at cap. Run /triage again or delete notes to re-enable /capture."
- If count < 15: "Inbox under cap. /capture is re-enabled."
