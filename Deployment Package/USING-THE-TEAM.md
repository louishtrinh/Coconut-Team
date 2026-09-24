# Using the team — the dummy guide

For Claude Code on the web (browser). No terminal needed.

---

## Who they are

Four teammates. You talk to them by name, and the name has a `coconut-team:`
prefix — that is how plugin agents work.

| Say this | Who you get | Use them for |
| :-- | :-- | :-- |
| `coconut-team:bob` | Design director | What to build, how it should feel, is the idea any good |
| `coconut-team:daisuki-chan` | Engineer | Building the thing Bob specified |
| `coconut-team:hiram` | QA + security | Breaking it before your users do |
| `coconut-team:amy` | Project manager | Keeping the record, telling you who is waiting on what |

If you type just `bob`, nothing happens. It needs the full `coconut-team:bob`.

---

## Part 1 — This project (AgentSmokeTest)

Already set up. Nothing to do. Open a session and ask:

> Have coconut-team:bob design a login screen for me.

That is the whole thing. The plugin installs itself when the session starts.

If the agents are not there on your very first message, they will be on the
next one — the hook installs the plugin just after Claude Code has built its
list of agents, so it can be a turn late. `/reload-plugins` fixes it
immediately. Option A above avoids the wait entirely.

---

## Part 2 — Any other project you already have

Pick **one** of these. A is the smoothest, C is the one that definitely works.

### Option A — the environment setup script (agents ready immediately)

A setup script runs **before Claude Code starts**, so the team is loaded from
your very first message. It is cached, so it only runs once per environment.

1. Go to claude.ai/code.
2. Open the environment dialog (**Add cloud environment**, or the settings icon
   on an existing one).
3. In the **Setup script** box, add:

```bash
claude plugin marketplace add louishtrinh/Coconut-Team
claude plugin install coconut-team@coconut
claude plugin install modern-web-guidance@coconut
```

4. Save. The next new session has the team from turn one.

This is the only option where the agents are guaranteed to be there on your
first message. The other two install the plugin *after* Claude Code has already
built its list of agents, so they can be a turn late.

### Option B — turn it on for your claude.ai account

1. Go to claude.ai and open **Customize** in the sidebar.
2. Click the **Plugins** tab — not Skills. A plugin is not a skill, and
   searching for it under Skills finds nothing.
3. Enable `coconut-team`.

Covers every project at once with nothing added to any repository.

### Option C — set up one repository

Use this if Option A is not available to you, or if you want the team to work
for anyone else who opens that repo.

1. In that repository, open (or create) the file `.claude/settings.json`.
2. Paste this in. If the file already has things in it, add the `"hooks"` key
   alongside what is there — do not delete the rest.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "[ \"${CLAUDE_CODE_REMOTE:-}\" = true ] || exit 0; L=$(claude plugin list 2>/dev/null); echo \"$L\" | grep -q coconut-team@coconut && echo \"$L\" | grep -q modern-web-guidance@coconut && exit 0; { claude plugin marketplace add louishtrinh/Coconut-Team; claude plugin marketplace update coconut; claude plugin install coconut-team@coconut; claude plugin install modern-web-guidance@coconut; } >/dev/null 2>&1; exit 0",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

3. Commit and push it.
4. Start a new browser session on that repo. The team is there.

It adds about 2.5 seconds to the first session and nothing after that.

---

## How to actually use them

**Run them one at a time, in order.** They cannot talk to each other. Each one
reads what the last one left on disk, so running them at once just gets you
four agents guessing.

The order that works:

```
Amy      →  what is the state of things?
Bob      →  design it
Daisuki  →  build it
Hiram    →  break it
Bob      →  does the design still hold?
Amy      →  write down what happened
```

**Tell them where to look.** They start with an empty head. They cannot see
your conversation with me. This fails:

> coconut-team:daisuki-chan, build the upload thing

This works:

> coconut-team:daisuki-chan, build the upload flow described in
> docs/design/upload.md, decisions 3 and 4. Code goes in src/upload/.

Name the file. Name the folder. Name the decision.

**Before any real QA run, ask me first.** Rule 13 — I ask your permission, then
Hiram does the bug bashing so you do not have to.

---

## Checking it worked

Ask, in a session:

> Which coconut-team agents can you use?

You should get four names, all starting with `coconut-team:`.

---

## When it does not work

| What you see | What it means | Fix |
| :-- | :-- | :-- |
| No agents on your first message, fine afterwards | Normal with options B and C — the plugin installed just after the agent list was built | Run `/reload-plugins`, or use option A so it never happens |
| No agents at all, ever | Plugin did not install | Ask me to run `claude plugin list`; if empty, the setup above is missing or the repo is not trusted |
| Nothing found searching "coconut" on claude.ai | You are on the **Skills** tab | Switch to the **Plugins** tab — a plugin is not a skill |
| Agents exist but ignore your instructions | You did not tell them where to look | Re-ask with the file path and folder named |
| An agent edits the wrong folder | It went outside its lane | Tell me — that is a bug worth reporting, not something to work around |
| Changes vanish between agents | Someone did not commit | Handoffs are commits. Ask Amy to check the record |

---

## The one rule worth remembering

**Nobody works in someone else's folder.** Bob writes designs, Daisuki writes
code, Hiram writes tests, Amy writes the record. If Hiram finds a bug he
reports it — he does not fix it. That is what keeps four agents from undoing
each other's work.
