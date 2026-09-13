---
name: using-schematic-planner
description: Use when starting any conversation in a repository whose plans live on a Schematic Planner canvas - binds the repository to its plan, checks the connection, and routes design and planning work onto the canvas before anything gets built
---

# Planning on a canvas

<SUBAGENT-STOP>
If you were dispatched as a subagent to carry out one specific task, ignore this
skill. Your caller has already been through the gate.
</SUBAGENT-STOP>

Plans here do not live in Markdown files. They live in a Schematic Planner
canvas that you and your human partner are both looking at: a graph of features,
tasks and decisions, reached through the `schematic-planner` MCP server.

A file gets re-derived every session because nothing holds it still. A graph
holds still, and the person you are working with can see it change while you
change it.

## The rule

**Before any design or planning work — including the first clarifying question —
run the startup sequence below, then invoke the skill that fits.** If it turns
out to be the wrong one, you have lost one tool call.

Announce which one you are using and why: "Using brainstorming-on-canvas to
shape the invitation page."

## Which skill

| The request | The skill |
| --- | --- |
| "Let's build X", "I have an idea", anything not yet shaped | `schematic-planner:brainstorming-on-canvas` |
| A design already agreed, now needing tasks | `schematic-planner:writing-plans-on-canvas` |
| A plan already on the canvas, now needing building | `schematic-planner:executing-plans-on-canvas` |
| A question about what is already planned | Read it: `get_plan(id, { view: 'outline' })` |

Superpowers, if it is installed, still owns the disciplines that are not about
planning — test-driven development, systematic debugging, code review. Name
those skills when you reach them. If it is not installed, work normally; nothing
here depends on it.

## The startup sequence

Run this once, at the start, before answering anything substantive.

**1. Read `.schematic-planner.json` at the repository root.**
See `references/binding-file.md` for the schema.

**2. If the Schematic Planner MCP tools are not available, stop.**
Do not plan in Markdown instead, do not carry on and hope, do not offer to write
a design document as a substitute. Point at the setup reference for the harness
you are running in — `references/mcp-setup-claude-code.md`,
`references/mcp-setup-codex.md`, `references/mcp-setup-cursor.md` — and stop.

The commonest case is not "nothing is configured" but "configured somewhere
else": the server is registered for other directories and invisible in this one.
Say which of the two it is rather than handing over a generic setup page.

**3. If the binding names a plan, read it.**
`get_plan(plan, { view: 'outline' })`. One call gives you the whole shape, every
node's status, and anything waiting on your human partner.

If that fails — deleted, or in the trash, which reads as missing — run
`list_plans` and ask which plan to use. Do not open a replacement. A plan
somebody threw away is not one to recreate unasked.

**4. If nothing is bound, ask before opening anything.**
Adopt an existing plan (`list_plans`) or open a new one (`create_plan`). On
creation, write `workspace`, `project` and `plan` into the binding file and say
that you have.

**5. Report the link, then hand off.**
Assemble `{server}/plan/{plan}` and give it to your human partner, so they can
watch what you are about to draw.

## The gate

Your questions go on the canvas, not only in the terminal, and they stop you.

- Leave a question as a comment whose id starts with `q-`, a stage approval as
  `gate-`, a stuck task as `blocked-`. Ids are readable and upsert by id, so
  asking twice leaves one comment.
- Always name a recommended option, because resolving a comment unchanged means
  "take your recommendation".
- **Do not advance while any unresolved `q-` or `gate-` comment exists.** Do not
  poll for an answer either: report to the terminal and end your turn.
- Your human partner may answer in the terminal instead. Write their answer into
  the comment and resolve it. The canvas is the record; the terminal is only how
  they hear about it.

Each skill says how it uses this. The rule is the same in all of them.

## Never

- **Never read, write, or ask for an API key on behalf of a repository file.**
  The credential belongs to the harness's own configuration. `.schematic-planner.json`
  is committed and must stay safe to commit.
- **Never set coordinates.** The agent-facing operations have no position field
  at all. Declare structure; the server places it.
- **Never recreate what somebody deleted.** Deletion is intent.
- **Never edit an exported Markdown tree as if it were the plan.** It is output.

## Red flags

| Thought | Reality |
| --- | --- |
| "I'll just answer this quickly first" | The sequence comes before the first answer, not after it |
| "The MCP is missing, I'll write a design doc instead" | That is the failure this plugin exists to prevent. Stop and say so |
| "I know what's on the canvas" | You know what was on it. Read the outline; it costs one call |
| "I'll ask in chat, it's faster" | It is. It is also gone tomorrow. The question goes on the drawing |
| "They haven't answered, I'll start on the obvious part" | An unanswered gate is the whole point. End the turn |
| "This is too small to need a canvas" | Then it is a bounded change and goes on the canvas you already have. Still not Markdown |
