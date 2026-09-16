#!/usr/bin/env node
/**
 * Connects this machine's agents to a Schematic Planner instance.
 *
 * The plugin used to ship a `.mcp.json` naming `${SCHEMATIC_PLANNER_KEY}` and a
 * page of prose per harness explaining where to put the same three facts. That
 * is a setup guide, not a setup: the variable goes unset, the header is sent
 * empty, and the server answers 401 — which reads as "the tool is broken"
 * rather than "nobody has given it a key". This asks once and writes it
 * everywhere, after checking that the key is actually accepted.
 *
 *   node scripts/connect.mjs --key sp_… [--host https://…] [--client all]
 *
 * Each client's configuration is merged, never rewritten: whatever else is in
 * the file stays, and only the schematic-planner entry is set.
 */
import { spawnSync } from 'node:child_process';
import { chmodSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { createInterface } from 'node:readline/promises';
import { dirname, join } from 'node:path';

const DEFAULT_HOST = 'https://schematic-planner.com';
const SERVER = 'schematic-planner';
const HOME = homedir();

/**
 * Every client, and the one thing each of them is: a file, a shape, and how to
 * tell whether this machine has it.
 *
 * `env` marks a client that cannot hold a credential itself and reads one from
 * the environment instead. Those get the variable written to a file of our own
 * and a line to source; everything else gets the key.
 */
const CLIENTS = {
  'claude-code': {
    label: 'Claude Code',
    file: join(HOME, '.claude.json'),
    looksInstalled: () => existsSync(join(HOME, '.claude.json')) || existsSync(join(HOME, '.claude')),
    write: (host, key) => viaClaudeCli(host, key),
    restart: 'Start a new session — MCP servers connect at startup.',
  },
  codex: {
    label: 'Codex',
    file: join(HOME, '.codex', 'config.toml'),
    env: true,
    looksInstalled: () => existsSync(join(HOME, '.codex')),
    write: (host) => writeToml(join(HOME, '.codex', 'config.toml'), host),
    restart: 'Restart Codex.',
  },
  cursor: {
    label: 'Cursor',
    file: join(HOME, '.cursor', 'mcp.json'),
    looksInstalled: () => existsSync(join(HOME, '.cursor')),
    write: (host, key) => writeMcpServers(join(HOME, '.cursor', 'mcp.json'), host, key, 'http'),
    restart: 'Restart Cursor.',
  },
  kimi: {
    label: 'Kimi CLI',
    file: join(HOME, '.kimi', 'mcp.json'),
    looksInstalled: () => existsSync(join(HOME, '.kimi')),
    write: (host, key) => writeMcpServers(join(HOME, '.kimi', 'mcp.json'), host, key, null),
    restart: 'Restart Kimi.',
  },
  'kimi-code': {
    label: 'Kimi Code',
    file: join(process.env['KIMI_CODE_HOME'] ?? join(HOME, '.kimi-code'), 'mcp.json'),
    looksInstalled: () =>
      existsSync(process.env['KIMI_CODE_HOME'] ?? join(HOME, '.kimi-code')),
    write: (host, key) =>
      writeMcpServers(
        join(process.env['KIMI_CODE_HOME'] ?? join(HOME, '.kimi-code'), 'mcp.json'),
        host,
        key,
        null,
      ),
    restart: 'Restart Kimi Code.',
  },
  opencode: {
    label: 'OpenCode',
    file: join(configHome(), 'opencode', 'opencode.json'),
    looksInstalled: () => existsSync(join(configHome(), 'opencode')),
    write: (host, key) => writeOpenCode(join(configHome(), 'opencode', 'opencode.json'), host, key),
    restart: 'Restart OpenCode.',
  },
};

function configHome() {
  return process.env['XDG_CONFIG_HOME'] ?? join(HOME, '.config');
}

function usage() {
  return [
    'Connect this machine to a Schematic Planner instance.',
    '',
    '  --key <key>       Your agent key, from /settings/agents.',
    '                    Falls back to $SCHEMATIC_PLANNER_KEY, then asks.',
    `  --host <url>      Default ${DEFAULT_HOST}. A self-hosted instance`,
    '                    replaces the host and nothing else.',
    `  --client <name>   ${Object.keys(CLIENTS).join(', ')}, or all.`,
    '                    Repeatable. Default: whichever are on this machine.',
    '  --print           Write nothing; show what each client needs.',
    '',
  ].join('\n');
}

function parse(argv) {
  const options = { clients: [], print: false, host: DEFAULT_HOST, key: null };
  for (let at = 0; at < argv.length; at += 1) {
    const flag = argv[at];
    const value = argv[at + 1];
    if (flag === '--print') options.print = true;
    else if (flag === '--help' || flag === '-h') options.help = true;
    else if (flag === '--host' && value !== undefined) (options.host = value), (at += 1);
    else if (flag === '--key' && value !== undefined) (options.key = value), (at += 1);
    else if (flag === '--client' && value !== undefined) options.clients.push(value), (at += 1);
    else return { error: `Unknown argument: ${flag}` };
  }
  return options;
}

async function main() {
  const options = parse(process.argv.slice(2));
  if (options.error !== undefined) {
    process.stderr.write(`${options.error}\n\n${usage()}`);
    return 2;
  }
  if (options.help === true) {
    process.stdout.write(usage());
    return 0;
  }

  const host = options.host.replace(/\/+$/, '');
  const chosen = pickClients(options.clients);
  if (chosen.length === 0) {
    process.stderr.write(
      'No agent configuration found on this machine, and none named.\n' +
        `Name one with --client: ${Object.keys(CLIENTS).join(', ')}\n`,
    );
    return 1;
  }

  const key = options.print ? '<your key>' : await resolveKey(options.key);
  if (key === null) {
    process.stderr.write(
      'No key. Get one from /settings/agents on your instance, then pass it\n' +
        'with --key or set SCHEMATIC_PLANNER_KEY.\n',
    );
    return 1;
  }

  if (options.print) {
    for (const name of chosen) {
      const client = CLIENTS[name];
      process.stdout.write(`\n${client.label} — ${client.file}\n`);
      process.stdout.write(`${snippetFor(name, host, key)}\n`);
    }
    return 0;
  }

  /*
   * Checked before anything is written. A key that is refused is the failure
   * this whole script exists to prevent, and finding out at the point of
   * writing costs nothing — whereas finding out afterwards means a session
   * that starts with the tools missing and no clue why.
   */
  const verdict = await verify(host, key);
  if (verdict !== 'ok') {
    process.stderr.write(`${verdict}\nNothing was written.\n`);
    return 1;
  }
  process.stdout.write(`The key is accepted by ${host}.\n\n`);

  const needsEnv = chosen.some((name) => CLIENTS[name].env === true);
  const envFile = needsEnv ? writeEnvFile(key) : null;

  const restarts = new Set();
  for (const name of chosen) {
    const client = CLIENTS[name];
    try {
      const where = client.write(host, key);
      process.stdout.write(`  ${client.label.padEnd(14)} ${where}\n`);
      restarts.add(client.restart);
    } catch (error) {
      process.stdout.write(`  ${client.label.padEnd(14)} not written — ${reason(error)}\n`);
      process.stdout.write(`${indent(snippetFor(name, host, key))}\n`);
    }
  }

  if (envFile !== null) {
    process.stdout.write(
      `\nCodex reads its credential from the environment rather than holding one,\n` +
        `so the key is in ${envFile} (readable only by you).\n` +
        `Add this to your shell profile:\n\n  . ${envFile}\n`,
    );
  }

  process.stdout.write('\n');
  for (const line of restarts) process.stdout.write(`${line}\n`);
  return 0;
}

function pickClients(named) {
  if (named.includes('all')) return Object.keys(CLIENTS);
  if (named.length > 0) {
    const unknown = named.filter((name) => CLIENTS[name] === undefined);
    if (unknown.length > 0) {
      process.stderr.write(`Unknown client: ${unknown.join(', ')}\n`);
      return [];
    }
    return named;
  }
  return Object.keys(CLIENTS).filter((name) => CLIENTS[name].looksInstalled());
}

async function resolveKey(given) {
  const fromFlag = given ?? process.env['SCHEMATIC_PLANNER_KEY'] ?? '';
  if (fromFlag.trim() !== '') return fromFlag.trim();
  if (!process.stdin.isTTY) return null;

  const asking = createInterface({ input: process.stdin, output: process.stdout });
  const typed = await asking.question('Agent key (from /settings/agents): ');
  asking.close();
  return typed.trim() === '' ? null : typed.trim();
}

/**
 * Whether the server will take this key, asked the way a client asks.
 *
 * An `initialize` is the first thing any MCP client sends, so a server that
 * answers it will answer the rest. Anything other than a refusal counts: the
 * question here is the credential, not the protocol version.
 */
async function verify(host, key) {
  const url = `${host}/api/mcp`;
  let response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json, text/event-stream',
        authorization: `Bearer ${key}`,
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {
          protocolVersion: '2025-06-18',
          capabilities: {},
          clientInfo: { name: 'schematic-planner-connect', version: '1' },
        },
      }),
    });
  } catch (error) {
    return `Could not reach ${url} — ${reason(error)}`;
  }

  if (response.status === 401 || response.status === 403) {
    return `${url} refused the key (HTTP ${response.status}). Check it against /settings/agents.`;
  }
  if (response.status === 404) {
    return `${url} is not a Schematic Planner MCP endpoint (HTTP 404). Check the host.`;
  }
  if (!response.ok) return `${url} answered HTTP ${response.status}.`;
  return 'ok';
}

