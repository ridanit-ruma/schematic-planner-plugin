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
limitations back for the Plan's `evidence-<slug>` comment.

If progress requires destructive action, missing user authority, or an external
state change, stop with evidence and a recommended decision. A reversible
implementation choice is a ruling to record, not a reason to abandon diagnosis.

## Red flags

These thoughts are the failure, not the way round it.

| Thought | What is actually true |
| --- | --- |
| "I can see what is wrong, I will just fix it." | Seeing a symptom is not knowing a cause. This is the thought that produces the second fix, and then the third. |
| "It is probably the change I just made." | Probably. Check the recent changes — and do not assume the newest one is the cause because it is the newest. |
| "I will add a guard here and move on." | A per-caller guard leaves the cause in place for every caller you have not met yet. |
| "Two fixes at once saves a turn." | Then you cannot tell which one worked, and you own the side effects of both. |
| "This is taking too long — patch the symptom and note it." | A noted symptom patch is a bug with a paper trail. The task is not done, and the evidence note will have to say so. |
| "Three fixes have not worked; one more should do it." | Three failures is a question about the design, not a fourth attempt. Stop, write what you found in the evidence note, and raise it. |
| "I cannot reproduce it, but I know what it is." | Then you have a theory and no evidence. Reduce the case until it reproduces, or say plainly that it does not. |
