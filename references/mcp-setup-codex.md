# Connecting the canvas — Codex

Codex reads MCP servers from `~/.codex/config.toml`, under `[mcp_servers.<name>]`.

Start from the configuration the Schematic Planner settings page gives you —
`/settings/agents`, or <https://schematic-planner.com/settings/agents> — which
hands over the whole client configuration as JSON, including the remote URL and
the `Authorization` header. Everything below is that same information in the
shape Codex wants.

```toml
[mcp_servers.schematic-planner]
url = "https://schematic-planner.com/api/mcp"
bearer_token_env_var = "SCHEMATIC_PLANNER_KEY"
```

```sh
export SCHEMATIC_PLANNER_KEY="…"
```

**Check the key names against your Codex version before trusting this file.**
Remote-MCP support in Codex has moved more than once, and which keys are
accepted — and whether an HTTP client has to be enabled explicitly — depends on
the release you have. `codex --version`, then the configuration documentation
for that release, settles it. If what you find differs from the above, the
documentation is right and this file is stale: fix this file.

What does not change: the URL ends in `/api/mcp`, the credential travels as
`Authorization: Bearer <key>`, and the key never goes in a repository file.

A self-hosted instance replaces the host and nothing else.

Restart Codex after editing the configuration.
