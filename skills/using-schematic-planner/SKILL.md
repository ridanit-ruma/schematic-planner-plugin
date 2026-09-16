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
   If they are missing, use `connecting-the-canvas` — that is the whole of the
   answer, and it takes one command. Never substitute Markdown or raw HTTP.
3. If no binding exists, list workspaces and projects. Ask which existing
   project to adopt or whether to create one, then write only `server`,
   `workspace`, and `project` to the binding.
4. Confirm the bound project still exists. If not, list projects and ask rather
   than silently creating a replacement.
5. Run `list_folders` for the bound project. Ensure `specs` and `plans` with
   idempotent `create_folder` calls. If historical duplicate names make either
   folder ambiguous, stop for human cleanup.
6. Run `list_plans`, scoped to the binding's workspace, and use only the bound
   project's folder-qualified inventory for routing. When the request names
   something that might already be drawn, `search` for it before deciding that
   nothing covers it — a title in the inventory is not the whole of a canvas.

Treat stage and folder as one invariant:

- Select specification canvases only from `specs`; executable `task` nodes are forbidden there.
- Select executable Plans only from `plans`; their tasks must carry approved Spec provenance.

A top-level or wrong-folder canvas is not a fallback candidate.

An older binding may contain `plan`. Treat this legacy id as prior context: read
it when it still exists, but do not require it, replace it, or recreate it when
it is gone. Remove the field once project discovery succeeds.

## Route the request

| Request | Selection and skill |
| --- | --- |
| A bounded change to a flow no Spec draws | Say what you intend in two or three sentences, get a yes, then build. No canvas. |
| A new idea or design change | Select or create a cohesive Plan in `specs`; use `brainstorming-on-canvas` |
| Approved Spec needing executable tasks | Select the approved Spec; use `writing-plans-on-canvas`, which writes a separate Plan in `plans` |
| Approved implementation Plan needing work | Select it from `plans`; use `executing-plans-on-canvas` |
| Read-only question | Select the relevant Spec or Plan; read its outline, `trace` one thread, or `read_nodes` the few that matter |
| Coming back to a canvas you drew before | `plan_history` first, then the outline. Assuming nothing moved is how two drawings of one system appear |

A bounded change is a change to a flow that is already here to read, of the
size a careful colleague would just make. It still needs a yes before you build
— what scales with smallness is the artefact, never the approval — and when a
Spec in `specs` already draws the flow you are changing, update that Spec
rather than taking this row. Creating a whole design canvas for a one-flag
change is how a plugin gets routed around; hidden complexity found halfway
through moves the work up to `brainstorming-on-canvas`, and nothing moves it
back down.

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

- Never invent, guess, or go looking for a key. A key comes from the person, out
  of their own `/settings/agents` page, and goes straight to
  `scripts/connect` — which is the one place that handles one. Never print it
  back, never commit it, never put it in a plan or a comment.
- Never set coordinates; declare graph structure and let the server lay it out.
- Never edit an exported Markdown tree as if it were the Plan.
- Never recreate or silently refile work a human deleted or moved.

## Red flags

These thoughts are the failure, not the way round it.

| Thought | What is actually true |
| --- | --- |
| "The canvas tools are missing, so I will write the plan into a file." | That is the one outcome this plugin exists to prevent. Connect it, or say plainly that it is not connected and stop. |
| "I cannot find the plan, so I will make a new one." | A second drawing of one system is how a workspace becomes a pile. Read `list_plans` again, and ask which one if it is genuinely ambiguous. |
| "The layout is wrong, so I will place the nodes." | There is no coordinate field in the agent surface, on purpose. Call `layout`. |
| "This is too small to need approval." | Then the design is two sentences. The approval does not shrink with the work. |
| "The human has not answered, so I will assume the recommended option." | Only once they resolve it unchanged. Report the link and the waiting comments, and end the turn. |
| "I read this plan an hour ago, so I know what is in it." | Somebody else has been drawing on it. `plan_history`. |
