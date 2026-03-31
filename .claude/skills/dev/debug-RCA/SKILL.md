---
name: debug-RCA
description: Systematically debug and diagnose reported problems with root cause analysis
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "[problem description]"
---

# Debug Issue

Systematically debug and diagnose the reported problem.

## Problem Description

$ARGUMENTS

## Step 0: Pattern Match (before forming hypotheses)

Check the symptom description against known patterns:

| Symptom | Likely Root Cause |
|---------|-------------------|
| "works after restart" | stale cache |
| "intermittent" | race condition |
| "works locally, fails in CI" | wrong environment |
| "no error, just wrong output" | silent swallow |
| "broke after update" | dependency mismatch |
| "fails on first/last" | off-by-one |
| "works for small input" | scaling / memory |
| "fails silently" | swallowed exception |
| "inconsistent results" | uninitialized state |

If a pattern matches, test that hypothesis first before broader investigation.

## Debugging Process

1. **Reproduce the Issue**
   - Get exact steps to reproduce
   - Verify you can see the same problem
   - Note any error messages or logs
   - Document the expected vs actual behavior

2. **Gather Information**

   ```bash
   # Check recent changes
   git log --oneline -10

   # Look for error patterns in logs
   # Search for related error messages
   ```

3. **Isolate the Problem**
   - **Binary Search**: Comment out code sections to narrow down
   - **Git Bisect**: Find when the bug was introduced
   - **Logging**: Add strategic log statements
   - **Debugger**: Set breakpoints if applicable

4. **Hypothesis Tracking (3-Strike Rule)**

   Track each hypothesis explicitly:

   ```
   Hypothesis 1: [description] → TESTED → [result]
   Hypothesis 2: [description] → TESTED → [result]
   Hypothesis 3: [description] → TESTED → [result]
   → 3 STRIKES: STOP. Escalation required.
   ```

   After 3 failed hypotheses, do NOT continue guessing. Choose an escalation path:

   - **A) Continue** — Reset strike count. Only if you have a genuinely new category of hypothesis (not a variation of a failed one).
   - **B) Escalate** — Ask the user for architectural context. The bug may require domain knowledge you don't have.
   - **C) Add logging** — Instrument the code path and wait for reproduction with better observability.

5. **Scope Lock**

   If your fix touches **>5 files**, STOP and ask before proceeding. A fix that requires changes across 5+ files is either:
   - Addressing the wrong root cause (symptom-chasing)
   - A legitimate cross-cutting issue that needs architectural review
   - Both

   Present the file list and rationale before making the changes.

6. **Common Debugging Strategies**

   ### For Runtime Errors
   - Read the full stack trace
   - Identify the exact line causing the error
   - Check variable values at that point
   - Verify assumptions about data types

   ### For Logic Errors
   - Add print/log statements to trace execution
   - Verify each step produces expected results
   - Check boundary conditions
   - Test with minimal reproducible example

   ### For Performance Issues
   - Add timing measurements
   - Check for N+1 queries
   - Look for inefficient algorithms
   - Profile if necessary

   ### For Integration Issues
   - Verify external service is accessible
   - Check authentication/credentials
   - Validate request/response formats
   - Test with curl/Postman first

7. **Root Cause Analysis**
   - Why did this happen?
   - Why wasn't it caught earlier?
   - Are there similar issues elsewhere?
   - How can we prevent this class of bugs?

8. **Implement Fix**
   - Fix the root cause, not just symptoms
   - Keep fix minimal and focused, follow KISS
   - Respect scope lock (>5 files → ask first)

9. **Verify Resolution**
   - Confirm original issue is fixed
   - Check for regression
   - Test related functionality
   - Add test to prevent recurrence

10. **Document Findings**

    ```markdown
    ## Debug Summary

    ### Issue
    [What was broken]

    ### Hypotheses Tested
    1. [hypothesis] → [result]
    2. [hypothesis] → [result]

    ### Root Cause
    [Why it was broken]

    ### Fix
    [What was changed — N files]

    ### Prevention
    [How to avoid similar issues]
    ```

## Debug Checklist

- [ ] Pattern table checked against symptom
- [ ] Issue reproduced locally
- [ ] Hypotheses tracked with strike count
- [ ] Root cause identified (not symptom-chased)
- [ ] Scope lock respected (<= 5 files, or user approved)
- [ ] Fix implemented
- [ ] Tests added/updated
- [ ] No regressions introduced
