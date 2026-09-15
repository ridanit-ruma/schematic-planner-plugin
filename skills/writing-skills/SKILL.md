---
name: writing-skills
description: Use when a recurring Schematic Planner plugin behavior gap may require creating or substantially revising a workflow skill; prove the gap, prefer extending its current owner, and validate behavior as well as structure.
---

# Writing skills

Create a skill only for a recurring behavioral gap with an independent trigger
and reusable workflow. First inspect existing local and installed skills and
their callers. If one already owns the behavior, make the smallest focused edit
there instead of adding another skill.

## Establish the behavior contract

Before editing, record a realistic prompt or scenario, expected observable
actions, actual result, and the evidence that it fails for the intended reason.
A missing file or invalid frontmatter is a structural failure, not a substitute
for a behavior baseline.

Define the trigger and exclusions, ordered behavior, stop conditions, authority
boundaries, and concrete pass/fail observables. Preserve user scope and require
authorization immediately before external or destructive actions.

## Implement the smallest owner

Keep the canonical workflow in one `SKILL.md` with valid, discriminating
frontmatter. Add a reference only for substantial conditional detail and a
script only when repeated deterministic execution justifies it. Keep harness
manifests thin, avoid speculative resources, and adapt relevant principles
without copying Superpowers text or requiring it at runtime.

## Validate behavior and packaging

Run the installed skill-creator `quick_validate.py`, the plugin package checks,
and manifest synchronization. Then read [the behavior scenarios](../../references/skill-evals.md)
and exercise the baseline plus every scenario affected by the change; core
cross-stage workflow changes exercise all seven. Judge actions, canvas state,
file changes, command order, evidence, and authority—not persuasive output text.

Record each scenario's setup, observed actions, result, and remaining limit.
Structural success cannot override a behavioral failure. Before release, use
the supported plugin development cachebuster/reinstall flow for the target
harness and confirm discovery and behavior in a fresh session. Installation,
publication, or unrelated configuration changes never gain implied authority.
