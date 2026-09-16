# Connecting the canvas — Cursor

## One command

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --key <your key> --client cursor
```

The key is on your instance at `/settings/agents`. The script checks it against
the server before writing anything, then merges this into `~/.cursor/mcp.json`,
leaving every other server in that file alone.

```json
{
  "mcpServers": {
    "schematic-planner": {
      "type": "http",
      "url": "https://schematic-planner.com/api/mcp",
      "headers": { "Authorization": "Bearer <your key>" }
    }
  }
}
```

Restart Cursor afterwards.

`"type": "http"` is required. Without it the URL is read as a command to run.

## Not in the project

Cursor also reads `.cursor/mcp.json` inside a project, and the script
deliberately does not write there. A project file is easy to commit by accident,
and a committed key is the one mistake with no undo. If you do need one, keep
`${SCHEMATIC_PLANNER_KEY}` in it rather than the key, and confirm
`.cursor/mcp.json` is ignored by Git.

A self-hosted instance takes `--host https://planner.example.com`; the path is
always `/api/mcp`.
