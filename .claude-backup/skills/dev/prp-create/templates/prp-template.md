# PRP: [Title]

**Goal**: [1 sentence — what observable result does this achieve?]

**Scope**: [Visual only / Behavior changes / Data model / Infrastructure]

**Files allowed to edit**:
- `path/to/file.ext`

**Files forbidden**:
- `path/to/file.ext` (reason)

**Non-negotiable invariants**:
- [3-8 hard constraints that must not be violated]

## 1) Current State

Observable problems or gaps:
1. [Problem 1] — evidence: [where/how you observed it]
2. [Problem 2] — evidence: [where/how you observed it]
3. [Problem 3] — evidence: [where/how you observed it]

## 2) Design Spec

### Structure
- [Component hierarchy, data flow, or layout changes]
- [Exact values where applicable, not "make it better"]

### Behavior
- [State transitions, user interactions, error handling]
- [Edge cases with expected outcomes]

### Constraints
- [Performance budgets, compatibility requirements]
- [Integration points with existing code]

## 3) Implementation Plan

1. **[File/Component]**: [Specific change]
   - Remove: [competing code if any]
   - Add: [new code/behavior]

2. **[File/Component]**: [Specific change]

## 4) Anti-Goals (DO NOT)

1. DO NOT [specific forbidden shortcut]
2. DO NOT [compensating behavior to avoid]
3. DO NOT [common misread to prevent]
4. DO NOT guess about imports, file names, or function signatures
5. DO NOT touch files outside the allowed list

## 5) Acceptance Tests (Verifiable)

| # | Test | PASS Criteria | Verification Method |
|---|------|---------------|---------------------|
| 1 | [What to test] | [Observable result] | [How to verify] |
| 2 | [What to test] | [Observable result] | [How to verify] |
| 3 | [Negative test] | [What must NOT happen] | [How to verify] |

## 6) Validation Checklist

- [ ] All acceptance tests pass with evidence
- [ ] No regressions in existing behavior
- [ ] Build/compile succeeds
- [ ] Tests pass
- [ ] No files outside allowed list were modified
- [ ] Anti-goals verified: none violated

## 7) Deliverable

The executor must output:
1. Summary of edits by file (with line numbers)
2. Evidence for each acceptance test (what was observed, not what code says)
3. Anti-goals verified: "none violated" or explain
4. Build/test status
