# Testing

## Placement

| Location           | Use for                            |
| ------------------ | ---------------------------------- |
| `lib/*.test.ts`    | Unit tests collocated with source  |
| `tests/*.test.tsx` | Cross-cutting component/page tests |
| `e2e/*.spec.ts`    | Playwright smoke and future e2e    |

**No `*.test.tsx` under `app/`** — route shell files are thin; test pages from `tests/`.

## Commands

- `pnpm test` — Vitest watch mode
- `pnpm test:run` — single run (pre-push, `pnpm check`)
- `pnpm test:coverage` — v8 coverage + lcov (CI)
- `pnpm test:smoke` — Playwright `@smoke` subset

## Hook checks

Agent file edits run the project `afterFileEdit` hook, which formats the touched file before the end-of-turn gate runs.

## Coverage excludes

Route shells excluded from coverage denominator: `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`.

## Smoke tests

Tagged with `@smoke` in `e2e/smoke.spec.ts`. Post-deploy against staging URL in CI; locally uses `webServer` unless `PLAYWRIGHT_BASE_URL` is set.

Smoke tests are explicit opt-in checks for local and Cloud agents. They are not part of Cursor Cloud setup or the default Cloud acceptance gate; run `pnpm check` first.

`pnpm test:smoke` starts its own dev server on port 3100 through `playwright.config.ts`. Stop any running `pnpm dev` server first, because Next.js 16 allows only one dev server per project directory.

The devcontainer installs Chromium and its Linux system dependencies during `postCreateCommand`, so `pnpm test:smoke` is ready after container setup. In non-devcontainer or Cursor Cloud environments, install Chromium first:

```bash
pnpm exec playwright install --with-deps chromium
```
