---
name: skill-recommend
description: "Context-aware skill suggestions — reads vault state, time, recent activity, and feedback history to recommend what to run next. Use when asking 'what should I do?'"
allowed-tools: Read, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), Bash(stat *)
argument-hint: "[--verbose]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Day of week: !`date +%A`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob and Read to gather: inbox count from notes/inbox/, feedback entry count from knowledge/feedback-ledger.jsonl, last modification of knowledge/epistemic-ledger.jsonl, and most recent file in studio/briefing/.)

# /skill-recommend — What Should I Run Next?

You are a context-aware recommendation engine. Read the current vault state, time of day, and recent activity to suggest 1-3 skills with reasoning.

## Step 0: Load activation candidates (if available)

Check if `knowledge/recommendation-candidates.json` exists. If so, read it and extract the top candidates:
- Parse the JSON and collect entries across all scopes
- Check `generated_at` at the document level — if older than 48h, treat all candidates as stale and skip (the activation engine hasn't run recently)
- Sort by `lane_score` descending
- Keep the top 5 as pre-scored suggestions

These candidates come from the activation engine (a richer, evidence-linked scoring system). Use them as **boosted inputs** to Step 2 scoring:
- If an activation candidate aligns with a skill you'd independently recommend, boost its score by +2
- If an activation candidate suggests a skill you wouldn't have recommended, include it if its `lane_score` >= 0.75 (it has evidence you don't)
- If `recommendation-candidates.json` doesn't exist or is empty, proceed with Step 1 only (no activation boost)

## Step 1: Assess Current State

From dynamic context above, determine:

### Time signals:
- **Morning (before 11:00)** → favor: boot, health-check, triage, briefing
- **Midday (11:00-16:00)** → favor: digest, challenge, report, capture
- **Evening (after 16:00)** → favor: handoff, weekly-review (if Friday), debrief
- **Weekend** → favor: drift, audit, consolidate, challenge

### Vault state signals:
- **Inbox > 10** → strongly recommend triage
- **Inbox > 0** → mildly recommend digest
- **No daily note** → recommend starting session with boot
- **Digest stale (>3 days)** → recommend digest
- **Briefing stale (>1 day)** → recommend briefing (if morning)
- **Graph stale (>7 days)** → recommend sync + debrief

### Activity signals:
Check recent daily notes (last 3 days) for what's already been run. Don't recommend what was just done.

### Feedback signals (if ledger has entries):
Read `knowledge/feedback-ledger.jsonl`. Apply recency-weighted feedback scoring:
- Last 3 days: full weight (1.0x)
- 4-7 days: half weight (0.5x)
- 8-14 days: quarter weight (0.25x)
- Older: ignore

Per-skill scoring:
- Each weighted accept: +0.5 points
- Each weighted rejection: -1.0 points
- Each weighted edit: -0.25 points (partial value — user found it useful enough to modify)
- Clamp total feedback score to [-2, +2] range

Edit-delta pattern matching: if a skill has 3+ edits with similar `edit_delta` values (e.g., "tags wrong", "wrong tags", "tag issues"), flag it in verbose output as a systematic issue.

## Step 2: Score and Rank

For each candidate skill, assign a score (0-10) based on:
- **Urgency** (vault state demands it): 0-4 points
- **Timeliness** (time of day fit): 0-2 points
- **Staleness** (hasn't been run recently): 0-2 points
- **Feedback history** (accepted vs. rejected): -2 to +2 points

Pick the top 1-3 with score > 3.

## Step 3: Output

```
=== Recommendations ===

1. /{skill-name} — {one-line reason}
   Why: {specific vault state that drives this}

2. /{skill-name} — {one-line reason}
   Why: {specific reason}

{3. if applicable}

State: inbox={count}, digest={age}, briefing={age}
```

If `--verbose`: also show the full scoring breakdown and what was deprioritized.

Keep this fast and concise — the user wants a quick answer, not an essay.
