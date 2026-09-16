# Connecting the canvas — Codex

## One command

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/connect" --key <your key> --client codex
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

Restart Codex afterwards.

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
