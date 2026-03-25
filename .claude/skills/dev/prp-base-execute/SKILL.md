---
name: prp-base-execute
description: Execute a PRP with phase gates, anti-laziness checks, and evidence-based verification. Use when user wants to execute/implement a PRP.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "[path to PRP file]"
---

# Execute PRP

Implement a feature using a PRP file. This command enforces verification at every phase.

## PRP File: $ARGUMENTS

---

## PHASE 0: BASELINE (DO THIS FIRST)

> **CRITICAL**: PRPs are about *observable outcomes*, not code structure.
> Code that "looks right" but doesn't achieve the intent is a FAILURE.
> "Already done" is almost always wrong.

### 0.1 Establish Current State

Before reading any code:
1. Determine how to observe the current behavior (run the app, execute a command, check output)
2. Actually observe it — do not skip this
3. Note what's wrong or missing based on the PRP's problem statement

### 0.2 Anti-Pattern Detection (Before Proceeding)

**Check for these. If ANY apply, you are on a failure path:**

1. **"Already done" trap**: If you believe the PRP is already implemented:
   - State what specific OBSERVABLE EVIDENCE proves it's done
   - If your evidence is a code pattern or class name, that's NOT proof
   - Code existing is not the same as code working correctly

2. **Code-as-proof trap**: If your evidence involves reading source files:
   - Code analysis is not behavioral verification
   - "The function handles this case" != "I verified the output is correct"

3. **Deferred verification trap**: If planning to "verify after implementation":
   - NO. You need a baseline FIRST to know if you improved anything

### 0.3 GATE: Phase 0 Completion Certificate

**You CANNOT proceed to Phase 1 until you output the following:**

```
## Phase 0 Completion Certificate

BASELINE ESTABLISHED: [How you observed current state]
CURRENT STATE OBSERVATION:
- Issue 1: [describe what you OBSERVED, not what code says]
- Issue 2: [describe what you OBSERVED]

PRP SCOPE CONFIRMED: [list files allowed to edit]
FILES FORBIDDEN: [list files you must not touch]

I confirm I have VERIFIED THE CURRENT STATE before proceeding.
```

**If you cannot complete this certificate, STOP and tell the user why.**

---

## PHASE 1: PRE-FLIGHT (Before Writing Code)

### 1.1 Read PRP Completely

Extract and memorize:
- **Files allowed to edit** (only touch these)
- **Files forbidden** (never touch, even if tempting)
- **Non-negotiable invariants** (hard constraints)
- **Anti-goals** (things you must NOT do)

### 1.2 Load Context

Read all files referenced in the PRP. For each file you'll modify:
- Understand its current structure
- Identify patterns to follow
- Note what must be preserved

### 1.3 Plan Implementation

Create a concrete task list mapping PRP steps to specific code changes.
- Reference real line numbers and function names
- Never guess about imports, file paths, or function signatures — verify first
- Identify which changes depend on others (ordering matters)

---

## PHASE 2: IMPLEMENTATION

### 2.1 Execute Plan In Order

- Follow the PRP's implementation steps in sequence
- Reference line numbers when editing
- Remove competing code before adding new code

### 2.2 Respect Anti-Goals

Anti-goals are **guardrails, not suggestions**:
- If tempted to violate an anti-goal, **STOP and ask user**
- "Technically correct but doesn't work" = FAIL
- Don't compensate for a broken foundation with surface fixes

### 2.3 Stay In Scope

- Only modify files in the allowed list
- If you discover you need to touch a forbidden file, STOP and ask
- If the scope needs to expand, STOP and ask

---

## PHASE 3: VERIFICATION

> **ORDER MATTERS**: Behavioral verification comes BEFORE build checks.
> A passing build with failing acceptance tests = FAILURE.

### 3.1 Run Acceptance Tests (MANDATORY)

For each acceptance test in the PRP:
1. Perform the verification method specified
2. Observe the actual result
3. **Report what you observed** (not what the code says)
4. **All tests must PASS with evidence** — checkboxes alone = FAIL

#### Evidence Format (Required)

