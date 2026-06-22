# UAPKB

AI-first reference repository: Next.js scaffold with enforced quality gates, explicit environment contracts, and smoke-gated fly.io deployment.

## Quick start

Canonical first-run path (most reliable):

```bash
git clone <repo-url> uapkb && cd uapkb
npx @devcontainers/cli@latest up --workspace-folder .
npx @devcontainers/cli@latest exec --workspace-folder . pnpm install --frozen-lockfile
npx @devcontainers/cli@latest exec --workspace-folder . pnpm test:run
npx @devcontainers/cli@latest exec --workspace-folder . pnpm dev
```

Open `http://localhost:60517`. Postgres is optional for current app behavior; start it separately with `docker compose up -d db` only when working on database-backed changes.

Cursor GUI "Reopen in Container" is supported as an optional convenience — see `docs/devcontainer.md`.

## Commands

| Command                | Purpose                                                      |
| ---------------------- | ------------------------------------------------------------ |
| `pnpm dev`             | Start Next.js dev server                                     |
| `pnpm build`           | Production build (standalone output)                         |
| `pnpm check`           | Full local gate (format, Node parity, lint, typecheck, test) |
| `pnpm test:smoke`      | Playwright `@smoke` suite                                    |
| `pnpm coverage:update` | Regenerate committed coverage floor                          |

See `package.json` scripts and `AGENTS.md` for the full list.

## Documentation

- `docs/local-dev.md` — Postgres, env vars, clone-to-running
- `docs/devcontainer.md` — local, CI, Cloud, and production environment contracts
- `docs/testing.md` — test placement conventions
- `docs/coverage.md` — repo ratchet + diff gate
- `docs/deployment.md` — fly.io staging/production
- `docs/runbook-rollback.md` — production rollback
- `docs/logging.md` — structured logging with Pino
- `PRINCIPLES.md` — engineering principles wired into this repo
