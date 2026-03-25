---
name: research-sprint
description: Generate a customized set of frontier-model prompts (research, adversarial, audit) tuned to a specific domain and project. Use when starting deep analysis on a new seed, business opportunity, or high-stakes decision.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls *), Bash(mkdir *), Bash(date *)
argument-hint: "[domain/project] [optional: key questions or focus areas]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

# /research-sprint — Generate Domain-Tuned Frontier Prompts

You generate a set of 3 prompts designed to be run in frontier models (ChatGPT deep research, Claude extended thinking, Gemini Deep Research, etc.) for intensive domain analysis. The prompts are customized to the specific domain, evidence base, and strategic questions at hand.

## The Three Archetypes

### 1. Research Prompt (`research-01-{domain}.md`)
Wide-aperture domain research. Goes deep on market, regulatory, competitive, technical, or strategic landscape. Structured output with sourced claims.

### 2. Adversarial Prompt (`adversarial-01-{domain}.md`)
Role-reversed threat modeling. The model assumes the identity of the strongest plausible opponent and builds the best case against the user's position. Forces confrontation with weak points, blind spots, and uncomfortable truths.

### 3. Audit Prompt (`audit-01-{domain}.md`)
Evidence fidelity check on the adversarial output. Verifies every substantive claim against source material. 100%-or-fail standard. Kills hallucinations, overstatement, and citation drift.

## Process

### Phase 1: Understand the Domain

Read the input. Then gather context:

1. **Check for an existing repo** — if user names a registered repo, read its CLAUDE.md for domain context
2. **Check for existing research** — look for deep research reports, position notes, reference notes related to this domain in the brain vault
3. **Check for existing prompts** — see if there are already prompts in the target repo's `prompts/sprints/` directory

From these, extract:
- **Domain**: What field/industry/topic (e.g., medical transport, career strategy, legal defense)
- **Stakeholder map**: Who are the key actors (e.g., insurers, regulators, competitors, partners)
- **Evidence base**: What source material already exists (reports, data, documents)
- **Key questions**: What the user needs answered (from input or inferred from context)
- **Opponent identity**: Who would be the strongest adversary in this domain (e.g., skeptical VC, opposing counsel, incumbent competitor, hostile regulator)

### Phase 2: Confirm with User

Present a brief summary:

```
Domain: {domain}
Opponent role: {who the adversarial agent will play}
Evidence base: {what source material exists}
Key questions: {3-5 questions the research should answer}
Output location: {repo}/prompts/sprints/{NN}/strategy/

Proceed? (or adjust)
```

### Phase 3: Generate Prompts

Generate all three prompts and write them to the target location. Each prompt is a self-contained markdown file ready to paste into a frontier model session.

#### 3a. Research Prompt

Structure:
```markdown
# Deep Research: {Domain Title}

## Objective
{What this research should produce — specific, actionable}

## Context
{Brief domain context so the frontier model starts informed}

## Research Axes
{4-8 specific research directions, each with:}
### Axis N: {Name}
- Key questions to answer
- What "good" looks like (specificity targets)
- Known starting points or leads

## Source Priority
{What types of sources matter most in this domain}
- Tier 1: {most authoritative}
- Tier 2: {supporting}
- Tier 3: {useful but verify}

## Output Format
{Structured output spec — sections, citation requirements, confidence levels}

## Anti-Hallucination Rules
- Every factual claim must cite a specific source
- Distinguish between: verified fact, reported claim, industry consensus, inference
- Flag uncertainty explicitly — "likely", "reported but unverified", "industry estimate"
- If you cannot find reliable data on an axis, say so — do not fill gaps with plausible-sounding assertions
```

#### 3b. Adversarial Prompt

This is the core innovation. Model after the aron-heroux-legal adversarial prompt's structural DNA but adapt to the domain:

```markdown
# Adversarial Agent: {Opponent Role Title}

## Role
You are not a neutral reviewer. You are {opponent identity} with zero concern for {user's} interests. Your job is not to collect concerns. Your job is to design the strongest {attack/critique/rejection/case} that could realistically be assembled from the available evidence.

Think like {the specific decision-maker who would say no}:
- {Domain-specific strategic thinking bullets}
- {What they would foreground}
- {What they would exploit}
- {Where they would apply pressure}

Do not help {the user}. Do not write a balanced assessment. Do not soften dangerous findings because rebuttals exist.

## Objective
{What this adversarial pass should produce — the strongest opposing case}

## Source Material
{What the adversarial agent should work from — the research output, existing documents, etc.}

### Tier 1: {Highest-priority sources}
{List with descriptions}

### Tier 2: {Supporting sources}
{List with descriptions}

## Strategic Decision Rules
- Prefer a coherent campaign over a laundry list
- Distinguish between:
  - Primary attack thesis
  - Supporting pressure points
  - Reserve leverage (hold back for escalation)
  - Facts best kept vague
- {Domain-specific decision rules}
- Resolve ambiguity in {opponent's} favor where plausible
- Assume the strongest version of each threat

## Mandatory Analysis Tracks
{Domain-specific tracks — each a separate angle of attack}

### Track 1: {Name}
{What to analyze, what the strongest attack looks like}

### Track 2: {Name}
...

## Output Structure
For each track:
1. Strongest attack thesis (1-2 sentences)
2. Best supporting evidence (with citations)
3. Strength tier: PRIMARY / SUPPORTING / RESERVE / TOO WEAK
4. Recommended tactic: foreground / hold in reserve / keep vague / abandon
5. What would make this track stronger (missing evidence)

## Final Deliverable
- Executive summary: the single most persuasive story {opponent} should tell
- Combined pressure architecture: how tracks reinforce each other
- Top 5 most dangerous facts/findings for {the user}
- Recommended counter-preparation: what {the user} must be ready to answer
```

