---
name: using-git-worktrees
description: Use before executing an approved Plan task when concurrent work or isolation may materially reduce risk; inspect repository state and optionally create a safe Git worktree without disturbing user changes.
---

# Using Git worktrees

Worktrees are optional. Reuse the current tree for small, isolated work unless
concurrency or separation materially reduces risk.

## Read-only preflight

Read the selected Plan task, then inspect `git status --short --branch`,
`git worktree list`, the intended base and branch, and the proposed target
directory. Check repository ignore rules before placing a worktree inside any
project-owned directory. Preserve unrelated changes and never assume an
uncommitted tree is disposable.

## Choose the environment

- Continue in the current tree when it is safe and the task does not conflict
  with other active work.
- Use a worktree when concurrent work, a dirty tree, or branch separation makes
  isolation materially safer.
- If no safe target or branch can be identified, stay in the current tree when
  safe; otherwise report the conflict instead of guessing.

For an approved location and branch intent, use native Git, for example
`git worktree add <path> -b <branch> <base>`, after satisfying the harness's
permission rules. Re-run `git worktree list` and `git status --short --branch`
inside the new tree before editing.

Worktree creation grants no authority to push, merge, delete branches, remove
worktrees, discard changes, or rewrite history. Cleanup is a separate action:
never run destructive cleanup without explicit user authority and a fresh
read-only check of the exact target. If creation fails, keep the original tree
unchanged and report the command and error.
