# `.schematic-planner.json`

The one file that ties a repository to the plan it is being built from. It lives
at the root of the **consuming** repository — the codebase being planned — and
never in this plugin.

```json
{
  "server": "https://schematic-planner.com",
  "workspace": "acme",
  "project": "billing",
  "plan": "018f3c2a-…"
}
```

## The fields

| Field | Meaning |
| --- | --- |
| `server` | Where the canvas lives. The default is `https://schematic-planner.com`; a self-hosted instance names its own address |
| `workspace` | Workspace slug, as `list_workspaces` reports it |
| `project` | Project slug, as `list_projects` reports it |
| `plan` | The plan being worked on now, by id |

`server` exists for one reason: no MCP tool returns a plan's web address, and a
human needs a link to click. The terminal assembles `{server}/plan/{plan}`.

## Why there is no folder field

The MCP surface has no folders — nothing creates one, chooses one, or lists by
one. A plan an agent opens lands at the project's top level and a human files it
from the rail. Because filing does not change the plan's id, nothing recorded
here breaks when they do.

## Lifecycle

**Written** by the entry-point skill, never by hand and never by any other
skill. It is created the first time a repository is bound to a plan: the skill
asks whether to adopt an existing plan or open a new one, and writes what it
learns.

**Changed** when architectural work opens a new plan — `create_plan` returns a
new id and `plan` is replaced. Bounded work reuses whatever `plan` already
names; a small change to an existing flow does not deserve a new canvas.

**Committed.** Different branches point at different plans, which is exactly the
statement "this branch follows that plan". The churn is one line per feature,
and it is a line worth reading in a diff.

**Read** at the start of every session by the entry-point skill, before anything
else happens.

## What is never in it

No API key, no token, no `Authorization` header, no password. The credential
reaches the MCP server through the harness's own configuration — an environment
variable, or a user-scope MCP entry — and this plugin neither reads nor writes
it. A repository file is the wrong place for a secret, and this one is meant to
be committed.

## When it is missing or stale

**Missing** — the entry-point skill asks whether to adopt an existing plan
(`list_plans`) or open a new one (`create_plan`), then writes the file.

**Pointing at a plan that is gone** — deleted, or in the trash, which reads as
missing to everything but the trash itself. `get_plan` fails; the skill runs
`list_plans` and asks again rather than silently opening a replacement. A plan
somebody threw away is not one to recreate without being asked.
