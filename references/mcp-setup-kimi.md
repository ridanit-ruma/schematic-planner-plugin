# Connecting the canvas — Kimi

## One command

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --key <your key> --client kimi
```

Kimi CLI reads MCP servers from `~/.kimi/mcp.json`. Kimi Code reads
`~/.kimi-code/mcp.json` — or `$KIMI_CODE_HOME/mcp.json` when that is set — and
is reached with `--client kimi-code`. Either way the shape is the same, and the
script merges it in rather than replacing the file:

```json
{
  "mcpServers": {
    "schematic-planner": {
      "url": "https://schematic-planner.com/api/mcp",
      "headers": { "Authorization": "Bearer <your key>" }
    }
  }
}
```

The key is on your instance at `/settings/agents`, and the script checks it
against the server before writing anything.

Restart Kimi afterwards.

## The interactive route

Kimi Code has `/mcp-config` in its interface, which adds and edits servers
without touching the file. Either works; use whichever you would rather trust,
and `--print` shows exactly what to type in:

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --print --client kimi
```

Kimi Code also has a project-level `.kimi-code/mcp.json`. The script does not
write there: a project file is easy to commit by accident, and a committed key
is the one mistake with no undo.

A self-hosted instance takes `--host https://planner.example.com`; the path is
always `/api/mcp`.
