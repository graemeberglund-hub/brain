#!/bin/bash
# PostToolUse hook: append tool call metadata to session activity log
# Zero tokens — pure shell. Provides mechanical full-coverage layer for session capture.
# Format: {timestamp} | {tool} | {file_path} | {summary}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Skip if no tool name
if [ -z "$TOOL_NAME" ]; then
  exit 0
fi

# Only log substantive tools (skip meta/navigation)
case "$TOOL_NAME" in
  Read|Edit|Write|Bash|Grep|Glob|Agent|Skill|NotebookEdit) ;;
  *) exit 0 ;;
esac

BRAIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ACTIVITY_DIR="$BRAIN_DIR/knowledge/session-activity"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)

# Get session ID from input if available
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -z "$SESSION_ID" ]; then
  SESSION_ID="unknown"
fi

LOG_FILE="$ACTIVITY_DIR/$TODAY-$SESSION_ID.log"
mkdir -p "$ACTIVITY_DIR"

# Extract file path (varies by tool)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Extract a brief summary based on tool type
SUMMARY=""
case "$TOOL_NAME" in
  Read)
    SUMMARY="read"
    ;;
  Edit)
    SUMMARY="edit"
    ;;
  Write)
    SUMMARY="write"
    ;;
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null | head -c 100)
    SUMMARY="$CMD"
    FILE_PATH=""
    ;;
  Grep)
    PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty' 2>/dev/null | head -c 60)
    SUMMARY="grep: $PATTERN"
    ;;
  Glob)
    PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty' 2>/dev/null | head -c 60)
    SUMMARY="glob: $PATTERN"
    FILE_PATH=""
    ;;
  Agent)
    DESC=$(echo "$INPUT" | jq -r '.tool_input.description // empty' 2>/dev/null | head -c 80)
    SUMMARY="agent: $DESC"
    FILE_PATH=""
    ;;
  Skill)
    SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null)
    SUMMARY="skill: $SKILL"
    FILE_PATH=""
    ;;
esac

# Write log line
echo "$TIMESTAMP | $TOOL_NAME | ${FILE_PATH:--} | $SUMMARY" >> "$LOG_FILE" 2>/dev/null

exit 0
