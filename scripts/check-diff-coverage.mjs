#!/usr/bin/env node
/**
 * Changed-line coverage gate: intersect Vitest lcov DA lines with git diff added lines.
 */
import { execSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { lcovParser } from "@friedemannsommer/lcov-parser";

const THRESHOLD = Number(process.env.DIFF_COVERAGE_THRESHOLD ?? 80);
const BASE = process.env.DIFF_COVERAGE_BASE ?? "origin/main";
const LCOV_PATH = "coverage/lcov.info";
const SOURCE_GLOB = /^(app|lib)\/.*\.(ts|tsx)$/;

function run(command) {
  return execSync(command, { encoding: "utf8" }).trim();
}

function parseAddedLines() {
  let diff;
  try {
    diff = run(`git diff --diff-filter=d -M --unified=0 ${BASE}...HEAD`);
  } catch {
    return new Map();
  }

  if (!diff) {
    return new Map();
  }

  const addedByFile = new Map();
  let currentFile = null;

  for (const line of diff.split("\n")) {
    if (line.startsWith("+++ b/")) {
      currentFile = line.slice("+++ b/".length);
      continue;
    }

    if (!currentFile || !SOURCE_GLOB.test(currentFile)) {
      continue;
    }

    const match = line.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/);
    if (!match) {
      continue;
    }

    const start = Number(match[1]);
    const count = Number(match[2] ?? 1);
    if (!addedByFile.has(currentFile)) {
      addedByFile.set(currentFile, new Set());
    }

    const lines = addedByFile.get(currentFile);
    for (let i = 0; i < count; i += 1) {
      lines.add(start + i);
    }
  }

  return addedByFile;
}

async function loadDaLinesByFile() {
  if (!existsSync(LCOV_PATH)) {
    console.error(`Missing ${LCOV_PATH}. Run pnpm test:coverage first.`);
    process.exit(1);
  }

  const report = await lcovParser({ from: readFileSync(LCOV_PATH, "utf8") });
  const byFile = new Map();

  for (const file of report) {
    const normalized = file.path.replace(/^\.\//, "");
    const da = new Map();
    for (const line of file.lines.details) {
      da.set(line.line, line.hit > 0);
    }
    byFile.set(normalized, da);
  }

  return byFile;
}

const addedByFile = parseAddedLines();
const daByFile = await loadDaLinesByFile();

let instrumented = 0;
let covered = 0;

for (const [file, addedLines] of addedByFile) {
  const daLines = daByFile.get(file);
  if (!daLines) {
    continue;
  }

  for (const lineNumber of addedLines) {
    if (!daLines.has(lineNumber)) {
      continue;
    }
    instrumented += 1;
    if (daLines.get(lineNumber)) {
      covered += 1;
    }
  }
}

if (instrumented === 0) {
  console.log("No instrumented changed lines — diff coverage gate passes.");
  process.exit(0);
}

const pct = (covered / instrumented) * 100;
console.log(`Changed-line coverage: ${covered}/${instrumented} (${pct.toFixed(1)}%)`);

if (pct < THRESHOLD) {
  console.error(`Below threshold ${THRESHOLD}%`);
  process.exit(1);
}
