#!/usr/bin/env bash
# Appends one dated line to the project log each time a teammate finishes.
# Fires on SubagentStop for bob, daisuki-chan, hiram, amy.
set -uo pipefail

input=$(cat)
agent=$(jq -r '.agent_type // "unknown"' <<<"$input" 2>/dev/null || echo unknown)

root="${CLAUDE_PROJECT_DIR:-$PWD}"
log="$root/.claude/project/LOG.md"

mkdir -p "$(dirname "$log")" || exit 0
printf '%s  %s finished\n' "$(date -u +%Y-%m-%dT%H:%MZ)" "$agent" >> "$log"

exit 0
