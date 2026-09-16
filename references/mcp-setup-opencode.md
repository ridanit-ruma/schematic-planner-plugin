# Connecting the canvas — OpenCode

## One command

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --key <your key> --client opencode
```

OpenCode reads `opencode.json` — `$XDG_CONFIG_HOME/opencode/opencode.json`, or
`~/.config/opencode/opencode.json`. A remote server goes under `mcp` rather than
`mcpServers`, and says so in its own `type`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "schematic-planner": {
      "type": "remote",
      "url": "https://schematic-planner.com/api/mcp",
      "enabled": true,
      "headers": { "Authorization": "Bearer <your key>" }
    }
  }
}
```

The key is on your instance at `/settings/agents`, and the script checks it
against the server before writing anything. Restart OpenCode afterwards.

A self-hosted instance takes `--host https://planner.example.com`; the path is
always `/api/mcp`.
