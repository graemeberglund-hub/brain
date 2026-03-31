# Convergence Protocol

Shared stopping criterion for iterative analysis loops. Loaded by skills that iterate: `/digest` tribunal, `/challenge`, `/review`, `prp-audit`.

## When to apply

Any time a skill runs multiple iterations of finding-generation against the same target set (e.g., prosecution → defense → re-prosecution, or challenge round N vs round N-1).

## Mechanic

After completing iteration N:

1. **Normalize** each finding to its structural core: strip severity labels, strip phrasing, keep the structural issue or epistemic claim. Example: "CRITICAL: SQL injection in auth handler" → "sql-injection-auth-handler".
2. **Hash** each normalized finding (lowercase, strip whitespace, simple string hash or exact match).
3. **Compare** the hash set against iteration N-1's hash set.
4. **If intersection > 50% of current set** → CONVERGENCE DETECTED.

Report format:
```
Convergence: {matched}/{total} findings match previous iteration. Stopping.
New findings this iteration: {list of unmatched findings, if any}
```

## State files

Each domain writes its convergence state to a dedicated JSONL file:

| Domain | State file |
|--------|-----------|
| Digest tribunal | `knowledge/tribunal-convergence.jsonl` |
| /challenge | `knowledge/challenge-convergence.jsonl` |
| /review | `knowledge/review-convergence.jsonl` |
| prp-audit | `PRPs/audit-history/{prp-slug}.jsonl` |

### Entry format

```jsonl
{"run_id": "...", "iteration": 1, "timestamp": "...", "findings_count": 5, "finding_hashes": ["abc123", "def456", ...], "converged": false}
{"run_id": "...", "iteration": 2, "timestamp": "...", "findings_count": 4, "finding_hashes": ["abc123", "ghi789", ...], "matched_previous": 1, "match_ratio": 0.25, "converged": false}
{"run_id": "...", "iteration": 3, "timestamp": "...", "findings_count": 4, "finding_hashes": ["abc123", "ghi789", ...], "matched_previous": 3, "match_ratio": 0.75, "converged": true}
```

## Rules

- **First iteration never converges.** You need at least two iterations to compare.
- **Convergence is per-run.** A new run_id starts fresh — don't compare against prior runs.
- **Log every iteration** to the state file, even if not converged. This provides an audit trail.
- **When converged, stop immediately.** Do not run another iteration "just to be sure."
- **Report new findings.** Even in a converged iteration, report any findings NOT in the previous set — these are the genuinely new discoveries that emerged late.
