/**
 * Schematic Planner plugin for OpenCode.
 *
 * Registration only: it points OpenCode at the canonical skills directory and
 * says nothing about how planning works. Every behavioural rule lives in
 * skills/*\/SKILL.md, and this adapter opens no connection of its own — the
 * canvas is reached through the Schematic Planner MCP server, configured by the
 * harness, never by this file.
 */

import path from 'path';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const pluginRoot = path.resolve(here, '..', '..');

export const name = 'schematic-planner';
export const version = '0.2.0';
export const skillsDirectory = path.join(pluginRoot, 'skills');

export default {
  name,
  version,
  skillsDirectory,
};
