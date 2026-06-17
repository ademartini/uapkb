# Agent entry point

UAPKB is an AI-first Next.js reference repo. Read `PRINCIPLES.md` for the why; this file is the how.

## Commands

Use `package.json` scripts — do not duplicate versions here.

- **Dev:** `pnpm dev`
- **Build:** `pnpm build`
- **Full gate:** `pnpm check` (format → lint → typecheck → test)
- **Tests:** `pnpm test:run`, `pnpm test:coverage`, `pnpm test:smoke`
- **Lint/format:** `pnpm lint`, `pnpm format:check`
- **Coverage floor update:** `pnpm coverage:update` (commit the `vitest.config.ts` diff)

## Directory map

| Path                 | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `app/`               | Next.js App Router routes (no `*.test.tsx` here) |
| `lib/`               | Shared modules with collocated `*.test.ts`       |
| `tests/`             | Cross-cutting component/integration tests        |
| `e2e/`               | Playwright smoke suite (`@smoke` tag)            |
| `scripts/`           | `check.sh`, coverage gates, parity guards        |
| `.devcontainer/`     | Shared dev + CI environment                      |
| `.cursor/`           | Hooks and scoped rules                           |
| `.github/workflows/` | CI and deploy pipelines                          |
| `docs/`              | Operational documentation                        |

## Conventions

- TypeScript `strict: true`; import alias `@/*`
- Prettier owns formatting; ESLint owns quality (`eslint-config-prettier` last)
- Lint debt ratchets via `eslint-suppressions.json` — new violations fail
- Coverage ratchets via Vitest `autoUpdate` in `vitest.config.ts` — commit threshold bumps
- Structured logs via `lib/logger.ts` (Pino, JSON stdout in production)

## Safety boundaries

- **Secrets:** never commit `.env*` (except `.env.example`). fly.io secrets are per-app.
- **`.cursorignore`:** context hygiene only — terminal and MCP bypass it.
- **Supply chain:** verify packages with `pnpm view <pkg>` before adding; exact-pin versions.
- **Deploy:** merge to `main` triggers staging → smoke → production. Manual trigger: GitHub Actions `deploy` workflow (`workflow_dispatch`).
- **Rollback:** `docs/runbook-rollback.md` — redeploy prior image; config/secrets/migrations are not rolled back.

## First-run environment

Prefer `@devcontainers/cli` (`devcontainer up` / `exec`) over GUI reopen. See `docs/devcontainer.md`.

Cursor CLI: `agent login` locally; CI uses `CURSOR_API_KEY` (GitHub Environment secret).

## Cursor Cloud specific instructions

Dependencies are refreshed on startup via the update script (`pnpm install --frozen-lockfile`). The devcontainer/Docker Compose flow in the README is not used here; run commands directly. Postgres is not required — the app and `/healthz` report the database as `not_configured` (see `lib/health.ts`).

Non-obvious caveats:

- `pnpm dev` serves on port **60517** (not 3000), per `package.json`.
- Next.js 16 allows only one dev server per project dir. `pnpm test:smoke` starts its own dev server (port 3100 via `playwright.config.ts`), so it fails with "Another next dev server is already running" if `pnpm dev` is up. Stop the running dev server before running smoke tests.
- Smoke tests need a Playwright browser: `pnpm exec playwright install --with-deps chromium` (one-time; `--with-deps` needs root for system libs). Not in the update script to keep startup reliable.
