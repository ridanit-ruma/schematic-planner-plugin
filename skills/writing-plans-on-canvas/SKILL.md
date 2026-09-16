---
name: writing-plans-on-canvas
description: Use after Spec approval to create or update a separate executable implementation Plan in the bound project's plans folder.
---

# Writing an implementation Plan

Start with the selected approved Spec id or ids from `specs`. Read each with
`get_plan(..., { view: "outline" })`; unresolved `q-` or `gate-` comments stop
the work. Read every source Spec's `constraints` note before planning.
Before authoring tasks, use `trace` to follow each affected Spec feature
upstream and downstream. Carry impacted nodes, interfaces, constraints,
dependent flows, and required checks into the relevant task bodies and review
context; do not copy unrelated branches of the Spec.

Run `list_plans` for the bound project. Reuse a Plan in `plans` only when its
scope matches and it cites the same Spec — `get_plan` prints what a Plan was
**Written from**, with each source's title, the drawer it is filed in, and
whether it still resolves.

Otherwise call `create_plan` with the bound workspace and project,
`folder: "plans"`, a scope-specific title, and `sourceSpecIds: [<spec-id>]`.
`set_plan_sources` changes the set later; it replaces the whole of it, so two
callers cannot half-agree about where a Plan came from.

Provenance is a field, not a sentence. An older Plan may carry it as a
`Source-Specs: <plan-id>` line at the top of its description — read that when it
is there, and set the field from it rather than writing another line. A field
can say that a source has been deleted or moved out of the project. A line of
prose says whatever it said the day it was written. After `create_plan` returns, run workspace-scoped
`list_plans` and confirm that exact new id appears under the bound project's
`plans` folder before writing tasks. If the just-created id is elsewhere, use
`move_plan` to put only that id in `plans`, list again, and stop if placement
still cannot be verified. Never move a pre-existing canvas as part of this
correction. One cohesive Spec may produce several Plans when delivery slices
have independent release order or prerequisites. Do not split merely because
there are many tasks.

Never add executable task nodes to a Spec. Never persist an active Plan pointer
or rewrite `.schematic-planner.json`. If several existing Plans are equally
plausible, stop for human selection before changing any of them.

Read the selected implementation Plan before writing. Represent only enough
`feature` nodes to group its delivery slices; the source Spec remains the design
authority. For every task, upsert a `task` node under its feature with a
`contains` edge. Use `depends_on` only for actual prerequisites. Each task body
must name:

1. Files to create, modify, and test.
2. Inputs, outputs, and interfaces required by dependent tasks.
3. A failing test command and its expected failure.
4. The smallest implementation that makes it pass.
5. Passing verification and a commit command.

Set a task to `planned` only when its body is complete. Before approval, run a
Plan self-review: confirm every approved Spec requirement is covered; remove
placeholder text; verify every path and interface against the repository; check
dependencies, failing and passing commands, and task size; split a task only
when the pieces can be executed and verified independently.

After the self-review passes, upsert `gate-plan` on the implementation Plan,
run `layout`, then read its outline again. Report its URL and every unresolved
`q-`/`gate-` comment and stop without polling.

When Superpowers is installed, execution may use its test-driven development
skills. Otherwise the task body is the execution contract.
