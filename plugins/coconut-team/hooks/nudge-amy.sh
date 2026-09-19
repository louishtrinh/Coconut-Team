#!/usr/bin/env bash
# Flags a stale project record at the end of a turn so Amy gets re-run.
# Cheap by design: a file-timestamp comparison, never an agent spawn.
set -uo pipefail

input=$(cat)

# Guard against re-entry. Without this, a Stop hook that ever blocks will
# block its own block and wedge the session.
active=$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null || echo false)
[[ "$active" == "true" ]] && exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"
log="$root/.claude/project/LOG.md"
status="$root/.claude/project/STATUS.md"

# Nothing logged yet means nothing to reconcile.
[[ -f "$log" ]] || exit 0

if [[ ! -f "$status" || "$log" -nt "$status" ]]; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext: "Teammate activity has been recorded in .claude/project/LOG.md since STATUS.md was last written. Run the amy subagent to reconcile the project record, update STATUS.md and DIGEST.md, and report any drift before the next task begins."
    }
  }'
fi

exit 0
