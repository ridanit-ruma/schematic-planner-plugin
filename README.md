# Schematic Planner Plugin

Plan software work on a shared [Schematic Planner](https://schematic-planner.com)
canvas instead of in a Markdown file nobody re-reads.

A plan in a file gets re-derived every session, because nothing holds it still.
A plan in a graph holds still, and the person you are working with can watch it
change while the agent changes it. The agent declares structure through the
Schematic Planner MCP; its open questions become comments on the drawing; and it
does not start building until those are answered.

## What it provides

| Skill | What it does |
| --- | --- |
| `using-schematic-planner` | Binds the repository to a plan, checks the connection, routes the work |
| `brainstorming-on-canvas` | Draws the design and gates it |
| `writing-plans-on-canvas` | Hangs test-first task nodes under it, in dependency order |
| `executing-plans-on-canvas` | Takes one ready task and keeps its status honest |

The canvas is the authoritative record for both the design and the plan. Markdown
in your repository is what `export_plan` produced, never a source. The plugin
reaches the canvas through the Schematic Planner MCP and nothing else, and it
never stores an API key in a repository.

## Install

**Claude Code**

```
/plugin marketplace add ridanit-ruma/schematic-planner-plugin
/plugin install schematic-planner@schematic-planner
```

**Codex**

```sh
codex plugin marketplace add ridanit-ruma/schematic-planner-plugin
codex plugin add schematic-planner@schematic-planner
```

Kimi Code reads the same manifests. Cursor reads `.cursor-plugin/plugin.json`.
OpenCode loads `.opencode/plugins/schematic-planner.js`.

## Connect the canvas

Get a key from your instance's agent settings — `/settings/agents`, or
<https://schematic-planner.com/settings/agents> — which hands over the whole
client configuration as pasteable JSON.

In Claude Code the plugin ships its own `.mcp.json`, so one environment variable
is the whole setup and it applies in every directory:

```sh
export SCHEMATIC_PLANNER_KEY="…"
```

Everywhere else, and as the fallback anywhere, the per-harness instructions are
in `references/mcp-setup-claude-code.md`, `references/mcp-setup-codex.md` and
`references/mcp-setup-cursor.md`.

The key belongs to the harness's configuration. It never goes in
`.schematic-planner.json`, which is committed.

## The workflow

1. `schematic-planner:using-schematic-planner` binds the repository and reports
   the canvas link.
2. `brainstorming-on-canvas` draws the design and leaves `q-` comments where it
   needs a decision, then `gate-design`.
3. You answer on the canvas. Resolving a comment unchanged takes the agent's
   recommendation.
4. `writing-plans-on-canvas` turns the approved design into tasks, then
   `gate-plan`.
5. `executing-plans-on-canvas` builds them, one at a time.

The agent never polls for an answer: it leaves the question, reports it, and
ends its turn. Retrying a write is safe, because every canvas operation is an
upsert keyed by slug.

## Repository layout

```
skills/          the four skill bodies — the only place behaviour is defined
references/      the MCP surface, the binding schema, per-harness setup
.claude-plugin/  plugin.json and marketplace.json
.mcp.json        ships the canvas connection with the plugin
hooks/           session-start injection, and its Windows wrapper
scripts/         check.sh (structure, credentials), sync-harnesses.sh (drift)
```

Every harness adapter only identifies the plugin and points at `skills/`. None of
them implements planning behaviour, and none opens a connection of its own.

```sh
sh scripts/check.sh           # structure, frontmatter, no credentials shipped
sh scripts/sync-harnesses.sh  # every manifest still agrees what this is
```

Both run with nothing installed.

## License

[Apache License 2.0](LICENSE).
