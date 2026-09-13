---
name: using-schematic-planner
description: Use at the start of any task that needs design, planning, or execution on a Schematic Planner canvas.
---

# Using Schematic Planner

The Schematic Planner canvas is the source of truth for design and implementation plans. Read `.schematic-planner.json` at the repository root before planning work, and read `references/mcp-surface.md` before composing an MCP operation.

1. Check that the Schematic Planner MCP tools are available. If they are absent, explain that setup is required and stop. Do not substitute direct HTTP, a CLI, or another MCP server.
2. If `plan` is non-empty, call `get_plan(plan, { view: "outline" })`. If it is missing, call `list_plans`, report the stale binding, and ask the human to adopt or create a plan.
3. If no plan is bound, ask whether to adopt an existing plan or create one. Use `list_workspaces`, `list_projects`, and `list_plans` to make adoption possible. For a new plan, call `create_plan` only after the human supplies its workspace, project, and title.
4. Write the selected `workspace`, `project`, and `plan` identifiers to `.schematic-planner.json`. Keep the default server unless the human explicitly chose another Schematic Planner server.
5. Report the canvas URL as `{server}/plan/{plan}` and continue with `brainstorming-on-canvas` when the task needs design.

Never place API keys in the binding, commits, comments, logs, or repository configuration. When setup is needed, direct the human to Schematic Planner agent settings or the matching file in `references/`.
