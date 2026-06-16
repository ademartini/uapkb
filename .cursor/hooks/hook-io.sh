# Cursor command-hook helpers.
#
# Protocol: hooks receive JSON on stdin and MUST print JSON on stdout.
# Human-readable logs go to stderr only. Exit 0 after emitting stdout JSON.

hook_read_stdin() {
  HOOK_INPUT="$(cat)"
}

hook_json_field() {
  local field=$1
  printf '%s' "$HOOK_INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get(sys.argv[1], '') or '')" "$field"
}

hook_json_int() {
  local field=$1
  local default=${2:-0}
  printf '%s' "$HOOK_INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); v=d.get(sys.argv[1]); print(int(v if v is not None else sys.argv[2]))" "$field" "$default"
}

# Success: no follow-up turn.
hook_emit_done() {
  printf '%s\n' '{}'
}

# Failure: ask Cursor to submit this as the next user message.
hook_emit_followup() {
  local body_file=$1
  python3 - "$body_file" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    body = f.read().strip()

prefix = (
    "End-of-turn gate failed (`scripts/check.sh`). "
    "Fix the issues below, then continue.\n\n"
)
print(json.dumps({"followup_message": prefix + body}))
PY
}
