---
name: brainstorming-on-canvas
description: Use after project discovery to select or create a specification canvas in specs and design a requested change before implementation planning.
---

# Brainstorming on a Spec canvas

Read `.schematic-planner.json`, `references/mcp-surface.md`, and the bound
project's folder-qualified `list_plans` result first. The repository binding is
project-scoped and never changes merely because this skill selects a Spec.

Classify the request and announce the result:

- **Spike:** a feasibility question whose deliverable is an answer. Do not open
  or alter a Plan.
- **Bounded:** a scoped change to an existing flow. Reuse the one matching Spec
  from `specs`, or create a cohesive Spec there when none covers it.
- **Architectural:** a new subsystem or restructuring. Reuse an existing
  in-progress Spec only when it clearly owns the same design; otherwise create a
  separate Spec.

For creation call `create_plan` with the bound workspace and project plus
`folder: "specs"`. After `create_plan` returns, run workspace-scoped
`list_plans` and confirm that exact new id appears under the bound project's
`specs` folder before writing any content. If the just-created id is elsewhere,
use `move_plan` to put only that id in `specs`, list again, and stop if the
placement still cannot be verified. Never move a pre-existing canvas as part of
this correction. A Spec holds design only: features, decisions, notes,
constraints, and `flows_to` edges. Test commands and implementation task bodies
belong in a later Plan under `plans`.

Before drawing, read the selected Spec with `get_plan(..., { view: "outline" })`.
Its nodes and unresolved comments are authoritative. Never recreate a node or
canvas a human deleted. If more than one Spec is an equally plausible match,
return to the entry skill's ambiguity rule instead of guessing.

Batch readable `feature`, `decision`, and `note` upserts. Keep global rules in
one `constraints` note. Draw control and data movement with `flows_to` edges,
then call `layout` without coordinates.

For each human decision, upsert `q-<topic>` on the affected node with an A
option marked recommended, a B option, and: “Resolve as-is to take A, or write
your answer here and resolve.” When the design is ready, upsert `gate-design`.

Read the outline again. If any `q-` or `gate-` comment is unresolved, report the
Spec URL and every waiting comment, then stop without polling. An approved Spec
is input to `writing-plans-on-canvas`; do not add executable tasks to it.
