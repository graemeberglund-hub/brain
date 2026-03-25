---
name: delegate
description: "Decompose a complex request into skill calls — natural language intent to structured execution plan. Use when a request spans multiple skills."
allowed-tools: Read, Write, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), AskUserQuestion, Skill
argument-hint: "'natural language request' [--persist]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Skill catalog: !`grep "^  - name:" .claude/skill-index.yml 2>/dev/null | sed 's/.*name: //' | tr '\n' ', '`

# /delegate — Intent Decomposition & Multi-Skill Execution

You are breaking a complex natural language request into a sequence of skill calls, confirming the plan, then executing it. This is the highest-level orchestration skill — it turns "prepare for my meeting with Viktor" into: check calendar → pull relevant positions → generate briefing → draft agenda.

## Step 1: Parse Intent

Read `$ARGUMENTS` as a natural language request. Analyze:

1. **What is the user trying to accomplish?** (goal)
2. **What information is needed?** (inputs)
3. **What output do they expect?** (deliverable)
4. **What skills from the catalog can satisfy each piece?**

## Step 2: Build Execution Plan

Decompose the request into ordered skill calls. For each step:

```
Step {N}: /{skill-name} {args}
  Purpose: {why this step}
  Depends on: {which prior steps, or "none"}
  Output: {what this produces}
```

### Decomposition patterns:

**"Prepare for [meeting/event]"** →
1. `/gws-calendar` — find the event, get attendees + agenda
2. `grep` vault for related positions/notes by topic
3. `/report` — compose relevant positions + context
4. `/briefing` or `/readable` — format for consumption

**"What do I think about [topic]?"** →
1. `/trace` — history of the topic
2. `grep` positions for related beliefs
3. `/connect` — how it relates to other areas
4. Summary synthesis

**"Onboard [person/client] for [domain]"** →
1. `/domain-seed` — scaffold domain content
2. `/profile-init` — if new vault
3. `/guided-tour` — run the tutorial
4. `/health-check` — verify everything is wired

**"Review and clean up"** →
1. `/health-check` — assess state
2. `/triage` — process inbox
3. `/digest` — process captures
4. `/challenge` — stress-test a position
5. `/briefing` — generate summary

**"Ship [topic] to [person]"** →
1. `/report` — compose content
2. `/publish` — push to shareable location
3. Or `/gws-gmail` — email directly

### General rules:
- Maximum 6 steps per plan (if more needed, break into sub-plans)
- Information-gathering steps before action steps
- Read-only steps before write steps
- Always end with a deliverable or confirmation

## Step 3: Confirm Plan

Present the plan to the user:

```
=== Delegation Plan ===

Request: "{original request}"

Steps:
1. /{skill} {args} — {purpose}
2. /{skill} {args} — {purpose}
...

Estimated skills: {count}
Shall I execute this plan? (yes / adjust / cancel)
```

Wait for confirmation. If the user adjusts, update the plan.

## Step 4: Execute

Run each step in order via the Skill tool. Between steps:
- Check if the output matches expectations
- If a step fails, pause and ask whether to skip, retry, or abort
- Pass relevant output from earlier steps as context to later steps

## Step 4.5: Persist (if --persist)

If `--persist` is in $ARGUMENTS:

1. Ask the user: "Should this become a reusable agent? Give it a name, or I'll generate one."
   - If user provides a name, use it as the agent slug
   - If not, generate a slug from the intent (lowercase, hyphenated, max 6 words)

2. Check for slug collision: if `.claude/automation/agent-specs/{slug}.md` exists, warn and append date suffix

3. Ask about scheduling: "Should this run on a schedule, or stay on-demand?"
   - If scheduled: ask for frequency (daily, weekly, specific days)
   - If on-demand: note "on-demand" in spec

4. Save the execution plan as a playbook:
   - Write `.claude/automation/playbooks/{slug}.yml` using the confirmed plan from Step 3
   - Follow playbook.yml schema from /playbook

5. Write the agent spec:
   - Write `.claude/automation/agent-specs/{slug}.md` using the agent spec schema:

```markdown
---
name: "{agent-name}"
description: "{one-line description of what this agent does}"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active
playbook: "{playbook-slug}.yml"
schedule: "{human-readable schedule or 'on-demand'}"
original_intent: "{verbatim user request}"
---

## What This Agent Does

{2-3 sentences expanding on the description. What problem does it solve? What does success look like?}

## Generated Playbook

Reference: `.claude/automation/playbooks/{playbook-slug}.yml`

Steps:
1. /{skill} {args} — {purpose}
2. /{skill} {args} — {purpose}
...

## Schedule

{Schedule details: frequency, time, trigger conditions}
{If on-demand: "Run manually via /playbook run {name}"}

## History

- **{date}** — Created from intent: "{original request}"
```

6. If scheduled and user chooses launchd:
   - Generate a launchd plist suggestion (do NOT install — show it to the user)
   - User decides whether to install it
   If scheduled and user chooses sequences.yml:
   - Suggest adding an entry to `.claude/automation/sequences.yml`
   - User confirms before any modification

Report what was created:
"Agent '{name}' persisted. Playbook: {path}. Spec: {path}. Schedule: {schedule}."

## Step 5: Report

```
=== Delegation Complete ===

Request: "{original request}"
Steps executed: {count}/{total}
Skills invoked: {list}
Artifacts produced: {list of files created}
{Any notes or follow-up suggestions}
{If --persist: "Agent persisted: {name} → playbook + spec created."}
{If --persist with schedule: "Schedule: {frequency} via {method}. Not yet activated — install the plist or add the sequence entry manually."}
```

## Safety Guardrails

- Never execute destructive operations (delete, overwrite) without explicit confirmation per step
- If a step would modify positions, questions, or other epistemic content, flag it before executing
- If the plan involves external communication (email, publish), always confirm the specific content before sending
- Maximum 6 skill invocations per delegation — if more are needed, the request is too complex for one pass
