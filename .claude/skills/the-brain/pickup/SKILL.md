---
name: pickup
description: Pick up where you left off — reads last handoff context and reconstructs working state. Use between sessions throughout the day. Complement to /boot (morning) and /handoff (session end).
allowed-tools: Read, Glob, Grep, Bash(date *), Bash(find *), Bash(ls *), Bash(test *), Bash(wc *), Bash(python3 *), Bash(.claude/workstreams/*)
dashterm: true
---

TODAY=!`date +%Y-%m-%d`
BRAIN_DIR=!`echo "$BRAIN_VAULT_PATH"`
HAS_HANDOFF=!`test -f "$BRAIN_DIR/knowledge/last-handoff.md" && echo "yes" || echo "no"`

# /resume — Session Resume

Pick up exactly where the last session left off. Not a morning orientation (/boot) — a mid-day context reload.

## Step 1: Load last handoff

If `$HAS_HANDOFF` = "no":
  Output: "No handoff file found. Run `/handoff` at end of sessions to enable `/resume`. Falling back to daily note."
  Read today's daily note (`notes/daily/{TODAY}.md`) and present the ## Decisions and ## Work sections.
  Skip to Step 4.

If `$HAS_HANDOFF` = "yes":
  Read `knowledge/last-handoff.md` completely.
  Extract: session_end timestamp, what happened, decisions, next actions, active workstream, files to read.

## Step 2: Read context files

Read each file listed in the "Files to read for context" section of last-handoff.md.
- PRPs: read frontmatter + current phase section only (not entire PRP)
- Skills: read only if modified in last session
- Notes: read fully

If an active workstream is listed:
  Read the workstream's `state/progress.json`
  Run the workstream runner: `.claude/workstreams/{name}/runner.sh --next`

## Step 3: Check what changed since handoff

Quick scan for activity since the handoff timestamp:
1. `git log --oneline --since="{session_end}" --all` — any commits since?
2. Check if daily note has new entries after the handoff timestamp
3. Check if metabolism daemon ran (compare `knowledge/metabolism-state.json` timestamp vs handoff)

If changes found: note them. If not: "No vault changes since last handoff."

## Step 4: Present resume

Output format (strict):

```
RESUME — {TODAY} at {NOW}
Last session: {session_end timestamp} ({relative time ago})

CONTEXT
{2-3 sentences from "what happened" in handoff}

NEXT ACTIONS
{numbered list from handoff, with any newly unblocked items from workstream}

ACTIVE WORKSTREAM
{workstream name}: {N} complete, {N} available, {N} blocked
Available now: {phase list from runner --next}

CHANGES SINCE HANDOFF
{any commits, daily note updates, metabolism runs — or "None"}
```

Do NOT add commentary, suggestions, or analysis beyond what the handoff recorded. The user knows what they were doing — just restore context.

## Step 5: Offer to proceed

After presenting the resume, ask:

"Pick up where you left off? I can start with {first next action} or you can redirect."

One question. Don't enumerate options. The user knows their priorities.
