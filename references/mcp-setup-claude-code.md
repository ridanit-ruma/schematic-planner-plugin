# Connecting the canvas — Claude Code

## Normally there is nothing to do

This plugin ships its own `.mcp.json`, so installing it declares the
`schematic-planner` server for every project at once. Supply the key as an
environment variable and the connection is there:

```sh
export SCHEMATIC_PLANNER_KEY="…"      # from /settings/agents
```

Put it wherever your shell reads on login, not in a repository file.

Get the key from the Schematic Planner settings page — `/settings/agents` on
your instance, or <https://schematic-planner.com/settings/agents> — which hands
over the whole client configuration as pasteable JSON.

## Telling the two failures apart

When the tools are missing, say which of these it is. They have different fixes
and the second one is far more common.

**Nothing is configured.** No `schematic-planner` entry anywhere. Install the
plugin, or configure the server by hand as below.

**Configured, but not here.** Claude Code stores MCP servers per directory in
`~/.claude.json`, so a server added while sitting in one project is invisible in
the next. To see which directories have it:

```sh
grep -n '"schematic-planner"' ~/.claude.json
```

The fix is to register it once at user scope rather than per directory.

## Configuring it by hand

**User scope — available in every directory:**

```sh
claude mcp add --scope user --transport http schematic-planner \
  https://schematic-planner.com/api/mcp \
  --header "Authorization: Bearer <your key>"
```

**Project scope, committable** — Claude Code expands environment variables in
`.mcp.json`, so the file can be checked in without the key:

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

`"type": "http"` is not optional: without it a client has no way to know the URL
names a remote server rather than a command to run.

## A self-hosted instance

Replace the host and nothing else. The path is always `/api/mcp`, and one key
works across every workspace its owner belongs to — a key belongs to a person,
not to a workspace.

## After changing any of this

Restart the session. MCP servers are connected at startup, so a server added
mid-session is not there until the next one.
