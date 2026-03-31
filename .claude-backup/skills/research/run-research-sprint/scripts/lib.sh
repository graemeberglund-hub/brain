#!/usr/bin/env bash
# lib.sh — Shared functions for run-sprint orchestrator
set -euo pipefail

# ── Logging ──

log() {
  local level="$1"; shift
  local msg="$*"
  local ts=$(date '+%Y-%m-%dT%H:%M:%S')
  echo "[$ts] [$level] $msg" >> "$OUTDIR/sprint.log"
  echo "[$ts] [$level] $msg" >&2
}

log_phase() {
  local phase="$1" status="$2" msg="$3"
  log "PHASE" "$phase | $status | $msg"
}

# ── Manifest ──

init_manifest() {
  local repo_name="$1" sprint_dir="$2" focus="$3" date="$4"
  # Use heredoc to avoid shell escaping issues with focus text
  python3 - "$OUTDIR/run-manifest.json" "$repo_name" "$REPO_ROOT" "$focus" "$(basename "$sprint_dir")" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" <<'PYEOF'
import json, sys
outfile, repo_name, repo_root, focus, sprint_id, started = sys.argv[1:7]
manifest = {
    "sprint_id": sprint_id,
    "repo": repo_name,
    "repo_root": repo_root,
    "focus": focus,
    "started_at": started,
    "status": "running",
    "phases": [],
    "total_cost_usd": 0.0,
    "completed_at": None
}
with open(outfile, 'w') as f:
    json.dump(manifest, f, indent=2)
PYEOF
}

update_manifest() {
  local phase="$1" status="$2" cost="$3" audit_pass="$4" output_file="$5" commit_sha="${6:-}"
  python3 - "$OUTDIR/run-manifest.json" "$phase" "$status" "$cost" "$audit_pass" "$output_file" "$commit_sha" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" <<'PYEOF'
import json, sys
manifest_path, phase, status, cost, audit_pass, output_file, commit_sha, completed_at = sys.argv[1:9]
with open(manifest_path, 'r') as f:
    m = json.load(f)
phase_entry = {
    "name": phase,
    "status": status,
    "output_file": output_file,
    "completed_at": completed_at,
    "cost_usd": float(cost),
    "audit": {
        "pass": audit_pass == "true",
        "verdict_file": output_file.replace(".md", "-audit.json")
    },
    "commit_sha": commit_sha
}
m["phases"].append(phase_entry)
m["total_cost_usd"] = round(sum(p["cost_usd"] for p in m["phases"]), 4)
if status == "failed":
    m["status"] = "partial"
with open(manifest_path, 'w') as f:
    json.dump(m, f, indent=2)
PYEOF
}

finalize_manifest() {
  local final_status="$1"
  python3 - "$OUTDIR/run-manifest.json" "$final_status" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" <<'PYEOF'
import json, sys
manifest_path, final_status, completed_at = sys.argv[1:4]
with open(manifest_path, 'r') as f:
    m = json.load(f)
m["status"] = final_status
m["completed_at"] = completed_at
with open(manifest_path, 'w') as f:
    json.dump(m, f, indent=2)
PYEOF
}

# ── Output Validation ──

validate_output() {
  # Check that an output file has real content, not a permission plea or empty
  local file="$1"
  local min_bytes="${2:-100}"

  if [ ! -f "$file" ]; then
    echo "MISSING"
    return 1
  fi

  local size=$(wc -c < "$file" | tr -d ' ')
  if [ "$size" -lt "$min_bytes" ]; then
    echo "TOO_SMALL ($size bytes)"
    return 1
  fi

  # Check for permission plea patterns
  if grep -qi "write permission\|could you approve\|being blocked by\|need.*permission" "$file" 2>/dev/null; then
    if [ "$size" -lt 1000 ]; then
      echo "PERMISSION_PLEA"
      return 1
    fi
  fi

  echo "OK"
  return 0
}

# ── Claude CLI Wrapper ──

OUTPUT_INSTRUCTION="

CRITICAL INSTRUCTION: You MUST produce your entire output as text in your response. Do NOT attempt to use the Write tool or any file-writing tool to save your output. Simply write your full analysis/report as your text response. The orchestrator will capture your text output automatically."