#### 3c. Audit Prompt

```markdown
# Audit Agent: {Domain} Evidence Fidelity Check

## Role
You are not a strategist, advocate, summarizer, or collaborator. You are an evidence auditor whose job is to kill hallucinations, overstatement, and citation drift in the adversarial report.

Assume the target report is polished, hostile, and rhetorically effective. Trust none of it. Verify all of it.

## Standard
This audit is 100% or fail.
- There is no "mostly right."
- There is no "close enough."
- If any substantive factual assertion is unsupported, overstated, misattributed, or materially misleading, the report FAILS.
- PASS is allowed only if every substantive factual assertion is faithful to source evidence and every inference is clearly labeled.

## Scope
Audit the adversarial report. Check every:
- Factual claim
- Source citation
- Quantitative assertion (numbers, percentages, dates)
- Attribution (who said/did what)
- Strength/tier classifications
- Inferences presented as facts
- {Domain-specific audit items}

## Source Material for Verification
{The same source hierarchy from the research prompt — what the auditor should verify against}

## Output Format
For each finding:
```
FINDING-{NNN}
Severity: CRITICAL | HIGH | MEDIUM | LOW
Location: {section/paragraph in adversarial report}
Claim: {exact text being audited}
Issue: {what's wrong — unsupported / overstated / misattributed / misleading}
Source check: {what the actual source says}
Recommendation: {remove / downgrade / reword / add qualifier}
```

## Final Verdict
- PASS: Every substantive claim verified. Report is evidence-faithful.
- FAIL: {N} findings at severity {breakdown}. Report requires remediation before use.

List findings by severity, then provide a remediated summary of which adversarial tracks survive audit intact and which are weakened.
```

### Phase 4: Write and Report

1. Ensure `{repo}/prompts/sprints/{NN}/strategy/` exists (create if needed)
2. Write all three prompt files
3. Report what was created:

```
Research sprint prompts generated:

  {repo}/prompts/sprints/{NN}/strategy/research-01-{domain}.md
  {repo}/prompts/sprints/{NN}/strategy/adversarial-01-{domain}.md
  {repo}/prompts/sprints/{NN}/strategy/audit-01-{domain}.md

Workflow:
1. Run research-01 in a frontier model (ChatGPT deep research recommended)
2. Save output to {repo}/prompts/sprints/{NN}/outputs/{date}-research-01-output.md
3. Run adversarial-01 with research output as context
4. Save output to {repo}/prompts/sprints/{NN}/outputs/{date}-adversarial-01-output.md
5. Run audit-01 against adversarial output
6. Save output to {repo}/prompts/sprints/{NN}/outputs/{date}-audit-01-output.md
7. Ingest findings back to brain: /ingest llm {output-path}
```

## Domain Adaptation Rules

The power of this skill is in customization. Every domain has different:

- **Opponent identities**: VC (business), opposing counsel (legal), regulator (compliance), hiring committee (career), incumbent competitor (market entry), peer reviewer (academic)
- **Evidence hierarchies**: legal sources have tiers (filings > testimony > inference); market research has tiers (public data > industry reports > expert opinion); academic has tiers (meta-analysis > RCT > observational)
- **Attack vectors**: legal has claim tracks; business has failure modes; career has rejection reasons; technical has vulnerability classes
- **Fidelity standards**: legal requires citation-level precision; business allows ranges; academic requires methodological rigor

Tune each prompt to these domain-specific patterns. Do not generate generic prompts with domain words swapped in — the adversarial prompt especially must encode real strategic thinking about how opposition works in that specific field.

## What This Skill Does NOT Do

- Does not run the prompts — they're designed for frontier model sessions
- Does not ingest outputs — use `/ingest llm` after running prompts
- Does not replace domain expertise — the prompts are scaffolding for human judgment
- Does not generate the audit itself — the audit prompt is run after adversarial output exists
