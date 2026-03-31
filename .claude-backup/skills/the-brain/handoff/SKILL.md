---
name: handoff
description: Session end ritual — record decisions, flag unresolved questions, surface inbox depth, emit operational events. Writes to daily note and operational-ledger.jsonl.
allowed-tools: Read, Write, Edit, Glob, Bash(date *), Bash(find *), Bash(wc *)
dashterm: true
---

TODAY=!`date +%Y-%m-%d`
NOW=!`date +%H:%M`
BRAIN_DIR=/Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob to check: inbox count by listing notes/inbox/*.md files excluding .gitkeep.)

# /handoff — Session End

**Note:** Automatic session capture is now active. The SessionEnd hook writes session metadata to `knowledge/session-index.jsonl`, and the metabolism daemon extracts structured intelligence from full transcripts. `/handoff` remains useful for explicit decision recording and active-context updates, but session context is no longer lost if you skip it. Boot will reconstruct context from micro-captures and daemon extractions.

Arguments: none (infer from conversation context and file reads)

Quick mode: if user says "quick handoff" or "just flag WIP" — skip steps 1-2, run only steps 3-5.

## Step 1: Session capture

Ask the user: "What decisions were made this session? What should be captured?"
- Accept free-form input
- For each confirmed decision: append to today's daily note ## Decisions section with format: `- HH:MM — {decision text}`
- If user says "none" or skips: do not write to daily note

If daily note does not exist: create it before writing (same template as /capture uses).

## Step 1.1: Operational event emission

For each decision captured in Step 1, check if it maps to an existing position or preference:

1. Glob `notes/positions/*.md` and read each position note's title and `## Thesis` section
2. For each decision, determine:
   - **APPLIED** — the decision reflects acting on a held position (e.g., "chose DuckDB" maps to a position about DuckDB superiority)
   - **OVERRIDDEN** — the decision contradicts an existing position or preference (e.g., "went with SQL Server instead" when a position favors DuckDB)
   - **No match** — the decision doesn't clearly map to any tracked position. Skip it.

3. For each matched decision, append a JSON line to `knowledge/operational-ledger.jsonl`. **Use the Edit tool** — read the file first, then append the JSON line after the last line. Each event is one line:

```json
{"timestamp": "{ISO8601}", "verb": "APPLIED|OVERRIDDEN", "source": "handoff:{TODAY}", "target": "notes/positions/{position-slug}.md", "target_type": "position", "decision": "{decision text from daily note}", "reasoning": "{one sentence: why this decision reflects/contradicts the position}", "confidence": 0.7, "inference_mode": "handoff-decision-mapping", "session_reported": true}
```

Rules:
- Only emit events for clear, non-ambiguous mappings. When in doubt, skip.
- Confidence range: 0.6 (loose thematic match) to 0.9 (direct, explicit alignment)
- `session_reported: true` distinguishes user-reported events from auto-detected ones
- Do NOT ask the user to confirm each mapping — this runs silently after decision capture
- If no decisions were captured, skip this step entirely
- Log count in close report: "Operational events: {N} APPLIED, {N} OVERRIDDEN"

## Step 1.5: Preference shift check

Read ~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/profile.yml (if it exists).

If any of these occurred during the session:
- New collaborator mentioned (not in profile.yml collaborators list)
- Explicit preference change ("be more concise", "use bullets", "stop doing X")
- Workspace boundary change ("don't touch that repo", "add this API")

Then update profile.yml with the changes. Log the delta in the close report.

If no preference shifts detected:
- Do not modify profile.yml
- Note "Profile: unchanged" in close report

If profile.yml does not exist:
- Skip this step entirely

## Step 2: Unresolved questions

Scan today's daily note ## Captured section for lines containing `?` or starting with "open:".
List any found as unresolved thread pointers.
Ask: "Any of these need a question note?" — for each yes, remind: "Run /question {text}"

## Step 3: Mini-triage signal

If INBOX_COUNT >= 15: "⚠ Inbox at cap ({N} items) — /capture is blocked until you triage."
If INBOX_COUNT >= 10: "Inbox has {N} items — consider running /triage before next session."
If INBOX_COUNT < 10: no message needed.

## Step 4: Recommendation completion tracking

Check if `knowledge/recommendation-state.json` exists. If so:

Note: recommendation-state.json maintains dual indexes (by_recommendation_id and by_cluster_action).
   When the file exceeds 200 recommendations, consolidate to single index by recommendation_id
   with by_cluster_action computed at read time. Current count: 26.

1. Read the file and identify all recommendations with `last_published_at` set but `last_completed_at` still null
2. Cross-reference against decisions captured in Step 1 and skills run during this session (infer from conversation context)
3. For each recommendation that was **acted on** (the user ran the suggested skill, or a decision aligns with the recommendation's action):
   - Update its entry: set `last_completed_at` to current ISO timestamp, increment `completion_count`
   - Append a completion event to `knowledge/recommendation-events.jsonl`:
     ```json
     {"timestamp": "{ISO8601}", "event": "completed", "recommendation_id": "{id}", "source": "handoff"}
     ```
4. Unacted recommendations are left as-is — they age out naturally when the activation engine regenerates candidates. No explicit expiry tracking needed.
   Note: recommendation-events.jsonl is consumed by dashterm observability tooling,
   not by pipeline skills. If dashterm is not active, this write is safely inert.
5. If `meta.published_served` has more than 100 entries, prune entries older than 30 days.
   Keep at most 100 entries. This prevents unbounded growth of audit metadata.
6. Log in close report: "Recommendations: {N} completed"

If `recommendation-state.json` doesn't exist, skip this step.

## Step 4.7: STATUS.md session update

Determine the current working repo from conversation context (the repo the user was working in, not necessarily brain).

If `STATUS.md` exists in that repo's root:

1. Read the current STATUS.md
2. Update the `## Session` section with:

```markdown
## Session
<!-- AUTO-UPDATED by status-update.sh intent layer or /handoff -->
**Now**: {synthesize from conversation — what was accomplished this session}
**Next**: {synthesize from decisions + conversation — next actions}
**Blocked**: {any blockers mentioned, or "None"}

_Source: handoff | {TODAY}T{NOW}_
```

3. Preserve all other sections exactly as-is (especially `## State` and `## Log`)

If no STATUS.md exists in the repo, skip silently.

Add to close report: `STATUS.md: updated ({repo-name}) | skipped (no STATUS.md)`

## Step 5: Close report

```
SESSION END — {TODAY} at {NOW}

Decisions recorded: {N}
Operational events: {N} APPLIED, {N} OVERRIDDEN {| skipped (no decisions)}
Recommendations: {N} completed {| n/a (no state file)}
Unresolved questions flagged: {N}
Inbox: {INBOX_COUNT} items {| ⚠ at cap if >= 15}
Profile: {updated (fields changed) | unchanged | n/a (no profile.yml)}
STATUS.md: {updated ({repo}) | skipped (no STATUS.md)}
```
