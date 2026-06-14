#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "→ Prettier (format check)"
pnpm format:check

echo "→ ESLint (--max-warnings 0)"
pnpm lint

echo "→ TypeScript (no emit)"
pnpm typecheck

echo "→ Vitest"
pnpm test:run

echo "✓ All checks passed"
