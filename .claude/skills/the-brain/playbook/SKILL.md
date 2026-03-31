---
name: playbook
description: "Create, run, and manage named workflows with conditional logic and decision points. User-facing skill orchestration. Use when building or running reusable workflows."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(wc *), AskUserQuestion, Skill
argument-hint: "run 'name' | create 'name' | create-from-intent 'intent' | list | edit 'name'"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Playbook dir exists: !`test -d $BRAIN_VAULT_PATH/.claude/automation/playbooks && echo "yes" || echo "no"`
Playbook count: !`ls $BRAIN_VAULT_PATH/.claude/automation/playbooks/*.yml 2>/dev/null | wc -l | tr -d ' '`

# /playbook — Named Workflow Orchestration

You are managing user-facing named workflows. Playbooks are like sequences.yml but editable, conditional, and domain-aware. They can branch, loop, prompt for input, and compose skills.

## Commands

### `create 'name'` — Build a new playbook

Ask the user to describe what the playbook should do. Then create `.claude/automation/playbooks/{name}.yml`:

```yaml
name: "{name}"
description: "{what this playbook does}"
created: {today}
updated: {today}
author: operator

# Steps execute in order. Each step invokes a skill or evaluates a condition.
steps:
  - id: step-1
    skill: "{skill-name}"
    args: "{arguments or template}"
    description: "{what this step does}"

  - id: step-2
    condition: "{vault state check — e.g., 'inbox_count > 5'}"
    if_true: step-3
    if_false: step-4
    description: "{why we branch here}"

  - id: step-3
    skill: "triage"
    description: "Clean up inbox before proceeding"

  - id: step-4
    skill: "digest"
    description: "Process recent captures"

  - id: step-5
    prompt: "{question to ask the user}"
    description: "Decision point — user chooses direction"
    options:
      - label: "Option A"
        goto: step-6
      - label: "Option B"
        goto: step-7

  - id: step-6
    skill: "briefing"
    args: ""
    description: "Generate briefing"

  - id: step-7
    skill: "challenge"
    args: "--all"
    description: "Run challenge on all positions"
```

### `create-from-intent 'natural language'` — Generate a playbook from intent

This is the bridge between natural language and structured playbooks. It reuses `/delegate`'s decomposition logic without immediate execution.

1. Parse the natural language intent (same analysis as delegate Step 1)
2. Decompose into ordered skill calls (same logic as delegate Step 2)
3. Present the plan to the user for review:

```
=== Generated Playbook Plan ===

From: "{original intent}"

Steps:
1. /{skill} {args} — {purpose}
2. /{skill} {args} — {purpose}
...

Name this playbook: [suggest a slug]
Save? (yes / adjust / cancel)
```

4. If user confirms:
   - Write `.claude/automation/playbooks/{name}.yml` using the standard playbook schema
   - Optionally create an agent spec in `.claude/automation/agent-specs/{name}.md` if the user says the intent should be traceable
5. If user adjusts: modify steps and re-present
6. Report: "Playbook '{name}' created. Run it with /playbook run {name}"

**Difference from delegate --persist:** `create-from-intent` does NOT execute the playbook. It only creates it. This is for users who want to design a workflow first and run it later.

### Step types:
- **skill** — invoke a vault/dev skill with args
- **condition** — evaluate vault state, branch to different steps
- **prompt** — ask the user a question, branch on response
- **loop** — repeat a step or range until condition met

### Built-in conditions:
- `inbox_count > N` — check inbox depth
- `positions_stale > N` — count stale positions
- `time_is morning|afternoon|evening` — time-of-day routing
- `day_is weekday|weekend` — day-of-week routing
- `graph_age > N` — knowledge graph freshness
- Custom: any natural language condition the agent evaluates

### `run 'name'` — Execute a playbook

1. Load the playbook YAML
2. Execute steps in order, following branches
3. For each step:
   - **skill**: invoke via Skill tool
   - **condition**: evaluate and follow branch
   - **prompt**: ask user via AskUserQuestion
   - **loop**: repeat until exit condition
4. Track execution: which steps ran, which were skipped, any errors

Report at end:
```
=== Playbook Complete: {name} ===
Steps executed: {count}/{total}
Skills invoked: {list}
Branches taken: {list}
Duration: {approximate}
```

### `list` — Show available playbooks

```
=== Playbooks ===
{name} — {description} ({step count} steps, created {date})
...
Total: {count}
```

### `edit 'name'` — Modify a playbook

Read the current playbook, show it to the user, and accept modifications. Common edits: add/remove steps, change conditions, update args.

## Starter Playbooks

If the playbook directory is empty and the user says `list`, suggest creating starter playbooks:

- **morning-routine** — health-check → triage (if inbox > 5) → digest → briefing
- **weekly-review** — sync → debrief → weekly-review → challenge (1 position) → bridge
- **deep-work** — boot → mode load → (work session) → handoff
