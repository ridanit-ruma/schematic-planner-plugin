# Codex Setup

Add the Schematic Planner Streamable HTTP MCP server through Codex settings. Use `https://schematic-planner.com/api/mcp` and an `Authorization: Bearer <key>` header. Keep the key in user-level configuration or a secret manager; do not add it to this repository.

If no Schematic Planner server appears in Codex, retrieve the current client configuration from Schematic Planner agent settings and add it before invoking `schematic-planner:using-schematic-planner`.
