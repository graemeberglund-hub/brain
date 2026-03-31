---
name: research-phase
description: Execute a single phase of a research pipeline with deep web research methodology. Reads a phase prompt file, substitutes date, and executes with systematic multi-round research.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), WebSearch, WebFetch
argument-hint: "<phase-prompt-path>"
dashterm: true
timeout: 0
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

# /research-phase — Deep Research Pipeline Phase

You are executing a single phase of an automated research pipeline. Your research must be systematic, thorough, and source-verified.

## Deep Research Methodology

You MUST follow this methodology for every research task in the phase prompt:

### 1. Multi-Query Search (minimum 3 queries per topic)
- Start with a broad query, then narrow based on results
- Use different phrasings and synonyms for the same concept
- Search for specific companies, people, and products mentioned in results
- Search for counter-evidence and failures, not just success stories
- If a topic has sub-topics, search each one independently

### 2. Full-Page Reading (WebFetch, not just snippets)
- For every promising search result, use WebFetch to read the FULL page
- Extract specific data points: numbers, dates, names, quotes
- Don't rely on search result snippets — they're often misleading or truncated
- Read at least 10-15 full pages per research task

### 3. Source Cross-Referencing
- Never cite a single source for a factual claim
- Cross-reference statistics across at least 2-3 sources
- When sources disagree, note the disagreement and which seems more credible
- Follow citation chains — if an article references a report, find the original report

### 4. Iterative Deepening
- After your first round of searches, identify gaps in your findings
- Run a second round of targeted searches to fill those gaps
- If you find an unexpected angle or contradiction, pursue it
- Don't stop at "good enough" — each research task should have depth

### 5. Evidence Quality
- Distinguish: primary source (original data) vs secondary (someone's analysis) vs tertiary (aggregated/summarized)
- Prefer recent sources (2024-2026) over older ones
- Note the credibility of each source (industry report > blog post > forum comment)
- Flag when you could only find weak evidence for a claim

### 6. Output Standards
- Every factual claim must have a source URL
- Include a "Sources" section at the end with all URLs consulted
- Mark unverified claims with [UNVERIFIED]
- Mark contradicted claims with [CONTRADICTED] and explain
- Aim for 3000-8000 words per phase output — depth matters

## Execution

1. Read the phase prompt file at the path provided in `input`
2. Replace all occurrences of `DATEVAR` in the prompt with today's date
3. Follow the phase instructions using the deep research methodology above
4. Write your output to the path specified in the prompt
5. Include a source list at the end of your output

Read `input` now and execute.
