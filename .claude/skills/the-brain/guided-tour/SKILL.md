---
name: guided-tour
description: "Interactive walkthrough of core vault skills using your real data. Runs 6 skills with narration. Use when onboarding or wanting a refresher on what the system does."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), AskUserQuestion, Skill
argument-hint: "[--skip-to step-number]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Has areas: !`ls $BRAIN_VAULT_PATH/notes/areas/ 2>/dev/null | head -3`
Has positions: !`ls $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | head -3`
Has questions: !`grep -rl 'classification: question' $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | head -3`
Inbox count: !`ls $BRAIN_VAULT_PATH/notes/inbox/ 2>/dev/null | wc -l | tr -d ' '`

# /guided-tour — Interactive Vault Walkthrough

You are guiding a user through their first real interaction with the Brain vault. This is NOT documentation — you are running actual skills with the user's real input, explaining what happens at each step.

## Pre-check

Check dynamic context above. If the vault has no areas or positions:
- Suggest running `/profile-init` first: "Your vault is empty — the tour works best with some starter content. Want me to run /profile-init first to set up your areas and positions?"
- If they say yes, invoke `profile-init`, then continue the tour.
- If they say no, proceed — the tour will create content as it goes.

If `--skip-to N` is passed, jump to that step number.

## The Tour (6 steps)

Present each step with a brief explanation of WHAT this skill does and WHY it matters, then run it with the user's input.

---

### Step 1: Capture — "Catch a thought"

**Narration:**
> The most basic skill. Anything you think, notice, or want to remember goes through /capture. It timestamps it in your daily note and optionally creates an inbox note for processing later. Think of it as the intake valve — everything enters here.

**Action:** Ask the user:
> "Share something you've been thinking about lately — a belief, a question, an observation. Anything. I'll capture it."

Take their response and invoke the `capture` skill with it.

**After:** Show what was created (daily note entry, inbox note if applicable). Explain the daily note structure briefly.

---

### Step 2: Position — "Stake a claim"

**Narration:**
> A position is a belief you want to track over time. Unlike a capture (which is raw input), a position has structure: a thesis, evidence for and against, confidence level, and an evolution log. The system will later test your positions against new evidence.

**Action:** Ask the user:
> "From what you just shared (or something else) — what's a belief or thesis you hold? Something you'd want to track whether you're right about."

Take their response and invoke the `position` skill with it.

**After:** Show the position note created. Point out the `status: exploring` and `confidence: exploring` defaults, and the empty "Evidence Against" section.

---

### Step 3: Question — "Open an inquiry"

**Narration:**
> Questions are co-equal with beliefs. A question is a position classified as `question` — something you don't know yet but want to investigate. The system tracks questions alongside other positions in `notes/positions/` and will surface evidence relevant to both. Some questions eventually resolve into decided positions.

**Action:** Ask the user:
> "What's something you're trying to figure out? A question you don't have an answer to yet."

Take their response and invoke the `question` skill with it.

**After:** Show the question note. Explain the `stage: open` → `active` → `resolved` lifecycle and that questions live in `notes/positions/` with `classification: question`.

---

### Step 4: Digest — "Process what you've captured"

**Narration:**
> Now the interesting part. /digest takes recent captures, references, and inbox notes and evaluates them against your positions and questions. It asks: does this new information SUPPORT, CONTRADICT, or ADVANCE anything you already believe or are investigating? It writes events to the epistemic ledger.

**Action:** No user input needed. Invoke the `digest` skill.

**After:** Show what events were generated (if any). If the vault is too fresh for meaningful digest results, explain: "With only a few notes, digest doesn't have much to work with yet. As you capture more over days and weeks, this is where the system starts to *think* — connecting new evidence to existing beliefs."

---

### Step 5: Bridge — "Check alignment"

**Narration:**
> /bridge checks whether your actions match your beliefs. It compares what you've been doing (git commits, project work) against what you say you believe (positions). If you hold a position that "small teams beat large ones" but you've been building enterprise tooling, bridge will flag that tension.

**Action:** No user input needed. Invoke the `bridge` skill.

**After:** Show results. If no misalignment found (likely for new vaults), explain: "Bridge becomes more valuable over time as your position graph and activity history grow. It's the honesty check."

---

### Step 6: Briefing — "See yourself"

**Narration:**
> The daily briefing is a narrative summary of your vault state — not a dashboard, but an editorial voice that tells you about yourself. What's active, what's stale, what deserves attention. It's like a personal newspaper.

**Action:** No user input needed. Invoke the `briefing` skill.

**After:** If HTML was generated, tell the user where to find it. If briefing couldn't run (too little data), explain what it would look like with more content.

---

## Wrap-up

After all 6 steps (or wherever the user stopped), give a concise summary:

```
=== Tour Complete ===

What you did:
- Captured a thought → daily note + inbox
- Staked a position → tracked belief with evidence structure
- Opened a question → active inquiry to investigate
- Ran digest → evaluated new content against beliefs
- Ran bridge → checked action-belief alignment
- Generated briefing → narrative vault summary

What to do next:
- /capture daily — build the intake stream
- /digest weekly — process captures against positions
- /challenge monthly — stress-test your beliefs
- /health-check anytime — quick vault status
- /handoff at end of session — preserve context for next time

Your vault has {N} areas, {M} positions, {K} questions, and {J} inbox items.
```
