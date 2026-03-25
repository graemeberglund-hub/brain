---
name: postmortem
description: "Cross-session failure analysis for multi-session pursuits. Exports bulk transcripts, extracts decisions/positions/findings, traces premature conclusions to their correction point, and measures token cost of wrong paths. Use when a pursuit has been running hot and needs honest accounting."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(python3 *), Bash(ls *), Bash(wc *), Bash(date *), Bash(cat *), Bash(head *), Bash(find *), Agent, AskUserQuestion
argument-hint: "[repo-slug] [date-range, e.g. 2026-03-17:2026-03-23] [--skip-export if bulk file already at /tmp/{slug}-sessions-bulk.txt]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain
Session parser: /Users/graeme/Desktop/DEVELOPMENT/brain/tools/session_parser.py

(At start of execution, use Glob to check: registered repos by listing repos/*.yml files in the vault root.)

# /postmortem — Cross-Session Failure Analysis

You are conducting a rigorous post-mortem on a multi-session pursuit. Your job is NOT to summarize what happened — it's to find where the model went wrong, how long it took to correct, and what architectural changes prevent recurrence.

**Bias directive:** You are the prosecution. Assume every confident claim was premature until proven otherwise. The system has a documented 76:1 SUPPORTS:CONTRADICTS ratio. Your job is to find the things that challenge, complicate, or contradict — not confirm.

## Phase 0: Parse Arguments

Parse `$ARGUMENTS` for:
- **repo-slug** (required) — registered repo name (e.g., `jason-holt`, `apollo`)
- **date-range** (optional) — `YYYY-MM-DD:YYYY-MM-DD`. Default: last 7 days.
- **--skip-export** — if present, assume bulk transcript already exists at `/tmp/{slug}-sessions-bulk.txt`

Look up the repo path from `repos/{slug}.yml`. Derive the Claude project path:
```
~/.claude/projects/-{repo-path-with-dashes}/{session-id}.jsonl
```
(Replace `/` with `-` in the repo path, prepend `-`)

## Phase 1: Export Sessions

**Skip if `--skip-export` is set.**

1. Find all session JSONL files for the project:
```bash
python3 tools/session_parser.py --scan ~/.claude/projects/{project-path-encoded}/
```

2. Filter to sessions within the date range (use timestamps from scan metadata).

3. For each session in chronological order, parse and extract the cleaned transcript:
```bash
python3 tools/session_parser.py {session.jsonl}
```

4. Concatenate all parsed sessions into a single bulk file at `/tmp/{slug}-sessions-bulk.txt`, separated by `====` markers with session metadata:
```
============================================================
SESSION: {session_id}
Date: {start_timestamp}
Duration: {duration}min | {user_messages} user messages
============================================================

{cleaned transcript — USER: and ASSISTANT: alternating}
```

5. Report: session count, total size, date range covered.

Ask the user to confirm before proceeding to extraction. Show session count and date range.

## Phase 2: Structured Extraction

Read the bulk file (`/tmp/{slug}-sessions-bulk.txt`). This may be very large — read in chunks if needed.

Extract into 6 categories. Be concrete — include numbers, names, file paths, session IDs.

### 2.1 Decisions
For each decision:
- **Date** and session context
- **What was decided** and why
- **What was rejected** (the alternative not taken)

### 2.2 Position Shifts
For each shift:
- **Position** stated clearly
- **Direction** (formed / strengthened / weakened / reversed)
- **Evidence** that drove the shift
- Note any positions that CONTRADICTED prior beliefs

### 2.3 Key Technical Findings
For each finding:
- **Finding** in plain language
- **Significance** — why it matters
- Flag **dead-ends** explicitly — these are as valuable as successes

### 2.4 Open Questions
For each:
- **Question** as stated
- **Context** — why it came up

### 2.5 People and Relationships
- Who was discussed, what roles, what dynamics
- Corrections to initial assumptions about people

### 2.6 Counter-Evidence and Tensions
- Arguments against the pursuit's thesis
- Technical limitations discovered
- Competitive threats identified
- Internal disagreements or reversals

Write the extraction to `knowledge/{slug}-session-extraction.md`.

## Phase 3: Premature Conclusion Analysis (THE CORE VALUE)

This is what makes /postmortem different from /debrief or /sync. Re-read the bulk transcript specifically hunting for this pattern:

```
Model makes confident claim → downstream artifacts built on it → correction forced later
```

For EACH instance found, document:

### Failure Template
```
### F{N}: "{the confident claim}"
**Claim**: Exact quote or paraphrase with session ID
**What was actually true**: The corrected understanding
**Sessions from claim to correction**: Count and duration
**Who forced the correction**: User / new data / the work itself / model self-corrected
**Downstream contamination**: Which documents, deliverables, messages inherited the wrong claim
**Token cost estimate**: How much work was built on the false premise and had to be redone
**What would have caught it earlier**: The specific test, search, or question that was missing
**Root cause**: Which failure mode — completion pressure / forward momentum / confirmation bias / scope erasure / external doc lock-in
```

After documenting all failures, write:

### Cost Summary Table
| Failure | Sessions to correct | Who forced it | Artifacts contaminated | Severity |
|---------|-------------------|---------------|----------------------|----------|

### Root Cause Analysis
- Which failure modes appeared most often?
- Were existing countermeasures available but not used? (Check brain vault for `/challenge`, `devil-advocate`, `/research-sprint`, graph-dev.yml patterns)
- What was the ratio of confirmatory to adversarial research?
- Where did the knowledge boundary prevent correction? (Brain tools invisible in target repo?)

### Guidance
- Concrete rules that would have prevented each failure
- Architectural fixes (not advisory — the lesson from graph-dev.yml is that prompt warnings don't work)
- Operator-level guidance (what prompts from the user shortened correction cycles)

Write the analysis to `knowledge/{slug}-premature-conclusion-analysis.md`.

## Phase 4: Update Memory and Gates

1. **Check if `feedback_premature_conclusions.md` memory exists.** If yes, update it with any new failure patterns. If no, create it.

2. **Check the target repo's CLAUDE.md for Falsification Gates section.** If missing, add it. If present, update with repo-specific failure examples from this postmortem.

3. **Update `graph-dev.yml`** — increment recurrence count on `llm-research-structural-confirmation-bias` and `confirmation-bias-structural-not-prompt` patterns if relevant failures were found. Add `recurrence_notes` entries.

4. **Report to user:**
```
POSTMORTEM COMPLETE — {repo-slug} ({date-range})

Sessions analyzed: {N}
Extraction: knowledge/{slug}-session-extraction.md
  - {N} decisions, {N} position shifts, {N} findings, {N} open questions
Failure analysis: knowledge/{slug}-premature-conclusion-analysis.md
  - {N} premature conclusions traced
  - Worst: {F-name} — {sessions} sessions to correct, {severity}
  - Confirmation:adversarial ratio: {N}:{N}
Memory: updated / created
Target repo gates: updated / added / already current
Graph patterns: {N} recurrence increments

Key finding: {one sentence — the most important thing learned}
```

## What This Skill Does NOT Do

- Does not summarize sessions (that's `/sync` + `/debrief`)
- Does not process individual sessions (that's metabolism)
- Does not run periodically (invoke when a pursuit feels like it needs honest accounting)
- Does not fix the problems it finds (it documents them and updates gates — fixes are human decisions)
