# Schematic Planner Plugin

Plan software work in a shared [Schematic Planner](https://schematic-planner.com)
project instead of in Markdown files nobody re-reads.

A project keeps design canvases in `specs` and executable task canvases in
`plans`. Each folder can hold as many focused canvases as the work needs, and the
person you are working with can watch them change while the agent changes them.
The agent declares structure through the Schematic Planner MCP; its open
questions become comments on the relevant drawing; and it does not start
building until those are answered.

## What it provides

| Skill | What it does |
| --- | --- |
| `using-schematic-planner` | Binds the repository to a project, checks its folders, routes the work |
| `brainstorming-on-canvas` | Creates or extends a design canvas in `specs` and gates it |
| `writing-plans-on-canvas` | Creates a linked implementation canvas in `plans` with test-first tasks |
| `executing-plans-on-canvas` | Finds one ready task in `plans` and keeps its status honest |
| `test-driven-development` | Observes the relevant failure before the smallest implementation change |
| `systematic-debugging` | Reproduces unexpected failures and fixes their shared root cause |
| `verification-before-completion` | Requires fresh evidence before success or completion claims |
| `requesting-code-review` | Records Spec-compliance review before code-quality review |
| `receiving-code-review` | Verifies and resolves review findings against the Spec and evidence |
| `using-git-worktrees` | Optionally isolates work when separation materially reduces risk |
| `finishing-a-development-branch` | Reviews the whole branch before an explicitly authorized finish action |
| `subagent-driven-development` | Delegates one bounded Plan task while the coordinator owns acceptance |
| `dispatching-parallel-agents` | Parallelizes only tasks that pass an explicit conflict scan |
| `writing-skills` | Extends or creates workflow skills from a failing behavior baseline and observable scenarios |

The project is the binding boundary. Its `specs` canvases are the authoritative
design record; its `plans` canvases are the authoritative execution record and
link back to their source with `Source-Specs`. Markdown in your repository is
what `export_plan` produced, never a source. The plugin reaches the project
through the Schematic Planner MCP and nothing else, and it never stores an API
key in a repository.

A Spec never contains executable `task` nodes. An implementation Plan is never
selected outside `plans`, and a newly created canvas is verified in its intended
folder before the agent writes design or execution content to it.

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
<https://schematic-planner.com/settings/agents>. Then, once, for every agent on
the machine:

```sh
scripts/connect --key sp_…
```

It checks the key against the instance before writing anything, then merges a
`schematic-planner` entry into each client's own configuration — Claude Code at
user scope, Codex, Cursor, Kimi, Kimi Code and OpenCode in their own files —
leaving everything else in them alone. Start a new session afterwards: MCP
servers connect at startup.

```sh
scripts/connect --host https://planner.example.com --key sp_…   # self-hosted
scripts/connect --client cursor --key sp_…                      # just one
scripts/connect --print                                         # show, write nothing
```

Codex holds no credential of its own and reads `SCHEMATIC_PLANNER_KEY` from the
environment, so it gets one more step, which the script prints.

Per-harness detail, including how to do it by hand, is in
`references/mcp-setup-*.md`.

**When the tools are missing.** The commonest cause is a configuration that
names `${SCHEMATIC_PLANNER_KEY}` and an environment that never had it set: the
header goes out empty, the server answers 401, and the tools are simply absent
with nothing to read. That is what the command above fixes, and what the
`connecting-the-canvas` skill tells an agent to run.

The key belongs to the harness's configuration. It never goes in
`.schematic-planner.json`, which is committed.

## The workflow

1. `schematic-planner:using-schematic-planner` binds the repository to a project,
   ensures the non-nesting `specs` and `plans` folders exist, and inventories
   their canvases.
2. `brainstorming-on-canvas` creates or reuses the matching canvas in `specs`,
   leaves `q-` comments where it needs a decision, then adds `gate-design`.
3. You answer on the Spec canvas. Resolving a comment unchanged takes the
   agent's recommendation.
4. `writing-plans-on-canvas` creates a separate canvas in `plans`, records its
   `Source-Specs` provenance, traces affected features upstream and downstream,
   turns the approved design into tasks, runs a Plan self-review, then adds
   `gate-plan`.
5. `executing-plans-on-canvas` discovers the matching Plan and builds one ready
   task at a time only after checking for source Spec drift. It uses opaque
   revisions when available and compares the current affected graph and gates
   as the compatibility fallback. Execution routes through
   `test-driven-development`, `systematic-debugging` when needed, and
   `verification-before-completion`, then records one evidence comment.
6. When delegation is available and allowed, `subagent-driven-development`
   assigns one bounded task. `dispatching-parallel-agents` may assign multiple
   ready tasks only after dependency, path, interface, configuration, and
   migration conflicts are excluded. Sequential execution remains equivalent.
7. `requesting-code-review` records `review-spec-<task-slug>` before
   `review-quality-<task-slug>`; `receiving-code-review` verifies any findings.
   After the last task, `finishing-a-development-branch` records the final
   branch-wide `review-branch`. `using-git-worktrees` remains optional.

Implementation approval is not Git mutation authority. Push, PR, merge,
deletion, discard, or history rewrite requires explicit authorization for that
action and target; AI or co-author attribution is never added by default.

The agent never polls for an answer: it leaves the question, reports it, and
ends its turn. Retrying a write is safe, because every canvas operation is an
upsert keyed by slug. The Plan is the coordination ledger across sessions;
agent memory and repository-local orchestration state are never required.

## Repository layout

```
skills/          skill bodies — the only place behaviour is defined
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
