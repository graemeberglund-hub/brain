---
name: feedback-capture
description: "Log skill output quality — accepted, edited, rejected, or deferred. Builds the learning signal for skill improvement. Use when recording whether a skill output was useful."
allowed-tools: Read, Write, Edit, Glob, Bash(date *), Bash(mkdir *), Bash(wc *)
argument-hint: "skill-name accepted|edited|rejected|deferred ['context'] | report [skill-name]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Read to check: whether knowledge/feedback-ledger.jsonl exists and count its lines.)

# /feedback-capture — Log Skill Quality Signal

You are recording whether a skill's output was useful. This is the sensor layer for the learning loop — without this data, the system can't improve.

## Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **skill** — name of the skill that produced output (e.g., `capture`, `digest`, `briefing`)
- **action** — one of:
  - `accepted` — output used as-is
  - `edited` — output used but modified
  - `rejected` — output discarded
  - `deferred` — output saved but not acted on
- **context** — optional free-text explaining why (especially important for `edited` and `rejected`)

If arguments are missing, infer from conversation context:
- Look at the most recent skill invocation in this session
- Ask which action applies if unclear

## Step 2: Build Feedback Event

Construct a JSON object:

```json
{
  "timestamp": "{ISO 8601}",
  "date": "{YYYY-MM-DD}",
  "skill": "{skill-name}",
  "action": "{accepted|edited|rejected|deferred}",
  "context": "{user's explanation or empty string}",
  "session_skills_before": {number of skills run before this one in session, if known, else null},
  "edit_delta": "{brief description of what changed, for 'edited' action, else null}"
}
```

## Step 3: Write to Ledger

Append the JSON object as a single line to `knowledge/feedback-ledger.jsonl`.

If the file doesn't exist, create it with a comment header:

```
// feedback-ledger.jsonl — skill quality signal for learning loop
// Schema: {timestamp, date, skill, action, context, session_skills_before, edit_delta}
// Written by: /feedback-capture
```

Then append the event.

## Step 3.5: Emit Activation-Compatible Event

After writing to the feedback ledger, also append to `knowledge/activation-feedback.jsonl` for the activation layer's learning loop.

Map feedback-capture actions to activation actions:
- `accepted` → `accepted`
- `edited` → `accepted` (still used, just modified)
- `rejected` → `rejected`
- `deferred` → `ignored`

Append a single JSON line:
```json
{"timestamp": "{ISO 8601}", "candidate_id": null, "skill_ref": "{skill-name}", "action": "{mapped action}", "context": "{context from Step 1}", "state_fingerprint": null}
```

If the file doesn't exist, create it (no header needed — pure JSONL).
If this step fails for any reason, log a note and continue — do not block the main feedback flow.

## Step 4: Check for Patterns (lightweight)

If the ledger has 10+ entries, do a quick scan:
- Count actions by skill — any skill with 3+ rejections? Flag it.
- Count actions by type — what's the overall accept/reject ratio?
- Most recent 5 entries — any trend?

Only surface patterns if they're notable. Don't force analysis on small datasets.

## Step 5: Confirm

Report (keep it brief):
```
Logged: {skill} → {action}
Ledger: {total entries} events ({accepted count} accepted, {rejected count} rejected)
{Pattern note if any, else omit}
```

## Passive Capture Note

This skill is designed for explicit invocation. Future enhancement: a PostToolUse hook that automatically prompts for feedback after skill runs. For now, the user says things like:
- "that briefing was good" → `feedback-capture briefing accepted`
- "the digest missed the point" → `feedback-capture digest rejected 'missed connection to gold position'`
- "I had to fix the capture tags" → `feedback-capture capture edited 'tags were wrong'`

The agent router should recognize these natural language patterns and route here.

## Step 6: Report Subcommand

If $ARGUMENTS starts with "report":

1. Read `knowledge/feedback-ledger.jsonl` in full
2. Group entries by skill name
3. For each skill with 5+ entries, calculate:
   - Accept rate: accepted / total
   - Edit rate: edited / total
   - Rejection rate: rejected / total
   - Common edit deltas: group edit_delta values by similarity
   - Common rejection reasons: group rejected context values
   - Trend: compare last 10 entries to previous 10 (improving/stable/declining)
4. If a specific skill name is given as argument, filter to that skill only

Write report to `activity/reports/feedback/{today}-feedback-report.md`:

```markdown
---
title: "Feedback Report — {date}"
type: reference
tags: [feedback, learning-loop]
created: {today}
---

## Overall
- Total events: {N}
- Accept rate: {%}
- Skills tracked: {N}

## Per-Skill Breakdown

### {skill-name}
- Events: {N} (accepted: {n}, edited: {n}, rejected: {n}, deferred: {n})
- Accept rate: {%}
- Common edits: {list or "none"}
- Common rejections: {list or "none"}
- Trend: {improving|stable|declining}

{repeat for each skill with 5+ entries}

## Patterns
- {Notable cross-skill patterns}
- {Skills that should be investigated}
```

Also output the report summary to stdout.
