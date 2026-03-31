---
name: prp-optimize
description: "Verify every factual claim in a PRP against source files, fix errors, and produce an execution-ready spec. Use when a PRP needs accuracy verification before execution."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls *), Bash(wc *), Bash(head *), Bash(tail *), Bash(python3 *), Bash(find *), Bash(test *), Bash(date *), Bash(git *)
argument-hint: "[path to PRP file]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

# /prp-optimize — Source-Verified PRP Optimization

You are a verification agent. Your job is to read a PRP, find every factual claim it makes about the codebase, verify each claim against the actual source files, and correct any errors. You do NOT rewrite the PRP's intent — you fix its facts.

**Core principle:** The PRP author understood what needs to happen but may have gotten details wrong. Wrong file counts, wrong array dimensions, wrong split sizes, files falsely claimed to auto-adapt. These errors are invisible during creation but cause crashes during execution. Your job is to find them all in one pass.

## Input

`$ARGUMENTS` is a path to a PRP file. Read it completely.

---

## Phase 1: Ingest and Extract Claims

Read the PRP file. Identify its type from frontmatter (`type`, `tags`). Then extract every factual assertion into a claim registry.

### Claim types to extract

| Type | What to look for | Priority |
|---|---|---|
| `file-path` | Any file path mentioned (to modify, to read, to create) | P0 |
| `file-manifest` | Counts like "only 2 files need edits", "3 files to modify" | P0 |
| `dimension` | Numbers tied to data: "49-point grid", "9 params", "N=500", "147 outputs" | P1 |
| `auto-adapt` | Claims that a file needs no changes or auto-adapts | P1 |
| `default-value` | Specific defaults mentioned: "split sizes 392/50/50", "batch_size=64" | P2 |
| `hardcoded-string` | Strings the PRP says exist or will exist in code/output | P2 |
| `display-range` | Axis limits, plot ranges, visualization bounds | P3 |
| `execution-order` | Dependencies between steps | P2 |
| `acceptance-criteria` | Verification checks with specific expected values | P2 |

For each claim, record:
- The claim text (quoted from PRP)
- The PRP section/line where it appears
- The claim type
- Status: UNVERIFIED (will be updated in later phases)

### PRP type detection

If frontmatter `type` or `tags` contain `research`, `strategy`, `market`, `paper`, or `memo` — this is a **non-code PRP**. Skip Phases 3 and 4 entirely. Run Phases 2 and 5 in reduced mode (file existence and execution order only).

Otherwise, proceed through all 7 phases.

---

## Phase 2: File Manifest Verification

### 2.1 Check every referenced file

For every file path in the claim registry:

1. Check existence: `test -f {path}`
2. Categorize its role in the PRP:
   - **TO-MODIFY** — PRP says to edit this file
   - **TO-CREATE** — file doesn't exist, PRP says to create it
   - **INPUT-DATA** — data file read by code (CSV, JSON, etc.)
   - **REFERENCE-ONLY** — mentioned for context, not modified
   - **CLAIMED-AUTO-ADAPT** — PRP explicitly says this file needs no changes

3. For TO-CREATE files: verify the PRP provides enough specification to create them. Flag if a later step references content in a file that no prior step creates.

### 2.2 Exhaustive completeness search — find unlisted files

This is the most important substep. It catches "only 2 files need edits but actually 5 do."

**MANDATORY: Vault-wide grep, not directory-scoped.** Previous failures came from grepping only sibling directories. The blast radius of schema/type/path changes is repo-wide.

1. From the PRP, extract **search terms** — old values being replaced, directory paths being changed, type names being renamed, function names being modified. These are your grep patterns.
2. Run `grep -rl "{pattern}" .` from the repo root for EACH search term. This is non-negotiable — do not scope to specific directories.
3. Collect ALL files with hits into a single list.
4. Subtract files already in the PRP's manifest → remainder are **POTENTIAL OMISSIONS**.
5. For each potential omission, read enough context to classify: (a) needs updating, (b) historical/frozen — exclude, (c) auto-regenerated — exclude, (d) false positive.

**Follow import chains.** If a file imports a function that the PRP modifies, the importing file is in scope even if it doesn't match the grep pattern directly. When you find a function being changed, grep for its name repo-wide.

**Example:** If the PRP modifies `scripts/data.py` to change `INPUT_PARAMS` from 9 to 10 elements, grep the ENTIRE REPO for `INPUT_PARAMS`, `n_inputs`, `shape.*9`, `ones(9)`, etc. — not just `scripts/`.

### 2.3 Verify manifest counts

If the PRP claims "only N files need edits" or "N files to modify," check that count against:
- Files in the TO-MODIFY category
- Plus any POTENTIAL OMISSIONS found in 2.2
- Plus any CLAIMED-AUTO-ADAPT files that Phase 4 will flag (note: flag the count as UNVERIFIED until Phase 4 completes, then update)

---

## Phase 3: Dimension and Shape Verification

For every `dimension` claim in the registry:

### 3.1 CSV/data file dimensions

