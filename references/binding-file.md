# `.schematic-planner.json`

The one file that ties a repository to its Schematic Planner project. It lives
at the root of the **consuming** repository — the codebase being planned — and
never in this plugin. The binding is project-scoped: individual specification
and implementation plans are discovered inside that project.

```json
{
  "server": "https://schematic-planner.com",
  "workspace": "acme",
  "project": "billing"
}
```

## The fields

| Field | Meaning |
| --- | --- |
| `server` | Where the canvas lives. The default is `https://schematic-planner.com`; a self-hosted instance names its own address |
| `workspace` | Workspace slug, as `list_workspaces` reports it |
| `project` | Project slug, as `list_projects` reports it |
| `plan` | Optional legacy field. It is only a migration hint for finding prior work, never the repository's permanent working pointer |

`server` exists so the terminal can assemble links for plans discovered or
created during the current workflow: `{server}/plan/{plan}`.

## Why there is no folder field

Folders belong to the bound project, not to the repository identity. The entry
skill discovers or creates the conventional `specs` and `plans` folders through
the MCP surface, then routes each request to a plan inside them. Moving a plan
within the project therefore does not rewrite the binding.

## Lifecycle

**Written** by the entry-point skill, never by hand and never by any other
skill. It is created the first time a repository is bound: the skill asks which
existing project to use or whether to open a new one, then writes the project
identity it learns.

**Stable across plans.** Opening, selecting, or splitting a specification or
implementation plan does not rewrite the binding. It changes only when the
repository moves to another workspace, project, or server.

**Migrated** when an older binding contains `plan`. The optional legacy plan is
a migration hint: inspect it when it still exists, use it to preserve prior
context, and continue with project-level discovery. Do not keep replacing it as
work moves between canvases.

**Committed.** Branches for the same codebase normally keep the same project
binding. Individual spec and implementation plan selection remains on the
canvas instead of producing one binding-file change per feature.

**Read** at the start of every session by the entry-point skill, before anything
else happens.

## What is never in it

No API key, no token, no `Authorization` header, no password. The credential
reaches the MCP server through the harness's own configuration — an environment
variable, or a user-scope MCP entry — and this plugin neither reads nor writes
it. A repository file is the wrong place for a secret, and this one is meant to
be committed.

## When it is missing or legacy

**Missing** — the entry-point skill lists reachable workspaces and projects,
asks which project to adopt or whether to create one, then writes the file.

**Containing `plan`** — treat that id as prior context only. If it is gone or in
the trash, ignore the hint and discover the project's remaining plans. Never
silently recreate a plan somebody deleted.
