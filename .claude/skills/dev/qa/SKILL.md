# /qa — Browser QA

Opens the live application in a browser, tests critical paths, finds bugs, fixes them, and verifies. Produces structured bug reports with evidence.

## Trigger

User says: "qa", "test this", "qa the app", "check if this works", "run qa", "smoke test"

## Prerequisites

- The app must be running and accessible at a URL
- Browser tools MCP must be available (`mcp__browser-tools__takeScreenshot`, `mcp__browser-tools__getConsoleErrors`, etc.)
- If no browser tools: fall back to code-based static analysis (see Fallback Mode)

## Tiers

Specify tier when invoking, or default to Standard:

| Tier | Scope | When |
|------|-------|------|
| **Quick** | Critical + high severity only | Pre-push sanity check |
| **Standard** | + medium severity | Normal QA pass |
| **Exhaustive** | + cosmetic, edge cases, performance | Pre-release |

## Procedure

### Step 1: Discover Test Surface

1. Read the project structure to understand what pages/routes exist
2. Identify the primary user flows (the things 80% of users do)
3. Check for existing test files — don't duplicate what's already covered
4. Build a test plan:

```markdown
### Test Plan
| # | Flow | Steps | Priority |
|---|------|-------|----------|
| 1 | {primary flow} | {step1 → step2 → step3} | critical |
| 2 | {secondary flow} | {steps} | high |
| 3 | {edge case} | {steps} | medium |
```

### Step 2: Execute Tests

For each flow in the test plan (filtered by tier):

1. Navigate to the starting URL
2. Take a screenshot (baseline)
3. Execute each step:
   - Click elements, fill forms, navigate
   - Check console for errors after each action (`mcp__browser-tools__getConsoleErrors`)
   - Check network for failed requests (`mcp__browser-tools__getNetworkErrors`)
   - Take screenshots at key states
4. Verify the expected outcome
5. Record: PASS / FAIL / BLOCKED (with evidence)

### Step 3: Bug Triage

For each failure:

```markdown
#### BUG-{N}: {title}
- **Severity**: critical / high / medium / cosmetic
- **Flow**: {which test flow}
- **Steps to reproduce**: {exact steps}
- **Expected**: {what should happen}
- **Actual**: {what happened}
- **Evidence**: {console error, network error, screenshot}
- **Root cause**: {if determinable from code inspection}
```

### Step 4: Fix & Verify

For critical and high bugs:
1. Read the relevant source code
2. Identify the root cause
3. Fix the code
4. Reload the page and re-execute the test steps
5. Take an after-screenshot
6. Confirm the fix doesn't break other tests

For medium and cosmetic bugs:
- Fix if the fix is obvious and low-risk
- Otherwise, report only

### Step 5: Regression Tests

For each bug fixed, suggest a test that would catch it:

```markdown
### Suggested Regression Tests
| Bug | Test Description | Type |
|-----|-----------------|------|
| BUG-1 | {what to test} | {unit/integration/e2e} |
```

If the project has a test framework, write the actual test file.

### Step 6: Report

```markdown
## QA Report: {project}

### Summary
- **Tier**: {Quick/Standard/Exhaustive}
- **Flows tested**: {N}
- **Bugs found**: {N} ({critical}, {high}, {medium}, {cosmetic})
- **Bugs fixed**: {N}
- **Health score**: {0-100}

### Results
| # | Flow | Result | Notes |
|---|------|--------|-------|
| 1 | {flow} | PASS/FAIL | {brief note} |

### Bugs
{Full bug reports from Step 3}

### Fixes Applied
{Summary of each fix with before/after}

### Ship Readiness
- [ ] All critical bugs fixed
- [ ] All high bugs fixed or documented
- [ ] No new console errors
- [ ] No network failures
- [ ] Regression tests suggested/written

**Verdict**: {SHIP / FIX FIRST / BLOCK}
```

## Fallback Mode (No Browser Tools)

If browser MCP tools are unavailable:

1. Read all source files for the target pages/routes
2. Static analysis checks:
   - **Error handling**: Are fetch calls wrapped in try/catch? Do forms validate input?
   - **Edge cases**: What happens with empty data, null values, long strings?
   - **State management**: Can state become inconsistent? Race conditions?
   - **Security**: XSS vectors in rendered user input? Unsanitized queries?
   - **Accessibility**: Are form labels present? Are ARIA attributes used correctly?
3. Report findings with file:line references
4. Fix what can be fixed without runtime verification

## Rules

- Test like a user, not like a developer. Click things, fill in forms, try to break it.
- Evidence everything. No "I think this might fail" — show the console error, the network response, the screenshot.
- Fix bugs, don't just report them. This is a QA engineer who can also write code.
- Don't change features. Fix bugs only — the behavior should match the spec, not your preference.
- If a bug is ambiguous (might be intentional), ask before fixing.
- Atomic fixes. One bug = one fix. Don't bundle.