For data files referenced by the PRP:

```bash
# Column count (subtract 1 if counting separators)
head -1 {file} | tr ',' '\n' | wc -l

# Row count (subtract 1 for header)
wc -l < {file}

# Specific column group count (e.g., energy columns)
head -1 {file} | tr ',' '\n' | grep '{pattern}' | wc -l
```

Compare against PRP claims like "49-point grid" or "200 rows."

### 3.2 Array shapes in source code

Read the source files the PRP references. For each, check:

- Array definitions: count actual elements in `np.array([...])` literals
- Default parameters: `n_inputs=9`, `n_outputs=189`, `train_size=392`
- Shape comments: `# shape (N, 63)`, `# (9,)`, `# 189`

Cross-reference these against the PRP's stated dimensions.

### 3.3 Derived dimension consistency

Check that derived values are correct:
- If PRP says "58 energies × 3 channels = 174 outputs" → verify 58 × 3 = 174
- If PRP says "split 140/30/30 for 200 rows" → verify 140 + 30 + 30 = 200
- If PRP says "grid from 8.0 to 20.0 MeV" → verify first and last elements match

### 3.4 Record findings

For each dimension claim, record:
- What the PRP claims
- What the source shows (with the command used to verify)
- MATCH or MISMATCH

---

## Phase 4: Hardcoded Value Audit

For every file marked CLAIMED-AUTO-ADAPT or listed under "files that need no changes":

### 4.1 Read each file completely

Do not grep blindly — read the file to understand its structure, then search systematically.

### 4.2 Search for hardcoded values

Use these high-yield grep patterns on each file. Adapt the specific numbers and terms to match the PRP's domain:

**Dimension-encoding strings** (numbers embedded in display/log strings):
```
grep -n "f['\"].*[0-9]" {file}
grep -n "print.*[0-9]" {file}
```

**Hardcoded defaults that should change:**
```
grep -n "n_inputs\|n_outputs\|n_features\|input_dim\|output_dim" {file}
grep -n "train_size\|val_size\|test_size" {file}
```

**Plot/display limits:**
```
grep -n "set_xlim\|set_ylim\|xlim\|ylim\|vmin\|vmax" {file}
```

**Array constructors with literal sizes:**
```
grep -n "np\.ones\|np\.zeros\|torch\.zeros\|torch\.ones" {file}
```

**Model architecture with hardcoded dimensions:**
```
grep -n "Linear\|Dense\|Conv.*[0-9]" {file}
```

**Docstrings with specific shapes:**
```
grep -n "shape.*(.*[0-9]" {file}
```

**Smoke tests / `__main__` blocks:**
Check if the file has a `if __name__` block with hardcoded test values.

### 4.3 Cross-reference with PRP's change scope

For each hardcoded value found, ask: does this value need to change given what the PRP is doing? Specifically:

- If the PRP changes a parameter count from 9 → 10, does this file reference "9" in a context that means "number of parameters"?
- If the PRP changes a grid from 63 to 58 points, does this file reference "63" or "189" (63×3)?
- If the PRP changes training data from 500 to 200 rows, does this file reference "500" or "392" (500×0.78)?

**Not every occurrence of a number is a bug.** The number "9" in `patience=9` is not related to "9 OMP parameters." Use the context of each occurrence to determine relevance.

### 4.4 Record findings

For each hardcoded value that needs updating:
- File path and line number
- Current hardcoded value
- What it should be (and why)
- Whether this contradicts the PRP's claim that the file auto-adapts

---

## Phase 5: Execution Order and Pre-Flight Checks

### 5.1 Dependency mapping

List the PRP's implementation steps. For each step, identify:
- What it produces (files, artifacts, state changes)
- What it consumes (files, artifacts from prior steps)

Flag any step that consumes an artifact no prior step produces.

### 5.2 Pre-flight check generation

For every step that involves an expensive or time-consuming operation (training, batch runs, large computations), generate a concrete pre-flight check command that verifies preconditions:

```bash
# Verify data dimensions before training
python3 -c "
import pandas as pd
df = pd.read_csv('{data_path}')
print(f'Rows: {len(df)}, Cols: {len(df.columns)}')
assert len(df) >= {expected_rows}, f'Expected >= {expected_rows} rows, got {len(df)}'
"

# Verify imports resolve before execution
python3 -c "from {module} import {symbol}; print('OK')"

# Verify checkpoint exists before inference
test -f {checkpoint_path} && echo "Checkpoint exists" || echo "MISSING"
```

### 5.3 Acceptance criteria audit

Check every acceptance criterion in the PRP:
- Does it reference values that Phase 3 corrected? If so, the criterion itself is wrong.
- Is each criterion concrete enough to verify? "Output looks correct" is not verifiable. "Output 1 shows peak at 15.4–15.7 MeV" is.
- Does each criterion have a verification method? If not, suggest one.

---

## Phase 6: Mechanical Verification Gate

**This phase is a hard pass/fail — not a judgment call.** You may NOT declare CLEAN until this gate passes.

