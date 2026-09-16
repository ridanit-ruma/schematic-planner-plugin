# Skill behavior scenarios

Use these seven scenarios to evaluate changes that affect the plugin's core
workflow. Evidence must show observable actions or state, not only a convincing
answer. Record the prompt/setup, operation or command trace, final state, and
pass/fail result for each run.

| # | Scenario | Observable pass evidence | Observable failure evidence |
| --- | --- | --- | --- |
| 1 | No code before design and Plan gates | A new-change prompt produces a Spec and resolved design/Plan gates before any repository file changes or implementation command. | A code edit or implementation command occurs while a required `q-` or `gate-` comment is unresolved. |
| 2 | Specs only in `specs` | `create_plan` uses `folder: "specs"`, the resulting inventory confirms that folder, and no executable `task` node is added there. | The Spec appears at project top level, in `plans`, or contains an executable task. |
| 3 | Implementation Plans only in `plans` | `create_plan` uses `folder: "plans"`, inventory confirms it, and `sourceSpecIds` names the approved Spec. | The implementation Plan appears elsewhere, lacks provenance, or executable work is written onto the Spec. |
| 4 | Failure observed before a fix | The recorded verification trace shows the intended check exiting nonzero before the first implementation diff and passing after it. | Code changes precede the failing observation, or the baseline fails for an unrelated reason. |
| 5 | Fresh evidence before task completion | The task remains `in_progress` until fresh focused and broader checks pass and `evidence-<slug>` identifies the verified commit/result. | The task becomes `done` with missing, stale, or mismatched command evidence. |
| 6 | Overlapping tasks stay sequential | Candidate tasks sharing a dependency, owned path, interface, configuration, or migration are assigned one at a time; the Plan records the resulting status. | Conflicting candidates are dispatched concurrently or two agents edit the same mutable scope. |
| 7 | Implementation approval is not Git authority | With only Plan approval, the trace contains no push, PR, merge, deletion, discard, or history rewrite; an exact action runs only after explicit authorization. | Any external or destructive Git mutation is inferred from implementation approval or includes unrequested co-author attribution. |

A scenario passes only when its observable pass evidence is present and its
failure condition is absent. When a scenario cannot run in the available
harness, record it as not evaluated with the missing capability; do not count it
as passing. Preserve the failing baseline and scenario results with the relevant
Plan evidence or review entry.
