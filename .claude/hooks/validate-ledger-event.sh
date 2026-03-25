#!/bin/bash
# PreToolUse hook: validate events before writing to epistemic-ledger.jsonl
# Only fires on Write/Edit to knowledge/epistemic-ledger.jsonl
# Exit 2 = block the write; exit 0 = allow

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate Write and Edit tools
case "$TOOL_NAME" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

# Only validate writes to the epistemic ledger
case "$FILE_PATH" in
  *knowledge/epistemic-ledger.jsonl) ;;
  *) exit 0 ;;
esac

CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [ -z "$CONTENT" ]; then
  exit 0
fi

ALLOWED_VERBS="SUPPORTS|CONTRADICTS|CHALLENGES|EXTENDS|REFINES|CONVERGES|DECAYS|SUPERSEDES|WITHDRAWS|ADVANCES|COMPLICATES|SPAWNS|RESOLVES|ALIGNS_WITH_ACTION|MISALIGNED_WITH_ACTION|UNTESTED_IN_ACTION|PREDICTION_PASSED|PREDICTION_FAILED|STAGE_PROMOTED"

ERRORS=""

# Validate each JSON line
while IFS= read -r line; do
  # Skip empty lines
  [ -z "$line" ] && continue

  # Must be valid JSON
  if ! echo "$line" | jq . >/dev/null 2>&1; then
    ERRORS="${ERRORS}Invalid JSON: ${line:0:80}...\n"
    continue
  fi

  # Required fields
  for FIELD in timestamp verb source target target_type reasoning confidence inference_mode; do
    VAL=$(echo "$line" | jq -r ".${FIELD} // empty")
    if [ -z "$VAL" ]; then
      ERRORS="${ERRORS}Missing required field '${FIELD}'\n"
    fi
  done

  # Validate ISO 8601 timestamp format (YYYY-MM-DDTHH:MM:SSZ or with offset)
  TS=$(echo "$line" | jq -r '.timestamp // empty')
  if [ -n "$TS" ]; then
    if ! echo "$TS" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$'; then
      ERRORS="${ERRORS}Invalid timestamp format '${TS}' — must be ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)\n"
    fi
  fi

  # Verb must be in allowed set
  VERB=$(echo "$line" | jq -r '.verb // empty')
  if ! echo "$VERB" | grep -qE "^(${ALLOWED_VERBS})$"; then
    ERRORS="${ERRORS}Invalid verb '${VERB}'\n"
  fi

  # Source file must exist
  SOURCE=$(echo "$line" | jq -r '.source // empty')
  if [ -n "$SOURCE" ] && [ ! -f "$SOURCE" ]; then
    ERRORS="${ERRORS}Source file does not exist: ${SOURCE}\n"
  fi

  # Target file must exist
  TARGET=$(echo "$line" | jq -r '.target // empty')
  if [ -n "$TARGET" ] && [ ! -f "$TARGET" ]; then
    ERRORS="${ERRORS}Target file does not exist: ${TARGET}\n"
  fi

  # Check for duplicates in last 7 days
  if [ -f "knowledge/epistemic-ledger.jsonl" ] && [ -s "knowledge/epistemic-ledger.jsonl" ]; then
    CUTOFF=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d 2>/dev/null)
    if [ -n "$CUTOFF" ] && [ -n "$SOURCE" ] && [ -n "$TARGET" ] && [ -n "$VERB" ]; then
      DUPE=$(grep "\"source\":\"${SOURCE}\"" knowledge/epistemic-ledger.jsonl 2>/dev/null | \
             grep "\"target\":\"${TARGET}\"" | \
             grep "\"verb\":\"${VERB}\"" | \
             jq -r ".timestamp // empty" 2>/dev/null | \
             while read ts; do
               ts_date="${ts:0:10}"
               if [[ "$ts_date" > "$CUTOFF" ]] || [[ "$ts_date" == "$CUTOFF" ]]; then
                 echo "DUPE"
                 break
               fi
             done)
      if [ "$DUPE" = "DUPE" ]; then
        ERRORS="${ERRORS}Duplicate event: ${VERB} from ${SOURCE} to ${TARGET} already exists in last 7 days\n"
      fi
    fi
  fi

done <<< "$CONTENT"

if [ -n "$ERRORS" ]; then
  echo -e "BLOCKED: Ledger validation failed:\n${ERRORS}" >&2
  exit 2
fi

exit 0
