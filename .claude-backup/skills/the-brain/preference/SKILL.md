---
name: preference
description: "Create or update a design preference note. Use when user expresses a taste decision, rejects a visual pattern, or identifies what they like/dislike about a design."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *)
argument-hint: "'preference description' [--category surface|color|typography|texture|motion|controls|composition|rejection]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain
Preference index: studio/design-system/preference-index.yml

(At start of execution, use Grep to check: existing taste positions by searching notes/positions/ for classification: taste.)

# /preference — Record a Design Taste Decision

You are capturing a discrete design preference — an atomic unit of taste. Preferences are like positions but for visual/interaction design: named beliefs about what looks right, feels right, or works right.

## Parse Input

From `$ARGUMENTS`, extract:
- The preference being expressed (required)
- `--category` (optional): surface, color, typography, texture, motion, controls, composition, rejection

If no explicit category, infer from context:
- Surface/background talk → surface
- Color/palette talk → color
- Font/type talk → typography
- Texture/material talk → texture
- Animation/transition talk → motion
- Button/nav/input talk → controls
- Layout/spatial talk → composition
- "Never/don't/hate" → rejection

## Check for Existing Preference

Search `notes/positions/` for an existing note with `classification: taste` that covers this taste decision. If found:
- Update the existing note rather than creating a duplicate
- Add new evidence to "Where it came from"
- Adjust stage/confidence if the preference is being reinforced or challenged

## Create the Preference Note

Write to `notes/positions/YYYY-MM-DD-pos-{slug}.md`:

```yaml
---
title: "{Preference Name}"
type: position
classification: taste
testable: false
tags: [design, {category}, {additional tags}]
created: {date}
updated: {date}
stage: forming
confidence: low
---

## Thesis

{One sentence stating the preference clearly.}

## Evidence For

- {Concrete implementation detail}
- {Token values if applicable}
- {Visual description}

## Evidence Against

- {What this preference explicitly excludes}
- {Anti-examples}

## Where it came from

{Context: which project, which iteration, which reference prompted this.}

## Related

- [[{related-position-slug}]]
```

### Field definitions

**stage:**
- `forming` — just noticed this preference, not yet tested
- `exploring` — survived a few iterations, under active consideration
- `held` — repeatedly validated, core to the identity

**confidence:** low | medium | high

## Update the Preference Index

After creating/updating the note, update `studio/design-system/preference-index.yml`:

1. Add a new entry under the appropriate category section
2. Include: slug, name, category, summary, key_tokens (if any), styles (which named styles use this)
3. Keep entries sorted by category

## Regenerate Affected Looks

After updating the preference index, regenerate look HTML for any styles that use this preference:

1. Read the `styles:` field for this preference's entry in `preference-index.yml`
2. For each listed style, run: `python3 lab/archived/surfaces/gallery/generate.py <style-name>`
3. If no styles reference this preference yet, skip this step

## Report

```
Preference recorded: {name}
Classification: taste
Stage: {stage}
File: notes/positions/{slug}.md
Index: updated
Looks regenerated: {list of style names, or "none (no styles use this preference yet)"}

Related: {list any related preferences that were found}
```
