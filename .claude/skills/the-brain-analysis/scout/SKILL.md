---
name: scout
description: Analyze an external repo or system — map architecture, compare against own systems, extract actionable learnings to vault.
context: fork
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, WebFetch, WebSearch
argument-hint: "[github-url or local-path] [vs brain|repo-name] [focus: architecture|workflows|persistence|philosophy|all]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Registered repos: !`ls repos/*.yml 2>/dev/null | xargs -I{} basename {} .yml | tr '\n' ', ' || echo "none"`
Position count: !`ls notes/positions/ 2>/dev/null | wc -l | tr -d ' '`

# /scout — External System Intelligence Extraction

Analyze an external repo or system, compare it against our own systems, and extract actionable learnings. Produces a reference note, immutable scout report, position updates, inbox items for high-priority steals, and graph-dev entries for durable patterns.

## Phase 0: Parse Input & Resolve Target

Parse `input` to extract three components:

- **target**: GitHub URL (e.g., `https://github.com/owner/repo`) or local filesystem path
- **compare-to**: Everything after `vs` keyword. Default: `brain`
- **focus**: Everything after `focus:` keyword. One of: `architecture`, `workflows`, `persistence`, `philosophy`, `all`. Default: `all`

### Resolution

**GitHub URL:**
1. Extract `{owner}/{repo}` from the URL
2. If the URL includes a specific file path (e.g., `/blob/main/docs/use.md`), note it as the entry point but still explore the full repo
3. Use WebFetch to read the repo's README (raw URL: `https://raw.githubusercontent.com/{owner}/{repo}/main/README.md` — try `main`, then `master`)
4. Use Bash: `gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1 --jq '.tree[] | select(.type=="blob") | .path'` to get the full file tree
5. Read up to 10 key files via WebFetch (raw GitHub URLs) — see Phase 1 for prioritization
6. If the user's URL pointed to a specific file, read that file first

**Local path:**
1. Confirm it exists with Glob/Read
2. Read files directly

