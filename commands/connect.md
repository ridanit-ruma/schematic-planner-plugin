---
description: Point every agent on this machine at a Schematic Planner instance
argument-hint: [key] [--host https://…] [--client name]
---

Connect this machine to a Schematic Planner instance, so the canvas tools are
there in the next session.

Run:

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" $ARGUMENTS
```

**If no key was given**, run it with `--print` first to show what each client
needs, then ask the person for their key — it is on their instance at
`/settings/agents`, or <https://schematic-planner.com/settings/agents> on the
hosted one — and run it again with `--key <what they gave you>`.

Never invent a key, never go looking for one in a repository or a history file,
and never print it back in your reply. It goes to the script and nowhere else.

The script checks the key against the instance before writing anything, so its
output already says whether it worked. Report what it wrote, in a line or two,
and then say the one thing the script cannot do for them: **start a new
session.** MCP servers connect at startup, so the tools are not there until the
next one — retrying them now will fail for a reason that has nothing to do with
the key.

If it reported that Codex needs a line sourced in a shell profile, say so
plainly; Codex holds no credential of its own and stays refused until that line
is read.
