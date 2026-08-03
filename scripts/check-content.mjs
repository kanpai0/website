#!/usr/bin/env node
// scripts/check-content.mjs — CLI (thin IO shell) over scripts/lib/frontmatter.mjs.
// Called by `make check-content`. Exits 1 on any extraction, shape or
// validation error. Replaces scripts/check-fridge.sh + scripts/check-flavors.sh.
//
// Front-matter extraction is delegated to yq (mikefarah, pinned in
// .mise.toml as "aqua:mikefarah/yq") — a real YAML parser, invoked once per
// recipe via `yq -o=json --front-matter=extract`. This file owns IO and
// process invocation only; shape + semantic validation lives in
// scripts/lib/frontmatter.mjs (pure, yq-free).
//
// Cross-reference sets are extracted straight from the templates/styles
// that actually define them, never hardcoded here, so a rename shows up
// without a second edit:
//   iconSlugs   <- layouts/partials/fridge-icons.html      id="fi-<slug>"
//   panelSlugs  <- layouts/partials/fridge-panel-body.html id="fr-<slug>"
//   flavorSlugs <- layouts/index.html                      const FLAVORS = [...]
//   glassIds    <- layouts/partials/glass-icon.html        {{ eq $type "…" }}
//   colorNames  <- static/css/main.css                     body.<name> { --accent

import { execFileSync } from 'node:child_process';
import { readFileSync, readdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { assertRecipeShape, validateRecipe } from './lib/frontmatter.mjs';

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

function readText(relPath) {
  return readFileSync(path.join(REPO_ROOT, relPath), 'utf8');
}

// Fails fast with a clear remediation instead of a confusing ENOENT if the
// pinned tool isn't installed/activated in this shell.
function ensureYqAvailable() {
  try {
    execFileSync('yq', ['--version'], { stdio: 'ignore' });
  } catch {
    console.error('check-content: yq not in PATH — run: mise install');
    process.exit(1);
  }
}

/**
 * Extracts a recipe file's front-matter as JSON via yq.
 * @param {string} absPath
 * @returns {{ ok: true, data: unknown } | { ok: false, message: string }}
 */
function extractFrontmatter(absPath) {
  let stdout;
  try {
    stdout = execFileSync('yq', ['-o=json', '--front-matter=extract', '.', absPath], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    });
  } catch (e) {
    const stderr = (e.stderr ?? '').toString().trim();
    return { ok: false, message: stderr || e.message };
  }
  try {
    return { ok: true, data: JSON.parse(stdout) };
  } catch (e) {
    return { ok: false, message: `invalid JSON produced by yq: ${e.message}` };
  }
}

function extractAll(text, re) {
  return [...text.matchAll(re)].map((m) => m[1]);
}

// Best-effort line lookup for a top-level frontmatter key, used only to
// annotate validateRecipe's field-level errors with a source line — the
// parser itself already returns a line for its own (grammar) errors.
function fieldLineNumbers(content) {
  const map = {};
  const lines = content.split(/\r?\n/);
  for (let idx = 0; idx < lines.length; idx++) {
    const m = /^([a-z_][a-z0-9_]*):/.exec(lines[idx]);
    if (m && !(m[1] in map)) map[m[1]] = idx + 1;
  }
  return map;
}

function buildRefs() {
  const iconSlugs = extractAll(readText('layouts/partials/fridge-icons.html'), /id="fi-([a-z0-9-]+)"/g);
  const panelSlugs = extractAll(
    readText('layouts/partials/fridge-panel-body.html'),
    /id="fr-([a-z0-9-]+)"/g,
  );

  const indexHtml = readText('layouts/index.html');
  const flavorsLine = indexHtml.split('\n').find((l) => /const FLAVORS\s*=/.test(l)) ?? '';
  const flavorSlugs = extractAll(flavorsLine, /'([^']+)'/g);

  // Deduped: `{{- else if or (eq $type "highball") (eq $type "collins") -}}`
  // yields two matches on one line.
  const glassIds = [
    ...new Set(extractAll(readText('layouts/partials/glass-icon.html'), /eq \$type "([a-z0-9_-]+)"/g)),
  ];

  const colorNames = extractAll(readText('static/css/main.css'), /^body\.([a-z]+)\s*\{\s*--accent/gm);

  return { iconSlugs, panelSlugs, flavorSlugs, glassIds, colorNames };
}

function main() {
  ensureYqAvailable();

  const start = Date.now();
  const refs = buildRefs();
  const recipesDir = path.join(REPO_ROOT, 'content/recettes');
  const files = readdirSync(recipesDir)
    .filter((f) => f.endsWith('.md'))
    .sort();

  let hasErrors = false;

  for (const file of files) {
    const relFile = `content/recettes/${file}`;
    const absFile = path.join(recipesDir, file);

    const extracted = extractFrontmatter(absFile);
    if (!extracted.ok) {
      hasErrors = true;
      console.error(`${relFile}: ${extracted.message}`);
      continue;
    }

    const shape = assertRecipeShape(extracted.data);
    if (!shape.ok) {
      hasErrors = true;
      console.error(`${relFile}: ${shape.message}`);
      continue;
    }

    const errors = validateRecipe(shape.data, refs, file);
    if (errors.length > 0) {
      hasErrors = true;
      const content = readFileSync(absFile, 'utf8');
      const fieldLines = fieldLineNumbers(content);
      for (const { field, message } of errors) {
        const line = fieldLines[field];
        console.error(line ? `${relFile}:${line}: ${message}` : `${relFile}: ${message}`);
      }
    }
  }

  if (hasErrors) {
    process.exit(1);
  }

  const elapsed = Date.now() - start;
  console.log(`\x1b[32m✓\x1b[0m check-content \x1b[90m${elapsed}ms\x1b[0m`);
}

main();
