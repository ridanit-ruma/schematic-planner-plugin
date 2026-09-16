---
name: test-driven-development
description: Use when implementing a non-trivial approved Plan task whose behavior can be checked before and after the change; observe the relevant failure, make the smallest fix, and preserve fresh evidence.
---

# Test-driven development

Work on exactly one approved, dependency-ready task. Read its files, acceptance
criteria, failing command, and source-Spec constraints before editing. Inspect
the repository's existing test path and reuse it; do not introduce a framework
when a focused existing check can express the behavior.

## Red

Add or select the smallest check that proves the requested behavior. Run it and
observe it fail for the intended missing behavior. A syntax error, environment
failure, or unrelated regression is not a useful red result: diagnose that
failure before implementation. If the check already passes, improve the check
or establish why no behavioral change is required instead of claiming a test-
first cycle that did not happen.

## Green

Make the smallest production change that satisfies the observed failure. Reuse
the shared implementation path and existing helpers. Do not add speculative
abstractions, broad cleanup, or unrelated fixes. Run the focused check again and
confirm it passes.

## Verify and hand off

Run proportionate surrounding checks after the focused check. Report the exact
commands, exit results, and any limitations to the caller so the implementation
Plan can update its single `evidence-<slug>` comment. Never mark a task
done from remembered, partial, or stale results.

For prose-only or trivial metadata changes, use the smallest relevant validator
instead of inventing a behavioral test, and record why that validator is the
appropriate red/green boundary. When an unexpected failure persists, switch to
root-cause debugging before making more edits.

## Red flags

These thoughts are the failure, not the way round it.

| Thought | What is actually true |
| --- | --- |
| "The task body says what to build, so I can just build it." | A body is a contract, not a failing check. Until you have watched one fail you do not know it would have caught anything. |
| "It already passes." | Then either the check is wrong or the behaviour is already there. Find out which, and say so, rather than claiming a cycle that did not happen. |
| "There is no test framework for this." | Then the smallest relevant validator is the check. Record in the evidence note why that is the red/green boundary. |
| "I will write the check after — same tests either way." | A check written after passes immediately, which proves nothing. It is also biased by the code you just wrote: you cover the cases you remembered, not the ones you would have found. |
| "It failed, that is red enough." | A syntax error or a broken environment is not evidence for the behaviour you are adding. Diagnose that failure first. |
| "This change is too small to be worth a check." | Small changes break. The check costs less than the turn you will spend finding out. |