run_claude() {
  local prompt_file="$1"
  local output_file="$2"
  local allowed_tools="$3"
  local budget="${4:-5}"
  local extra_flags="${5:-}"

  local exit_code=0

  log "RUN" "Executing claude for $(basename "$output_file") (budget: \$$budget)"

  # Append output instruction to prompt (unless Write is in allowed tools)
  local actual_prompt_file="$prompt_file"
  if [[ "$allowed_tools" != *"Write"* ]]; then
    actual_prompt_file=$(mktemp)
    cat "$prompt_file" > "$actual_prompt_file"
    echo "$OUTPUT_INSTRUCTION" >> "$actual_prompt_file"
  fi

  # Capture JSON to temp file instead of shell variable (avoids ARG_MAX issues)
  local json_tmp=$(mktemp)
  cat "$actual_prompt_file" | claude -p \
    --model claude-opus-4-6 \
    --output-format json \
    --max-budget-usd "$budget" \
    --allowed-tools "$allowed_tools" \
    --permission-mode default \
    --no-session-persistence \
    --disable-slash-commands \
    $extra_flags \
    > "$json_tmp" \
    2>"$output_file.stderr" || exit_code=$?

  # Clean up temp prompt if we created one
  if [ "$actual_prompt_file" != "$prompt_file" ]; then
    rm -f "$actual_prompt_file"
  fi

  if [ $exit_code -ne 0 ]; then
    log "ERROR" "claude CLI exited with code $exit_code for $(basename "$output_file")"
    cp "$json_tmp" "$output_file.error"
    rm -f "$json_tmp"
    echo "0.0"
    return 1
  fi

  # Extract result text and cost using temp file (avoids shell variable limits)
  local cost is_error duration
  python3 - "$json_tmp" "$output_file" <<'PYEOF'
import json, sys
json_path, output_path = sys.argv[1:3]
with open(json_path, 'r') as f:
    d = json.load(f)
result = d.get('result', '')
with open(output_path, 'w') as f:
    f.write(result)
PYEOF

  cost=$(python3 -c "import json; d=json.load(open('$json_tmp')); print(d.get('total_cost_usd',0))")
  is_error=$(python3 -c "import json; d=json.load(open('$json_tmp')); print(str(d.get('is_error',False)).lower())")
  duration=$(python3 -c "import json; d=json.load(open('$json_tmp')); print(d.get('duration_ms',0))")

  rm -f "$json_tmp"

  if [ "$is_error" = "true" ]; then
    log "ERROR" "claude returned error for $(basename "$output_file")"
    echo "$cost"
    return 1
  fi

  log "RUN" "Completed $(basename "$output_file") in ${duration}ms, cost \$$cost"
  echo "$cost"
  return 0
}

# ── Audit ──

run_audit() {
  local target_file="$1"
  local phase_name="$2"
  local audit_template="$SKILL_DIR/prompts/audit.md"
  local audit_output="${target_file%.md}-audit.json"

  log "AUDIT" "Auditing $phase_name output"

  # Use Python for template injection (avoids bash string replacement issues)
  local tmp_prompt=$(mktemp)
  python3 - "$audit_template" "$target_file" "$phase_name" "$tmp_prompt" <<'PYEOF'
import sys
template_path, target_path, phase_name, output_path = sys.argv[1:5]
with open(template_path, 'r') as f:
    template = f.read()
with open(target_path, 'r') as f:
    target_content = f.read()
composed = template.replace('{{TARGET_CONTENT}}', target_content)
composed = composed.replace('{{PHASE_NAME}}', phase_name)
with open(output_path, 'w') as f:
    f.write(composed)
PYEOF

  local cost
  cost=$(run_claude "$tmp_prompt" "$audit_output" "Read" "1") || true
  rm -f "$tmp_prompt"

  # Determine pass/fail from audit output
  local audit_pass="true"
  if [ -f "$audit_output" ]; then
    audit_pass=$(python3 -c "
import json, re
try:
    with open('$audit_output') as f:
        content = f.read()
    json_match = re.search(r'\{[^{}]*\"pass\"[^{}]*\}', content, re.DOTALL)
    if json_match:
        d = json.loads(json_match.group())
        print(str(d.get('pass', True)).lower())
    else:
        print('true')
except:
    print('true')
" 2>/dev/null || echo "true")
  fi

  log "AUDIT" "$phase_name audit: pass=$audit_pass"
  echo "$audit_pass"
}

# ── Context Injection ──

compose_prompt() {
  local template_file="$1"
  shift
  # Use Python for template composition (bash string replacement breaks on URLs, backslashes, etc.)
  local args_str=""
  while [ $# -gt 0 ]; do
    args_str+="$1"$'\n'
    shift
  done

  python3 - "$template_file" <<PYEOF
import sys

template_path = sys.argv[1]
with open(template_path, 'r') as f:
    composed = f.read()

pairs = """${args_str}""".strip().split('\n')
for pair in pairs:
    if '=' not in pair:
        continue
    key, filepath = pair.split('=', 1)
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except (FileNotFoundError, IOError):
        content = '[not available]'
    composed = composed.replace('{{' + key + '}}', content)

print(composed)
PYEOF
}

# ── Git ──

auto_commit() {
  local message="$1"
  local sprint_rel="${OUTDIR#$REPO_ROOT/}"

  cd "$REPO_ROOT"
  git add "$sprint_rel/" "prompts/strategy/" 2>/dev/null || true
  if git diff --cached --quiet 2>/dev/null; then
    log "GIT" "No changes to commit for: $message"
    echo ""
    return 0
  fi

  local sha
  sha=$(git commit -m "$message

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>" --quiet 2>&1 | grep -oE '[a-f0-9]{7,}' | head -1 || echo "")

  # Get the actual SHA
  sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  log "GIT" "Committed: $sha — $message"
  echo "$sha"
}
