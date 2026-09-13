# Schematic Planner Plugin — Design

**Status:** approved in brainstorming, 2026-09-13. Ready for an implementation plan.

## Summary

A skills plugin that carries the Superpowers working philosophy — nothing gets
built until a human has agreed to the shape of it — but keeps the plan itself in
a Schematic Planner canvas instead of in Markdown files. The agent declares
structure through the Schematic Planner MCP; the human watches it appear, drags
it about, and answers questions in comments left on the drawing.

Superpowers plans live in one dimension: a file, read top to bottom, re-derived
every session because nothing holds it still. A plan on a canvas has a shape two
people can point at, and the same artifact is open in the human's browser and in
the agent's tool calls at the same moment.

## Why not just use Superpowers

Superpowers is right about the process and limited by its medium. A Markdown
plan cannot show that task 7 belongs inside feature B, that decision C is what
made task 4 necessary, or that three tasks are waiting on one interface — it can
only say so in prose and hope the reader holds it. Schematic Planner already
models exactly those relations (`contains`, `depends_on`, `flows_to`) and
already exports them back to Markdown when the shape is settled. The plugin's
job is to teach an agent to plan in that vocabulary.

## Scope

**v1 ships four skills — the planning chain, and nothing else:**

| Skill | Replaces |
| --- | --- |
| `using-schematic-planner` | `superpowers:using-superpowers` |
| `brainstorming-on-canvas` | `superpowers:brainstorming` |
| `writing-plans-on-canvas` | `superpowers:writing-plans` |
| `executing-plans-on-canvas` | `superpowers:executing-plans` |

**Deferred to v2**, because they are transcription rather than new work:
`test-driven-development`, `systematic-debugging`,
`verification-before-completion`, `requesting-code-review`,
`receiving-code-review`, `using-git-worktrees`,
`finishing-a-development-branch`, `subagent-driven-development`,
`dispatching-parallel-agents`, `writing-skills`.

Until v2 exists, the four planning skills name Superpowers' implementation
skills when Superpowers is installed, and say nothing when it is not. The plugin
never depends on Superpowers being present.

## Decisions taken

1. **The canvas is the only plan artifact.** Both the design and the
   implementation plan live in the graph. Markdown in the repository is what
   `export_plan` produced, never a source.
2. **Self-contained.** The plugin works with Superpowers absent.
3. **Questions and approvals happen in canvas comments**, not in chat.
4. **One binding file in the repository** ties it to a plan.
5. **One canvas grows** — the design graph matures into the plan graph, rather
   than a second plan being opened for implementation.
6. **The only connection is the Schematic Planner MCP.** No CLI, no direct HTTP,
   no second MCP server wrapping the first.
7. **Multi-harness**, in the shape Superpowers uses: one Markdown skill body,
   thin per-harness manifests.

---

## 1. The workflow and the four skills

```
human: "let's build the invitation acceptance page"
  |
  (1) using-schematic-planner
  |     reads the binding file
  |     absent -> asks whether to open a new plan or adopt an existing one,
  |               then writes the file
  |
  (2) brainstorming-on-canvas
  |     draws the rough design: feature, decision, note nodes; flows_to edges
  |     leaves what it does not know as comments
  |     reports to the terminal and stops
  |     human answers on the canvas; no open q-/gate- comments -> proceed
  |
  (3) writing-plans-on-canvas
  |     hangs task nodes inside the approved features with `contains`
  |     orders them with `depends_on`
  |     task bodies carry files, interfaces, TDD steps
  |     status: idea -> planned. Gate again.
  |
  (4) executing-plans-on-canvas
        picks the next task, status -> in_progress
        writes code locally, runs tests, status -> done
        stuck -> status blocked, plus a comment
```

### The vocabulary mapping

This table is the core of the plugin. Every skill is an elaboration of one of
its rows.

