---
name: readable
description: Convert markdown files to styled, mobile-friendly HTML for reading on any device. Use when user says "make readable", "create HTML", "readable version", or wants phone-friendly documents.
allowed-tools: Read, Write, Glob, Bash(date *), Bash(ls *), Bash(mkdir *)
argument-hint: "[file or directory path, optional: output dir]"
---

input = $ARGUMENTS

(At start of execution, use Read to check: whether ~/.claude/styles/clean-90s.md exists for styling.)

# /readable — Markdown to Styled HTML

Convert markdown files into self-contained, mobile-friendly HTML documents using the clean-90s design system.

## 1. Resolve inputs

Parse $ARGUMENTS to determine:
- **Source**: a file path, glob pattern, or directory. If directory, find all `*.md` files in it.
- **Output dir**: if specified after a `->` or `to` keyword, use that. Otherwise default to `studio/readable/` relative to the project root.

Create the output directory if it doesn't exist.

## 2. Read the style

Read `~/.claude/styles/clean-90s.md` for the design tokens. If missing, use these fallback values:

```
bg: #f5f0e8, bg-panel: #faf7f2, text: #1a1a18
muted: rgba(26,26,24,.65), faint: rgba(26,26,24,.40)
ink-blue: #4a6fa5, ink-amber: #9e7c3a, ink-red: #a85656, ink-green: #4d8a74
border: rgba(26,26,24,.10), bg-2: #ede8df
serif: 'Instrument Serif', Georgia, serif
sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif
```

## 3. Convert each file

For each markdown file, create a self-contained HTML document:

### HTML structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{document title}</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Instrument+Serif&family=Inter:wght@300;400;500;600&display=swap');
  {inline CSS using clean-90s tokens}
</style>
</head>
<body>
  {converted content}
  {navigation bar if batch}
</body>
</html>
```

### Conversion rules

- **Title**: Extract from first `# heading` or YAML `title:` field. Render with `Instrument Serif`, 28px.
- **Date**: Extract from YAML `created:` or `Date:` line. Render as uppercase label (11px, faint, letter-spaced).
- **H2**: `Instrument Serif`, 20px, bottom border hairline.
- **H3**: `Inter` 14px semibold, `ink-blue` color.
- **Body text**: `Inter` 15px, `muted` color, line-height 1.65.
- **Lists**: 20px left padding, 6px spacing between items.
- **Bold text**: `text` color (darker than body).
- **Code/inline code**: `bg-2` background, 3px radius, 13px.
- **Callout blocks**: Any blockquote or section that feels like a key takeaway → `bg-panel` fill, `ink-amber` left border (3px), padded.
- **Warning blocks**: Any content about risks, cautions, or "do not" → `bg-panel` fill, `ink-red` left border.
- **Tables**: Full width, collapsed borders, uppercase 11px headers, hairline row separators.
- **Links**: `ink-blue` color, subtle underline (25% opacity border-bottom).
- **Max width**: 640px, centered, 24px horizontal padding, 64px bottom padding (room for nav).

### Mobile optimization

- All sizing in px or rem, no fixed layouts
- Touch-friendly spacing (minimum 6px between list items)
- No horizontal scroll — tables use `font-size: 13px` and `word-break: break-word` if needed

## 4. Add batch navigation

If converting multiple files, add a fixed bottom nav bar to each HTML file linking to the others:

```html
<div class="nav">
  <a href="other-file.html">Short Label</a>
  ...
</div>
```

Style: fixed bottom, frosted glass (`rgba(245,240,232,.92)` background, `backdrop-filter: blur(8px)`), hairline top border, 12px links.

Generate short labels from filenames (drop date prefixes, abbreviate intelligently).

## 5. Report

Output:
- Number of files converted
- Output directory path
- List of generated HTML files
- Remind user they can open these directly in a mobile browser, AirDrop them, or serve locally with `python3 -m http.server`
