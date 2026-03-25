# Brain Vault — Command Cheatsheet

## Session lifecycle

| Command | When |
|---------|------|
| `/boot` | Session start — reads briefing, session index, shows what changed |
| `/handoff` | Session end — records decisions, flags open threads, emits events |

## Daily capture (as things happen)

| Command | When |
|---------|------|
| `/capture` | Thought, idea, observation |
| `/position` | Belief or thesis to track |
| `/question` | Open question to investigate |
| `/decision` | Choice or trade-off made |
| `/reference` | URL, article, paper, tool |
| `/preference` | Design taste decision (surface, color, typography, etc.) |

## Ingest (content comes in)

| Command | When |
|---------|------|
| `/ingest youtube <url>` | YouTube video |
| `/ingest llm <path>` | GPT/Claude conversation export |
| `/transcribe` | Audio conversation |
| `/youtube <url>` | Shortcut for youtube ingest |

## Metabolism pipeline (automated)

The metabolism daemon (Layer 1) runs every 90 min via launchd — zero tokens. It senses vault state and decides what needs processing. Layer 2 dispatches phases through dashterm as fresh Claude instances.

**Phases (in order):**

| Tier | Phase | What it does |
|------|-------|-------------|
| 0 — Intake | `sync` | Git commits → daily note + knowledge graph |
| | `debrief` | Process insights, agent patterns from commits |
| | `triage` | Route inbox notes to proper locations |
| | `session-extract` | Extract decisions from past Claude sessions |
| Bridge | `retrieval` | Index candidate pairs for epistemic processing |
| 1 — Epistemic | `digest` | Tribunal: prosecution/defense/judge on new intake |
| | `challenge` | Stress-test a stale position |
| | `gap-fill` | Generate questions for belief-heavy domains |
| 2 — Generative | `drift` | Detect unnamed themes and blind spots |
| | `consolidate` | Promote cross-domain patterns |
| 3 — Synthesis | `surface` | Compose outputs for next session |
| | `briefing` | Generate The Mirror (editorial HTML) |
| | `crystallize` | Refresh living memory files |

**Manual triggers:**

```bash
# Daemon
python3 tools/metabolism_daemon.py --status    # see what it senses
python3 tools/metabolism_daemon.py --dry-run   # sense without writing
python3 tools/metabolism_daemon.py --force     # full run, writes state

# Pipeline (requires dashterm running)
cd .claude/workstreams/metabolism
./runner.sh --force     # run all phases
./runner.sh --resume    # resume from last crash

# Start dashterm
uv run --with aiohttp --with claude-agent-sdk --with pyyaml python studio/dashterm/server.py
```

**Monitor:** `http://localhost:3334/monitor` — live pipeline schematic with phase status, activity feed, and process visualization.

## Skills (run individually)

| Command | What it does |
|---------|-------------|
| `/sync` | Git commits → daily note (idempotent) |
| `/debrief` | Deep process analysis per repo |
| `/triage` | Route inbox notes |
| `/digest` | Epistemic tribunal on intake |
| `/challenge` | Stress-test a position |
| `/drift` | Find gaps, emerging themes |
| `/briefing` | Generate The Mirror editorial |

## Analysis (on-demand)

| Command | When |
|---------|------|
| `/trace <topic>` | History/evolution of a topic |
| `/connect <X> <Y>` | How two topics relate |
| `/bridge` | Check belief-action alignment |
| `/audit` | Comprehensive vault health check |
| `/scout <repo>` | Analyze an external repo |

## Periodic maintenance

| Command | Cadence |
|---------|---------|
| `/weekly-review` | Weekly — generate activity YAML |
| `/consolidate` | Weekly — promote cross-domain patterns |
| `/memory-refresh` | As needed — regenerate living memory files |
| `/resolve-feedback` | When predictions resolve in PH |

## Typical flow

```
Boot session:     /boot
Capture:          /capture, /position, /reference, /decision
Ingest:           /youtube, /transcribe, /ingest llm
End session:      /handoff

Automated:        Daemon senses → Pipeline runs → Briefing generated
                  (every 90 min, zero intervention)
```

## Key files

| File | What |
|------|------|
| `knowledge/metabolism-state.json` | Daemon's sensing output + processing plan |
| `knowledge/metabolism-live.json` | Live pipeline status (for monitor) |
| `knowledge/metabolism-events.jsonl` | Live agent/tool events (for monitor) |
| `knowledge/metabolism-last-run.json` | Last completed run timestamps |
| `knowledge/session-index.jsonl` | Cross-repo session metadata |
| `knowledge/epistemic-ledger.jsonl` | Validated epistemic events |
| `knowledge/absorption-log.jsonl` | Content consumption pipeline |
| `studio/briefing/latest.html` | Most recent daily briefing |
