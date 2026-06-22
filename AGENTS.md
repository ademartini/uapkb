# Agent entry point

UAPKB is an AI-first Next.js reference repo. Read `PRINCIPLES.md` for the why; this file is the how.

## Commands

Use `package.json` scripts — do not duplicate versions here.

- **Dev:** `pnpm dev`
- **Build:** `pnpm build`
- **Full gate:** `pnpm check` (format → Node parity → lint → typecheck → test)
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
| `.devcontainer/`     | Shared local + CI devcontainer                   |
| `.cursor/`           | Cloud Agent environment, hooks, and scoped rules |
| `.github/workflows/` | CI and deploy pipelines                          |
| `docs/`              | Operational documentation                        |

## Conventions

- TypeScript `strict: true`; import alias `@/*`
- Prettier owns formatting; ESLint owns quality (`eslint-config-prettier` last)
- Lint debt ratchets via `eslint-suppressions.json` — new violations fail
- Coverage ratchets via Vitest `autoUpdate` in `vitest.config.ts` — commit threshold bumps
- Structured logs via `lib/logger.ts` (Pino, JSON stdout in production)

## Safety boundaries

- **Secrets:** never commit `.env*` (except `.env.example`). Cursor Secrets, GitHub Environment secrets, fly.io secrets, and local `.env.local` are separate surfaces.
- **`.cursorignore`:** context hygiene only — terminal and MCP bypass it.
- **Supply chain:** verify packages with `pnpm view <pkg>` before adding; exact-pin versions.
- **Deploy:** merge to `main` triggers staging → smoke → production. Manual trigger: GitHub Actions `deploy` workflow (`workflow_dispatch`).
- **Rollback:** `docs/runbook-rollback.md` — redeploy prior image; config/secrets/migrations are not rolled back.

## First-run environment

Prefer `@devcontainers/cli` (`devcontainer up` / `exec`) over GUI reopen for local development. See `docs/devcontainer.md`.

Cursor CLI: `agent login` locally; CI uses `CURSOR_API_KEY` (GitHub Environment secret).

## Cursor Cloud specific instructions

Cursor Cloud Agents use `.cursor/environment.json` and `.cursor/Dockerfile`, not `.devcontainer/devcontainer.json`. Dependencies are refreshed on startup via `pnpm install --frozen-lockfile` from the repo root. The devcontainer/Docker Compose flow in the README is not used here; run commands directly. Postgres is not required — the app and `/healthz` report the database as `not_configured` (see `lib/health.ts`).

Use `pnpm check` as the default Cloud acceptance gate after setup. Rebuild or start a new Cloud setup run when `.cursor/environment.json`, `.cursor/Dockerfile`, `.nvmrc`, `package.json` `packageManager`, or system packages change; dependency-only changes should be handled by the install step.

Do not commit or echo secret values in Cloud setup. Use Cursor Secrets only for Cloud-only needs, and only from trusted branches.

Non-obvious caveats:

- `pnpm dev` serves on port **60517** (not 3000), per `package.json`.
- Next.js 16 allows only one dev server per project dir. `pnpm test:smoke` starts its own dev server (port 3100 via `playwright.config.ts`), so it fails with "Another next dev server is already running" if `pnpm dev` is up. Stop the running dev server before running smoke tests.
- Smoke tests are ready in the devcontainer because `.devcontainer/post-create.sh` installs Chromium and its system dependencies. In Cursor Cloud, install browser dependencies explicitly before smoke; they are not part of Cloud startup.
