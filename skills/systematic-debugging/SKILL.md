---
name: systematic-debugging
description: Use when a test, command, or runtime behavior fails unexpectedly or persists after an attempted fix; reproduce it, trace the shared path, test one causal hypothesis, and fix the root cause.
---

# Systematic debugging

Do not patch the reported symptom first. Preserve the failure, collect evidence,
and identify the shared cause before changing production code.

## Reproduce

Run the smallest deterministic command that demonstrates the problem. Record
the exact invocation, exit result, and relevant output. If reproduction depends
on unknown external state, inspect that state or reduce the case before forming
a theory. Do not treat an environment or syntax failure as evidence for the
reported behavior.

## Trace the path

Read the failing code and search every caller, sibling path, configuration
source, and boundary that can produce the value or event. Follow data and
control from input to failure. Compare a working path when one exists. Check
recent relevant changes, but do not assume the newest change is the cause.

## Test one hypothesis

State one falsifiable explanation and the observation that would disprove it.
Use the smallest read-only probe or focused test to distinguish that hypothesis
from alternatives. When disproved, update the explanation from the new evidence
instead of stacking speculative fixes.

## Fix once and verify

Add or preserve one regression check, then change the narrowest shared point
that fixes all affected callers. Avoid per-caller guards when one correct shared
invariant is smaller. Rerun the reproducer, regression check, and proportionate
surrounding checks. Hand the exact commands, results, causal explanation, and
limitations back for the Plan's `evidence-<task-slug>` comment.

If progress requires destructive action, missing user authority, or an external
state change, stop with evidence and a recommended decision. A reversible
implementation choice is a ruling to record, not a reason to abandon diagnosis.
