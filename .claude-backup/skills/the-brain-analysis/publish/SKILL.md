---
name: publish
description: "Push a report, readable, or briefing artifact to a shareable location — Google Drive, local server, or clipboard. Use when sharing vault output externally."
allowed-tools: Read, Write, Glob, Bash(date *), Bash(ls *), Bash(cp *), Bash(pbcopy), Bash(open *), Skill
argument-hint: "'artifact-path' --to drive|clipboard|local [--open]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob to check: report count from artifacts/reports/*, briefing count from studio/briefing/*.html, and readable count from studio/readable/*.html.)

# /publish — Share Vault Artifacts

You are pushing vault-generated artifacts (reports, briefings, readables) to shareable locations. This bridges the gap between on-disk artifacts and external visibility.

## Step 1: Parse Arguments

- **artifact-path** — path to the file to publish. Can be:
  - Explicit: `artifacts/reports/2026-03-16-crypto-positions.html`
  - By type: `latest-report`, `latest-briefing`, `latest-readable`
  - By query: `"the crypto report"` → search artifacts/

- **--to** — destination:
  - `drive` — upload to Google Drive via `/gws-drive-upload`
  - `clipboard` — copy file content to clipboard
  - `local` — copy to a local web-accessible directory (default: `~/Sites/brain/`)
  - If not specified, ask the user

- **--open** — open in browser after publishing (for local and drive)

## Step 2: Resolve Artifact

If the path is a shorthand:
- `latest-report` → most recently modified file in `artifacts/reports/`
- `latest-briefing` → most recently modified file in `studio/briefing/`
- `latest-readable` → most recently modified file in `studio/readable/`

If the path is a query, search all artifact directories for a match.

Read the file to verify it exists and is an HTML or markdown file.

## Step 3: Publish

### Google Drive (`--to drive`):
Invoke `/gws-drive-upload` with the artifact file. Report the share link.

### Clipboard (`--to clipboard`):
```bash
cat '{artifact-path}' | pbcopy
```
Report: "Copied to clipboard — paste into email, message, or document."

### Local web server (`--to local`):
```bash
mkdir -p ~/Sites/brain/
cp '{artifact-path}' ~/Sites/brain/{filename}
```
Report the local URL: `http://localhost/brain/{filename}` (assumes macOS Apache/nginx).

If `--open`: `open http://localhost/brain/{filename}` or `open '{artifact-path}'`

## Step 4: Confirm

```
=== Published ===

Artifact: {filename}
Source: {full path}
Destination: {drive URL | clipboard | local path}
Size: {file size}
{Share link if drive}
{If --open: "Opened in browser"}
```