**Registered repo name (matches a repos/*.yml entry):**
1. Read `repos/{name}.yml` for the path
2. Treat as local path

If the target cannot be resolved (404, missing path), tell the user and stop.

## Phase 1: Explore & Map

**Goal:** Build a structural map without judgment.

### 1.1 Classify the system type

Determine which category best fits:
- Development framework / CLI tool
- Knowledge management system / second brain
- Design system / component library
- AI agent / LLM application / prompt engineering system
- Data pipeline / ETL system
- Documentation / wiki system
- Other (describe)

### 1.2 Read key files

Prioritize in this order (stop at 10 files total):

1. README.md, CLAUDE.md, AGENTS.md, CONTRIBUTING.md (philosophy)
2. Package manifest: package.json, Cargo.toml, pyproject.toml, go.mod (scope)
3. Config files: tsconfig.json, .eslintrc, Makefile, justfile (tooling)
4. Entry points: main.ts, index.ts, src/lib.rs, cmd/main.go, src/index.js (architecture)
5. Schema / type definitions: types.ts, schema.prisma, models/ (data model)
6. Documentation: docs/ directory contents (design intent)
7. Test files: __tests__/, test/, spec/ (testing philosophy)
8. CI/CD: .github/workflows/ (delivery philosophy)

### 1.3 Build the structural map

```
System: {name}
Type: {classification from 1.1}
Language/Stack: {primary language, framework, key dependencies}
Scale: {file count estimate, contributor count if visible}

Directory Structure:
{depth-2 tree of significant directories — skip node_modules, .git, etc.}

Key Architectural Decisions:
- {decision 1}
- {decision 2}

Data/Persistence Model:
- {how state is stored}
- {schema approach}

Extension Model:
- {how the system is extended: plugins, skills, middleware, hooks, etc.}
```

## Phase 2: Extract Philosophy

**Goal:** Understand the "why" behind the architecture.

Analyze documentation, code structure, and comments to identify:

### Stated Philosophy
What the creators explicitly say they believe (from README, docs, comments). Bullet list.

### Revealed Philosophy
What the code structure actually shows — may differ from stated. Bullet list.

### Key Trade-offs
What was explicitly chosen over alternatives. Format: "Chose X over Y because Z."

### Conspicuous Absences
What is NOT in the system and what that implies. Missing tests, missing types, missing docs, missing CI — each is a signal.

## Phase 3: Compare

**Goal:** Structured comparison between the scouted system and the comparison target.

### 3.1 Load comparison target

- If `compare-to` is "brain": Read CLAUDE.md, `knowledge/graph-index.yml`, scan `.claude/skills/` directory listing, and read titles/theses from `notes/positions/*.md` and `notes/concepts/*.md` that are relevant to the scouted system's domain
- If `compare-to` is a registered repo: Read its CLAUDE.md and key structural files from its manifest

### 3.2 Compare across dimensions

Skip dimensions that don't apply to the system type. For each applicable dimension:

```
### {Dimension}

**{Scouted System}:** {1-2 sentences}
**{Comparison Target}:** {1-2 sentences}
**Delta:** {what's different and why it matters}
**Verdict:** {adopt | adapt | skip | watch}
```

**Verdicts:**
- **adopt** — directly applicable, implement soon
- **adapt** — principle is sound but needs modification for our context
- **skip** — not relevant or our approach is stronger
- **watch** — interesting but premature; note what would make it actionable

**Dimensions (use all that apply):**

| Dimension | What to Compare |
|---|---|
| Philosophy | Core beliefs, design principles, what each optimizes for |
| Architecture | Structural patterns, modularity, coupling, extension model |
| Data Model | How state is represented, schema approach, persistence layer |
| Workflows | How users interact, command structure, automation |
| Scaling Strategy | How the system handles growth (data, users, features) |
| Error Handling | How failures are surfaced, recovered from, prevented |
| Testing | What is tested, how, what is not |
| Developer Experience | Onboarding, documentation, discoverability |

## Phase 4: Extract Learnings

**Goal:** Distill comparison into concrete, actionable items.

### 4.1 Steal List

Specific patterns worth adopting. Each item:
- **What**: the specific thing
- **Where**: which file/pattern in the scouted system demonstrates it
- **How**: concrete next step to implement in our system
- **Priority**: high / medium / low

### 4.2 Challenge List

Things that challenge current positions or assumptions. Each item:
- **Position challenged**: link to `[[position-note]]` if one exists, or describe the implicit assumption
- **Evidence**: what in the scouted system provides counter-evidence
- **Severity**: minor / moderate / significant

### 4.3 Watch List

Interesting but not yet actionable. Each item:
- **What**: the pattern or approach
- **Why watch**: what makes it potentially valuable
- **Trigger**: what event or condition would promote this to "steal"

### 4.4 Anti-patterns

Things the scouted system does that we should explicitly avoid. Each with reasoning.

## Phase 5: Persist to Vault

### 5a. Reference note

Create `notes/references/{date}-ref-scout-{slug}.md` where `{slug}` is a 2-4 word lowercase hyphenated identifier for the system:

```yaml
---
title: "{date} Scout: {System Name}"
type: reference
tags: [scout, {system-type-tag}, {relevant-domain-tags}]
created: {date}
updated: {date}
source: "{URL if applicable}"
source_type: tool
concepts_mentioned: [{concept-1}, {concept-2}]
---

## Summary

{2-3 sentences: what this system is and why it was scouted}

## Key Innovation

{The single most interesting thing about this system}

## Why It Matters

{Relevance to our work}

## Related

- [[{existing vault notes}]]
```

### 5b. Immutable scout report

Create `knowledge/scouts/{date}-{slug}.md`:

```yaml
---
title: "Scout Report: {System Name} vs {Comparison Target}"
type: scout-report
target: "{URL or path}"
target_type: "{system classification}"
compared_to: "{brain|repo-name}"
date: {date}
focus: "{focus dimension}"
steal_count: {N}
challenge_count: {N}
watch_count: {N}
---

{Full content from Phases 1-4: structural map, philosophy, comparison, and all learnings}
```

This file is **immutable** — never edited after creation. If re-scouting, create a new dated file.

### 5c. Position updates

For each Challenge List item that maps to an existing position note:

1. Append to that position's `## Evidence Against`:
   ```
   - [[{date}-scout-{slug}]] — {one-line challenge description} ({date}, via /scout)
   ```

2. Append to that position's `## Evolution`:
   ```
   - **{date}** — CHALLENGED by scout of {System Name}: {reasoning} (via /scout)
   ```

Only update positions that clearly exist and are clearly challenged. Do not force matches.

### 5d. Inbox notes for high-priority steals

For each Steal List item with priority **high**, create `notes/inbox/YYYY-MM-DD-in-scout-{slug}-{steal-slug}.md`:

```yaml
---
title: "Steal from {System}: {what}"
type: inbox
tags: [scout, actionable]
created: {date}
source_scout: "knowledge/scouts/{date}-{slug}.md"
---

{What to steal, where it lives in the scouted system, and concrete implementation steps}
```

### 5e. Graph-dev entries

For Steal items that represent **durable patterns** (not one-off implementation tasks), append to `knowledge/graph-dev.yml`:

```yaml
  scout-{slug}-{pattern-slug}:
    type: pattern
    domain: "{domain}"
    title: "{pattern name}"
    project: "Brain"
    date: "{date}"
    daily_note: "[[{date}]]"
    scout_report: "knowledge/scouts/{date}-{slug}.md"
    insight: "{the pattern, 1-3 sentences}"
    applies_when: "{when this is relevant}"
    source_system: "{system name}"
    feeds_positions: []
```

Read `knowledge/graph-dev.yml` first to check for duplicates before appending.

### 5f. Daily note entry

Ensure today's daily note exists (create if missing using standard daily note template). Append under `## Captured`:

```
- {time} — [scout] [[{date}-scout-{slug}]]: scouted {System Name} vs {compare-to}. {steal_count} steals, {challenge_count} challenges, {watch_count} watching. Report: knowledge/scouts/{date}-{slug}.md
```

## Phase 6: Report

Print a summary:

```
Scout complete: {System Name}

Target: {URL or path}
Type: {system classification}
Compared to: {comparison target}
Focus: {focus dimension}

Artifacts:
  - Reference: notes/references/{date}-scout-{slug}.md
  - Report: knowledge/scouts/{date}-{slug}.md
  - Inbox items: {N} high-priority steals
  - Position updates: {N} challenges written
  - Graph patterns: {N} persisted

Top steals:
  1. {highest priority steal — one line}
  2. {second — one line}

Top challenge:
  - {most significant challenge — one line}
```

## Design Notes

- **No epistemic ledger writes.** Position updates will be picked up by `/digest` on its next cycle. This respects the separation of concerns — scout persists raw findings, metabolism skills synthesize.
- **Immutable artifacts.** Scout reports are never edited. Re-scouting the same system creates a new dated file, allowing evolution tracking.
- **Cap file reads at 10.** For large repos, the structural map matters more than reading every file. Be selective using the file tree.
- **Re-scout detection.** If `knowledge/scouts/` already has a report for the same system slug, note the prior report exists in the new report's body but create a new file anyway.
- **Private repos / rate limits.** If WebFetch fails on a GitHub URL, suggest the user clone locally and re-run with the local path. Do not attempt `git clone`.
