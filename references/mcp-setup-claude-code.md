# Connecting the canvas — Claude Code

## One command

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --key <your key>
```

The key is on your instance at `/settings/agents` — `https://schematic-planner.com/settings/agents`
on the hosted one. The script checks it against the server before writing
anything, then registers `schematic-planner` at **user scope**, so it is there in
every directory rather than in the one you happened to be sitting in.

Then start a new session. MCP servers connect at startup, so a server added
mid-session is not there until the next one.

A self-hosted instance takes `--host https://planner.example.com`. The host is
the only part that changes; the path is always `/api/mcp`, and one key reaches
every workspace its owner belongs to — a key belongs to a person, not to a
workspace.

## Telling the failures apart

When the tools are missing, say which of these it is. They look identical from
inside a session and have different fixes.

**Nothing is configured.** No `schematic-planner` entry anywhere. Run the
command above.

**Configured, but refused.** The entry exists and the key is missing, empty or
wrong, so the server answers `401` and Claude Code reports the server as failed
to connect. This is the common one: a configuration naming
`${SCHEMATIC_PLANNER_KEY}` and an environment that never had it set. Run the
command above; it replaces the entry with one that holds the key.

**Configured, but not here.** Claude Code stores MCP servers per directory, so a
server added in one project is invisible in the next:

```sh
grep -n '"schematic-planner"' ~/.claude.json
```

Run the command above, which registers it once at user scope.

## Doing it by hand

`--print` writes nothing and shows what is needed:

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --print --client claude-code
```

which is:

```sh
claude mcp add --scope user --transport http schematic-planner \
  https://schematic-planner.com/api/mcp \
  --header "Authorization: Bearer <your key>"
```

`--transport http` is not optional: without it a client has no way to know the
URL names a remote server rather than a command to run.

The plugin no longer ships an `.mcp.json` of its own. One naming
`${SCHEMATIC_PLANNER_KEY}` sat beside whatever the command above registers,
under the same name, so a machine that had run it got both — the working server
and a second one answering 401, with duplicate tools and a permanent error in
the server list.

A project `.mcp.json` is still yours to write, and can be committed without the
key, because Claude Code expands environment variables in it:

```json
{
  "mcpServers": {
    "schematic-planner": {
      "type": "http",
      "url": "https://schematic-planner.com/api/mcp",
      "headers": { "Authorization": "Bearer ${SCHEMATIC_PLANNER_KEY}" }
    }
  }
}
```

That is the form that fails silently when the variable is unset, so prefer user
scope unless the file has to be shared.
