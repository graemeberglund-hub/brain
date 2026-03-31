# Template: .claude/settings.json

Baseline settings with standard permissions, full hook lifecycle, and statusline. Add domain-specific Bash permissions if obvious (e.g., `python3 *` for data projects, `node *` for JS projects).

Stop hooks use absolute paths to brain-centralized scripts for session indexing, backup, STATUS.md auto-update, and activity logging.

---

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(mv *)",
      "Bash(mkdir *)",
      "Bash(date *)",
      "Bash(wc *)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start-context.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$BRAIN_VAULT_PATH/.claude/hooks/session-end-cleanup.sh"
          },
          {
            "type": "command",
            "command": "$BRAIN_VAULT_PATH/.claude/hooks/session-end-index.sh"
          },
          {
            "type": "command",
            "command": "$BRAIN_VAULT_PATH/.claude/hooks/status-update.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$BRAIN_VAULT_PATH/.claude/hooks/post-tool-activity-log.sh"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash .claude/statusline.sh"
  }
}
```