/** Claude Code keeps servers per directory, so this is registered at user scope. */
function viaClaudeCli(host, key) {
  const run = spawnSync(
    'claude',
    [
      'mcp',
      'add',
      '--scope',
      'user',
      '--transport',
      'http',
      SERVER,
      `${host}/api/mcp`,
      '--header',
      `Authorization: Bearer ${key}`,
    ],
    { encoding: 'utf8' },
  );

  if (run.error !== undefined && run.error !== null) throw run.error;
  if (run.status !== 0) {
    throw new Error((run.stderr || run.stdout || 'claude mcp add failed').trim().split('\n')[0]);
  }
  return 'registered at user scope';
}

/** A client that reads `mcpServers`, which is most of them. */
function writeMcpServers(file, host, key, type) {
  const config = readJson(file);
  const servers = typeof config.mcpServers === 'object' && config.mcpServers !== null
    ? config.mcpServers
    : {};
  servers[SERVER] = {
    ...(type === null ? {} : { type }),
    url: `${host}/api/mcp`,
    headers: { Authorization: `Bearer ${key}` },
  };
  config.mcpServers = servers;
  return saveJson(file, config);
}

function writeOpenCode(file, host, key) {
  const config = readJson(file);
  if (config.$schema === undefined) config.$schema = 'https://opencode.ai/config.json';
  const mcp = typeof config.mcp === 'object' && config.mcp !== null ? config.mcp : {};
  mcp[SERVER] = {
    type: 'remote',
    url: `${host}/api/mcp`,
    enabled: true,
    headers: { Authorization: `Bearer ${key}` },
  };
  config.mcp = mcp;
  return saveJson(file, config);
}

