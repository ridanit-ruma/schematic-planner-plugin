---
name: writing-plans-on-canvas
description: Use after design approval to turn a Schematic Planner design graph into reviewable implementation tasks.
---

# Writing Plans on Canvas

Read the bound plan with `get_plan(plan, { view: "outline" })`. Do not advance while unresolved `q-` or `gate-` comments exist. Read the `constraints` note before each task write.

For each approved feature, upsert `task` nodes and attach them with `contains` edges. Use `depends_on` only for actual prerequisites. Every task body is Markdown and must include all of the following concrete information:

1. Files to create, modify, and test.
2. Inputs, outputs, and named interfaces expected by dependent tasks.
3. A failing test command and its expected failure.
4. The smallest implementation step that makes that test pass.
5. A passing test command and a commit command.

Set a task to `planned` only after its body is complete. Keep bodies below the MCP limit. Upsert `gate-plan` after all task nodes and dependency edges are ready.

Call outline view again. If `q-` or `gate-` comments remain unresolved, report the canvas URL and stop. When Superpowers is installed, execution may invoke `superpowers:test-driven-development`; otherwise the executor follows the test-first steps in the task body.
