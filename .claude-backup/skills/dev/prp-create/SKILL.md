---
name: prp-create
description: Generate a complete, production-grade PRP through deep research with built-in quality gates. Use when user wants to create a PRP or product requirement prompt.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch
argument-hint: "[path to request file OR inline feature description]"
---

# Create PRP

Generate a PRP so comprehensive that it enables one-pass implementation success.

## Input: $ARGUMENTS

---

## Phase 1: Ingest & Understand

### 1.1 Parse Input
- If `$ARGUMENTS` is a file path -> Read that file
- If `$ARGUMENTS` is inline text -> Use directly

### 1.2 Extract Requirements
Identify and list:
- **What changes?** (new feature, refactor, fix, visual change)
- **Which files/components?** (list specific files likely to change)
- **What must NOT change?** (preserve existing behavior)
- **What does success look like?** (observable, verifiable outcomes)

---

## Phase 2: Deep Research

> **Strategy:** Optimize for certainty and success, not speed.

### 2.1 Codebase Analysis
- Search for similar features, patterns, or modules in the codebase
- Identify all relevant files (code, tests, configs) to use as patterns
- Note conventions (naming, styling, architecture) to follow
- Map the dependency graph of affected files

### 2.2 External Research (if needed)
- Web search for library docs, implementation examples, best practices, pitfalls
- For critical references, summarize into `PRPs/ai_docs/` and reference from PRP

### 2.3 Synthesize
Consolidate research into:
- **Known patterns** to follow
- **Known pitfalls** to avoid
- **Open questions** to resolve before implementation

---

## Phase 3: Generate PRP

Use the template at `.claude/skills/prp-create/templates/prp-template.md` as the output structure. Fill in every section with concrete, evidence-based content:

### Section requirements:

**Header**: 1-sentence goal, explicit scope, allowed/forbidden files, 3-8 non-negotiable invariants.

**Current State (section 1)**: 3-6 concrete, evidence-based observations. Not assumptions — things you verified.

**Design Spec (section 2)**: Never say "improve X." Give exact specifications.

**Implementation Plan (section 3)**: 5-15 ordered steps. Each step names the file and specific change. Include "remove competing X" where conflicts are possible.

**Anti-Goals (section 4)**: 5-10 explicit guardrails encoding lessons from past failures:
- DO NOT guess about imports, file names, or function signatures
- DO NOT compensate for a broken foundation with surface fixes
- DO NOT touch files outside the allowed list
- DO NOT skip validation steps
- DO NOT claim "already done" without observable evidence

**Acceptance Tests (section 5)**: 6-12 PASS/FAIL checks. Each must be verifiable by observation, not by reading code. Include at least one negative test and one edge case test.

**Validation Checklist (section 6)**: Standard checklist.

**Deliverable (section 7)**: What the executor must report back.

---

## Phase 4: Quality Gate

Before saving, the PRP must pass ALL of these:

- [ ] Contains **explicit constraints** (not vibes or vague goals)
- [ ] Has **5+ anti-goals** that block common failure modes
- [ ] Has **6+ verifiable acceptance tests** with concrete verification methods
- [ ] Lists **allowed and forbidden files** explicitly
- [ ] States **what the executor must report back**
- [ ] Every claim about current state is **evidence-based** (you verified it)
- [ ] Implementation steps reference **real files and patterns** (not guesses)
- [ ] A different agent could execute this PRP **without subjective decisions**

**Confidence score**: Rate 1-10 for one-pass implementation success. If below 7, identify what's missing and fix it before saving.

---

## Phase 5: Output

Save to: `PRPs/YYYY-MM-DD-prp-{feature-name}.md` (use today's date). Convention v2 requires the date prefix and `prp` type tag.

---

## When to STOP and Ask User

- Requirements are too vague to produce concrete acceptance tests
- Multiple valid architectures exist (need a decision)
- Scope requires touching files you're uncertain about
- Change would affect behavior beyond what was requested
- Confidence score is below 5 even after revision
