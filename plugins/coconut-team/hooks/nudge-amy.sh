#!/usr/bin/env bash
# Flags a stale project record at the end of a turn so Amy gets re-run.
# Cheap by design: a file-timestamp comparison, never an agent spawn.
set -uo pipefail

input=$(cat)

# Guard against re-entry. Without this, a Stop hook that ever blocks will
# block its own block and wedge the session.
active=$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null || echo false)
[[ "$active" == "true" ]] && exit 0

# Resolve the MAIN checkout, not whatever directory the turn happened to end
# in. --git-common-dir points at the shared .git even from inside a worktree,
# so the record is always the one on main.
root="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$root" ]]; then
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
    && root=$(dirname "$common") || exit 0
fi

log="$root/.claude/project/LOG.md"
status="$root/.claude/project/STATUS.md"

# Nothing logged yet means nothing to reconcile.
[[ -f "$log" ]] || exit 0

# A missing STATUS.md is always worth a nudge, whoever ran last.
[[ -f "$status" ]] || { jq -nc '{hookSpecificOutput:{hookEventName:"Stop",additionalContext:"Teammate activity has been recorded in .claude/project/LOG.md since STATUS.md was last written. Run the amy subagent to reconcile the project record, update STATUS.md and DIGEST.md, and report any drift before the next task begins."}}'; exit 0; }

# Amy writes STATUS.md before LOG.md inside a single run, so LOG.md is ALWAYS
# newer once she finishes. Timestamps alone therefore fire after every Amy run
# forever. Ask the real question instead: has anyone OTHER than Amy finished
# since the last reconcile? If the most recent teammate to finish is Amy, the
# record was just brought current and there is nothing to nudge about.
last=$(grep -oE '^[0-9-]{10}T[0-9:]{5}Z  [^ ]+ finished$' "$log" \
       | tail -1 | awk '{print $2}')
[[ "$last" == *amy ]] && exit 0

if [[ "$log" -nt "$status" ]]; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext: "Teammate activity has been recorded in .claude/project/LOG.md since STATUS.md was last written. Run the amy subagent to reconcile the project record, update STATUS.md and DIGEST.md, and report any drift before the next task begins."
    }
  }'
fi

exit 0
