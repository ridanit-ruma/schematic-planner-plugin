---
name: verification-before-completion
description: Use immediately before claiming work is fixed, passing, or complete or marking a Plan task done; run fresh checks that directly prove the claim and report their exact results and limits.
---

# Verification before completion

Evidence must match the scope of the claim. A focused check can prove its own
behavior, not the whole repository. Old output, another agent's summary, or the
absence of an obvious error is not fresh verification.

## Define the proof

Restate the task's acceptance criteria and identify the smallest command that
directly proves each one. Include proportionate surrounding checks for shared
interfaces, packaging, build output, or integration paths affected by the diff.
Inspect the current diff and repository status so the verification covers the
files that actually changed.

## Run fresh checks

Run the focused command after the final implementation edit, then the relevant
broader checks. Read the exit result and meaningful output; do not infer success
from silence unless that command defines silence as success. If a check fails,
report the failure and return to debugging or implementation rather than
softening the completion claim.

## Record the boundary

Hand back every command, exit or result summary, and any untested limitation for
the implementation Plan's single `evidence-<task-slug>` comment. Include the
commit id after the task's owned files are committed. Update the same evidence
comment on retry rather than creating a second history.

Mark the task done only when current evidence proves all acceptance criteria.
If an essential check cannot run, say what is missing and whether the task is
genuinely blocked; partial verification must be described as partial. Never use
confidence, plausibility, or a passing unrelated check as a substitute.
