# Schematic Planner MCP Surface

Use Schematic Planner MCP tools only. Do not call a CLI, an HTTP API, or a second MCP server to read or change a plan.

## Read tools

- `list_workspaces` and `list_projects` locate a destination.
- `list_plans` finds an existing plan when a binding is absent or stale.
- `get_plan(id, { view: "outline" })` is the normal status and approval-gate read.
- `get_plan(id, { view: "graph" })` reads full nodes and comments only when needed.
- `trace` follows a `flows_to` path.
- `export_plan` creates a Markdown export after the graph is settled; the export is not a plan source.

## Write tools

- `create_project` and `create_plan` create a project or plan when the user selected that path.
- `apply_ops` is the only mutation route. It is atomic and accepts at most 2,000 operations.
- `layout` places nodes after graph writes. Never send coordinates or pinned state in an operation.
- `delete_plan` is never used without an explicit user request.

`apply_ops` supports `upsert_node`, `delete_node`, `upsert_edge`, `delete_edge`, `upsert_comment`, `delete_comment`, and `set_plan`. Upsert operations make retries safe.

## Graph vocabulary

| Field | Allowed values |
| --- | --- |
| Node kind | `feature`, `task`, `decision`, `note`, `group` |
| Status | `idea`, `planned`, `in_progress`, `blocked`, `done`, `dropped` |
| Edge kind | `flows_to`, `contains`, `depends_on`, `relates_to` |

Node and comment slugs use lowercase alphanumeric words joined by one hyphen. Node bodies are Markdown and must not exceed 100,000 characters; comment bodies must not exceed 10,000 characters.

## Payload patterns

```json
{
  "op": "upsert_node",
  "slug": "invite-page",
  "kind": "feature",
  "status": "idea",
  "title": "Invitation page",
  "body": "Accept an invitation from a tokenized link."
}
```

```json
{
  "op": "upsert_edge",
  "from": "invite-page",
  "to": "invite-status",
  "kind": "flows_to"
}
```

```json
{
  "op": "upsert_comment",
  "id": "q-session-storage",
  "anchor": "invite-page",
  "body": "**Question:** where should the session live?\n\n- **A (recommended):** HTTP-only cookie.\n- **B:** JWT.\n\nResolve as-is to take A, or write your answer here and resolve.",
  "resolved": false
}
```

Comment IDs beginning `q-`, `gate-`, and `blocked-` identify agent-created questions, approvals, and blockers. Do not set `author`: the MCP write surface does not accept it.
