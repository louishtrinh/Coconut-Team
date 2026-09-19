# coconut

Big Coconut's private Claude Code marketplace. One plugin: `coconut-team`.

## What's in it

| Agent | Role | Model |
| :-- | :-- | :-- |
| `bob` | Design director. Owns `docs/design/`, approves merges. | opus / high |
| `daisuki-chan` | Implementation. Owns `src/`, builds in a worktree, merges. | sonnet / high |
| `hiram` | QA and security. Owns `tests/`. | opus / high |
| `amy` | Project record, drift detection, branch lifecycle. | sonnet / medium |

Plus two hooks: `SubagentStop` logs every teammate finish to
`.claude/project/LOG.md`, and `Stop` flags a stale record so Amy gets re-run.

## Install

Private repo — Claude Code uses your existing git credentials, so if
`git clone` works in your terminal it works here.

```
/plugin marketplace add BigCoconut/coconut-team
/plugin install coconut-team@coconut
/reload-plugins
```

To make it load in cloud sessions, declare it in the *target project's*
`.claude/settings.json` (a user-scope install does not travel):

```json
{
  "extraKnownMarketplaces": {
    "coconut": {
      "source": { "source": "github", "repo": "BigCoconut/coconut-team" }
    }
  },
  "enabledPlugins": ["coconut-team@coconut"]
}
```

## Per project, still by hand

- `CLAUDE.md` at the repo root. Not a plugin component; copy it in.
- `Prototype/` in `.gitignore`.
- `docs/design/`, `src/`, `tests/` created, so the ownership lanes point at
  real paths.
- `.claude/project/` — Amy creates it on her first run.

## Updating

Edit an agent here, bump `version` in
`plugins/coconut-team/.claude-plugin/plugin.json`, push, then in each project:

```
/plugin update coconut-team@coconut
```

**If you previously copied agents into a project**, delete
`.claude/agents/{bob,daisuki-chan,hiram,amy}.md` there. Project-scope agents
override same-named plugin agents, so the stale copy wins silently and the
plugin appears to do nothing.

## Requires

`jq` on PATH for the hook scripts.
