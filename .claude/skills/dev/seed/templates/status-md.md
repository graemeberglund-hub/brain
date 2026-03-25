# Template: STATUS.md

Auto-updated repo status file. The `## State` and `## Session` sections are maintained by the `status-update.sh` hook at session end (zero tokens for mechanical layer, ~500 tokens for intent layer). The `## Log` section is manual — never auto-modified.

---

```markdown
# Status: {Repo Name}

{One-line description}

## State
<!-- AUTO-UPDATED by status-update.sh — do not edit -->
_No data yet — will populate after first session._

## Session
<!-- AUTO-UPDATED by status-update.sh intent layer or /handoff -->
_No session data yet._

## Log
<!-- MANUAL — never auto-modified. Newest first. -->
### {TODAY} — Initial scaffold
**Completed**: Repo scaffolded with `/seed`
```
