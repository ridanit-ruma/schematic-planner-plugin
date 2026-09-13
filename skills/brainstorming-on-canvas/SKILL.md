---
name: brainstorming-on-canvas
description: Use after the Schematic Planner binding is ready to design a requested change on the shared canvas before implementation.
---

# Brainstorming on Canvas

Read `.schematic-planner.json`, `references/mcp-surface.md`, and `get_plan(plan, { view: "outline" })` first. The outline and unresolved comments are authoritative; never recreate a node a human deleted.

Classify the request before asking detailed questions and announce the result:

- **Spike:** a feasibility question whose deliverable is an answer. Do not open or alter a plan.
- **Bounded:** a scoped change in an existing flow. Add its design to the bound plan.
- **Architectural:** a new subsystem, project, or restructuring. Create a plan and update the binding before drawing.

The classification may only escalate during the work. For Bounded and Architectural work, batch `apply_ops` upserts for readable `feature`, `decision`, and `note` nodes. Use one `note` node with slug `constraints` for global rules. Join control or data movement with `flows_to` edges. Call `layout` after graph writes; never send coordinates or pinned values.

For each question that needs human input, upsert one idempotent comment named `q-<topic>` anchored to the affected node. It must include an A option marked recommended, a B option, and this instruction: “Resolve as-is to take A, or write your answer here and resolve.” Then upsert `gate-design` with a request to approve the graph.

Before any next stage, call outline view. If an unresolved comment ID starts with `q-` or `gate-`, print the canvas URL and each waiting comment, then end the turn. Read unresolved human comments too: answer and resolve only those that do not need a new human decision. Never poll for an answer.
