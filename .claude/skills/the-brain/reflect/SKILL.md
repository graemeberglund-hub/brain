---
name: reflect
description: End-of-day reflection — synthesize the day's arc from handoff log, daily note, and session index. Writes daily note Reflection section + tomorrow's boot primer. The honest accounting of a day.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(find *), Bash(wc *), Bash(python3 *), Bash(git log *)
context: fork
dashterm: true
effort: medium
---

TODAY=!`date +%Y-%m-%d`
NOW=!`date +%H:%M`
BRAIN_DIR=!`echo "$BRAIN_VAULT_PATH"`

# /reflect — End of Day

Not a handoff (tactical: what's next). Not a debrief (process: how was work done). Not an audit (health: is the vault sound). This is the honest shape of a day — what threads advanced, what shifted, what the day meant.

## Step 1: Gather the day's evidence

Read these sources for today's data:

1. **Handoff log** — `knowledge/handoff-log.jsonl`: filter to entries where timestamp starts with `{TODAY}`. Count sessions, extract summaries and next_actions from each.

2. **Daily note** — `notes/daily/{TODAY}.md`: read ## Work, ## Decisions, ## Captured sections.

3. **Session index** — `knowledge/session-index.jsonl`: filter to entries where date = `{TODAY}`. Count sessions, repos touched, total messages.

4. **Git activity** — `git log --oneline --since="{TODAY} 00:00" --all`: count commits across all repos.

5. **Epistemic changes** — `knowledge/epistemic-ledger.jsonl`: filter to entries from today. Count SUPPORTS, CONTRADICTS, ADVANCES, STAGE_PROMOTED.

6. **Positions touched** — scan positions modified today: `find notes/positions/ -name "*.md" -newer notes/daily/{TODAY}.md`

7. **Last handoff** — `knowledge/last-handoff.md`: what was the final state?

If any source is missing or empty, skip it — don't error.

## Step 2: Synthesize the arc

From the evidence, identify:

**Threads** — What distinct work threads ran today? (e.g., "jason-holt falsification sprint", "brain vault intake contract strategy"). Each thread gets 1-2 sentences on what moved.

**Shifts** — Did anything change direction? Position weakened? Approach abandoned? New insight that reframes prior work? These are the interesting moments — when the day started assuming X and ended knowing Y.

**Momentum** — Where is energy concentrated? Is work converging (fewer threads, deeper) or diverging (more threads, shallower)?

**Unfinished** — What was explicitly deferred? What's hanging? Not a to-do list — the threads that have tension.

**Honest assessment** — Was this a productive day or a scattered one? Did sessions build on each other or were they independent? Is the operator moving toward their stated goals or drifting?

Do NOT soften. Do NOT inflate. If it was a scattered day, say so. If momentum is unclear, say so. The point is honest accounting, not encouragement.

## Step 3: Write reflection to daily note

Append to today's daily note (`notes/daily/{TODAY}.md`) after the last section:

```markdown

## Reflection

### Threads
{bulleted list of threads with 1-2 sentence progress summary each}

### Shifts
{what changed direction or revealed something new — or "None today"}

### Momentum
{one sentence: converging/diverging, where energy is}

### Unfinished
{threads with tension, explicitly deferred items — or "Clean"}

### Shape
{1-2 sentences: honest assessment of the day's character}
```

## Step 4: Write boot primer

Write `knowledge/boot-primer.md` (overwrite):

```markdown
---
written_by: reflect
date: {TODAY}
---

# Boot Primer — {TOMORROW's date}

## Carry forward
{top 2-3 next actions from last handoff + any unfinished threads with tension}

## Watch for
{any shifts detected — positions weakening, approaches abandoned, energy patterns to be aware of}

## Active workstream
{workstream name and status, or "None"}

## Day shape yesterday
{one sentence from honest assessment — so boot can calibrate tone}
```

## Step 5: Prune handoff log

If `knowledge/handoff-log.jsonl` has entries older than 30 days:
  Count lines. If > 500, prune entries older than 30 days.
  Use: `python3 -c "..."` to filter and rewrite.

If under 500 lines, skip pruning.

## Step 6: Close

```
REFLECT — {TODAY} at {NOW}

Threads: {N}
Sessions: {N} (from handoff log) | {N} (from session index)
Commits: {N}
Epistemic events: {N} (SUPPORTS: {N}, CONTRADICTS: {N})
Positions touched: {N}
Shifts: {N}
Momentum: {converging|diverging|steady}

Daily note: ## Reflection written
Boot primer: written (knowledge/boot-primer.md)
Handoff log: {pruned to 30d | no pruning needed}
```
