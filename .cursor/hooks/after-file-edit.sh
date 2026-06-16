#!/usr/bin/env bash
# afterFileEdit hook — format + eslint --fix on agent-edited files.
#
# Cursor protocol:
#   stdin  -> JSON with file_path (absolute path)
#   stdout -> {} (no response fields required for this event)
#   stderr -> tool output only on failure
set -euo pipefail

hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hook-io.sh
source "$hook_dir/hook-io.sh"
# shellcheck source=env.sh
source "$hook_dir/env.sh"

hook_read_stdin

file="$(hook_json_field file_path)"
if [ -z "$file" ]; then
  echo "after-file-edit: file_path missing from hook input" >&2
  hook_emit_done
  exit 0
fi

tool_log="$(mktemp)"
trap 'rm -f "$tool_log"' EXIT

if ! pnpm exec prettier --write --ignore-unknown "$file" >"$tool_log" 2>&1; then
  cat "$tool_log" >&2
  hook_emit_done
  exit 1
fi

if ! pnpm exec eslint --fix --no-warn-ignored --no-error-on-unmatched-pattern "$file" >"$tool_log" 2>&1; then
  cat "$tool_log" >&2
  hook_emit_done
  exit 1
fi

hook_emit_done
exit 0
