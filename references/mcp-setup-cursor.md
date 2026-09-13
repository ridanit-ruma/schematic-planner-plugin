# Cursor Setup

Copy `.cursor/mcp.json.example` to Cursor's project or global MCP configuration and set `SCHEMATIC_PLANNER_KEY` in the environment. Do not commit `.cursor/mcp.json` when it contains a token.

Cursor exposes the workflow adapters as `.cursor/commands/*.md`. Invoke the Start command first, then Brainstorm, Write Plan, and Execute Plan as the canvas approval gates allow.
