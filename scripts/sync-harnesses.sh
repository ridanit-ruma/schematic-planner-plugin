#!/bin/sh
set -eu

node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs'

const paths = [
  '.claude-plugin/plugin.json',
  '.codex-plugin/plugin.json',
  '.kimi-plugin/plugin.json',
]
const manifests = paths.map((path) => ({ path, value: JSON.parse(readFileSync(path, 'utf8')) }))
const expected = {
  name: 'schematic-planner',
  version: '0.1.0',
  description: 'Plan software work on a Schematic Planner canvas.',
  license: 'Apache-2.0',
}

for (const { path, value } of manifests) {
  for (const [key, expectedValue] of Object.entries(expected)) {
    if (value[key] !== expectedValue) {
      throw new Error(`${path}: expected ${key} to be ${JSON.stringify(expectedValue)}`)
    }
  }
}
NODE
