# /plan-eng-review — Engineering Plan Review

Reviews architecture and technical design BEFORE implementation. Finds structural problems when they're cheap to fix — not after 2000 lines of code exist.

## Trigger

User says: "eng review", "plan review", "review my plan", "architecture review", "is this plan sound", or presents a PRP/design doc for technical review.

## Input

Accepts any of:
- A PRP file path
- A design doc (from `/office-hours` or manual)
- A free-text description of what the user intends to build
- The current working state of a repo (inferred from recent commits + changed files)

## Review Passes

Run all 7 passes sequentially. Each pass produces findings. At the end, aggregate into a rated summary.

### Pass 1: System Boundaries
- What are the components? Where does each one start and end?
- Are the boundaries drawn at natural seams (network, process, trust level, data ownership)?
- Does any component do two unrelated things? Flag it.
- Are there implicit dependencies that should be explicit?

### Pass 2: Data Flow
- Trace every piece of data from origin to final resting place
- Identify transformations, validations, and serialization boundaries
- Check: can data arrive in an unexpected shape at any boundary? (nil, empty, wrong type, too large)
- Draw an ASCII data flow diagram:

```
[Source] --format--> [Transform] --validate--> [Store] --query--> [Render]
                                     |
                                     v
                                 [Error Path]
```

### Pass 3: State & Transitions
- What state does the system manage? Where does it live?
- Draw a state diagram for any non-trivial state machine:

```
[idle] --trigger--> [processing] --success--> [complete]
                         |
                         +--failure--> [error] --retry--> [processing]
                                          |
                                          +--max_retries--> [dead_letter]
```

- Check: can the system get stuck in any state? Is there always a path out?
- Check: can two processes modify the same state concurrently?

### Pass 4: Failure Modes
- For each component: what happens when it's unavailable?
- For each data flow: what happens when the data is malformed, late, or missing?
- For each external dependency: what happens when it returns an error, times out, or returns stale data?
- Are failures loud (error + alert) or silent (swallowed, logged, ignored)?
- Is there a degraded mode or is it all-or-nothing?

### Pass 5: Edge Cases
- What happens at zero? (no data, no users, empty state, first run)
- What happens at scale? (1M rows, 1000 concurrent users, 10GB file)
- What happens at boundaries? (midnight, month-end, timezone change, DST)
- What happens with adversarial input? (SQL injection, XSS, path traversal, oversized payloads)

### Pass 6: Trust Boundaries
- Where does untrusted input enter the system? (user input, API responses, file uploads, env vars)
- Is every trust boundary validated?
- Are secrets managed correctly? (not hardcoded, not logged, not in URLs)
- Are there elevation-of-privilege paths? (user → admin, read → write)

### Pass 7: Implementation Complexity
- Which parts of this plan are genuinely hard vs. just tedious?
- Where will the implementer likely take shortcuts?
- What's the riskiest single component? (the one most likely to cause a rewrite)
- Is the plan ordered correctly? (hardest/riskiest things first, or are they buried at the end?)

## Rating

After all passes, rate the plan on 4 dimensions (1-5 scale):

| Dimension | 1 | 5 |
|-----------|---|---|
| **Clarity** | Ambiguous, multiple interpretations | Unambiguous, one way to read it |
| **Completeness** | Major gaps, undefined behavior | Every path specified |
| **Feasibility** | Requires unknown technology or heroics | Straightforward with known tools |
| **Risk** | High risk of rewrite after implementation | Low risk, well-bounded |

## Output Format

```markdown
## Engineering Review: {plan title}

### Findings

#### Critical (blocks implementation)
- {finding with specific reference to plan section}

#### Important (should fix before building)
- {finding}

#### Advisory (consider, not blocking)
- {finding}

### Diagrams
{ASCII diagrams from passes 2 and 3}

### Ratings
| Clarity | Completeness | Feasibility | Risk |
|---------|-------------|-------------|------|
| {1-5}  | {1-5}       | {1-5}       | {1-5}|

### Verdict
{APPROVE / REVISE / RETHINK}
- APPROVE: safe to implement as-is
- REVISE: fix the critical/important findings, then implement
- RETHINK: structural problems — go back to /office-hours or redesign

### Suggested Plan Edits
{If REVISE: specific edits to the plan. If RETHINK: what needs to change.}
```

## Rules

- Review the PLAN, not hypothetical code. Don't write code.
- Be specific. "This might have issues" is not a finding. "The webhook handler has no retry logic, so dropped webhooks are silently lost" is.
- Don't invent requirements. Only flag gaps that matter for what the plan describes.
- If the plan is genuinely solid, say so. Don't manufacture findings to justify the review.
