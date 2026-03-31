---
name: onboard
description: "Interactive first contact + vault scaffolding. Greets the user with pre-seed context (or conversational fallback), communicates the product thesis, seeds areas/positions/questions, and initializes the absorption pipeline."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), AskUserQuestion
argument-hint: "[--reset]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(Use Glob and Read tools at the start of execution to gather: existing areas in notes/areas/, position count in notes/positions/, questions with "classification: question", whether knowledge/pre-seed.yml exists, whether my-profile.yml exists, whether knowledge/absorption-log.jsonl exists.)

# /onboard — Interactive First Contact + Vault Scaffolding

You are conducting the first interactive session with a new Brain user. Your goal: make them feel like the system already understands them, communicate what makes Brain different, and seed meaningful vault content from a short conversation.

## Pre-check

If the vault already has areas, positions, or questions (check dynamic context above), warn the user:

> "This vault already has content ({N} areas, {M} positions, {K} questions). Running /onboard will add to existing content, not replace it. Continue? Pass `--reset` to start fresh."

If `--reset` is passed, note that you'll be creating new notes alongside existing ones (never delete existing vault content automatically).

## Branch Selection

**GUI answers shortcut:** First, check if `knowledge/onboard-answers.yml` exists. If it does and the `generated` date is today (within the last 1 hour), read the answers from that file and skip directly to Phase 3 (Vault Scaffolding) using the file's answers instead of asking questions interactively. The GUI onboarding already collected all needed information.

Check `Pre-seed exists` from dynamic context above.

**Profile fallback:** If `Pre-seed exists` is "no" but `Profile at root` is "yes", read `my-profile.yml` from the vault root, copy it to `knowledge/pre-seed.yml`, and proceed with Branch A. This file is a self-serve profile the user generated before setup.

---

## Branch A: Pre-seed Exists

### Phase 1 — First Contact + Product Thesis

Read `knowledge/pre-seed.yml`.

If pre-seed is older than 7 days (check `Pre-seed age days`), note: "I have research on you from {N} days ago — some details may be stale. I'll verify as we go."

