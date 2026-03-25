---
name: find-skills
description: Helps users discover available local skills when they ask "how do I do X", "find a skill for X", "is there a skill that can...", or want to see what the system can do.
---

# Find Skills

This skill discovers capabilities from Brain's local machine-readable skill catalog.

## When to Use This Skill

Use this skill when the user:

- Asks "how do I do X" where X may map to an existing skill
- Says "find a skill for X" or "is there a skill for X"
- Asks what Brain can do in a domain or workflow
- Wants to know whether a capability already exists before building a new skill

## Source of Truth

- Read `.claude/skill-index.yml`
- Search all catalog sections: `vault_skills`, `dev_skills`, `writing_skills`, `google_skills`, `persona_skills`, `research_skills`
- Treat the nested family key as the family label
- Do not parse router prose for discovery

## Search Workflow

### Step 1: Understand the Request

Extract:

1. The domain or surface
2. The concrete task
3. Any keywords the user already used

### Step 2: Load the Catalog

Read `.claude/skill-index.yml` and search every family across:

- `name`
- `trigger`

Use simple keyword matching. Prefer:

1. Exact skill-name matches
2. Trigger matches with strong keyword overlap
3. Family relevance to the user's request

### Step 3: Present Matches

Return the best matches with family labels so the user can see what kind of skill each one is.

Response format:

```text
I found these local skills:

- [family] skill-name — one-line trigger
  Path: .claude/skills/...
  Deployed: ~/.claude/skills/...   # only if `deployed_to` exists
```

Keep the list short unless the user asks for a broad inventory.

### Step 4: If Nothing Matches

If no local match exists:

1. Say no relevant local skill was found in `.claude/skill-index.yml`
2. Offer to handle the task directly if possible
3. If the gap looks reusable, suggest:
   - `skill-scaffold` to create a new skill
   - `skill-audit` to validate the skill catalog afterward

## Catalog Notes

- Brain is the canonical source of truth for local skills
- Some entries include `deployed_to`; those are symlinked into `~/.claude/skills`
- Discovery is local-catalog-driven, not router-prose-driven

## Example Matches

- User asks "what can help me package a skill?" -> `[dev] skill-package`
- User asks "how do I stress-test my positions?" -> `[the-brain-analysis] challenge`
- User asks "what should I run next?" -> `[the-brain] skill-recommend`
- User asks "can I get a fast vault health scan?" -> `[the-brain] health-check`
