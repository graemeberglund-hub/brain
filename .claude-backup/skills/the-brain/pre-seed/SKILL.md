---
name: pre-seed
description: "Research phase — build a profile of a new user from public information before interactive onboarding. Writes to knowledge/pre-seed.yml. Runs unattended."
allowed-tools: Read, Write, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), WebSearch, WebFetch
argument-hint: "'name' [--github handle] [--website url]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: $BRAIN_VAULT_PATH

# /pre-seed — Research Phase for New User Onboarding

You are building a profile of a new user from publicly available information. This profile will be consumed by `/onboard` to create a "this already knows me" first contact experience. You do NOT ask the user anything — this skill runs silently and produces a structured YAML file.

## Parse Arguments

Extract from `$ARGUMENTS`:
- `name` (required) — the person's name
- `--github {handle}` (optional) — their GitHub username
- `--website {url}` (optional) — their personal/professional website

If no name is provided, output an error:
```
Usage: /pre-seed 'Jane Doe' [--github janedoe] [--website janedoe.dev]
```

## Research Phase

### Step 1: GitHub (if handle provided)

Use WebFetch to read their GitHub profile page. Extract:
- Bio/description
- Pinned/popular repositories (names, descriptions, languages)
- Activity level (recent commits, contribution graph description)
- Organizations
- Location, blog URL, Twitter handle if listed

If no GitHub handle provided, use WebSearch: `"{name}" github` to attempt discovery.

### Step 2: Website (if URL provided)

Use WebFetch to read their website/blog. Extract:
- Self-description or "About" page content
- Topics they write about
- Projects or portfolio items mentioned
- Professional affiliations

### Step 3: General web search

Use WebSearch for: `"{name}" {any known context from github/website}`

Look for:
- Conference talks or presentations
- Blog posts on other platforms (Medium, Substack, dev.to)
- Professional profiles (LinkedIn summary if publicly visible)
- Open-source contributions or community involvement
- Published papers or articles

### Step 4: Synthesize

From all gathered information, build a coherent profile. Be conservative — only include things you found evidence for. Flag gaps explicitly.

## Write Pre-seed File

Write to `knowledge/pre-seed.yml`:

```yaml
generated: {today}
source_inputs:
  name: "{name}"
  github: "{handle or null}"
  website: "{url or null}"
profile:
  name: "{full name}"
  summary: "{1-2 sentence synthesis of who they are and what they do}"
  domains: ["{domain1}", "{domain2}", ...]
  likely_role: "{best guess at their professional role}"
projects:
  - name: "{project name}"
    description: "{what it does}"
    languages: ["{lang1}", "{lang2}"]
    activity: "{active|inactive|unknown}"
  # ... up to 5 most notable projects
signals:
  working_style: "{synthesis of how they seem to work — solo/team, builder/researcher, etc.}"
  interests: ["{interest1}", "{interest2}", ...]
confidence: {low|medium|high}  # how much signal did we find?
gaps: ["{what we couldn't find}", ...]
```

## Rules

1. **Never ask the user anything.** This skill is silent research.
2. **Be conservative.** Only include what you found evidence for. Don't fabricate.
3. **Confidence reflects signal quality.** If you only found a GitHub profile with 2 repos, that's `low`. If you found GitHub + blog + talks, that's `high`.
4. **Gaps are valuable.** Listing what you didn't find helps `/onboard` know what to ask about.
5. **One person per pre-seed.** If the vault already has a `pre-seed.yml`, overwrite it (new user setup).
6. **Don't create any vault notes.** That's `/onboard`'s job.

## Report

After writing the file, output a brief summary:

```
PRE-SEED COMPLETE — {name}

Confidence: {level}
Domains found: {list}
Projects found: {count}
Gaps: {list}

Pre-seed written to knowledge/pre-seed.yml
Next: run /onboard to start the interactive setup.
```
