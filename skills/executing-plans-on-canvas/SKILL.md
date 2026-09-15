---
name: executing-plans-on-canvas
description: Use after implementation Plan approval to discover a Plan in the bound project's plans folder and execute one ready task while keeping canvas status accurate.
---

# Executing one implementation task

Read `.schematic-planner.json`, then run `list_plans` for its workspace and use
only implementation Plans under the bound project's `plans` folder. An explicit
Plan id or link wins; otherwise choose the single clear topical match. If more
than one is plausible, stop for human selection. Keep no persistent active Plan
pointer and never rewrite the project binding.

Read the selected Plan with `get_plan(..., { view: "outline" })`. Its description
must start with `Source-Specs: <plan-id>[, ...]`; a Plan without provenance is
not executable under this workflow. Read its `constraints` note and, when a task
depends on design detail not present there, read the named source Spec.
Refuse to execute a task node found in a Spec, at project top level, or anywhere
outside the bound project's `plans` folder; report its actual location instead
of treating the canvas name as proof of stage.

## Source Spec drift guard

Before selecting a ready task, Re-read every named source Spec, including its
current decisions, affected flow, and comments. If both the Plan's recorded
source state and the MCP read expose an opaque revision, compare those tokens;
a mismatch triggers inspection rather than automatically proving incompatibility.
When revision metadata is absent, use the compatibility fallback: compare the
current affected graph, decisions, constraints, and gates with the Plan's task
scope and recorded impact. Treat `updatedAt` as informational only.

If a source now has an unresolved `q-` or `gate-`, or the comparison shows
material drift in behavior, interfaces, constraints, or acceptance checks, do
not start a task. Report the changed source and return the Plan to
`writing-plans-on-canvas` for review or revision. Continue only when the current
Spec still supports the approved task contract.

Stop and report the Plan URL if any `q-` or `gate-` comment is unresolved.
Select exactly one `planned` task whose `depends_on` prerequisites are all
`done`. Read its complete body before changing local files, then set only that
task to `in_progress` with `apply_ops`.

Follow the task body test-first: add its failing check, run it and confirm the
expected failure, make the smallest implementation change, and run the passing
verification. Execute its commit step only for the files the task owns. On
success, set the task to `done` on the implementation Plan; never put execution
status on a Spec.

If execution cannot continue, set the task to `blocked` and upsert exactly one
`blocked-<task-slug>` comment with evidence, attempts, and the recommended human
decision. Report it and end the turn without polling. Never recreate deleted
nodes, change human layout, or silently switch Plans.

When Superpowers is available, use its relevant implementation, testing,
debugging, and verification skills. Otherwise follow the task body directly.
