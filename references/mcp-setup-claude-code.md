# Claude Code Setup

Configure Schematic Planner in Claude Code before using the plugin. Prefer user scope so the same server is available in every repository:

```sh
claude mcp add --scope user --transport http schematic-planner \
  https://schematic-planner.com/api/mcp \
  --header "Authorization: Bearer <key>"
```

For a committed project configuration, use an environment variable rather than a literal key:

```json
{
  "mcpServers": {
    "schematic-planner": {
      "type": "http",
      "url": "https://schematic-planner.com/api/mcp",
      "headers": {
        "Authorization": "Bearer ${SCHEMATIC_PLANNER_KEY}"
      }
    }
  }
}
```
