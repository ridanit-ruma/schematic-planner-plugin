---
name: executing-plans-on-canvas
description: Use after implementation Plan approval to carry out one ready task from a Plan in the bound project's plans folder, keeping the canvas honest as you go.
---

# Carrying out one task

The canvas is not a record of the work. It is where the work is visible while it
happens, to somebody watching who did not ask you for a summary. That is the
whole difference between this and a plan in a file, and most of what follows is
about not throwing it away.

One task per turn. Say which, by slug, before touching anything.

## 1. Find the Plan

Read `.schematic-planner.json`, then `list_plans` for its workspace. Use only
implementation Plans under the bound project's `plans` folder. An explicit id or
link wins; otherwise the single clear topical match. If more than one is
plausible, stop and ask — never guess between two Plans, and never rewrite the
binding. Keep no active-Plan pointer; the address is in the conversation.

Refuse to carry out a task node found in a Spec, at the project top level, or
anywhere outside `plans`. Report where it actually is rather than treating the
canvas's name as proof of its stage.

## 2. Ask the Plan what is next

```
next_task(planId)
```

It answers with where the Plan has got to, what is already started, what is
blocked and on what, and the tasks that can be started now — each with its body.
Take the first ready one. Do not read the whole outline and decide for yourself:
that decision is where a task already finished gets done twice, and where one
waiting on unfinished work gets started.

Then read what the body does not carry: `read_nodes` the `constraints` note, and
the nodes of the cited Spec when the task turns on design detail in neither.
**A task carried out from its title is a task carried out from a guess.**

Stop before starting if the Plan has an unresolved `q-` or `gate-` comment.
Report the Plan URL and the waiting comments, and end the turn. Never poll.

## 3. Check the Spec has not moved under you

Re-read every Spec the Plan cites; `get_plan` lists them under **Written from**.
`plan_history` on a Spec is the cheapest way to see whether anything changed
while you were away: who changed what, newest first. `get_plan` also
ends with an opaque `Revision:` token; when the Plan recorded one, compare them,
and treat a mismatch as a reason to look rather than proof of incompatibility.
Where neither is available, compare the current affected graph, decisions,
constraints and gates against the task's contract. `updatedAt` is informational
only.

If a Spec now has an unresolved `q-` or `gate-`, or its behaviour, interfaces,
constraints or acceptance checks have moved away from that contract, do not
start. Report the changed Spec and hand the Plan back to
`writing-plans-on-canvas`.

## 4. Move the node before you move the code

```
apply_ops(planId, [{ op: 'upsert_node', node: { slug, status: 'in_progress' } }])
```

First, not last. Somebody is looking at this canvas, and between "I have chosen
a task" and "here is the result" there is a stretch of minutes in which the
drawing should not be still. Mark exactly one task; everything else stays as it
is.

Then build it. `test-driven-development` for the failing check and the smallest
change that satisfies it. `systematic-debugging` when a failure is unexpected or
survives a fix. `verification-before-completion` before any claim that it works.
`using-git-worktrees` only when isolation materially reduces risk; otherwise
keep the current tree and leave unrelated changes alone.

The moment you are stuck on something only a person can settle, leave the
`blocked-<slug>` note and set the status — then, not at the end of the turn. A
question that arrives with the final report is a question the person could have
been answering for the last ten minutes.

## 5. Prove it, then say so on the canvas

Commit only the files the task owns. Then upsert one resolved
`evidence-<slug>` comment carrying the whole account of that task:

- the failing baseline, and the command that produced it
- what you changed
- the verification commands, and their exit or result summaries
- the commit id
- **Spec compliance** — what `requesting-code-review` found, and what you did
- **Quality** — the same, for the second stage
- anything you decided along the way that could have gone either way, and why
- what you know is still not covered

One note per task, updated on retry, rather than four notes for somebody to
assemble later. Use `receiving-code-review` when either stage returns findings.
Set the task to `done` only after both stages pass, and never put execution
status on a Spec.

Then call `next_task` again. That is the loop.

## 6. When the Plan runs out

`next_task` says so. Use `finishing-a-development-branch` for a branch-wide
review, record it as `review-branch`, then offer the finish actions.

**Approval to implement is not authority over the remote.** Push, PR, merge,
branch deletion, discard, worktree removal and history rewrite each need the
user's word for that exact action on that exact target, immediately before it
happens. Never add co-author attribution unless it is asked for.

Never recreate a node a person deleted, never move what a person placed, and
never quietly switch to another Plan.

## The four notes, and no more

| Prefix | For |
| --- | --- |
| `q-<topic>` | A question for a person, with the options as a task list |
| `gate-<stage>` | A stage waiting on approval |
| `blocked-<slug>` | A task stopped on something only a person can settle |
| `evidence-<slug>` | The whole account of one task: baseline, change, checks, reviews, rulings, limits |

There used to be seven. `ruling-` and the two `review-` prefixes each held one
paragraph of the same story, and a story told in four notes is a story nobody
reads. The server knows none of these — they are a convention, and a convention
with seven parts is a convention that drifts.

Mark a task `blocked` only for a destructive or irreversible act, missing
authority, an unresolved gate, a genuine external impasse, or a required failure
that survives real attempts to fix it. Anything reversible you decide yourself
and write down in the evidence note.

Resume from the canvas rather than from memory. The statuses and these notes
are the ledger — not your recollection, and not a file on disk.

## Delegating

Sequential is always valid. One independently bounded task may go to
`subagent-driven-development`. Two or more ready tasks may go to
`dispatching-parallel-agents` **only** after a conflict scan clears dependency,
owned paths, interfaces, shared configuration and migrations. Each agent gets
exactly one complete task contract; you keep integration, the canvas and the
statuses. Unexpected overlap falls back to one agent, or to sequential.

When a delegated result comes back, inspect the repository and rerun its checks.
A report is a claim, not evidence. Spec-compliance review comes before quality
review, and acceptance or rejection goes in that task's own evidence note.

## Red flags

These thoughts are the failure, not the way round it.

| Thought | What is actually true |
| --- | --- |
| "I read this Plan earlier, so I know what is next." | Somebody has been drawing on it. `next_task`, every turn. |
| "I can see from the outline which task is ready." | That is the judgement `next_task` exists to replace, and the one a model gets wrong on a long Plan. |
| "The title is clear enough to start from." | Then the body will cost you ten seconds. `read_nodes`. |
| "I'll mark it in_progress once I have something to show." | Then the canvas is still for ten minutes while somebody watches it. Move the node first. |
| "I'll raise the blocker in my final report." | They could have been answering it for the last ten minutes. |
| "Two tasks look independent, so I'll run both." | Independent means the conflict scan cleared it, not that it looks that way. |
| "The subagent says its checks passed." | A report is a claim. Rerun them. |
| "It's approved, so I can push it." | Implementing is not remote authority. Ask for the exact action on the exact target. |
| "The Spec probably hasn't changed." | `plan_history` costs one call and answers it. |
| "This one is small, I'll skip the evidence note." | The note is how the next turn — yours or somebody else's — knows what was already proved. |
