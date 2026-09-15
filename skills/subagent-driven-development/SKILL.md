---
name: subagent-driven-development
description: Use when an approved Schematic Planner implementation Plan has a bounded ready task and the runtime and user allow delegation; assign one task, then have the coordinator verify and record the result.
---

# Subagent-driven development

Delegation is optional. If the runtime lacks agents, the user has not allowed
them, or the task is not independently bounded, execute it sequentially with
the same Plan contract.

## Resume from the Plan

Read the current Plan and every named source Spec. Reconstruct progress from
task statuses and `evidence-*`, `review-spec-*`, `review-quality-*`, `ruling-*`,
and `blocked-*` comments, never from agent memory or a repository-local
coordination directory. Select only a task whose dependencies and gates are
satisfied, understand it fully, and have the coordinator set it `in_progress`.

## Assign one bounded task

Give one agent a written contract containing:

- Plan id and link, source Spec ids, task slug, and complete task body;
- owned files and preserved user changes;
- required inputs, output, failing check, passing verification, and evidence;
- scope and authority limits, including whether commits are allowed.

Do not delegate discovery the coordinator has not understood. The agent owns
only its assigned files and returns changed paths, diff summary, commands and
results, caveats, and any blocker. It must not broaden scope, change unrelated
Plan state, or infer authority for external or destructive actions.

## Accept or resume

The coordinator inspects the actual worktree and Plan after the result arrives;
agent prose is not evidence. Confirm owned-path scope, reproduce the failing
baseline when applicable, run fresh focused and combined checks, review Spec
compliance first, then code quality, and integrate only a passing result.

The coordinator alone updates final task status and the idempotent ledger:
`evidence-<task-slug>`, `review-spec-<task-slug>`,
`review-quality-<task-slug>`, `ruling-<task-slug>`, or
`blocked-<task-slug>`. Use a resolved ruling for safe reversible ambiguity;
block only for a genuine gate, authority, destructive-action, or external
impasse. On interruption or failure, re-read current Plan and repository state
before retrying, and continue sequentially when that safely preserves meaning.
