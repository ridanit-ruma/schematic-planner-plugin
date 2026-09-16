# The Schematic Planner MCP surface

Every skill in this plugin reads and writes plans through this surface and
nothing else. There is no CLI, no HTTP client, no second MCP server. If a
behaviour is not expressible here, it does not happen.

Verified against `apps/api/src/mcp/` and `packages/schema/src/` on 2026-09-16.
The product README's tool table is slightly behind the code; this file is not.

## The tools

| Tool | Use |
| --- | --- |
| `list_workspaces()` | Workspaces the key can act in |
| `list_projects({ workspace? })` | Projects reachable by the key |
| `create_project(...)` | Open a project |
| `list_plans({ workspace? })` | Plans, grouped by workspace, project and folder |
| `list_folders({ workspace?, projectSlug? })` | Non-nesting folders in one project, with plan counts |
| `create_folder({ name, workspace?, projectSlug? })` | Ensure a folder exists |
| `rename_folder({ folder, to, workspace?, projectSlug? })` | Rename a folder |
| `delete_folder({ folder, confirmName, workspace?, projectSlug? })` | Move a folder and its plans to trash |
| `create_plan({ title, workspace?, projectSlug?, folder?, description? })` | Open an empty plan, optionally filed in a folder |
| `move_plan({ planId, workspace?, projectSlug?, folder? })` | File a plan in a folder, at project top level, or in another project |
| `delete_plan(id)` | Remove a plan |
| `get_plan(id, { view })` | Read. `view` is `outline`, `detail`, `graph` or `markdown` |
| `read_nodes(id, { slugs })` | What the nodes you name actually say, in full |
| `plan_history(id, { limit? })` | Who changed what, newest first |
| `set_plan_sources(id, { sourceSpecIds })` | Which plans this one was written from |
| `trace(id, { from, direction?, depth? })` | Walk `flows_to` edges out of a node, a title or a tag |
| `apply_ops(id, ops[])` | The only write door |
| `layout(id, { scope? })` | Re-run layout over everything unpinned |
| `export_plan(id)` | Markdown tree plus `.canvas`, as a download link |

## Reading

`get_plan(id, { view: 'outline' })` is the default read and usually the first
one worth spending. It returns the containment tree with the flows out of each
node, a `*` against every node that has a body, and then the unresolved
comments in full:

```
# Invitation acceptance page

- invite-page [feature/planned] Invitation page *
    --> invite-endpoint (click Accept: { token })
  - invite-status [task/done] inviteStatus() *
  - invite-endpoint [task/planned] GET /invites/:token *
      --> invite-status (the token)
- auth-decision [decision/idea] Public GET vs guarded

A node marked * has a body. read_nodes prints them.

## Notes left on this plan

- q-session-vs-jwt on invite-page — Ruma's agent:
    Cookie session or JWT?

    - [ ] Session cookie (recommended)
    - [x] JWT
```

Nodes are listed in the order the flows run, not alphabetically, so the first
line of a chain is the first step of it. Ties break alphabetically and anything
caught in a cycle comes last.

One call therefore answers three questions: what is here, how it is wired, and
whether anything is waiting on the human — including *what they answered*,
because an open note is printed whole rather than flattened to a line.

`view: 'detail'` is the same outline with every body printed underneath its
node, indented behind `|`. Use it when you need all of them; use `read_nodes`
when you need three.

`read_nodes(id, { slugs })` prints those nodes in full: body, kind, status,
tags, what holds them, and every line into and out of them. This is the tool
for "what exactly does this task say to do". Reading a plan and then asking for
the handful you need costs a fraction of the export.

`view: 'graph'` returns JSON nodes, edges and **all** comments, each with
`author` and `resolved`. Use it to read a resolved note, which the outline no
longer shows.

`view: 'markdown'` returns the whole export with placement stripped. It is large.
Use it when handing a plan to someone who will read it as prose, not to find one
node.

`plan_history(id)` says who changed what, newest first, grouped by the act it
arrived in. A plan is a drawing two parties share: when you come back to one you
drew earlier, this is how you find out what the human did instead of assuming
nothing moved.

`list_plans` renders each project's folders and the plans filed under them. It
also shows empty folders, because an agent that cannot see an empty `specs`
drawer will create a duplicate or pile work at the project top level.

## Folders and filing

Folders do not nest. They are addressed by name within a project rather than by
an opaque id:

```text
list_folders({ workspace?, projectSlug? })
create_folder({ name, workspace?, projectSlug? })
rename_folder({ folder, to, workspace?, projectSlug? })
delete_folder({ folder, confirmName, workspace?, projectSlug? })
```

