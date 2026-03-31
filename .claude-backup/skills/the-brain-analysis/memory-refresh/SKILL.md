---
name: memory-refresh
description: Refresh durable memory files — decision-patterns, profile.yml, and goal-structured operator-state. Vault is the source of truth; skills read it directly.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(wc *), Bash(ls *)
dashterm: true
timeout: 240
---

Today's date: !`date +%Y-%m-%d`
Memory dir: ~/.claude/projects/-Users-ritual-Projects-Development-brain/memory

# /memory-refresh — Durable Memory Maintenance

Refresh the durable-tier memory files from current vault state. These are files that contain genuinely unique content not derivable from the vault itself (cognitive signatures, preferences, collaboration guidance, goal-structured operator view).

**What this skill does NOT do:** It does not regenerate positions-summary, questions-summary, or project-state. Those were stale summary caches deleted 2026-03-24. Skills now read the vault directly.

## Phase 1: Vault load (targeted)

Load for synthesis:

1. **Goal positions** — `grep -l "^classification: goal" notes/positions/*.md` — read all
2. **Cognitive signatures** — `knowledge/cognitive-signatures.yml`
3. **Conversation signatures** — `knowledge/conversation-signatures/` (recent files)
4. **Prediction calibration** — `knowledge/prediction-calibration.yml`
5. **Corrections ledger** — `knowledge/corrections-ledger.jsonl`
6. **Recent debriefs** — last 5 from `knowledge/debriefs/`
7. **Recent daily notes** — last 7 days from `notes/daily/`
8. **Graph files** — `knowledge/graph-epistemic.yml`, `knowledge/graph-projects.yml`

## Phase 2: Regenerate operator-state.md

Read `{Memory dir}/operator-state.md` if it exists. Rewrite it entirely from goal positions and vault state.

The operator-state is a **view** generated from `classification: goal` positions — not a separate data store. Structure:

```markdown
## Active Goals (by weight)

### [high] {goal title}
Progress: {synthesize from goal's Progress Signals section and recent daily notes}
Supporting positions: {positions whose evidence supports this goal — filter graph-epistemic.yml}
Threatening positions: {positions whose evidence complicates or blocks this goal}
Open questions: {classification: question positions related to this goal}
Active projects: {from graph-projects.yml and daily notes}

### [medium] {goal title}
...

## Constraints
{Synthesize from positions tagged with constraint-like content, recent daily notes}

## Attention Policy
{Where should the system direct attention based on goal weights and current momentum?}

## Cognitive Signatures
{Brief pointer to decision-patterns.md for full detail; surface top 2-3 relevant signatures}
```

For each goal position:
1. Read its `weight`, `stage`, `confidence`, Weight Evidence, and Progress Signals sections
2. Scan `knowledge/graph-epistemic.yml` for edges touching this goal or its related positions
3. Scan recent daily notes for activity related to this goal's tags/area
4. Identify supporting and threatening positions by checking Evidence for/against sections

Format: narrative sections, not mechanical lists. Reference specific positions by wikilink. Keep under 600 words total.

## Phase 3: Regenerate decision-patterns.md

Read and rewrite `{Memory dir}/decision-patterns.md`.

This is the L4 identity file populated from L3.5 conversation mining. Synthesize from:
- `knowledge/cognitive-signatures.yml` — established and provisional signatures
- `knowledge/conversation-signatures/` — recent conversation patterns
- `knowledge/prediction-calibration.yml` — calibration data

Write:
- **Established cognitive signatures** — patterns with 10+ observations, what they mean for collaboration
- **Provisional patterns** — emerging patterns worth monitoring
- **Signature tensions** — where instincts pull in opposite directions, how they typically resolve
- **Calibration insights** — what prediction data says about judgment quality (if any)
- **Collaboration guidance** — based on behavioral evidence, how should the agent work with this user?

Format: structured with headers. This is the primary reference for future conversations to calibrate to the user's thinking style.

## Phase 4: profile.yml

Read `{Memory dir}/profile.yml` if it exists. Update it based on current vault state:

1. **Collaborator last-interaction dates**: Scan last 30 days of daily notes and conversation notes for mentions of known collaborators. Update `last_interaction` dates.
2. **Workspace boundary validation**: Cross-reference `workspace_boundaries.repos.active` against the Registered Repos table in CLAUDE.md. Add new repos, flag removed ones.
3. **Preference drift from corrections**: Read `{Memory dir}/corrections.md`. If any correction maps to a profile field (e.g., "stop using emojis" → preferences.communication.emoji: never), update the profile field.
4. **Update `last_refreshed` date**.

If profile.yml does not exist, skip this phase — profile-init must be run first.

Do NOT overwrite preferences the user has explicitly set. Only update derived fields (collaborator dates, workspace boundary sync, correction-derived adjustments).

## Phase 5: Report

```
Memory refresh for {date}:
- operator-state.md: {refreshed — N goals (H high, M medium, L low weight)}
- decision-patterns.md: {refreshed — N signatures, M tensions}
- profile.yml: {refreshed (N collaborator dates updated, M boundary changes) | skipped (no profile.yml)}
- Cognitive signatures: {N established}, {M provisional}, {K emerging}
- Key changes: {1-2 sentence summary of what shifted}
```
