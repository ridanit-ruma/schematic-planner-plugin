---
name: receiving-code-review
description: Use when review findings arrive for a Plan task; verify each finding against the approved Spec, current code, and runnable evidence before fixing, rejecting, or requesting material clarification.
---

# Receiving code review

Read the existing `review-spec-<task-slug>` and
`review-quality-<task-slug>` comments in stage order. Treat findings as claims
to investigate, not commands to obey or objections to dismiss.

For each finding:

1. Locate the cited behavior and compare it with the approved Spec and task.
2. Reproduce the issue or run the smallest probe that can confirm it.
3. Classify it as valid and blocking, valid and non-blocking, unsupported, or
   materially ambiguous.
4. Apply a valid fix test-first, then rerun focused and proportionate checks.
5. Reject an unsupported finding with concrete code, requirement, and command
   evidence; ask only when ambiguity would materially change the result.

Update the same stage comment with each disposition and fresh evidence. Keep it
unresolved while a blocking finding remains; resolve it only when that stage
passes. A non-blocking improvement outside approved scope is not an excuse for
scope creep—record it without silently implementing it.

Do not mark the task accepted until Spec compliance passes before code quality
and both comments identify the result they reviewed. Feedback handling grants
no authority to publish, merge, delete, or rewrite Git history.
