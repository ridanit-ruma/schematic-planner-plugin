# Schematic Planner Plugin

Plan software work on a shared Schematic Planner canvas instead of a Markdown plan file.

## What it provides

- `using-schematic-planner` binds the repository to a canvas plan.
- `brainstorming-on-canvas` draws and gates the design.
- `writing-plans-on-canvas` creates test-first task nodes and dependencies.
- `executing-plans-on-canvas` performs one ready task and updates its status.

The canvas is the authoritative design and plan record. The plugin uses only the Schematic Planner MCP, and it never stores an API key in the repository.

## Install and configure

Install the repository in the plugin manager for your harness. Claude Code and Kimi Code discover the plugin manifests and `skills/` directory; Codex uses `.codex-plugin/plugin.json`; Cursor discovers `.cursor/commands`; and OpenCode loads `.opencode/plugins/schematic-planner.js`.

Configure the Schematic Planner MCP before use. Harness-specific instructions are in `references/mcp-setup-claude-code.md`, `references/mcp-setup-codex.md`, and `references/mcp-setup-cursor.md`. Cursor can start from `.cursor/mcp.json.example`.

## Workflow

1. Run `schematic-planner:using-schematic-planner`.
2. Design with `brainstorming-on-canvas`.
3. Resolve every `q-*` and `gate-design` comment on the canvas.
4. Create tasks with `writing-plans-on-canvas`.
5. Resolve `gate-plan`, then execute tasks with `executing-plans-on-canvas`.

The agent never polls for answers. It stops whenever a `q-*` or `gate-*` comment remains unresolved. Retrying a write is safe because canvas operations use idempotent upserts.

## License

Licensed under [Apache License 2.0](LICENSE).
