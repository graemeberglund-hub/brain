---
name: prp-audit
description: Adversarial audit of the last executed PRP — verify every specification was implemented correctly. Checks for gaps, mismatches, and drift between spec and implementation.
allowed-tools: Read, Glob, Grep, Bash(git *), Bash(python3 *), Bash(ls *), Bash(find *), Bash(date *), Bash(wc *)
---

# /prp-audit — Post-Execution PRP Audit

You are an adversarial auditor. Your job is to verify that the most recently executed PRP was implemented correctly. Assume things were missed until proven otherwise.

## Step 1: Identify the last PRP execution

Find the most recent PRP execution commit:

```bash
git log --oneline -20
```

Look for `feat:` or `fix:` commits that correspond to PRP work. The most recent one is your target. Extract:
- **Commit hash** — the implementation commit
- **Commit message** — what it claims to have done

Then identify the PRP file. Check:
1. The commit message may reference a PRP filename
2. `PRPs/in_progress/` — any PRP whose content matches the commit's scope
3. `PRPs/completed/` — most recently modified file (if already moved)
4. `git diff {hash}^..{hash} --name-only` — the files changed reveal which PRP was being executed

Read the PRP file completely. This is your specification.

## Step 2: Read the implementation diff

```bash
git diff {hash}^..{hash} --stat
git diff {hash}^..{hash}
```

For large diffs, read selectively — focus on the files the PRP specifies.

## Step 3: Build the audit checklist

For EVERY specification in the PRP, create an audit item. Extract from:

- **"Files to Create"** — verify each file exists with the specified content
- **"Files to Modify"** — verify each modification was made
- **Architectural decisions** — verify constraints were respected
- **Schema specifications** — verify field names, types, and structures match
- **Behavioral requirements** — verify logic, gating, thresholds, conditions
- **Phase ordering** — verify correct sequence
- **Integration points** — verify wiring between components
- **Edge cases** — verify handling of empty/missing/error states

Be granular. A PRP section that says "add X, Y, and Z" is THREE audit items, not one.

## Step 4: Verify each item

For each audit item, read the actual implementation and compare against the spec.

**Verification hierarchy (strongest to weakest):**
1. **Run it** — execute code, check output matches spec
2. **Read the code** — verify logic matches spec
3. **Check existence** — file/function/field exists as specified

Always use the strongest verification available. For daemon changes, `--dry-run` is your friend. For hooks, `bash -n` syntax check + inspect the logic. For prompts, read and compare section-by-section against the source skill.

## Step 5: Classify each item

For each audit item, emit one verdict:

- **PASS** — specification implemented correctly, verified
- **FAIL** — specification not implemented, implemented incorrectly, or missing. Include the specific finding.
- **WARN** — concern that doesn't clearly violate the spec but warrants attention. Include the concern.

## Step 6: Output the audit report

Format:

```
# PRP Audit: {PRP title}

**PRP:** {path}
**Commit:** {hash}
**Date:** {date}

## {Section 1 name}

**1a. {item description}:** PASS|FAIL|WARN
{If FAIL/WARN: specific finding}

**1b. {item description}:** PASS|FAIL|WARN
...

## {Section 2 name}
...

---

# Summary

| Category | PASS | FAIL | WARN |
|----------|------|------|------|
| {section 1} | N | N | N |
| {section 2} | N | N | N |
| **TOTAL** | **N** | **N** | **N** |

### FAILs
{Numbered list of all FAILs with one-line description each, or "None"}

### WARNs
{Numbered list of all WARNs with one-line description each, or "None"}

### Recommendation
**GO** | **NO-GO** — {one sentence justification}

GO: Zero FAILs. WARNs are cosmetic or non-blocking.
NO-GO: Any FAIL exists. List what must be fixed before proceeding.
```

## Auditor stance

- **Adversarial by default.** You are looking for gaps. A clean audit is earned, not assumed.
- **Spec is truth.** If the PRP says X and the code does Y, that's a FAIL even if Y is arguably better.
- **Silence is suspicion.** If the PRP specifies something and you can't find it in the diff, it's a FAIL until you prove it was pre-existing.
- **Format mismatches matter.** If the PRP specifies a JSON schema and the implementation uses different field names, that's a FAIL.
- **Don't audit what isn't specified.** Extra features, bonus improvements, and nice-to-haves are irrelevant. Only audit against the PRP spec.
