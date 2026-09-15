---
name: dispatching-parallel-agents
description: Use when an approved Schematic Planner implementation Plan has at least two ready tasks that may be independent; scan for conflicts before bounded parallel delegation and fall back to sequential execution when overlap remains.
---

# Dispatching parallel agents

Parallelism is optional. Use native harness delegation only when the runtime and
user allow it and parallel work materially helps. Otherwise use one subagent or
execute sequentially without changing the Plan contract.

## Prove independence first

Read the current Plan, source Specs, ready task bodies, and repository state.
For every candidate pair, compare:

- dependency edges and gates;
- owned paths, generated files, and likely edit locations;
- public interfaces, schemas, types, and shared data contracts;
- build, dependency, deployment, and other shared configuration;
- migrations, fixtures, and ordering or data assumptions.

Shared read-only input is acceptable. A dependency, likely concurrent edit, or
mutable shared contract is not: remove one task from the batch or run the work
sequentially. Do not use agents as a substitute for understanding task scope.

## Dispatch bounded contracts

Assign exactly one ready task per agent. Each contract names the Plan and source
Specs, task slug and full body, exclusively owned files, fixed interfaces,
inputs and output, failing and passing checks, evidence to return, and authority
limits. Have the coordinator mark only dispatched tasks `in_progress`.

Agents return changed paths, a diff summary, commands and results, caveats, and
blockers. They must not edit another assignment, broaden scope, mutate unrelated
Plan state, or infer external/destructive authority. Unless isolated contracts
explicitly say otherwise, the coordinator owns commits and integration so
agents do not race on shared Git state.

## Receive results independently

Process each result as it arrives; never accept a batch by consensus. Inspect
the actual worktree, confirm path and interface ownership, run focused checks,
then review Spec compliance before code quality. The coordinator records that
task's `evidence-<task-slug>`, `review-spec-<task-slug>`,
`review-quality-<task-slug>`, `ruling-<task-slug>`, or
`blocked-<task-slug>` entry and alone sets final task status.

After all accepted results are integrated, run combined checks for cross-task
effects. If an agent fails or an unexpected overlap appears, preserve completed
independent work, stop conflicting assignments when safely possible, re-read
the Plan and repository, and resume the affected work sequentially. Do not add
a scheduler, lock service, or repository-local orchestration state.
