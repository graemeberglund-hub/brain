---
name: domain-seed
description: "Pre-contextualize a vault for a specific domain — scaffold starter positions, questions, areas, and curated skill subset. Use when onboarding a new domain or client."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(wc *), AskUserQuestion
argument-hint: "'domain description' [--depth light|full]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Existing areas: !`ls $BRAIN_VAULT_PATH/notes/areas/ 2>/dev/null | head -10`
Template dir exists: !`test -d $BRAIN_VAULT_PATH/artifacts/domain-templates && echo "yes" || echo "no"`

# /domain-seed — Domain Pre-Contextualization

You are scaffolding a vault for a specific domain. Given a domain description, you generate starter areas, positions, questions, and a curated skill recommendation. This is the moat — the difference between a blank tool and a tool that already understands the user's world.

## Step 1: Parse Domain

Parse `$ARGUMENTS` for:
- **Domain description** — natural language (e.g., "gun shop SEO", "family office wealth management", "indie documentary production", "SaaS B2B analytics")
- **--depth** — `light` (3 positions, 2 questions, 1 area) or `full` (8-12 positions, 5-8 questions, 2-4 areas). Default: `full`.

If description is too vague (fewer than 3 words), ask ONE clarifying question:
> "Tell me more about the domain. Who is the primary user? What decisions do they make? What do they track?"

## Step 2: Domain Analysis

Before generating content, think through the domain:

### Identify core axes:
1. **Key decisions** — what choices does someone in this domain regularly face?
2. **Common beliefs** — what do practitioners typically believe? What's contested?
3. **Open questions** — what is genuinely unknown or debated?
4. **Information sources** — where does signal come from?
5. **Success metrics** — how is value measured?

### Check for domain templates:
If `artifacts/domain-templates/` exists, check for a matching template. Templates provide curated starter content for known domain archetypes.

## Step 3: Generate Starter Content

### Areas (1-4 based on depth)

Create `notes/areas/{domain-slug}.md` and sub-areas if the domain is broad enough:

```yaml
---
title: "{Domain Area}"
type: area
tags: [{domain-tags}]
created: {today}
updated: {today}
---

## About
{2-3 sentences on what this area covers and why it matters}

## Active Projects
- (none yet)

## Key Decisions
- {List 3-5 decisions common in this domain}

## Information Sources
- {List 2-3 where practitioners get signal}

## Key Concepts
- (to be populated)
```

### Positions (3-12 based on depth)

Generate positions that represent common domain beliefs — both consensus and contested. Mix:
- **2-3 consensus positions** (widely held, high confidence starting point)
- **2-3 contested positions** (debated, exploring confidence)
- **2-4 contrarian positions** (non-obvious, low confidence — designed to provoke investigation)

Each position follows the standard schema in `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "{Position statement}"
type: position
classification: belief
tags: [{domain-tags}]
created: {today}
updated: {today}
stage: exploring
confidence: {exploring|low|medium}
area: "[[{domain-area}]]"
---

## Thesis
{Clear one-paragraph statement}

## Evidence For
- Domain-seeded position ({today}) — {brief rationale}

## Evidence Against
- (to be investigated)

## Evolution
- **{today}** — Position seeded via /domain-seed for {domain}. Needs validation against user's specific context.
```

### Questions (2-8 based on depth)

Generate questions that are genuinely useful for someone operating in this domain:
- **Strategic questions** — about direction and priorities
- **Tactical questions** — about methods and tools
- **Contrarian questions** — that challenge domain assumptions

Each follows standard schema in `notes/positions/YYYY-MM-DD-pos-{slug}.md` with `classification: question`.

## Step 4: Skill Recommendations

Based on the domain, recommend which vault skills will be most valuable:

```markdown
### Recommended skill workflow for {domain}:

**Daily:**
- /capture — log observations, data points, client feedback
- {domain-specific capture patterns}

**Weekly:**
- /digest — process captures against domain positions
- /report — generate shareable {domain-specific output}

**Monthly:**
- /challenge — stress-test domain beliefs
- /bridge — check if actions align with stated strategy

**As needed:**
- {2-3 other skills particularly relevant to this domain}
```

## Step 5: Present for Review

Show the user everything that will be created BEFORE writing:

```
=== Domain Seed Preview: {domain} ===

Areas: {count}
{list with titles}

Positions: {count}
{list with titles and confidence levels}

Questions: {count}
{list with titles}

Skill workflow recommendation included.

Create all of these? (yes / adjust / cancel)
```

Wait for confirmation before writing files.

## Step 6: Write and Confirm

Create all files. Report:

```
=== Domain Seed Complete ===

Created:
- {count} areas in notes/areas/
- {count} positions in notes/positions/
- {count} questions in notes/positions/ (classification: question)

Next steps:
- Review seeded positions — adjust confidence based on your experience
- Add evidence to positions from your existing knowledge
- Run /digest after adding your first captures to start connecting dots
- Run /challenge in a week to stress-test the seeded positions
```
