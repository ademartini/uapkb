#!/usr/bin/env bash
# stop hook — end-of-turn quality gate (mirrors CI fast path: format, lint, typecheck, test).
# hooks.json must set timeout ≥ ~5s (check.sh runtime in hook env); default ~4s kills mid-run.
#
# Cursor protocol:
#   stdin  -> JSON with status, loop_count, etc.
#   stdout -> JSON only: {} on success, or {"followup_message":"..."} on check failure
#   stderr -> check output only on failure (the Settings UI treats stderr as error output)
#   exit   -> always 0 after printing stdout JSON (non-zero marks the hook failed in UI)
set -euo pipefail

hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hook-io.sh
source "$hook_dir/hook-io.sh"
# shellcheck source=env.sh
source "$hook_dir/env.sh"

hook_read_stdin
loop_count="$(hook_json_int loop_count 0)"
max_loops=5

check_log="$(mktemp)"
trap 'rm -f "$check_log"' EXIT

if ./scripts/check.sh >"$check_log" 2>&1; then
  hook_emit_done
  exit 0
fi

cat "$check_log" >&2

if [ "$loop_count" -ge "$max_loops" ]; then
  echo "stop hook: check failed; loop_count=$loop_count (max $max_loops) - not requesting follow-up" >&2
  hook_emit_done
  exit 0
fi

hook_emit_followup "$check_log"
exit 0