VALID evidence:
```
- [x] User login redirects to dashboard: PASS
  Evidence: "Ran the app, entered test credentials, observed redirect
  to /dashboard with user name displayed in header."

- [x] Invalid input shows error: PASS
  Evidence: "Submitted empty form, saw red border on required fields
  and 'This field is required' message below each."
```

INVALID (will be rejected):
```
- [x] PASS — "the code handles this case correctly"
- [x] PASS — "implementation follows the spec"
```

**"PASS" without observed evidence = FAIL.**

### 3.2 Build/Test Verification (After Acceptance Tests Pass)

Run whatever build, lint, and test commands are appropriate for the project.
Build checks verify code correctness, not behavioral correctness. Both are required.

### 3.3 Regression Check

- [ ] Existing behavior not broken
- [ ] No files outside allowed list were modified
- [ ] No anti-goals violated

---

## PHASE 4: OUTPUT

### Required Deliverable

```markdown
## PRP Execution Summary

### Files Modified
- `path/to/file.ext` (lines X-Y): [description of change]

### Acceptance Tests (with evidence)
- [x] Test 1: PASS — Evidence: "[what you observed]"
- [x] Test 2: PASS — Evidence: "[what you observed]"
- [x] Test 3: PASS — Evidence: "[what you observed]"

### Anti-Goals Checked
- [x] [Anti-goal 1]: Not violated
- [x] [Anti-goal 2]: Not violated

### Build/Test Status
- [Build tool]: PASS/FAIL
- [Test runner]: PASS/FAIL

### Scope Compliance
- Files modified: [list] (all within allowed list)
- Forbidden files touched: NONE
```

---

## SPECIAL CASE: Claiming "No Changes Required"

If you believe no code changes are needed, you MUST:

1. Complete Phase 0 Certificate (above)
2. Run ALL acceptance tests with observable evidence for each
3. State specific observations that prove each test passes
4. Explicitly state: "I have verified that [specific outcomes] are working"

**If you cannot do all four, changes ARE required.**

"No changes required" without observable evidence = AUTOMATIC FAILURE.

This is the most common failure mode. PRPs exist because something needs to change.

---

## Anti-Patterns (Never Do These)

| Pattern | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| **Claim "already done"** | PRPs exist because something needs to change | Verify current state, then implement |
| **Analyze code instead of behavior** | Code structure != working software | Run the app/tests first, always |
| **Generate checklist without verifying** | Cargo cult verification | Actually run each test |
| **Guess at file paths or imports** | Causes cascading errors | Verify every reference against codebase |
| **Touch forbidden files** | Out of scope | Stop and ask |
| **Skip baseline observation** | Can't know if you improved anything | Phase 0 is mandatory |
| **"Close enough" acceptance** | Ships bugs | Must be exact PASS with evidence |
| **Defer to user** | "Let me know if it works" offloads your job | YOU verify and report observations |
| **Future tense** | "This should work" / "You can verify by..." | State what you DID verify |
| **Surface fix for structural problem** | Masks root cause | Fix the foundation first |

### The Laziness Trap

The most common failure mode: existing code has names or patterns that match PRP terminology, leading to "this is done" without behavioral verification.

**Code existing is not proof of code working.**

If you find yourself writing "the implementation already fulfills the PRP" without having observed the actual behavior, you are being lazy and your output will fail.

---

## When to STOP and Ask

- PRP requires changes to a forbidden file
- Implementation approach violates an anti-goal
- Acceptance test can't pass without scope change
- Build fails and fix requires out-of-scope changes
- You discover the PRP's assumptions about current state are wrong

---

## PHASE 5: COMMIT

After Phase 4 output is complete and all acceptance tests pass, **commit the work**.

1. Stage only files within the allowed list (no `git add -A`)
2. Write a commit message that summarizes the PRP outcome, not the process:
   - **Format**: `feat: {what was built/changed}` or `fix: {what was fixed}`
   - **Body**: 1-2 sentences on the observable outcome, referencing the PRP filename
   - Include `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
3. Do NOT push — the user will push when ready

This is automatic. Do not ask the user whether to commit — a completed PRP with passing tests is a concrete unit of work that warrants a commit.
