# Connecting the canvas — Cursor

Cursor reads MCP servers from `~/.cursor/mcp.json` for every project, or
`.cursor/mcp.json` inside one project.

Get the configuration from the Schematic Planner settings page —
`/settings/agents`, or <https://schematic-planner.com/settings/agents> — which
hands it over as pasteable JSON. It looks like this:

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

```sh
export SCHEMATIC_PLANNER_KEY="…"
```

**Prefer `~/.cursor/mcp.json`.** A project-level `.cursor/mcp.json` is easy to
commit by accident, and a committed key is the one mistake with no undo. If you
do keep it in the project, keep the variable rather than the key, and confirm
`.cursor/mcp.json` is ignored by Git.

`"type": "http"` is required. Without it the URL is read as a command to run.

A self-hosted instance replaces the host and nothing else; the path is always
`/api/mcp`.

Restart Cursor after editing the configuration.
