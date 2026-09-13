---
name: executing-plans-on-canvas
description: Use after plan approval to execute one ready Schematic Planner task and keep its canvas status accurate.
---

# Executing Plans on Canvas

Read `.schematic-planner.json` and call `get_plan(plan, { view: "outline" })`. Stop and report the canvas URL when unresolved `q-` or `gate-` comments exist.

Select exactly one `planned` task whose `depends_on` prerequisites are all `done`. Read its body and the `constraints` note before changing local files. Set only that task to `in_progress` with `apply_ops`.

Follow the task body test first: write the failing test, run it and confirm the expected failure, make the smallest implementation change, then run the passing verification. On success, set the task to `done` with `apply_ops`.

If execution cannot continue, set the task to `blocked` and upsert exactly one `blocked-<task-slug>` comment. State the evidence, what was tried, and the recommended next human decision. Print the blocker and end the turn. Do not recreate deleted nodes, change a human layout, or poll for a response.

When Superpowers is available, use its relevant implementation, test, debugging, and verification skills. Without it, the task body remains the execution contract.