| In a Superpowers document | On the canvas |
| --- | --- |
| Architecture prose in the spec | `feature` nodes joined by `flows_to` edges |
| "Approach A vs approach B" | a `decision` node |
| An open question in the spec | an unresolved `comment` |
| `### Task 3` in the plan | a `task` node, held by its feature with `contains` |
| "Task 3 comes after task 1" | a `depends_on` edge |
| A task's Files / Interfaces / Steps | the task node's `body` (Markdown, up to 100,000 chars) |
| `- [ ]` checkboxes | `status`: `planned` -> `in_progress` -> `done` |
| Global Constraints | one `note` node, slug `constraints`, re-read before each task |
| The human's "yes" | a comment marked `resolved` |
| The finished plan as files | `export_plan`: directories from `contains`, file numbering from `depends_on` |

Two rows have no Superpowers equivalent and are worth using anyway:
`flows_to` edges, which draw how control and data actually move and which the
`trace` tool walks; and comments anchored to a node, which keep an objection
attached to the thing it was raised against.

### Three paths, and when a plan gets opened

`brainstorming-on-canvas` keeps Superpowers' three paths, and each decides what
happens to the canvas:

| Path | Canvas |
| --- | --- |
| **Spike** — a feasibility question whose output is an answer | Opens nothing. A spike has no shape to agree on. If its answer leads to work, that work is classified again |
| **Bounded** — a scoped change to a flow already in the repository | Draws into the plan the binding file already names. No new plan |
| **Architectural** — a new project, subsystem, or restructuring | Opens a new plan with `create_plan` and rewrites `plan` in the binding file. This is the full flow through all four skills |

The classification is announced before the first question, as in Superpowers, so
the human can override it. The ratchet is one-way: complexity found mid-task
upgrades the path and nothing downgrades it.

### Test-first steps without a test-first skill

`writing-plans-on-canvas` writes each task body with its failing test first,
even though v1 ships no TDD skill — the discipline belongs to the plan's
content, not to a separate document. `executing-plans-on-canvas` invokes
`superpowers:test-driven-development` when Superpowers is installed and
otherwise just follows the steps the task body already spells out.

---

## 2. The comment gate

### Checking the gate is one cheap call

`get_plan(id, { view: 'outline' })` returns the containment tree with each
node's kind, status and dependencies, followed by the unresolved comments only:

```
# Invitation acceptance page

- invite-page [feature/planned] Invitation page
  - invite-status [task/done] inviteStatus()
  - invite-endpoint [task/planned] GET /invites/:token (needs: invite-status)
- auth-decision [decision/idea] Public GET vs guarded

## Notes left on this plan

- q-session-vs-jwt on invite-page — Someone: Cookie session or JWT? …
```

Resolved comments do not appear; bodies are flattened to one line and truncated
at 240 characters. So one call answers both "what is next" and "is anything
waiting on the human". Full comment text needs `view: 'graph'`, which is only
worth spending when something is actually waiting.

### Waiting means ending the turn

The agent never polls. It leaves its questions, prints them to the terminal, and
hands the turn back. This is the only waiting strategy that behaves identically
across Claude Code, Codex, Cursor, Kimi and opencode — a turn boundary exists
everywhere, a background loop does not.

### The author gap, and the id convention

`upsert_comment` over MCP accepts `id`, `body`, `anchor` and `resolved` — **not
`author`**. The underlying schema has the field; the agent-facing tool does not
expose it, and nothing on the server fills it in. Every comment an agent leaves
therefore renders as "Someone", indistinguishable from a human's.

Comment ids are chosen by the agent and are readable, so they carry the
distinction instead:

| Prefix | Meaning |
| --- | --- |
| `q-…` | a question from the agent, e.g. `q-session-vs-jwt` |
| `gate-…` | a stage approval, e.g. `gate-design`, `gate-plan` |
| `blocked-…` | the agent is stuck on a task, e.g. `blocked-invite-endpoint` |
| anything else | left by a human |

Because upsert is keyed by id, asking the same question twice leaves one
comment rather than two.

### How a human answers

- **Resolve and change nothing** — the agent's recommended option is taken.
- **Write into the body, then resolve** — that answer is taken.

A question comment must therefore always name a recommendation, or resolving it
means nothing. The body format:

