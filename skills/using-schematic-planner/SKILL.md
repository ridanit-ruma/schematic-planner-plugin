---
name: using-schematic-planner
description: Use when starting any conversation in a repository planned on Schematic Planner; bind the repository to a project, discover its specs and plans, and route work before anything is built.
---

# Planning on a project canvas

<SUBAGENT-STOP>
If you were dispatched as a subagent for one task, ignore this skill. Your caller
already selected the project and canvas.
</SUBAGENT-STOP>

The repository binds to one Schematic Planner **project**, not one permanent
Plan. Design canvases live in its `specs` folder and executable task canvases in
`plans`. Both folders are flat; individual changes may use several canvases.

## Start here

Run this sequence before substantive design, planning, implementation, or the
first clarifying question.

1. Read `.schematic-planner.json` and `references/binding-file.md`.
2. Confirm the Schematic Planner MCP exposes `list_projects`, `list_folders`,
   `create_folder`, `list_plans`, `create_plan`, and the Plan read/write tools.
   If not, stop and point to the setup reference for the current harness. Never
   substitute Markdown or raw HTTP.
3. If no binding exists, list workspaces and projects. Ask which existing
   project to adopt or whether to create one, then write only `server`,
   `workspace`, and `project` to the binding.
4. Confirm the bound project still exists. If not, list projects and ask rather
   than silently creating a replacement.
5. Run `list_folders` for the bound project. Ensure `specs` and `plans` with
   idempotent `create_folder` calls. If historical duplicate names make either
   folder ambiguous, stop for human cleanup.
6. Run `list_plans`, scoped to the binding's workspace, and use only the bound
   project's folder-qualified inventory for routing.

An older binding may contain `plan`. Treat this legacy id as prior context: read
it when it still exists, but do not require it, replace it, or recreate it when
it is gone. Remove the field once project discovery succeeds.

## Route the request

| Request | Selection and skill |
| --- | --- |
| A new idea or design change | Select or create a cohesive Plan in `specs`; use `brainstorming-on-canvas` |
| Approved Spec needing executable tasks | Select the approved Spec; use `writing-plans-on-canvas`, which writes a separate Plan in `plans` |
| Approved implementation Plan needing work | Select it from `plans`; use `executing-plans-on-canvas` |
| Read-only question | Select the relevant Spec or Plan and read its outline or trace |

An explicit Plan id or link wins. Otherwise reuse the single clear topical
match. Do not keep an active-canvas pointer. If multiple canvases are plausibly
the target, ask the human to choose before opening or changing any of them;
after selection, record that answer as a resolved comment on the chosen canvas.
Never recreate a candidate a human deleted.

Report the selected canvas as `{server}/plan/{plan-id}` before handing off to
the routed skill.

## Gates

- Questions use idempotent `q-<topic>` comments, approvals use `gate-<stage>`,
  and execution blockers use `blocked-<task>`.
- Every question names a recommended option. Resolving it unchanged accepts the
  recommendation.
- Do not advance while the selected canvas has an unresolved `q-` or `gate-`
  comment. Report the link and waiting comments, then end the turn; never poll.
- A human may answer in chat. Copy the answer into the comment and resolve it so
  the canvas remains authoritative.
- Canvas selection is the only question that may begin in chat because no Plan
  exists on which to record it yet.

## Never

- Never read, write, or ask for an API key. Credentials belong to the harness.
- Never set coordinates; declare graph structure and let the server lay it out.
- Never edit an exported Markdown tree as if it were the Plan.
- Never recreate or silently refile work a human deleted or moved.
