---
name: mode
description: Crystallize current working context into a reusable mode loadout. Save, list, or load named cognitive stances for cross-session re-entry.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(test *), Bash(find *)
argument-hint: "[save [name] | list | load {slug} | update {slug} | delete {slug}]"
dashterm: true
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Modes directory: knowledge/modes
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob to check: available modes by listing knowledge/modes/*.md files.)

# /mode — Crystallized Working Context

Parse args:
- No args → auto-detect from current session context; if ambiguous, ask "What project/context should this mode capture?"
- `save [name]` → crystallize current context into a named mode
- `list` → show all modes in knowledge/modes/
- `load {slug}` → read and surface the mode file so the agent re-orients to it
- `update {slug}` → re-run save flow against existing mode file, preserving created: date
- `delete {slug}` → confirm with user ("Delete mode '{slug}'? This cannot be undone. (yes/no)"), then delete the file

## Mode File Schema

```yaml
---
title: "{descriptive title}"
type: mode
slug: {human-readable-slug-max-6-words}
created: YYYY-MM-DD
updated: YYYY-MM-DD
project: "[[{project-slug}]]"
positions:
  - "[[{position-slug}]]"
concepts:
  - "[[{concept-slug}]]"
decided:
  - "[[{decided-position-slug}]]"
key_files:
  - "notes/projects/{area}/{project}.md"
repo: {repo-slug-if-applicable}
tags: [{tag1}, {tag2}]
operator_role: "{snapshot of active role}"
operator_domain: "{primary domain this mode serves}"
operator_objective: "{primary objective this mode serves}"
operator_constraints:
  - "{relevant constraint 1}"
decision_horizon: "{snapshot of current horizon}"
operator_context_captured: YYYY-MM-DD
workspace_boundaries_snapshot:
  repos_active: ["{repo-slugs in scope for this mode}"]
  repos_ask_first: ["{repos requiring confirmation in this mode}"]
---

## Vantage Point

[2-4 sentences: the cognitive stance, active lens, working hypothesis, key tension. NOT a summary of what was done — the perspective FROM WHICH work is being approached.]

## Active Context

[2-5 bullets: most recent insight or pivot, what just changed, what to pick up next session.]

## Re-entry Prompt

[Optional: single sentence the user would give Claude at session start to reconstruct this stance.]
```

Rules:
- `updated:` is required for all mode files saved or updated after this schema
- `operator_role`, `operator_domain`, `operator_objective`, `decision_horizon`, and `operator_context_captured` are required for all mode files saved or updated after this schema
- `operator_constraints` must exist as a list; it may be empty only if the user explicitly says there are no mode-relevant constraints
- Legacy mode files missing these fields must still load without error, but they are considered legacy until updated

## Operator Field Extraction (required for save and update)

When saving or updating a mode, operator persistence is part of the core artifact, not optional enrichment.

Required extraction order:

1. Read `~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/operator-state.md`
2. Determine `operator_role` from the `## Roles & Mandates` section
3. Determine `operator_domain` using this rule order:
   - If the linked project note has a `repo:` and exactly one `## Domain-Activity Map` row in `operator-state.md` that is fed by that repo, use that domain label
   - Else if the project note has exactly one `areas:` entry, use that area slug
   - Else ask the user: "What primary operator domain should this mode carry?"
4. Determine `operator_objective` by matching the mode's project/repo/title against the bullets in `## Current Objectives`
   - If no objective can be matched confidently, ask the user: "What primary objective does this mode serve?"
5. Determine `decision_horizon` from the `## Decision Horizon` section
6. Determine `operator_constraints` by selecting the 1-3 constraints from `## Active Constraints` most relevant to this mode's project/domain

Critical behavior:
- If `operator-state.md` exists and any required operator field cannot be inferred confidently, `/mode save` or `/mode update` MUST ask a targeted clarification question rather than writing a mode without operator fields
- If `operator-state.md` does not exist, `/mode` MUST ask the user for the missing operator fields and still persist them
- NEVER silently omit operator fields from a newly saved or updated mode

## When saving a mode (core path)

1. Read today's daily note (notes/daily/YYYY-MM-DD.md) for current project and recent work
2. If a project is determinable, read that project note from notes/projects/
3. Grep notes/positions/ for any positions referenced in the daily note or conversation
4. Grep notes/concepts/ for any concepts referenced
5. Find recent decided positions in notes/positions/ (classification: decided) matching the project (last 30 days)
6. Run operator field extraction (see above) — this is mandatory, not optional
7. Determine `workspace_boundaries_snapshot` by reading profile.yml:
   - If the mode's project/repo maps to a specific subset of active repos, capture that subset
   - If the mode implies restricted repos (e.g., a production-focused mode might restrict dev repos), capture that
   - If profile.yml does not exist, omit workspace_boundaries_snapshot
8. Identify key_files — 2-4 most specific files read this session
9. Ask user (or infer): what is the vantage point? What cognitive stance is active?
10. Generate slug from title (lowercase, hyphenated, max 6 words)
11. Check for slug collision: if knowledge/modes/{slug}.md already exists, warn user and append date suffix ({slug}-{TODAY}) and note the collision
12. Set `created:` = today, `updated:` = today, `operator_context_captured:` = today
13. Write knowledge/modes/{slug}.md with full schema (all operator fields required)
14. Confirm with path and one-line description of what was crystallized

## When loading a mode

1. Read knowledge/modes/{slug}.md
2. Read the linked project note and key_files
3. Surface the Vantage Point and Active Context sections prominently in output
4. If operator-scoped fields are present, show a dedicated block:

```text
OPERATOR SNAPSHOT:
{operator_role} | {operator_domain} | {operator_objective} | {decision_horizon}
Constraints: {comma-separated operator_constraints list}
Captured: {operator_context_captured}
```

5. If `workspace_boundaries_snapshot` is present, show:

```text
WORKSPACE SCOPE:
Active: {repos_active}
Restricted: {repos_ask_first or "none"}
```

Legacy modes without workspace_boundaries_snapshot load without error; the workspace scope section is simply omitted.

6. If `operator-state.md` exists, compare the live operator state to the persisted snapshot
7. If the persisted and live states materially differ in domain, objective, or horizon, show:

```text
OPERATOR DRIFT:
Mode captured under: {persisted objective / horizon}
Current operator state: {live objective / horizon}
Use this as a historical stance, or run /mode update {slug}.
```

8. If no material drift exists, show:

```text
OPERATOR DRIFT: none
```

9. If a pre-PRP legacy mode lacks operator fields, load it successfully but label it:
   `Legacy mode — no persisted operator snapshot. Run /mode update {slug} to harden it.`

10. Offer to read positions and concepts for deeper re-orientation
11. Do NOT silently re-orient — always show the mode content explicitly

## When listing modes

For each .md file in knowledge/modes/ (excluding .gitkeep):

Hardened modes (have `operator_domain` and `updated:`):
```text
slug | operator_domain | updated | operator_objective_excerpt (first 80 chars)
```

Legacy modes (missing operator fields):
```text
slug | legacy | created | title
```

If no modes exist: "No modes saved yet. Use /mode save [name] to crystallize your current context."

## When updating a mode

1. Read existing knowledge/modes/{slug}.md
2. Re-gather current positions, concepts, decisions using the same steps as save
3. Run operator field extraction (see above) — mandatory, refresh all operator fields from current operator state
4. Ask user: should the Vantage Point and Active Context sections be rewritten, or just metadata updated?
5. Preserve `created:` date
6. Set `updated:` = today, `operator_context_captured:` = today
7. Do not leave stale operator data in place if the mode's role/domain/objective/horizon has changed

## When deleting a mode

1. Confirm: "Delete mode '{slug}'? This cannot be undone. (yes/no)"
2. On yes: delete knowledge/modes/{slug}.md and confirm "Mode '{slug}' deleted."
3. On no: "Delete cancelled."

## Edge cases

- If knowledge/modes/ does not exist: create it on first save
- If no daily note and no context: ask "What project/context should this mode capture?"
- Slug collision: append -{TODAY} date suffix and warn user
- Mode files are Obsidian-compatible YAML (use wikilink format [[slug]] for positions/concepts/decided positions)
- key_files: use vault-relative paths for brain files; repo-relative paths prefixed with repo name for other repos; NEVER absolute paths beginning with /Users/
- Legacy mode files (pre-hardening, missing operator fields) must still load without error. They are labeled as legacy with an update recommendation. But ALL newly saved or updated modes MUST include the full operator snapshot.