```
**Question:** where should the login session live?

- **A (recommended):** HTTP-only cookie, session row in Postgres. …
- **B:** JWT. Stateless, but logout needs a revocation list. …

Resolve as-is to take A, or write your answer here and resolve.
```

### The gate rule

Do not advance while any unresolved comment whose id starts with `q-` or
`gate-` exists. Unresolved comments left by humans are read too: answer in the
body and resolve the ones that are answerable, leave the ones that need a
decision.

### The terminal is a notification channel, not the record

```
Design drawn on the canvas — https://schematic-planner.com/plan/018f3c2a-…

2 questions waiting:
  q-session-vs-jwt  (on invite-page)   Cookie session or JWT?
  gate-design                          Is this the right shape?

Answer on the canvas and resolve them.
You can also answer here — I will write it onto the canvas.
```

The last line matters. A human away from a browser can answer in chat; the agent
then writes that answer into the comment body and resolves it. The canvas stays
the record either way.

---

## 3. The plugin body and harness layout

### Repository layout

One Markdown body per skill is the truth; every harness gets a thin adapter.

```
schematic-planner-plugin/
├── skills/
│   ├── using-schematic-planner/SKILL.md
│   ├── brainstorming-on-canvas/SKILL.md
│   ├── writing-plans-on-canvas/SKILL.md
│   └── executing-plans-on-canvas/SKILL.md
├── references/
│   ├── mcp-setup-claude-code.md
│   ├── mcp-setup-codex.md
│   ├── mcp-setup-cursor.md
│   └── mcp-surface.md          ← the tool surface, as verified
├── .claude-plugin/plugin.json
├── hooks/{hooks.json,session-start}
├── .codex-plugin/plugin.json
├── .cursor-plugin/plugin.json
├── .kimi-plugin/plugin.json
├── .opencode/plugins/schematic-planner.js
├── .agents/plugins/marketplace.json
├── scripts/sync-harnesses.sh
├── README.md
└── LICENSE
```

Plugin name: `schematic-planner`. Skills keep the `-on-canvas` suffix so that
`schematic-planner:brainstorming-on-canvas` cannot be confused with
`superpowers:brainstorming` when both are installed.

### The binding file

`.schematic-planner.json` at the repository root:

```json
{
  "server": "https://schematic-planner.com",
  "workspace": "acme",
  "project": "billing",
  "plan": "018f3c2a-…"
}
```

- `server` exists because no MCP tool returns a plan's web address. The terminal
  link is assembled as `{server}/plan/{plan}`. Default `https://schematic-planner.com`.
- `plan` is the one being worked on now. A new feature opens a new plan and
  replaces this value; older plans are found with `list_plans` rather than
  accumulated here.
- **Committed.** Different branches point at different plans, which is exactly
  the statement "this branch follows that plan".
- No folder field. The MCP surface has no concept of folders, and moving a plan
  between folders does not change its id.

### MCP setup is explained, never automated

The API key is a personal secret, so the plugin does not write it anywhere. The
entry-point skill detects the situation and stops with instructions,
distinguishing two cases:

1. **No server configured at all** — send the user to `/settings/agents`, which
   hands over the whole client configuration as pasteable JSON.
2. **Configured for other directories but not this one** — the common case with
   Claude Code's per-directory `~/.claude.json` entries. Recommend user scope:

   ```
   claude mcp add --scope user --transport http schematic-planner \
     https://schematic-planner.com/api/mcp \
     --header "Authorization: Bearer <key>"
   ```

A committable project form exists for Claude Code, since it expands environment
variables:

```json
{ "mcpServers": { "schematic-planner": {
  "type": "http",
  "url": "https://schematic-planner.com/api/mcp",
  "headers": { "Authorization": "Bearer ${SCHEMATIC_PLANNER_KEY}" } } } }
```

Per-harness differences go in `references/mcp-setup-*.md` so the skill bodies do
not swell.

### Harness differences are smaller than Superpowers' were

