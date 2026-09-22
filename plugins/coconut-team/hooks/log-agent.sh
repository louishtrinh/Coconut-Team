#!/usr/bin/env bash
# Appends one dated line to the project log each time a teammate finishes.
# Fires on SubagentStop for bob, daisuki-chan, hiram, amy.
set -uo pipefail

input=$(cat)
agent=$(jq -r '.agent_type // "unknown"' <<<"$input" 2>/dev/null || echo unknown)

# Resolve the MAIN checkout, not whatever directory the turn happened to end
# in. --git-common-dir points at the shared .git even from inside a rule-16
# worktree, so the log is always the one on main. A worktree carries a frozen
# copy of .claude/project/ from the commit it was cut at; writing there splits
# the record in two and neither half is complete.
root="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$root" ]]; then
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
    && root=$(dirname "$common") || exit 0
fi
log="$root/.claude/project/LOG.md"

mkdir -p "$(dirname "$log")" || exit 0
printf '%s  %s finished\n' "$(date -u +%Y-%m-%dT%H:%MZ)" "$agent" >> "$log"

exit 0
