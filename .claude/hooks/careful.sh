#!/bin/bash
# PreToolUse hook: intercept destructive Bash commands
# Exit 0 = allow, Exit 2 = block
# Phase b1 of system-upgrade workstream

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only validate Bash tool
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Safe commands — these can contain destructive keywords in arguments (e.g., commit messages)
# without being destructive themselves
if echo "$COMMAND" | grep -qE '^git\s+commit\b|^git\s+log\b|^echo\b|^cat\b|^grep\b|^printf\b'; then
  exit 0
fi

# Whitelist paths — if ALL targets are in these dirs, allow even if pattern matches
WHITELIST="node_modules/|dist/|build/|__pycache__/|\.cache/|/tmp/|\.next/|\.turbo/"

# Destructive patterns (checked case-insensitive)
LOWER_CMD=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

check_destructive() {
  local cmd="$1"

  # rm -rf / rm -fr (not targeting whitelisted paths)
  if echo "$cmd" | grep -qE 'rm\s+-(rf|fr)\s'; then
    return 0
  fi

  # SQL destructive
  if echo "$cmd" | grep -qiE 'drop\s+table'; then
    return 0
  fi

  # Git destructive
  if echo "$cmd" | grep -qE 'git\s+push\s+--force|git\s+push\s+-f\b'; then
    return 0
  fi
  if echo "$cmd" | grep -qE 'git\s+reset\s+--hard'; then
    return 0
  fi
  if echo "$cmd" | grep -qE 'git\s+clean\s+-f'; then
    return 0
  fi

  # Infrastructure destructive
  if echo "$cmd" | grep -qE 'kubectl\s+delete'; then
    return 0
  fi
  if echo "$cmd" | grep -qE 'docker\s+system\s+prune'; then
    return 0
  fi

  # Filesystem destructive
  if echo "$cmd" | grep -qE 'chmod\s+777'; then
    return 0
  fi
  if echo "$cmd" | grep -qE '\bmkfs\b'; then
    return 0
  fi
  if echo "$cmd" | grep -qE '\bdd\s+if='; then
    return 0
  fi
  if echo "$cmd" | grep -qE 'truncate\s'; then
    return 0
  fi
  if echo "$cmd" | grep -qE 'shred\s'; then
    return 0
  fi

  return 1
}

# Fast path: no destructive pattern → allow immediately
if ! check_destructive "$LOWER_CMD"; then
  exit 0
fi

# Destructive pattern matched — check if targets are all whitelisted
# Extract file/path arguments after the destructive command
ARGS=$(echo "$COMMAND" | grep -oE '[^ ]+' | tail -n +3)

ALL_WHITELISTED=true
HAS_ARGS=false
while IFS= read -r arg; do
  [ -z "$arg" ] && continue
  # Skip flags
  [[ "$arg" == -* ]] && continue
  HAS_ARGS=true
  if ! echo "$arg" | grep -qE "$WHITELIST"; then
    ALL_WHITELISTED=false
    break
  fi
done <<< "$ARGS"

if [ "$HAS_ARGS" = true ] && [ "$ALL_WHITELISTED" = true ]; then
  exit 0
fi

# Blocked — print warning
echo "BLOCKED by /careful: Destructive command detected" >&2
echo "Command: $COMMAND" >&2
echo "Add to whitelist or confirm manually to proceed." >&2
exit 2