MCP tool names are identical everywhere — `get_plan` is `get_plan` in every
client. The only variation is which tool reads a local file, and the skills
avoid naming one: they say "read `.schematic-planner.json` at the repository
root" and let the harness choose. Superpowers needs a `references/*-tools.md`
per harness largely because its skills name file and shell tools directly.

---

## 4. Failure modes

| Situation | What the skill does |
| --- | --- |
| MCP tools absent | Explain setup and **stop**. Nothing happens without the canvas |
| Binding file absent | Ask: new plan or adopt existing. Write the file |
| Binding file points at a missing plan (deleted or trashed) | `list_plans` and ask again |
| `apply_ops` rejected | The whole batch fails atomically. Usually a slug that is not lowercase words joined by single hyphens. Fix and retry — upsert makes retry safe |
| Human deleted a node | **Do not recreate it.** Deletion is intent. The outline is the truth |
| Human dragged a node | Leave it. The agent-facing ops carry no `position` field at all, so this cannot be got wrong |
| Nobody answers a question | Do not wait. Leave the comment, report, end the turn |
| The same step runs twice | Safe. Upsert by slug collapses to one node |
| Removing a `flows_to` edge | `delete_edge` needs the `via` value the edge was drawn with; a triggered flow drawn without it can only be removed without it |

## 5. Testing

Skills are Markdown, so there are no unit tests. Three layers instead.

1. **Structural checks (scripted, CI).** Per-harness manifests agree with each
   other; every `SKILL.md` has valid frontmatter with a name and a description
   that says when to use it; `scripts/sync-harnesses.sh` leaves no diff.

2. **Behavioural checks (subagents).** Give a subagent an empty repository and a
   fabricated requirement, and let it work from the skills alone. Assert:
   - `feature` and `decision` nodes actually appeared on a plan
   - it left a `gate-` comment and **stopped**
   - it wrote no code before approval — the most important assertion
   - it never tried to invent coordinates

3. **One real pass (human).** Plan a genuine feature in `~/schematic-planner`
   with the plugin, end to end. Three roadmap items are open and suitable:
   social sign-in callbacks, email, plan version history.

---

## Appendix: the MCP surface, as verified

Read from `apps/api/src/mcp/` and `packages/schema/src/` on 2026-09-13. The
README's tool table is slightly behind the code.

**Eleven tools:** `list_workspaces`, `list_projects`, `create_project`,
`list_plans`, `create_plan`, `delete_plan`, `get_plan`, `trace`, `apply_ops`,
`layout`, `export_plan`. (`trace` and `create_project` and `delete_plan` are
absent from the README table.)

**No folder support anywhere.** `create_plan` takes `title`, `workspace`,
`projectSlug`, `description` only. Agent-created plans land at the project's top
level; a human files them from the rail.

**Node kinds:** `feature`, `task`, `decision`, `note`, `group`.
**Statuses:** `idea`, `planned`, `in_progress`, `blocked`, `done`, `dropped`.
**Edge kinds:** `flows_to`, `contains`, `depends_on`, `relates_to`.

**`apply_ops`** is the only write door: atomic, up to 2000 ops, upsert keyed by
slug. Ops are `upsert_node`, `delete_node`, `upsert_edge`, `delete_edge`,
`upsert_comment`, `delete_comment`, `set_plan`.

**Limits:** node `body` 100,000 chars; comment `body` 10,000; plan
`description` 2,000; `title` 200; up to 20 `tags` of 40 chars; `meta` is a
string map for extra export frontmatter, for keys the product has no field for.

**Slugs** are lowercase alphanumeric words joined by single hyphens.

**Agent ops carry no `position` or `pinned`.** This is deliberate: a model shown
a coordinate field fills it in. Placement is the server's, via `layout`.

**`get_plan` views:** `outline` (indented tree plus unresolved comments, bodies
flattened and truncated at 240 chars), `graph` (JSON nodes, edges and all
comments including `author` and `resolved`), `markdown` (the full export, with
placement stripped).

**`set_plan`** only changes `title` and `description`. Global constraints are
too long for a 2,000-character description, hence the `constraints` note node.
