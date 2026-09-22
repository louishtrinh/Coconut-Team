# coconut

Big Coconut's Claude Code marketplace. One plugin: `coconut-team`.

## What's in it

| Agent | Role | Model |
| :-- | :-- | :-- |
| `bob` | Design director. Owns `docs/design/`, approves merges. | opus / high |
| `daisuki-chan` | Implementation. Owns `src/`, builds in a worktree, merges. | sonnet / high |
| `hiram` | QA and security. Owns `tests/`. | opus / high |
| `amy` | Project record, drift detection, branch lifecycle. | sonnet / medium |

Plus two hooks: `SubagentStop` logs every teammate finish to
`.claude/project/LOG.md`, and `Stop` flags a stale record so Amy gets re-run.

Plugin agents are namespaced, so they load as `coconut-team:bob`,
`coconut-team:daisuki-chan`, `coconut-team:hiram` and `coconut-team:amy` — not
the bare names. A project `CLAUDE.md` that names the bare ones needs updating
to match.

## Setup

Three ways. Take the first one that applies.

### 1. Everywhere, with nothing in any repo

Enable `coconut-team` on your claude.ai account. Claude Code downloads the
plugins enabled there into each Cowork and cloud session's own environment when
the session starts — no marketplace, no install step. They load as
`coconut-team@synced`.

This is the simplest setup there is, and it covers every project at once. If a
plugin of the same name is installed from a marketplace, that copy wins and the
synced one reports as not loaded.

### 2. One project's web sessions — a single paste

Paste this into the project's `.claude/settings.json`. That is the entire
setup: no script file, nothing else to add.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "[ \"${CLAUDE_CODE_REMOTE:-}\" = true ] && ! claude plugin list 2>/dev/null | grep -q coconut-team@coconut && { claude plugin marketplace add louishtrinh/Coconut-Team; claude plugin install coconut-team@coconut; } >/dev/null 2>&1; exit 0",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

Why it is needed: registering a marketplace in `settings.json` does **not**
install its plugin. Claude Code reports a plugin from an external source as not
installed until each user installs it, and a cloud session has no interactive
`/plugin` to do that with. The `claude` CLI *is* present in cloud sessions and
installs non-interactively, so the hook does it at session start.

Measured: 2.5s on a cold session, 0.4s once installed, 0.4s to skip outside a
web session. It exits 0 on every path, so it can never block a session from
starting.

`AgentSmokeTest` uses this exact block, if you want a working example to
copy from.

### 3. Your own machine — install once

```
/plugin marketplace add louishtrinh/Coconut-Team
/plugin install coconut-team@coconut
```

Pick **User scope** at the prompt: the team is then available in every project
on that machine.

If the install summary says `Run /reload-plugins to activate.`, Claude Code
runs that for you. If the reload warns about the prompt cache, run
`/reload-plugins --force`.

### Registering the marketplace for collaborators

This registers the marketplace for anyone who opens the repo. It does not
install the plugin — pair it with setup 1 or 2 above.

```json
{
  "extraKnownMarketplaces": {
    "coconut": {
      "source": { "source": "github", "repo": "louishtrinh/Coconut-Team" }
    }
  },
  "enabledPlugins": {
    "coconut-team@coconut": true
  }
}
```

`enabledPlugins` is an **object** mapping `plugin@marketplace` to a boolean.
An array (`["coconut-team@coconut"]`) is silently ignored — no error, the
plugin just never loads.

It is honoured only after the workspace trust dialog is accepted for that
folder. In an untrusted folder it is ignored with no message.

### Pinning

The `github` source takes a `ref` (branch or tag):

```json
"source": { "source": "github", "repo": "louishtrinh/Coconut-Team", "ref": "v0.1.0" }
```

Without a `ref` a project tracks the default branch, so an unfinished edit
pushed here reaches every project immediately. Tag releases and pin anything
that needs to stay still.

Add `"autoUpdate": true` next to `source` to refresh in the background after
startup. Third-party marketplaces default to `false`.

## Per project, still by hand

- `CLAUDE.md` at the repo root. Not a plugin component; copy it in.
- `Prototype/` in `.gitignore`.
- `docs/design/`, `src/`, `tests/` created, so the ownership lanes point at
  real paths.
- `.claude/project/` — Amy creates it on her first run.

## Updating

Edit an agent here, bump `version` in
`plugins/coconut-team/.claude-plugin/plugin.json`, tag the release, push.
Then in each project:

```
/plugin marketplace update coconut
/plugin update coconut-team@coconut
```

Users only receive updates when `version` is bumped, so an edit pushed without
a version bump reaches nobody.

**If you previously copied agents into a project**, delete
`.claude/agents/{bob,daisuki-chan,hiram,amy}.md` there. Project and user
`.claude/agents/` definitions override same-named plugin agents, so the stale
copy wins silently and the plugin appears to do nothing.

**`claude plugin uninstall` edits the repo you run it in.** Run from inside a
project, it strips that project's `.claude/settings.json` down to
`{"enabledPlugins": {}, "extraKnownMarketplaces": {}}` — a tracked file, so the
change lands in your diff. Run it from outside a repo, or check `git status`
afterwards.

## Private vs public

This repo is public, so nothing here needs credentials.

If it ever goes private again: the commands you run (`/plugin marketplace add`,
`/plugin install`, `/plugin update`, `/plugin marketplace update`) use your
existing git credential helpers and keep working. Background auto-update is the
exception — it disables credential helpers when it checks the remote over
HTTPS, so it cannot authenticate to a private repo over HTTPS. An SSH remote is
authenticated by a key in `ssh-agent` and is unaffected.

## Requires

`jq` on PATH for the hook scripts.

## Validate before pushing

```
claude plugin validate ./plugins/coconut-team
```
