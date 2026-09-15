---
name: finishing-a-development-branch
description: Use after all tasks in an approved implementation Plan are complete; review the whole branch, verify it freshly, and offer only explicitly authorized keep, PR, merge, or delete actions.
---

# Finishing a development branch

Implementation approval is not Git publication or deletion authority. Finish
only after every scoped task and its Spec-compliance and code-quality reviews
have passed.

## Review the whole branch

Inspect repository status, the complete accumulated branch diff against its
intended base, commit history, and the Plan's task review ledger. Preserve
unrelated user changes. Run fresh, proportionate checks that cover cross-task
integration, not only the last task.

Upsert one `review-branch` Plan comment with the base and reviewed revision,
diff scope, commands and results, findings, known limits, and pass/fail outcome.
Update the same comment on retry. Do not offer a finish mutation while a
branch-wide finding or required task review remains unresolved.

## Choose and authorize the finish

Present the applicable outcomes: keep the branch as-is, open a PR, merge it, or
delete it. State the exact local and remote effects. A prior Plan approval does
not choose an outcome.

Immediately before any push, PR creation, merge, branch deletion, worktree
removal, discarded change, or history rewrite, confirm that the user explicitly
authorized that exact action and target. Follow the harness permission rules;
if authority is absent, stop after the verified local result. Never add AI,
session, or co-author attribution unless the user explicitly requests it.

After an authorized action, inspect and report the final local branch,
worktree, remote, and PR state that applies. Do not claim an external result
from command intent alone; verify it from current state.
