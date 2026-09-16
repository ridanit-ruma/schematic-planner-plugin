---
name: connect
description: Use when a user wants to connect Schematic Planner or its canvas tools are missing because the MCP server is unconfigured or has no credential.
---

# Connect Schematic Planner

Use the plugin's existing connection implementation; do not recreate its config
editing or key validation in shell commands. Resolve `../../scripts/connect`
relative to this `SKILL.md`.

Keep each harness's established behavior:

- In Codex, add `--client codex` so the skill changes only
  `~/.codex/config.toml` and the shared environment file.
- In Claude Code, preserve the existing command behavior: pass the user's
  arguments to the shared script without adding a client filter. The retained
  `commands/connect.md` entry point uses this same implementation.
- In another supported harness, use its matching `--client` value when known;
  otherwise let the script configure the supported clients it detects.

Then:

1. If no key was supplied, run the selected form with `--print`, explain that
   the key comes from `/settings/agents`, and ask the user for it. Never search
   files, history, or environment variables for a key.
2. Before sending a supplied key to the selected host or changing user config,
   name the host and affected config. Obtain approval unless the user explicitly
   requested that exact connection in the current turn.
3. Run the resolved script with `--key <key>` and the client selection above;
   add `--host` only for a host the user selected. Never print the key back.
4. Report whether validation and configuration succeeded, then tell the user to
   fully restart the affected agent and begin a new session. MCP tools are
   discovered only at startup.

For Codex, do not treat the existence of `~/.schematic-planner/env.sh` as proof
that the credential reached the process. The environment that launches Codex
must load it. If the next session still lacks the tools, first verify that
`SCHEMATIC_PLANNER_KEY` is present in that Codex process without displaying its
value.
