---
name: run-research-sprint
description: "Autonomously execute a multi-phase research sprint: orient, recon (web research), design prompts, execute them, audit each phase, and synthesize findings. Use when user wants deep automated research on a business or domain. Run from the target repo."
---

# /run-research-sprint — Autonomous Research Sprint

You are launching an autonomous research sprint. This skill orchestrates 5 phases via background `claude` CLI invocations with audit gates after each phase.

## Input

Parse the user's input for:
- **Focus areas** — specific questions or domains to prioritize (optional)
- **`--continue`** — resume the most recent incomplete sprint (optional)

## Step 1: Validate Environment

1. Determine `REPO_ROOT`: run `git rev-parse --show-toplevel`
2. Check that `CLAUDE.md` exists at repo root. If not, warn: "This repo has no CLAUDE.md. The orient phase needs business context. Create one first or add context to prompts/context/."
3. Check `git status` — if there are uncommitted changes, warn: "You have uncommitted changes. The sprint auto-commits after each phase. Consider committing or stashing first."
4. Create sprint dirs if they don't exist: `mkdir -p prompts/sprints prompts/context`

## Step 2: Sprint Detection

Check for existing sprints:
```bash
ls -d prompts/sprints/*/ 2>/dev/null | sort | tail -5
```

If prior sprints exist, read the most recent `run-manifest.json`:
```bash
cat "$(ls -d prompts/sprints/*/ | sort | tail -1)/run-manifest.json"
```

**If `--continue` or prior sprint has `"status": "partial"` or `"status": "failed"`:**
- Show the user: sprint ID, which phases completed, which failed, audit summary
- Ask: "Resume from phase [N+1], re-run failed phase [N], or start fresh?"

**If prior completed sprints exist (continuation mode):**
- Read the most recent `run-summary.md`
- Check if new files appeared in `prompts/context/` since last sprint
- Check if new prompts were manually added to `prompts/strategy/` or prior sprint dirs
- Report: "Found Sprint [N] completed on [date]. [N new context files / N new prompts detected]. Start Sprint [N+1]?"

**If no prior sprints:** proceed to new sprint.

## Step 3: Compute Sprint Path

```python
import datetime, os, glob

existing = sorted(glob.glob("prompts/sprints/*/"))
sprint_num = len(existing) + 1
sprint_dir = f"prompts/sprints/{sprint_num:02d}"
```

## Step 4: Confirm with User

Present a summary:

```
Research Sprint: [repo name]
Sprint ID: [NN]
Focus: [user's focus or "full business analysis"]
Phases: Orient → Recon → Design → Execute → Synthesize
Audit: After every phase
Estimated runtime: 20-30 minutes
Estimated cost: ~$25-40 (Claude Opus)
Output: prompts/sprints/[NN]/run-summary.md

Prior sprints: [N found / none]
New context since last sprint: [list or none]

Proceed?
```

Wait for user confirmation via AskUserQuestion.

## Step 5: Launch

Make the orchestrate script executable and run it in the background:

```bash
chmod +x ~/.claude/skills/run-research-sprint/scripts/orchestrate.sh
bash ~/.claude/skills/run-research-sprint/scripts/orchestrate.sh \
  "$(git rev-parse --show-toplevel)" \
  "prompts/sprints/[NN]" \
  "[focus areas]" \
  > /tmp/sprint-[sprint_id].log 2>&1 &
```

Use the Bash tool with `run_in_background: true`.

## Step 6: Report

Tell the user:

```
Sprint launched in background.

Monitor progress:
  tail -f /tmp/sprint-[sprint_id].log

Check phase status:
  cat prompts/sprints/[NN]/run-manifest.json

When complete, read:
  prompts/sprints/[NN]/run-summary.md

Each phase auto-commits. You can walk away.
```