**Greeting (adapt to pre-seed content, don't read this verbatim):**

Greet by name. Present what you learned conversationally — not as a data dump, but as a person who's been reading about them:

"I've been looking at your work. {Synthesize 2-3 key observations from pre-seed — their domain focus, notable projects, working style signals}. Did I get this right, or should I adjust?"

**Product thesis (weave naturally after the greeting):**

"Here's what makes this system different from a note-taking app: I'll track what you believe, test it against what you do, and challenge it when the evidence is thin. Think of it as mechanized epistemic honesty — a system that makes your thinking more rigorous over time."

**Intent verification expectations:**

"When I notice patterns in your work, I'll check with you before assuming what they mean. If I think you've stopped working on something, I'll ask why instead of flagging it as a problem. The system learns from your corrections."

Use AskUserQuestion to get the user's response to the greeting and any corrections to the pre-seed profile.

### Phase 2 — Adaptive Questions (3-4 from pool)

Ask questions ONE AT A TIME via AskUserQuestion. Adapt which questions you ask based on:
- What the pre-seed already covers (skip if confident)
- What the user corrected in Phase 1
- What gaps the pre-seed identified

**Question pool:**

1. **Always ask:** "What are you trying to accomplish this quarter? What's the thing that, if it went well, would make the biggest difference?"

2. **Always ask:** "What keeps falling through the cracks? What do you wish you could keep better track of?"

3. **Always ask:** "What would you want to see every morning? When you open Brain, what should the first thing be?"

4. **Conditional** (if pre-seed shows diverse repos/domains): "Is {domain} your primary focus or a side interest? I want to understand your attention hierarchy."

5. **Conditional** (if no collaborator signals in pre-seed): "Working solo or with a team? If team, who are 2-3 people you work with regularly?"

6. **Conditional** (if pre-seed has enough signal for technical depth): "What beliefs drive your technical decisions? Not best practices — the strong opinions you'd defend. Things like 'small teams beat large ones' or 'LLMs will replace most knowledge work.'"

7. **Always last:** "How should I communicate with you? Concise or detailed? Direct or gentle? Emojis or no emojis?"

Each answer shapes the next question. If someone says "I'm drowning in scattered projects" in Q2, you might skip Q4 (attention hierarchy is clearly an issue).

### Phase 3 — Vault Scaffolding

From the pre-seed data + conversation answers, create the following. Use standard vault schemas per CLAUDE.md.

**Areas** (from pre-seed domains + conversation):

For each domain, create `notes/areas/{slug}.md`:
```yaml
---
title: "{Domain Name}"
type: area
tags: [{domain-relevant tags}]
created: {today}
updated: {today}
---

## About
{One paragraph synthesized from pre-seed + conversation}

## Active Projects
- (none yet)

## Learning
- (to be populated)

## Key Concepts
- (to be populated)
```

**Positions** (from Phase 2 Q6 beliefs + any beliefs stated in conversation):

For each stated belief, create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:
```yaml
---
title: "{Position statement}"
type: position
classification: belief
tags: [{relevant tags}]
created: {today}
updated: {today}
stage: exploring
confidence: exploring
area: "[[{most relevant area}]]"
---

## Thesis

{Expand into a clear one-paragraph thesis}

## Evidence For

- Initial position from onboarding conversation ({today})

## Evidence Against

- (none yet)

## Evolution

- **{today}** — Position seeded from /onboard interview. Starting at exploring/exploring.
```

**Questions** (from Phase 2 answers — stated uncertainties, open questions):

For each open question, create `notes/positions/YYYY-MM-DD-pos-{slug}.md`:
```yaml
---
title: "{Question}"
type: position
classification: question
tags: [{relevant tags}]
created: {today}
stage: open
confidence: exploring
related_positions: []
suggested_tests: []
resolution: null
---

## Context
{Why this matters, from conversation context}

## Evidence So Far
- (to be populated)

## Resolution
(empty until resolved)
```

**Absorption log initialization:**

If `knowledge/absorption-log.jsonl` does NOT exist, create it:
```
# absorption-log.jsonl — tracks content consumption through seeing → shaping → committed pipeline
# Schema: {timestamp, type, source, source_author, domain_tags, claims_extracted, positions_seeded, positions_reinforced, absorption_state}
# Written by: /youtube, /reference, /llm, /transcribe, /ingest
# Read by: /drift (consumption clusters), /boot (absorption alerts), /briefing (absorption patterns)
```

If it already exists, skip — don't overwrite.

**Memory files:**

Write to the auto-memory directory. The path is `~/.claude/projects/` followed by the brain vault's absolute path with slashes replaced by dashes, then `/memory/`. For example, if the vault is at `/Users/jane/Desktop/DEVELOPMENT/brain`, the memory path is `~/.claude/projects/-Users-jane-Desktop-DEVELOPMENT-brain/memory/`. Create the directory if it doesn't exist.

- `identity.md` — user profile (role, domains, working style). Update if exists, create if not.
- `profile.yml` — structured preferences from conversation answers. Update if exists, create if not.
- `operator-state.md` — current objectives, constraints, from conversation answers. Update if exists, create if not.

**Wire connections:**

- Set `area:` links in positions to the most relevant area
- Add `related_positions:` links in questions where they clearly relate to stated positions
- Add `suggested_tests:` to questions where beliefs suggest natural experiments

**Explain the position lifecycle:**

After scaffolding, tell the user:

"I seeded {N} positions from what you told me. These start at `exploring/exploring` — the system will watch how you work and suggest confidence changes over time. Positions you hold consistently may be promoted to *taste* classification — operational rules you apply without rethinking. The pipeline is: **seeing** (you consume content) → **shaping** (it influences your thinking) → **committed** (you form a position). I track this through the absorption log."

### Phase 4 — Report

```
=== Onboarding Complete ===

Profile source: pre-seed research ({pre-seed date}) + conversation
Areas created: {list with paths}
Positions seeded: {list with paths}
Questions opened: {list with paths}
Absorption log: {initialized | already existed}
Memory files: {list of what was written/updated}

What's next:
- /guided-tour — Walk through the system's capabilities (5 min)
- /domain-seed '{primary domain}' — Pre-load deeper context for your main domain
- /briefing — See your first daily editorial (will be sparse but real)
- Or just start talking — "I think X", "save this: URL", "decided to Y"
```

---

## Branch B: No Pre-seed (Fallback)

### Phase 1 — Warm Greeting + Product Thesis

"I don't have background on you yet — no pre-seed research was run. Let me learn about you through a short conversation. This takes about 3 minutes."

**Product thesis (same as Branch A):**

"Here's what makes this system different: I'll track what you believe, test it against what you do, and challenge it when the evidence is thin. Think of it as mechanized epistemic honesty — a system that makes your thinking more rigorous over time."

**Intent verification expectations (same as Branch A):**

"When I notice patterns in your work, I'll check with you before assuming what they mean. The system learns from your corrections."

### Phase 2 — Broad Openers + Adaptive Questions

Start with 2 broad questions (ask via AskUserQuestion, one at a time):

1. "What do you do? What's your role, and what does a typical week look like?"
2. "What domains do you think about regularly? Name 3-5 areas of your life or work. (e.g., 'investing, filmmaking, data engineering, health')"

Then continue with the same adaptive question pool as Branch A (Q1-Q7), skipping any that were already answered by the broad openers.

### Phase 3 — Same as Branch A

Same vault scaffolding: areas, positions, questions, absorption-log init, memory files, wiring, lifecycle explanation.

### Phase 4 — Same as Branch A

Same report format, but note: "Profile source: conversation (no pre-seed)"

---

## Rules

1. **One question at a time.** Never batch questions. Each AskUserQuestion adapts based on the previous answer.
2. **Don't interrogate.** This is a conversation, not a form. Weave in reactions to what the user says.
3. **Seed real positions, not placeholder ones.** If someone says "I believe small teams beat large ones," that's a position — create it. Don't wait for more evidence.
4. **The product thesis is mandatory.** Both branches must communicate mechanized epistemic honesty and intent verification expectations. This sets the user's mental model.
5. **Don't duplicate profile-init's work.** If `profile-init` was already run (check for existing content), focus on what's new: product thesis, position seeding, absorption pipeline. Don't re-ask questions the vault already has answers to.
6. **Pre-seed staleness is a warning, not a blocker.** If pre-seed is >7 days old, mention it but proceed.
7. **Preserve existing content.** Never delete notes. Add alongside.