/**
 * Codex, whose configuration is TOML and whose credential is an env var.
 *
 * Edited as text rather than parsed: this file is the user's, it holds settings
 * that have nothing to do with us, and a round trip through a TOML library we
 * do not ship would reformat all of it to change three lines.
 */
function writeToml(file, host) {
  const block = [
    `[mcp_servers.${SERVER}]`,
    `url = "${host}/api/mcp"`,
    'bearer_token_env_var = "SCHEMATIC_PLANNER_KEY"',
  ].join('\n');

  mkdirSync(dirname(file), { recursive: true });
  const existing = existsSync(file) ? readFileSync(file, 'utf8') : '';
  const header = `[mcp_servers.${SERVER}]`;

  if (!existing.includes(header)) {
    const spacer = existing === '' || existing.endsWith('\n\n') ? '' : existing.endsWith('\n') ? '\n' : '\n\n';
    writeFileSync(file, `${existing}${spacer}${block}\n`, { mode: 0o600 });
    return `${file} (added)`;
  }

  // Replace the table in place: from its header to the next one, or the end.
  const start = existing.indexOf(header);
  const after = existing.indexOf('\n[', start + 1);
  const tail = after === -1 ? '' : existing.slice(after + 1);
  writeFileSync(file, `${existing.slice(0, start)}${block}\n${tail === '' ? '' : `\n${tail}`}`, {
    mode: 0o600,
  });
  return `${file} (updated)`;
}

