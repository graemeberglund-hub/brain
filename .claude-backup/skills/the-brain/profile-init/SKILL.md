---
name: profile-init
description: "First-run interview — learn about the user's role, domains, goals, and beliefs. Populates starter areas, positions, and questions. Use when onboarding a new user."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), AskUserQuestion
argument-hint: "[--reset]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob and Grep to gather: existing areas in notes/areas/, position count in notes/positions/, and question count by grepping notes/positions/ for classification: question.)

# /profile-init — First-Run User Interview

You are conducting a structured interview to understand a new user and seed their vault with meaningful starter content. This solves the blank-slate problem — a vault can't be useful until it knows who it's working for.

## Pre-check

If the vault already has areas, positions, or question-classified positions (check dynamic context above), warn the user:

> "This vault already has content ({N} areas, {M} positions, {K} questions). Running profile-init will add to existing content, not replace it. Continue? Pass `--reset` to start fresh."

If `--reset` is passed, note that you'll be creating new notes alongside existing ones (never delete existing vault content automatically).

## Phase 1: The Interview

Ask the user ONE comprehensive AskUserQuestion with these 5 questions. Frame it conversationally, not like a form.

### Question 1: Who are you?
"What's your role? What do you do day-to-day? (e.g., 'systems architect at a startup', 'freelance journalist', 'graduate student in epidemiology')"

### Question 2: What domains matter to you?
"Name 3-5 domains or areas of your life/work that you think about regularly. These become your top-level areas. (e.g., 'investing, filmmaking, data engineering, health')"

### Question 3: What do you believe?
"Share 2-4 strong beliefs, theses, or positions you hold. These can be professional or personal. (e.g., 'LLMs will replace most knowledge work within 5 years', 'gold outperforms crypto in crisis', 'small teams beat large ones')"

### Question 4: What are you trying to figure out?
"What are 2-3 open questions you're actively thinking about? Things you don't have answers to yet. (e.g., 'Can I make a living from documentary work?', 'Is the HMM approach viable for regime detection?')"

### Question 5: How do you work?
"Describe your working style in a sentence or two. Are you a planner or improviser? Do you work in bursts or steady rhythm? Morning or night? Solo or collaborative? (This helps the system adapt to your patterns.)"

### Question 6: How should I communicate with you?
"What's your preference for how I talk to you? Some examples:
- Concise or detailed? (Do you want just the answer, or the reasoning too?)
- Direct or gentle? (Should I tell you straight, or cushion it?)
- Emojis? (Never, sometimes, freely?)
- Do you prefer prose paragraphs or bullet lists?"

### Question 7: Who do you work with?
"Name 2-4 people you work with regularly. For each, briefly describe their role and what you typically discuss with them. (This helps me track collaboration context.)"

## Phase 2: Generate Vault Content

From the interview answers, create the following notes. Use the vault's standard schemas (see CLAUDE.md).

### Areas (from Q2)

For each domain the user named, create `notes/areas/{slug}.md`:

```yaml
---
title: "{Domain Name}"
type: area
tags: [{domain-relevant tags}]
created: {today}
updated: {today}
---

## About
{One paragraph synthesized from the user's description of this domain}

## Active Projects
- (none yet — projects will link here as they're created)

## Learning
- (to be populated as references and captures accumulate)

## Key Concepts
- (to be populated as patterns emerge)
```

### Positions (from Q3)

For each belief/thesis, create `notes/positions/{slug}.md`:

```yaml
---
title: "{Position statement}"
type: position
classification: belief
tags: [{relevant tags}]
created: {today}
updated: {today}
stage: exploring
confidence: low
area: "[[{most relevant area}]]"
---

## Thesis

{Expand the user's statement into a clear one-paragraph thesis}

## Evidence For

- Initial position from profile interview ({today})

## Evidence Against

- (none yet)

## Evolution

- **{today}** — Position seeded from profile-init interview. Starting at exploring/exploring.
```

### Questions (from Q4)

For each open question, create `notes/positions/{slug}.md`:

```yaml
---
title: "{Question}"
type: position
classification: question
tags: [{relevant tags}]
created: {today}
updated: {today}
stage: open
confidence: exploring
related_positions: []
suggested_tests: []
resolution: null
---

## Context
{Why this question matters, synthesized from interview context}

## Evidence So Far
- (to be populated as research and captures accumulate)

## Resolution
(empty until resolved)
```

### Operator State Scaffold

Check if memory files exist at the standard memory path (`~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/`). If an `identity.md` or `operator-state.md` exists, update it with the new information. If not, create a basic identity note:

```markdown
---
name: identity
description: "User profile from profile-init interview"
type: user
---

Role: {from Q1}
Domains: {from Q2}
Working style: {from Q5}
Interview date: {today}
```

### Profile (from Q5, Q6, Q7)

Write `~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/profile.yml` using the profile.yml schema.

Map interview answers to structured fields:
- Q5 (working style) → preferences.workflow.session_style, risk_tolerance.overall
- Q6 (communication) → preferences.communication.*, tone_norms.*
- Q7 (collaborators) → collaborators list

For fields the user didn't explicitly address, use sensible defaults:
- verbosity: standard
- tone: balanced
- emoji: never (Brain default)
- automation aggressiveness: moderate
- risk_tolerance.overall: moderate

Populate workspace_boundaries from registered repos in CLAUDE.md:
- All repos listed in the Registered Repos table → repos.active
- repos.ask_first and repos.off_limits start empty

Set `last_refreshed:` to today's date.

## Phase 3: Wire Connections

- In each position, set the `area:` field to link to the most relevant area created
- In each question, add `related_positions:` links if a question clearly relates to a stated position
- Add `suggested_tests:` to questions where the user's beliefs suggest natural experiments

## Phase 4: Report

Summarize what was created:

```
=== Profile Init Complete ===

Areas created: {list with paths}
Positions seeded: {list with paths}
Questions opened: {list with paths}
Operator state: {updated|created|skipped}
Profile: {created|skipped}

Next steps:
- Run /capture to add daily thoughts
- Run /digest periodically to process captures against your positions
- Run /health-check anytime to see vault status
- Run /briefing for a daily editorial summary
```
