---
name: brand-foundation
description: "Build a research-backed brand foundation before naming or visual identity. Use when the user wants a truth audit, current market/category analysis, ICP definition, proof mapping, or a staged branding pipeline."
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Bash(ls *), Bash(find *), Bash(mkdir *), Bash(date *), Bash(git rev-parse *)
argument-hint: "[product/project name] [optional: --out path]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Repo root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

# /brand-foundation — Research-Backed Branding Foundation

You build the strategic foundation for branding. This phase exists to stop naming, verbal identity, and visual exploration from outrunning product truth.

## Non-negotiables

- Do not generate product names in this phase.
- Do not do logo or visual identity exploration in this phase.
- Do not use generic AI-product copy.
- Do not claim moats or readiness without evidence.
- If ICP, category, differentiators, or proof are too weak, say so directly and stop the downstream creative phase.

## Step 1: Resolve Scope and Output Path

Parse `input` for:

- the product / project / repo being branded
- optional output path after `--out`

If no output path is given:

1. If `notes/projects/` exists and there is a matching project directory or file, use that location.
2. Otherwise, use `strategy/branding/` relative to repo root.

Create the output directory if needed.

Default deliverables:

- `branding-pipeline.md`
- `brand-foundation.md`
- `brand-evidence-matrix.md`
- `competitive-positioning.md`
- `branding-backlog.md`

If these files already exist, update them instead of creating parallel duplicates.

## Step 2: Read Local Truth Sources First

Read only the sources that materially define current product truth:

- `AGENTS.md`, `CLAUDE.md`, `README.md`, `STATUS.md` if present
- roadmap, productization, launch, or strategy docs relevant to the target
- active PRPs/specs/issues that materially affect product scope, UX, positioning, or maturity
- existing branding docs if they already exist

Then summarize the product in plain English:

- what it is
- who it seems to be for now
- what is clearly real
- what is still being built
- what is still aspirational

## Step 3: Run a Truth Audit

Build a disciplined matrix separating:

- shipped now
- in progress
- aspirational / not yet claimable

For each major capability, capture:

- what is real now
- evidence
- the honest claim that can be made
- the claim discipline / caveat if it is partial

Also list:

- what can be honestly demoed now
- what claims would currently be inflated or false

## Step 4: Do Current Market and Category Research

Use the web for current external evidence whenever category, competitor, substitute, or market language could have changed.

Rules:

- prefer official sites and primary sources
- use current citations with links and dates or access dates
- include direct competitors, indirect competitors, adjacent categories, and substitutes
- compare against the actual market as it exists now, not just the local roadmap comparison set

Produce:

- competitor map
- category-language scan
- where the market is crowded
- where the product can still make a specific, credible claim

## Step 5: Build the Strategic Foundation

Define:

- earliest credible ICP
- jobs to be done
- problem framing
- category options
- category risks
- differentiators tied to proof
- proof obligations
- objections and trust barriers

Be explicit about what is usable now versus what only becomes true after more proof or more product work.

## Step 6: Write the Deliverables

### `brand-foundation.md`

Must include:

- plain-English product summary
- evidence snapshot
- 3-5 highest-leverage brand truths
- truth audit
- demoable-now list
- inflated-claim list
- ICP
- JTBD
- problem framing
- category options and recommended current stance
- differentiators
- proof obligations
- objections and trust barriers

### `brand-evidence-matrix.md`

Map candidate claims to:

- shipped / in-progress / aspirational status
- support level: supported / partial / hypothesis / do-not-claim
- confidence
- proof source
- caveats
- use guidance

### `competitive-positioning.md`

Include:

- current market read
- direct, adjacent, and substitute comparison set
- how each competitor positions itself
- where the target is stronger now
- where it is weaker now
- what not to claim in this market

### `branding-pipeline.md`

Define the branding process itself:

- stages
- inputs
- decisions made
- outputs
- validation method
- exit criteria
- now versus later sequencing
- hard gate before naming / identity work

### `branding-backlog.md`

Sort work into:

- do now
- do next
- later
- not yet

Also include open decisions and proof still needed.

## Step 7: Gate the Next Phase

At the end, explicitly state whether downstream naming / identity work can proceed.

The gate only passes if all of these are clear enough:

- ICP
- category stance
- differentiators tied to proof
- objections / trust barriers
- claim constraints

If any are weak:

- explain the gap
- write the blocker into the docs
- stop there

## Step 8: Verify Before Finishing

Check all of the following:

1. Every external market claim has a current source.
2. Every major product claim is marked as shipped, in-progress, aspirational, or forbidden.
3. The pipeline separates strategy, positioning, naming, verbal identity, visual identity, and GTM story.
4. No naming or visual identity work has been done prematurely.
5. The recommendation clearly states what should happen now, what should wait, and what evidence is still needed.

## Step 9: Report

In your final response:

1. Put findings first.
2. List the 3-5 highest-leverage brand truths.
3. Call out the top credibility risks.
4. Summarize the proposed pipeline in one tight staged list.
5. State whether the naming/identity phase is allowed to proceed.
6. List the files created or updated.
