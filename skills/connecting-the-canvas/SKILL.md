---
name: connecting-the-canvas
description: Use when the Schematic Planner tools are missing, refused, or unconfigured — no list_plans/create_plan in the tool list, an authorization error from one of them, or the person asking to connect an agent to their instance.
---

# Connecting the canvas

The skills in this plugin all reach the canvas through the Schematic Planner
MCP server. When that server is not there, every one of them fails in the same
way — the tools are simply absent — and the cause is almost always one of two
things, which look identical from inside a session.

**Do not work around a missing server.** Writing the plan into a Markdown file
instead is the failure this plugin exists to prevent. Connect it, or say plainly
that it is not connected and stop.

## Tell the two apart first

**Nothing is configured.** No `schematic-planner` entry anywhere. The tools are
absent and there is no error to read.

**Configured, but refused.** The entry exists and the key is missing, empty or
wrong, so the server answers `401` and the client reports the server as failed
to connect. The commonest cause by far: a configuration that names
`${SCHEMATIC_PLANNER_KEY}` and an environment that has never had it set.

A third, specific to Claude Code: **configured, but not here.** Claude Code
stores MCP servers per directory, so a server added while sitting in one project
is invisible in the next. `grep -n '"schematic-planner"' ~/.claude.json` shows
which directories have it; the fix is to register it once at user scope, which
is what the script below does.

## Connect it

If they are here to connect rather than in the middle of something else, the
short way is theirs to type:

```
/schematic-planner:connect <their key>
```

Otherwise, one command, for every agent on the machine:

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" <the key>
```

It checks the key against the instance before writing anything, then writes the
`schematic-planner` entry into each client's own configuration, merging rather
than replacing. Ask the person for the key — it is on their instance at
`/settings/agents` — and never put it in a repository file.

Useful arguments:

- `--host https://planner.example.com` — a self-hosted instance. The host is
  the only part that changes; the path is always `/api/mcp`.
- `--client claude-code` — one client rather than every one detected.
  Also `codex`, `cursor`, `kimi`, `kimi-code`, `opencode`, or `all`.
- `--print` — write nothing, and show what each client's file needs. Use this
  when the person would rather edit their own configuration.

## Then start a new session

MCP servers connect at startup, so a server added mid-session is not there until
the next one. Say so rather than retrying the tools: they will still be missing,
and a second failure reads as the connection not having worked.

## When it will not connect

- **The key is refused.** The script says so and writes nothing. A key belongs
  to a person, not to a workspace, and one key reaches every workspace its owner
  belongs to — so a key that works nowhere is the wrong key, not the wrong
  workspace. Issue a new one at `/settings/agents`.
- **The host is unreachable.** Check the instance is up before touching
  configuration; the tools being absent is a symptom of both.
- **Codex** holds no credential of its own and reads `SCHEMATIC_PLANNER_KEY`
  from the environment. The script writes the key to `~/.schematic-planner/env.sh`
  and prints the line to add to a shell profile. Until that line is sourced,
  Codex will be configured and still refused.