`create_folder` is idempotent and case-insensitive: asking for `specs` when
`Specs` already exists returns the existing folder. Historical duplicate names
are ambiguous, so the agent stops rather than guessing. `delete_folder` requires
the exact current name and moves both the folder and its plans to recoverable
trash.

Plans can be filed at creation or moved later:

```text
create_plan({ title, workspace?, projectSlug?, folder?, description? })
move_plan({ planId, workspace?, projectSlug?, folder? })
```

Omitting `folder` from `create_plan` leaves the new plan at project top level.
For `move_plan`, a folder name files it there, while `folder: null` takes it to
project top level. Naming no destination project keeps the current project.
Cross-workspace moves drop existing share links because their audience changes.

## Writing

`apply_ops(id, ops[])` is the only way to change a plan.

- **Atomic.** The whole batch applies inside one transaction or none of it does.
  A rejected batch changes nothing.
- **Upsert by slug.** Sending the same node twice leaves one node, so a retry
  after a network failure is safe and never duplicates.
- **Up to 2000 ops** per call.
- Every open canvas sees the batch at once. Drawing in a few meaningful batches
  is what a watching human actually sees happen; one giant batch appears rather
  than gets drawn.

### Operations

```json
{ "op": "upsert_node", "node": {
    "slug": "invite-status", "kind": "task", "title": "inviteStatus()",
    "body": "## Files\n…", "status": "planned", "tags": ["api"] } }

{ "op": "delete_node", "slug": "invite-status" }

{ "op": "rename_node", "from": "invite-status", "to": "invite-state" }

{ "op": "upsert_edge", "edge": {
    "kind": "contains", "from": "invite-page", "to": "invite-status" } }

{ "op": "delete_edge", "kind": "depends_on",
  "from": "invite-endpoint", "to": "invite-status", "via": null }

{ "op": "upsert_comment", "comment": {
    "id": "q-session-vs-jwt", "anchor": "invite-page",
    "body": "**Question:** …", "resolved": false } }

{ "op": "delete_comment", "id": "q-session-vs-jwt" }

{ "op": "set_plan", "title": "…", "description": "…" }
```

Edge identity comes from its endpoints, so submitting the same relationship
twice collapses to one edge.

## Vocabulary

**Node kinds:** `feature`, `task`, `decision`, `note`, `group`.

**Statuses:** `idea`, `planned`, `in_progress`, `blocked`, `done`, `dropped`.

**Edge kinds:**

- `flows_to` — control or data moves this way. A request and its reply are two
  edges pointing opposite ways. This is the one that draws the system.
- `contains` — nesting. Becomes directory structure on export.
- `depends_on` — what must exist first. Becomes the numeric filename prefix.
  Not the same as what calls what.
- `relates_to` — plain association, no structural meaning.

**Slugs** are lowercase alphanumeric words joined by single hyphens:
`invite-status`, never `inviteStatus` or `invite_status`. A rejected batch is
most often a slug that broke this rule.

## Limits

| Field | Limit |
| --- | --- |
| node `body` | 100,000 characters |
| comment `body` | 10,000 |
| plan `description` | 2,000 |
| `title` | 200 |
| `tags` | 20 tags, 40 characters each |
| ops per batch | 2,000 |

`meta` is a string map carried through to export frontmatter untouched, for keys
the product has no field of its own for. Do not use it for anything that already
has a field.

## Four things that will bite

**Agent operations carry no coordinates.** There is no `position` and no
`pinned` field in the agent-facing schema at all — deliberately, because a model
shown a coordinate field fills it in. Declare structure; call `layout` if you
must; a node a human has dragged is pinned and stays where they put it.

**`delete_edge` on a `flows_to` edge needs its `via`.** What sets a flow off is
part of its identity, so an edge drawn with a trigger can only be named again
with that trigger. Omit `via` only for an edge that never had one. Otherwise the
flow you drew is one you can never remove.

**`upsert_comment` does not accept `author`, and does not need one.** The
server signs a note it carries as "<owner>'s agent", because it knows whose key
it is and there is nothing an agent could put in that field worth trusting. Only
a note with a body is signed: resolving somebody's question is not claiming to
have asked it. Comment ids still carry the intent — see the gate conventions in
the skills: `q-` for a question, `gate-` for a stage approval, `blocked-` for a
stuck task.

**A resolved note is not in the outline.** Only open ones are, which is what
makes the read cheap. To see an answer after resolving it, use `view: 'graph'`,
which returns every comment with its `resolved` flag.

**Folder names are scoped to a project.** Folder tools accept the name shown by
`list_folders`; they do not expose ids and folders do not nest. A missing name
is an error, and duplicate historical names are deliberately ambiguous. Use
`create_folder` to ensure a conventional folder exists and `move_plan` to file
an existing plan without changing its id.
