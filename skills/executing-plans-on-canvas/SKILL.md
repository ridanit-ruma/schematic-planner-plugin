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

Use `test-driven-development` to observe the task's intended failing check and
make the smallest passing change. If a failure is unexpected or persists, use
`systematic-debugging` to reproduce it, trace its callers and shared path, and
test one causal hypothesis. Before any success claim, use
`verification-before-completion` to run fresh focused and proportionate broader
checks.

After verification passes, execute the task's commit step only for its owned
files. Then upsert exactly one resolved `evidence-<task-slug>` comment containing
the failing baseline, implementation summary, verification commands and exit or
result summaries, commit id, and explicit limitations. Update that same comment
on retry. Only then set the task to `done`; never put execution status on a Spec.

For safe, reversible, non-destructive ambiguity, upsert a resolved
`ruling-<task-slug>` comment with the choice and rationale, then continue. Mark
the task `blocked` only for a destructive or irreversible action, missing user
authority, an unresolved required gate, a genuine external impasse, or a
required failure that remains after evidence-driven attempts. Upsert exactly one
`blocked-<task-slug>` comment with evidence, attempts, and the recommended human
decision, then report it and end without polling. Never recreate deleted nodes,
change human layout, or silently switch Plans.