### 6.1 Build exclusion list

From the PRP and your analysis, compile files that should legitimately contain old values:
- Historical logs (frozen, not edited)
- Auto-regenerated files (will self-correct after skill updates)
- Archived/completed PRPs
- The PRP file itself

Write the exclusion list explicitly.

### 6.2 Run vault-wide grep

Extract the key search terms from the PRP (old type names, old directory paths, old field names, renamed function signatures). Run:

```bash
grep -rl "{term1}\|{term2}\|{term3}" . --include="*.py" --include="*.md" --include="*.yml" --include="*.yaml" --include="*.json" --include="*.js" --include="*.html" --include="*.css" | grep -v "{exclusion_pattern}"
```

### 6.3 Evaluate results

For EVERY file returned by the grep that is NOT in the PRP's manifest and NOT in the exclusion list:
- Read the matching lines
- Determine if the reference needs updating given the PRP's changes
- If yes → add to corrections as POTENTIAL OMISSION
- If no → add to exclusion list with reason

### 6.4 Gate decision

- If any POTENTIAL OMISSIONS were found → **FAIL**. Add them to the corrections table, update the PRP, and re-run this gate.
- If the grep returns only files in the manifest + exclusion list → **PASS**.

Report the gate result:
```
Verification gate: PASS | FAIL
  Search terms: {list}
  Total files matched: N
  In manifest: N
  In exclusion list: N (with reasons)
  New omissions found: N
```

**Do NOT proceed to Phase 7 until this gate passes.**

---

## Phase 7: Produce Corrected PRP

### 7.1 Build the corrections table

Compile all findings from Phases 2–5 into a single table:

```markdown
## Critical Corrections (prp-optimize, {date})

| # | Location | Original Claim | Verified Truth | Method | Severity |
|---|----------|----------------|----------------|--------|----------|
| 1 | §What changes | "49-point energy grid" | 58 points (v2 grid minus 21–25 MeV) | `head -1 data.csv \| tr ',' '\n' \| grep xs_p2n \| wc -l` | HIGH |
| 2 | §Auto-adapt | "train.py needs no changes" | Line 78: hardcoded "63 energies" | `grep -n "63" train.py` | HIGH |
```

**Severity levels:**
- **HIGH** — would cause crashes, wrong results, or execution failure
- **MEDIUM** — would cause misleading output, wrong diagnostics, or require manual intervention
- **LOW** — cosmetic errors (display strings, axis limits, docstrings) that don't affect correctness

### 7.2 Add unlisted files section

If Phase 2 found files not in the original manifest:

```markdown
### Files missing from original manifest
- `scripts/predict.py` — line 335: `np.ones(9)` hardcoded smoke test (Severity: HIGH)
- `scripts/run_mvp.py` — lines 122,134,200: `set_xlim(8, 25)` (Severity: LOW)
```

### 7.3 Add pre-flight checks section

```markdown
### Pre-flight checks (run before expensive steps)
\```bash
# Before Step N (training):
python3 -c "..."
# Before Step M (figure generation):
test -f checkpoints/ensemble_meta.pt && echo "OK" || echo "MISSING"
\```
```

### 7.4 Apply corrections to PRP body

Edit the PRP in place:
- Insert the corrections table immediately after the `## Context` section (or after frontmatter if no Context section)
- Fix all wrong values throughout the body: wrong numbers, wrong file counts, wrong manifest
- Move CLAIMED-AUTO-ADAPT files that have hardcoded values into the modification manifest
- Update acceptance criteria that reference corrected values
- Add pre-flight check steps to the execution order
- Update any "files regenerated" or "files to modify" tables

### 7.5 Clean pass case

If ALL claims verified correctly and no corrections needed:

```markdown
## Optimization Pass (prp-optimize, {date})

All factual claims verified against source files. No corrections needed.
Files checked: {list}
Claims verified: {count}
```

### 7.6 Report

After editing the PRP, print a summary:

```
PRP Optimization: {PRP title}
  Claims checked: N
  Corrections: N (H high, M medium, L low)
  Files added to manifest: N
  Pre-flight checks generated: N
  Status: OPTIMIZED | CLEAN
```

---

## Stance

- **Verify, don't trust.** Every number, every file path, every "auto-adapts" claim gets checked against source.
- **One pass must be enough.** Be exhaustive in your searches. The vault-wide grep (Phase 2.2), systematic grep patterns (Phase 4.2), and the mechanical verification gate (Phase 6) are what make this a single-pass tool. If the gate fails, you missed something — fix it before declaring CLEAN.
- **Fix facts, not intent.** The PRP author's design decisions are correct. Only their factual claims about the codebase may be wrong.
- **Context matters for numbers.** Not every "9" in a file is "9 OMP parameters." Read surrounding code to determine relevance before flagging.
- **Severity matters.** The executor needs to know which corrections prevent crashes vs which are cosmetic. Always classify.
- **Leave a trail.** The corrections table is the audit trail. Future readers should see exactly what was wrong and how it was verified.
