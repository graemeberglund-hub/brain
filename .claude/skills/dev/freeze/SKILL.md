# /freeze — Edit Scope Lock

Restricts all file edits (Edit and Write tools) to a single directory. Prevents accidental changes outside your focus area during debugging or concentrated work.

## Trigger

User says: "freeze", "freeze to {path}", "lock edits to {path}", "scope lock"

## Usage

### `/freeze {path}`
Lock all edits to the specified directory:

1. Resolve `{path}` to an absolute path
2. Verify the directory exists
3. Write the path to `~/.claude/freeze-scope`
4. Confirm: "Edit scope locked to: {path}. Only files under this directory can be modified. Run /unfreeze to remove."

### `/freeze` (no path)
Lock edits to the current working directory.

### `/unfreeze`
Remove the scope lock:

1. Delete `~/.claude/freeze-scope`
2. Confirm: "Edit scope unlocked. All directories are writable."

## How It Works

The `freeze.sh` hook runs as a PreToolUse hook on Edit and Write tool calls. It:
- Reads the frozen path from `~/.claude/freeze-scope`
- Checks if the file being edited is under the frozen directory
- Blocks the edit with an error message if it's outside scope
- Does nothing if no freeze file exists (all edits allowed)

## Hook Registration

The hook must be registered in settings.json:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "cat /dev/stdin | bash .claude/hooks/freeze.sh"
          }
        ]
      }
    ]
  }
}
```

## When to Use

- **Debugging**: Lock to the buggy module so you don't accidentally edit unrelated files
- **Focused work**: Lock to a single feature directory during implementation
- **Safety**: Prevent changes to production config while working on dev config
- **Code review fixes**: Lock to the files under review

## Complements `/careful`

`/careful` guards against destructive bash commands. `/freeze` guards against edits to the wrong files. Together they form a safety net:
- `/careful` — "don't accidentally delete things"
- `/freeze` — "don't accidentally edit things outside your scope"
