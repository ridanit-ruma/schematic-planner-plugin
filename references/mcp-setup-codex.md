# Connecting the canvas — Codex

## Easiest path

In Codex, invoke the plugin's dedicated skill:

```text
$schematic-planner:connect <your key>
```

It resolves and runs the shared connection implementation with `--client
codex`, so Claude Code and the other supported agents continue to use the same
verified implementation without sharing their invocation surface.

## From a plugin checkout

```sh
scripts/connect --key <your key> --client codex
```

The key is on your instance at `/settings/agents`. The script checks it against
the server before writing anything, then adds the table below to
`~/.codex/config.toml`, editing that file as text so the rest of your settings
are untouched.

```toml
[mcp_servers.schematic-planner]
url = "https://schematic-planner.com/api/mcp"
bearer_token_env_var = "SCHEMATIC_PLANNER_KEY"
```

## Codex holds no credential of its own

It reads one from the environment, which is why the table names a variable
rather than carrying the key. So there is a second step, and the connection is
refused until you take it: the script writes the key to
`~/.schematic-planner/env.sh`, readable only by you, and you add one line to
your shell profile.

```sh
. ~/.schematic-planner/env.sh
```

It is not written into your profile for you. Appending to a login file is an
edit you did not ask for, in the one file that locks you out when it goes wrong.

Load the file in the environment that launches Codex, then fully restart Codex
and begin a new session. Sourcing it in a terminal does not alter a desktop app
that is already running, and a desktop launcher may not read the same shell
profile. If the tools remain absent, verify that the new Codex process has a
non-empty `SCHEMATIC_PLANNER_KEY` without printing its value.

Plugin hooks require review before Codex runs them. In Codex CLI, use `/hooks`
to review and trust the Schematic Planner `SessionStart` hook; in other Codex
surfaces, accept the corresponding hook review prompt when it appears.

## Check the key names against your version

Remote-MCP support in Codex has moved more than once, and which keys are
accepted — and whether an HTTP client has to be enabled explicitly — depends on
the release you have. `codex --version`, then the configuration documentation
for that release, settles it. If what you find differs from the above, the
documentation is right and this file is stale: fix this file.

What does not change: the URL ends in `/api/mcp`, the credential travels as
`Authorization: Bearer <key>`, and the key never goes in a repository file.

A self-hosted instance takes `--host https://planner.example.com` and replaces
the host and nothing else.
