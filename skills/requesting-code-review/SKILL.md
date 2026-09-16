---
name: requesting-code-review
description: Use after a Plan task has fresh implementation evidence and before accepting it as complete; request Spec-compliance review first, then code-quality review, and record both outcomes on the Plan.
---

# Requesting code review

Review the actual result, not the implementer's confidence. Read the approved
source Spec, complete task body, current diff, and fresh `evidence-<slug>`
entry. Provide the reviewer only the relevant scope, changed files, acceptance
criteria, commands and results, known limits, and Plan link.

## Stage 1: Spec compliance

Check whether the implementation satisfies every approved requirement and task
criterion without silently dropping behavior or expanding scope. Confirm that
the evidence directly covers the claimed result. Upsert one
`the evidence note's Spec compliance section` comment with the reviewed revision or commit, findings,
evidence, and pass/fail outcome. Update the same comment on retry.

Do not start quality review while a Spec-compliance finding remains unresolved.
Return failures to implementation with a concrete missing requirement and a
focused way to verify it.

## Stage 2: code quality

Only after Stage 1 passes, inspect correctness risks, interfaces, error paths,
tests, maintainability, security implications, and avoidable complexity. Prefer
specific evidence and locations over style preference. Upsert one
`the evidence note's Quality section` comment with findings, severity, disposition, and
the reviewed revision or commit.

A human, available review agent, or the coordinator may perform a stage; do not
pretend delegation occurred when it did not. Acceptance requires both stage
comments to pass. Review approval does not authorize push, merge, deletion, or
any other Git mutation.

## Red flags

These thoughts are the failure, not the way round it.

| Thought | What is actually true |
| --- | --- |
| "The implementation is obviously right, review is a formality." | Then it costs little. Spec compliance is a different question from quality, and the obvious one is usually the first. |
| "I will run both reviews at once and combine the findings." | Quality review of work that does not match the Spec is review of the wrong thing. Spec compliance first. |
| "There is nothing to review, it is a one-line change." | Then say what was reviewed and what was found, in one line, in the evidence note. |
| "I reviewed it myself as I wrote it." | Writing and reviewing in the same pass is one pass. The stage exists to be a second look. |