/**
 * The key, in a file of our own, for the clients that will only read one from
 * the environment. Kept out of the shell profile: appending to somebody's
 * profile is an edit they did not ask for, in a file that breaks their login
 * when it goes wrong.
 */
function writeEnvFile(key) {
  const file = join(HOME, '.schematic-planner', 'env.sh');
  mkdirSync(dirname(file), { recursive: true, mode: 0o700 });
  writeFileSync(file, `export SCHEMATIC_PLANNER_KEY=${JSON.stringify(key)}\n`, { mode: 0o600 });
  return file;
}

function readJson(file) {
  if (!existsSync(file)) return {};
  const raw = readFileSync(file, 'utf8').trim();
  if (raw === '') return {};
  try {
    const parsed = JSON.parse(raw);
    return typeof parsed === 'object' && parsed !== null ? parsed : {};
  } catch (error) {
    throw new Error(`${file} is not valid JSON (${reason(error)})`);
  }
}

function saveJson(file, config) {
  mkdirSync(dirname(file), { recursive: true });
  const fresh = !existsSync(file);
  writeFileSync(file, `${JSON.stringify(config, null, 2)}\n`);
  // Only on a file we made. Tightening the mode of one the user already keeps
  // is a change to their setup that has nothing to do with connecting.
  if (fresh) chmodSync(file, 0o600);
  return `${file} (${fresh ? 'created' : 'updated'})`;
}

function snippetFor(name, host, key) {
  if (name === 'codex') {
    return indent(
      [
        `[mcp_servers.${SERVER}]`,
        `url = "${host}/api/mcp"`,
        'bearer_token_env_var = "SCHEMATIC_PLANNER_KEY"',
        '',
        `# and in your shell:  export SCHEMATIC_PLANNER_KEY=${key}`,
      ].join('\n'),
    );
  }
  if (name === 'claude-code') {
    return indent(
      `claude mcp add --scope user --transport http ${SERVER} \\\n  ${host}/api/mcp \\\n  --header "Authorization: Bearer ${key}"`,
    );
  }
  const entry = {
    ...(name === 'cursor' ? { type: 'http' } : {}),
    url: `${host}/api/mcp`,
    headers: { Authorization: `Bearer ${key}` },
  };
  const body =
    name === 'opencode'
      ? { mcp: { [SERVER]: { type: 'remote', enabled: true, ...entry } } }
      : { mcpServers: { [SERVER]: entry } };
  return indent(JSON.stringify(body, null, 2));
}

function indent(text) {
  return text
    .split('\n')
    .map((line) => (line === '' ? '' : `    ${line}`))
    .join('\n');
}

function reason(error) {
  return error instanceof Error ? error.message : String(error);
}

process.exitCode = await main();
