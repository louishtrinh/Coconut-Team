#!/usr/bin/env bash
# ============================================================
#  Coconut Team - per-project setup  (Linux / macOS / cloud sessions)
#
#  Usage:  ./setup.sh /path/to/new-project
#
#  Does the things the plugin cannot do for you:
#    - copies CLAUDE.md
#    - creates the ownership lanes (docs/design, src, tests)
#    - adds Prototype/ to .gitignore
#    - copies settings.json (plugin + web-session install hook) and
#      USING-THE-TEAM.md into the project
# ============================================================
set -euo pipefail

RULES_VERSION="v0.1.0"
MARKET="louishtrinh/Coconut-Team"
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  read -rp "Path to the project to set up: " TARGET
fi
[[ -n "$TARGET" ]]   || { echo "No path given."; exit 1; }
[[ -d "$TARGET" ]]   || { echo "Not found: $TARGET"; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

echo
echo "Setting up: $TARGET"
echo

# ---- 1. CLAUDE.md ---------------------------------------------------
if [[ -f "$TARGET/CLAUDE.md" ]]; then
  echo "  [skip] CLAUDE.md already exists - not overwriting."
  echo "         Compare against $KIT/CLAUDE.md (rules $RULES_VERSION)"
else
  cp "$KIT/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  [ok]   CLAUDE.md copied (rules $RULES_VERSION)"
fi

# ---- 2. ownership lanes ---------------------------------------------
for d in docs/design src tests .claude/project Prototype; do
  if [[ -d "$TARGET/$d" ]]; then
    echo "  [skip] $d already exists"
  else
    mkdir -p "$TARGET/$d"
    echo "  [ok]   created $d"
  fi
done

# git will not track an empty folder
for d in docs/design src tests; do
  [[ -e "$TARGET/$d/.gitkeep" ]] || touch "$TARGET/$d/.gitkeep"
done

[[ -e "$TARGET/docs/USING-THE-TEAM.md" ]] || { cp "$KIT/USING-THE-TEAM.md" "$TARGET/docs/USING-THE-TEAM.md"; echo "  [ok]   docs/USING-THE-TEAM.md copied"; }

# ---- 3. .gitignore ---------------------------------------------------
touch "$TARGET/.gitignore"
if grep -qxF 'Prototype/' "$TARGET/.gitignore"; then
  echo "  [skip] .gitignore: Prototype/ already listed"
else
  printf 'Prototype/\n' >> "$TARGET/.gitignore"
  echo "  [ok]   .gitignore: added Prototype/"
fi

# ---- 4. .claude/settings.json ---------------------------------------
write_settings() {
  cp "$KIT/settings.json" "$1"
}

if [[ -f "$TARGET/.claude/settings.json" ]]; then
  write_settings "$TARGET/.claude/settings.coconut-snippet.json"
  echo "  [skip] settings.json exists - wrote settings.coconut-snippet.json"
  echo "         Merge it by hand: marketplace, plugin, and the SessionStart hook."
else
  write_settings "$TARGET/.claude/settings.json"
  echo "  [ok]   .claude/settings.json written"
fi

cat <<EOF

Done. Next:

  1) cd "$TARGET"
  2) git add -A && git commit -m "Coconut Team setup" && git push
  3) In Claude Code:  /plugin marketplace add $MARKET
                      /plugin install coconut-team@coconut
                      /plugin install modern-web-guidance@coconut
                      /reload-plugins
  4) Check with /agents - Bob, Daisuki-chan, Hiram, Amy should be listed.

EOF
