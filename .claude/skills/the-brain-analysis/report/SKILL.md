---
name: report
description: "Generate a styled, portable report from vault data — positions, projects, decisions, or any filtered subset. Use when creating shareable documents from vault content."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(wc *), Agent
argument-hint: "'query description' [--format html|md] [--output path]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Position count: !`ls $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | wc -l | tr -d ' '`
Project count: !`ls $BRAIN_VAULT_PATH/notes/projects/ 2>/dev/null | wc -l | tr -d ' '`
Readable style exists: !`test -f $BRAIN_VAULT_PATH/studio/readable/style.css && echo "yes" || echo "no"`

# /report — Generate Shareable Report from Vault Data

You are composing a report by querying vault notes, then rendering a styled, self-contained document. This is the first outward-facing skill — the output is meant to be shared with people who don't have vault access.

## Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Query** — natural language description of what to include. Examples:
  - `"all positions tagged crypto"` → filter positions by tag
  - `"project status for RLA"` → pull project notes from `notes/projects/rla/`
  - `"weekly activity with decisions"` → combine weekly YAML + decision notes
  - `"questions about mortality"` → filter questions by tag/content
  - `"everything from this week"` → daily notes + captures + decisions from date range
- **--format** — `html` (default) or `md`
- **--output** — custom output path (default: `artifacts/reports/`)

If the query is too vague to act on, ask ONE clarifying question.

## Step 2: Gather Source Notes

Based on the query, search the vault:

1. **By type**: positions, questions, decisions, projects, references, areas, daily notes
2. **By tag**: grep frontmatter `tags:` arrays
3. **By content**: grep note bodies for keywords
4. **By date range**: filter by `created:` or `updated:` fields
5. **By project**: notes in `notes/projects/{name}/` or linked via frontmatter

Use the Explore agent for broad queries that might span multiple directories. For targeted queries (specific type + tag), use Glob + Grep directly.

Collect all matching notes. Read their full content.

## Step 3: Structure the Report

Organize gathered content into a coherent document:

### Report Structure

```markdown
# {Report Title}

*Generated {today} from Brain vault*
*Query: "{original query}"*

---

## Summary
{2-3 sentence synthesis of what's in this report}

## {Section per logical group}

{Content organized by type, project, theme, or chronology — whichever fits the query best}

### {Note title}
{Relevant excerpt or full content, with wikilinks resolved to readable text}

---

## Appendix
- Source notes: {list of note paths included}
- Generated: {timestamp}
- Query: {original query}
```

### Organization strategies (pick the best fit):
- **By type** — group positions together, then questions, then decisions
- **By project** — group all notes under their project
- **By timeline** — chronological order by created date
- **By theme** — cluster by shared tags or semantic similarity

### Content rules:
- Resolve `[[wikilinks]]` to readable text (bold the title, don't show brackets)
- Strip YAML frontmatter from displayed content
- Preserve markdown formatting
- Include the note's key metadata inline (status, confidence, dates) where relevant
- Omit `ai_generated`, `ai_model`, and other system metadata

## Step 4: Render Output

### HTML format (default)

Generate a self-contained HTML file with embedded CSS. Reuse the clean-90s design system if the readable style exists (check dynamic context). If not, use a clean, professional style:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{Report Title}</title>
  <style>
    /* Professional report styling */
    :root {
      --bg: #1a1a2e;
      --surface: #16213e;
      --text: #e0e0e0;
      --accent: #7fdbca;
      --muted: #888;
      --border: #2a2a4a;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Georgia', serif;
      background: var(--bg);
      color: var(--text);
      max-width: 800px;
      margin: 0 auto;
      padding: 2rem 1.5rem;
      line-height: 1.7;
    }
    h1 { font-size: 1.8rem; margin-bottom: 0.5rem; color: var(--accent); }
    h2 { font-size: 1.3rem; margin-top: 2rem; margin-bottom: 0.75rem; color: var(--accent); border-bottom: 1px solid var(--border); padding-bottom: 0.3rem; }
    h3 { font-size: 1.1rem; margin-top: 1.5rem; margin-bottom: 0.5rem; }
    p { margin-bottom: 1rem; }
    .meta { color: var(--muted); font-size: 0.85rem; font-style: italic; margin-bottom: 2rem; }
    .summary { background: var(--surface); padding: 1.2rem; border-radius: 6px; margin-bottom: 2rem; border-left: 3px solid var(--accent); }
    .note-card { background: var(--surface); padding: 1rem 1.2rem; border-radius: 6px; margin-bottom: 1rem; }
    .note-card h3 { margin-top: 0; color: #fff; }
    .note-meta { font-size: 0.8rem; color: var(--muted); margin-bottom: 0.5rem; }
    .tag { display: inline-block; background: var(--border); padding: 0.15rem 0.5rem; border-radius: 3px; font-size: 0.75rem; margin-right: 0.3rem; }
    .appendix { margin-top: 3rem; padding-top: 1rem; border-top: 1px solid var(--border); font-size: 0.85rem; color: var(--muted); }
    strong { color: #fff; }
    a { color: var(--accent); }
    ul, ol { margin-bottom: 1rem; padding-left: 1.5rem; }
    li { margin-bottom: 0.3rem; }
    @media (max-width: 600px) {
      body { padding: 1rem; }
      h1 { font-size: 1.4rem; }
    }
  </style>
</head>
<body>
  {rendered content}
</body>
</html>
```

### Markdown format

Write clean markdown with the same structure. No HTML wrapping.

## Step 5: Write Output

- Default path: `artifacts/reports/{today}-{slug}.html` (or `.md`)
- Create `artifacts/reports/` if it doesn't exist
- Slug derived from query keywords (max 4 words, hyphenated)

## Step 6: Confirm

Report:
- Output file path
- Notes included (count + list)
- Format used
- File size
- Suggestion: "Open in browser" for HTML, or "share directly" for both formats
