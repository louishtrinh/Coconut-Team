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

## Install

```
/plugin marketplace add louishtrinh/Coconut-Team
/plugin install coconut-team@coconut
```

Pick **User scope** at the prompt — that makes the team available in every
project on this machine, which is the point of shipping it as a plugin.

If the install summary says `Run /reload-plugins to activate.`, Claude Code
runs that for you. If the reload warns about the prompt cache, run
`/reload-plugins --force`.

### Declaring it in a project

A project can register the marketplace for anyone who opens it:

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

**This declaration registers the marketplace. It does not install the plugin.**
Claude Code does not install a plugin from an external source such as a GitHub
repo on the strength of a project's `settings.json`; it reports the plugin as
not installed until each user runs `/plugin install` themselves. That applies
to cloud sessions too, where there is no interactive `/plugin` — so a cloud
session gets the marketplace registered and no agents. Copying the agent files
into the target project's `.claude/agents/` is the only thing that works there
today, and it is a stopgap, not the distribution story.

The marketplace is only honoured after the workspace trust dialog is accepted
for that folder. In an untrusted folder it is ignored with no message.

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

## Private vs public

This repo works private for the commands you run: `/plugin marketplace add`,
`/plugin install`, `/plugin update` and `/plugin marketplace update` all use
your existing git credential helpers, so if `git clone` works in your terminal
it works here.

Background auto-update is the exception. It disables credential helpers when it
checks the remote over HTTPS, so it cannot authenticate to a private repo. Use
an SSH remote, which a key in `ssh-agent` authenticates the same way, or make
the repo public.

## Requires

`jq` on PATH for the hook scripts.

## Validate before pushing

```
claude plugin validate ./plugins/coconut-team
```
