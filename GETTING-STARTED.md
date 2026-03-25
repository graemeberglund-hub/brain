# Getting Started with Brain

Brain is a second-brain system powered by Claude Code. It captures what you know, tracks what you believe, and learns from how you work.

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed and authenticated
- Python 3.11+ with `uv` (for tools and Dashterm)
- A terminal (macOS Terminal, iTerm2, Warp, or VS Code terminal)

## First Run

1. Open a terminal and navigate to your Brain directory
2. Run `claude` to start a Claude Code session
3. Type `boot` — the system will detect this is a fresh vault and guide you through setup

The first-run flow will prompt you to:

1. **Onboard** — Interactive setup that learns who you are through conversation (~3 min). If you ran `/pre-seed 'Your Name' --github yourhandle` first, the system will greet you with what it already learned — making first contact feel like "this already knows me." The system will explain what makes Brain different: it tracks what you believe, tests it against what you do, and challenges it when evidence is thin.

2. **Guided tour** — A 5-minute walkthrough of what the system can do: capturing ideas, tracking positions, processing knowledge, and generating briefings.

3. **Domain seed** — Pre-load context for your primary domain. Examples: "gun shop SEO", "family office investing", "documentary investigation", "AI consulting".

### Optional: Pre-seed before onboarding

For the best first-run experience, have someone run `/pre-seed 'Your Name' --github yourhandle --website yoursite.com` before you start. This researches your public profile so `/onboard` can greet you by name with context about your work. Pre-seeding is silent — it doesn't ask you anything.

## Quick Start (skip the tour)

If you prefer to dive in, just start talking:

- **Capture a thought**: "I think we should try DuckDB for this"
- **Save a reference**: "save this: https://example.com/article"
- **Log a decision**: "decided to use postgres instead of sqlite"
- **Track a position**: "thesis: HMMs can detect regime changes"
- **Ask a question**: "can we automate the weekly report?"

The system routes your intent to the right skill automatically.

## Daily Workflow

A typical day with Brain:

1. `boot` — See your current state, inbox depth, top recommendations
2. Work normally — capture ideas, make decisions, reference links as they come up
3. `sync` — Pull in git commits from registered repos (auto-summarized)
4. `briefing` — Get a narrative daily briefing about your vault state
5. `handoff` — End the session (records decisions, flags open questions)

For a comprehensive daily pass: `daily-cycle` runs sync + debrief + digest + crystallize in one session.

## Registering Repos

Brain can track work across multiple repositories. To register a repo:

1. Copy `repos/_example.yml` to `repos/{repo-name}.yml`
2. Fill in the path, description, and key directories
3. Run `/sync` to start tracking commits

## Key Concepts

- **Notes** live in `notes/` organized by type (positions, questions, decisions, references, etc.)
- **Knowledge graph** lives in `knowledge/` — the system builds and maintains it automatically
- **Skills** are in `.claude/skills/` — they're the system's capabilities (119 skills across 9 families)
- **Dashterm** is the browser UI at `studio/dashterm/` — run it with `uv run --with aiohttp --with claude-agent-sdk python studio/dashterm/server.py`

## Getting Help

- Type `find skills` to discover what the system can do
- Type `health check` for a vault health scan
- Type `tour` for a guided walkthrough at any time
- Read `CLAUDE.md` for the full agent router and note schemas
